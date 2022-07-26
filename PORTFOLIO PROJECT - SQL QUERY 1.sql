SELECT *
FROM [Portfolia Project ]..CovidDeaths
where continent is not null
ORDER BY 3,4

SELECT *
FROM [Portfolia Project ]..CovidVaccinations
where continent is not null
ORDER BY 3,4


--SELECTING DATA THAT WE ARE GOING TO BE USING 

SELECT LOCATION,DATE,TOTAL_CASES,NEW_CASES,TOTAL_DEATHS , POPULATION 
FROM [Portfolia Project ]..CovidDeaths
where continent is not null
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
-- (SHOWS DEATH PERCENTAGE IN YOUR COUNTRY IF YOU CONTRACT COVID) 

SELECT LOCATION,DATE,TOTAL_CASES,TOTAL_DEATHS,(TOTAL_DEATHS/total_cases)*100 AS DEATH_PERCENTAGE  
FROM [Portfolia Project ]..CovidDeaths
--WHERE location = 'INDIA'
where continent is not null
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION 
--(SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID )

SELECT LOCATION,DATE,POPULATION,TOTAL_CASES,(total_cases/POPULATION)*100 AS CASES_PERCENTAGE  
FROM [Portfolia Project ]..CovidDeaths
--WHERE location = 'INDIA'
where continent is not null
ORDER BY 1,2 

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT LOCATION,POPULATION,MAX(TOTAL_CASES) AS HighestInfectionCount,MAX(total_cases/POPULATION)*100 AS PercentPopulationInfected
FROM [Portfolia Project ]..CovidDeaths
--WHERE location = 'INDIA'
where continent is not null
GROUP BY location , population
ORDER BY PercentPopulationInfected desc
 
--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 

SELECT LOCATION, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolia Project ]..CovidDeaths
--WHERE location = 'INDIA'
where continent is not null
GROUP BY location
ORDER BY  TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT 
-- SHOWING CONTTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION 

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [Portfolia Project ]..CovidDeaths
--WHERE location = 'INDIA'
where continent is NOT null
GROUP BY continent
ORDER BY  TotalDeathCount DESC

-- GLOBAL NUMBERS 
SELECT SUM(NEW_CASES) as total_cases,SUM(CAST(NEW_DEATHS as INT)) as total_deaths,SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES) *100 AS DEATHPERCENTAGE--TOTAL_CASES,TOTAL_DEATHS,(TOTAL_DEATHS/total_cases)*100 AS DEATH_PERCENTAGE  
FROM [Portfolia Project ]..CovidDeaths
--WHERE location = 'INDIA'
WHERE continent IS NOT NULL
--group by date
ORDER BY 1,2

--TOTAL POPULATION VS VACCINATIONS 
-- SHOWS PERCENTAGE OF POPULATION THAT HAS RECIEVED AT LEAST ONE COVID VACCINE 

SELECT DEA.continent,DEA.LOCATION,DEA.DATE,DEA.population,VAC.new_vaccinations,
SUM(CONVERT(INT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE)
AS RollingPeoplevaccinated
--,(RollingPeoplevaccinated/POPULATION)*100
FROM [Portfolia Project ]..CovidDeaths DEA
JOIN [Portfolia Project ]..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.DATE = VAC.date
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 1,2,3

-- USING CTE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY

WITH PopvsVac (CONTINENT,LOCATION,DATE,POPULATION,NEW_VACCINATIONS,ROLLINGPEOPLEVACCINATED)
AS
( SELECT DEA.continent,DEA.LOCATION,DEA.DATE,DEA.population,VAC.new_vaccinations,
SUM(CONVERT(INT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE)
AS RollingPeoplevaccinated
--,(RollingPeoplevaccinated/POPULATION)*100
FROM [Portfolia Project ]..CovidDeaths DEA
JOIN [Portfolia Project ]..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.DATE = VAC.date
WHERE DEA.CONTINENT IS NOT NULL
-- ORDER BY 2,3
)
 SELECT *,(RollingPeoplevaccinated/POPULATION)*100
 FROM PopvsVac


-- USING TEMP TABLE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY

DROP TABLE IF EXISTS #PERCENT_POPULATION_VACCINATED
CREATE TABLE #PERCENT_POPULATION_VACCINATED
(
CONTINENT NVARCHAR(255),
LOCATION NVARCHAR(255),
DATE DATETIME,
POPULATION INT,
NEW_VACCINATIONS INT,
RollingPeoplevaccinated INT,
)

INSERT INTO #PERCENT_POPULATION_VACCINATED
SELECT DEA.continent,DEA.LOCATION,DEA.DATE,DEA.population,VAC.new_vaccinations,
SUM(CONVERT(INT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE)
AS RollingPeoplevaccinated
--,(RollingPeoplevaccinated/POPULATION)*100
FROM [Portfolia Project ]..CovidDeaths DEA
JOIN [Portfolia Project ]..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.DATE = VAC.date
WHERE DEA.CONTINENT IS NOT NULL
-- ORDER BY 2,3

 SELECT *,(RollingPeoplevaccinated/POPULATION)*100
 FROM #PERCENT_POPULATION_VACCINATED


 --CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS 

 CREATE VIEW PERCENT_POPULATION_VACCINATED AS 
 SELECT DEA.continent,DEA.LOCATION,DEA.DATE,DEA.population,VAC.new_vaccinations,
SUM(CONVERT(INT,VAC.NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE)
AS RollingPeoplevaccinated
--,(RollingPeoplevaccinated/POPULATION)*100
FROM [Portfolia Project ]..CovidDeaths DEA
JOIN [Portfolia Project ]..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.DATE = VAC.date
WHERE DEA.CONTINENT IS NOT NULL
-- ORDER BY 2,3














