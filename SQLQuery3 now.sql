Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Data I will be using is below

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Total cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
AND
continent is not null
order by 1,2

--Total cases vs population
Select Location, date, Population, total_cases, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2


--Looking at Countries with Highest infection rate compared to population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population
Select Location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--By continent
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- continents with highest death count per population
Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-----

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int)) 
 * 100.0 / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY date
ORDER BY date;

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, SUM(CAST(new_deaths AS int)) 
 * 100.0 / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
--GROUP BY date
ORDER BY 1,2;

--Total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT dea.continent, dea.location,  dea.date,  dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


--Total population vs Vaccinations
SELECT dea.continent, dea.location,  dea.date,  dea.population, vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


--USE CTE

With PopvsVac (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,  dea.date,  dea.population, vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location,  dea.date,  dea.population, vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location,  dea.date,  dea.population, vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3