select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from PortfolioProject..['Covid Vaccination$']
--order by 3,4

select location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at the Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%' 
order by 1,2

--looking at Total Cases vs Population
--shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where location like '%states%' 
order by 1,2


--looking at countries with Highest Infesction Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count Population

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

--Breaking down by continent 

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing continents with the highest death count per population

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%' 
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert (int, vac.new_vaccinations)) over (partition by dea.location)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..['Covid Vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--or this 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast (vac.new_vaccinations as int)) over (partition by dea.location)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..['Covid Vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..['Covid Vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac




--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..['Covid Vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualization

-- Used "use portfolioProject" and executed the query before creating the view


use PortfolioProject;
Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..['Covid Vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated