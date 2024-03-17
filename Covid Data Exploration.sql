select *
from CovidDeaths
where continent is not NULL
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--Select Data that we are going to use
select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not NULL
order by 1,2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeaths
where location like 'India' and continent is not NULL
order by 1,2


--Lookin at Total Cases vs Population
--shows what percentage of population got Covid
select Location, date, total_cases, Population, (total_cases/population)*100 as PercentagePopulationInfected 
from CovidDeaths
where location like '%India%' and continent is not NULL
order by 1,2

--Looking at Countries with Highest Infection Rate campared to Population
select Location,Population,max(total_cases) as HighestInfection,max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
--where location like '%India%'
where continent is not NULL
group by Location, Population
order by PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population
select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%India%'
where continent is not NULL
group by Location
order by TotalDeathCount desc


--Let's break things down by continent
--Showing the continent with highest death count per population
select Continent, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
--where location like '%India%'
where continent is not NULL
group by continent
order by TotalDeathCount desc


--Global Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from CovidDeaths
--where location like 'India' and 
where continent is not NULL
--group by date
order by 1,2


--Looking at Total Population vs Vacinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100
from CovidDeaths as cd
join CovidVaccinations as cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not NULL
order by 1,2,3


--Using CTE
with PopvsVac(Continent, Loction, Date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths as cd
join CovidVaccinations as cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not NULL
--order by 1,2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths as cd
join CovidVaccinations as cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not NULL
--order by 1,2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualization
create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(float,cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from CovidDeaths as cd
join CovidVaccinations as cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not NULL
--order by 2,3

select *
from PercentPopulationVaccinated
