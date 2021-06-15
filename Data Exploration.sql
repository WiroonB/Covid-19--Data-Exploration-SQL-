USE Portfolio_Project

SELECT * 
FROM Covid_Deaths
WHERE continent is NOT NULL
ORDER BY 3,4;

-- Select Data that will be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid_Deaths
ORDER BY 1,2; 

---------------------------------------------------------------------------------------------------

--Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_Deaths
WHERE location like '%state%'
ORDER BY 1,2;

---------------------------------------------------------------------------------------------------


--Total Cases vs Population
--Shows what percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM Covid_Deaths
WHERE location like '%state%'
ORDER BY 1,2;


---------------------------------------------------------------------------------------------------


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_deaths/population))*100 AS PercentagePopulationInfection
FROM Covid_Deaths
GROUP BY location, population
ORDER BY PercentagePopulationInfection desc;


---------------------------------------------------------------------------------------------------


-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc;

---------------------------------------------------------------------------------------------------


-- By Continent
-- Continents with the Highest Death Count per Population

SELECT continent, MAX(CAST(total_deaths as INT)) AS TotalDeathCount
FROM Covid_Deaths
WHERE continent IS  NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc;


---------------------------------------------------------------------------------------------------


--GLobal Numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


---------------------------------------------------------------------------------------------------

--Total Population vs Vaccinations
--Shows percentage of population that has received at least one dose of covid vaccicne

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

---------------------------------------------------------------------------------------------------


--Using CTE to perform calculation on PARTITION BY in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
--use this can perform further calculation

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPeopleVaccinatedPercentage
FROM PopvsVac;

---------------------------------------------------------------------------------------------------

--Using Temp Table to perform calculation on PARTITION BY in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
Continent NVARCHAR(255),
Location NVARCHAR(225),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
);

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


---------------------------------------------------------------------------------------------------


--Creating View to Store data for later Visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(cast(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
	AS RollingPeopleVaccinated
FROM Covid_Deaths dea
JOIN Covid_Vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT * 
FROM PercentPopulationVaccinated;

