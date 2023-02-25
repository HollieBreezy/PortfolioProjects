 /*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--TOTAL DEATHS VS TOTAL CASES(SHOWS THE LIKELIHOOD OF DYING )

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM CovidDeaths
WHERE location LIKE '%Nigeria' AND continent is not null
ORDER BY 1,2

--TOTAL CASES VS POPULATION(SHOWS % OF POPULATION GOT COVID)

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%Nigeria'
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location, MAX(total_cases) AS HighestInfectionCount, population, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%Nigeria'
GROUP BY Location, population
ORDER BY PercentagePopulationInfected DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT Location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%Nigeria'
GROUP BY Location
ORDER BY HighestDeathCount DESC

SELECT Location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount, population, MAX(total_deaths/population)*100 AS PercentagePopulationDeaths
FROM CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%Nigeria'
GROUP BY Location, population
ORDER BY HighestDeathCount DESC

--CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%Nigeria'
GROUP BY continent
ORDER BY HighestDeathCount DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS totalcases, SUM(CAST(new_deaths as int)) AS totaldeaths, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--WHERE location LIKE '%Nigeria'
--GROUP BY date
ORDER BY 1,2

--JOINING BOTH TABLES

SELECT *
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date

--TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location, DEA.date) AS RollingPEopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3

--USING CTE

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--where dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3


--CREATING VIEW TO STORE DAT FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, VAC.new_vaccinations,
SUM(CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location, DEA.date) AS RollingPeopleVaccinated
FROM CovidDeaths DEA
JOIN CovidVaccinations VAC
   ON DEA.location = VAC.location
   AND DEA.date = VAC.date
WHERE DEA.continent IS NOT NULL
--where dea.continent is not null 
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
