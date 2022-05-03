
Select *
From PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercantage
From PortofolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 AS TotalCasesPercantage
From PortofolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
order by 1,2


-- Looking at countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, 
		MAX((total_cases/population))*100 AS PercentPopulationInfected
From PortofolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- Let's Break Things Down by Continent
-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBER

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
From PortofolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Total Cases

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
From PortofolioProject..CovidDeaths
where continent is not null


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidVaccinations vac
Join PortofolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- USE CTE

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidVaccinations vac
Join PortofolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
From PortofolioProject..CovidVaccinations vac
Join PortofolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
-- where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidVaccinations vac
Join PortofolioProject..CovidDeaths dea
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *
From PercentPopulationVaccinated