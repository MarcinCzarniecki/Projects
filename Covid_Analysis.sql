

SELECT *
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY location, date

--SELECT *
--FROM dbo.CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
WHERE continent is not null
ORDER BY location, date

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country.

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY location, date

--Looking at Total Cases vs Population
--Shows whtat percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY location, date
 
 --Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with highest death coount per population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Let's break things down by continent


SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date  
ORDER BY  1

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER ( PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

 
--USE CTE

With PopvsVac(continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER ( PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVaccinated
FROM PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER ( PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentRollingPeopleVaccinated
FROM #PercentPopulationVaccinated


--Create view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(NUMERIC, vac.new_vaccinations)) OVER ( PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3






