

SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE Continent IS NOT NULL

SELECT *
FROM  [PortfolioProject].[dbo].[CovidVaccinations]
WHERE Continent IS NOT NULL

SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE Continent IS NOT NULL

  SELECT location, date, total_tests
  FROM [PortfolioProject].[dbo].[CovidVaccinations]
  WHERE Continent IS NOT NULL

--Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE location like '%united%'
  ORDER BY 1,2

--Changing data type of existing column
ALTER TABLE CovidDeaths ALTER column total_cases FLOAT

--Total cases vs the population 
--Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infectedpercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE location like '%united%'
  ORDER BY 1,2

-- Looking at countries with the Highest Infection rate compared to population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentPopinfected
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE Continent IS NOT NULL
  ORDER BY 5 DESC

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX((total_cases)/population)*100) AS percentPopinfected
FROM portfolioproject..CovidDeaths
WHERE Continent IS NOT NULL
  GROUP BY location, population
  ORDER BY percentpopinfected desc

  --Show countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
WHERE Continent IS NOT NULL
  GROUP BY location
  ORDER BY TotalDeathCount desc

-- lETS BREAK THINGS DOWN BY cONTINENT
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
WHERE Continent IS NULL
  GROUP BY location
  ORDER BY TotalDeathCount desc

  SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM portfolioproject..CovidDeaths
WHERE Continent IS NOT NULL
  GROUP BY continent
  ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as TotalCase, SUM(new_deaths) as TotalDeath,
SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as Deathpercent
FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE Continent IS NULL
  --GROUP BY date
  ORDER BY 1,2


  --Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
	--(RollingPeopleVac/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
	--(RollingPeopleVac/population)*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
) 

SELECT *, (RollingPeopleVac/population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
RollingPeopleVac float
)
INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
	--(RollingPeopleVac/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVac/population)*100
FROM #PercentPeopleVaccinated

--Create view to store data for later visualisation

CREATE VIEW PercentPeopleVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVac
	--(RollingPeopleVac/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPeopleVac



