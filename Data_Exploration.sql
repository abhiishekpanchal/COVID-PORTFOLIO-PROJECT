--GETTING ALL THE DATA 
SELECT * FROM PortFolioProject..CovidDeaths 
WHERE continent is not null
order by 3,4
	
SELECT * FROM PortFolioProject..CovidVaccinations
WHERE continent is not null
order by 3,4

--SELECTING DATA THAT WE ARE GOING TO USE
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--TOTAL CASES vs TOTAL DEATHS
SELECT location,date,total_cases,total_deaths,(cast(total_deaths as int)/total_cases)*100 AS death_percentage
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--TOTAL CASES vs POPULATION
SELECT location,date,total_cases,population,(total_cases/population)*100 AS infected_people
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO COUNTRIES
SELECT location,population,max(total_cases) as highest_infection_count,max((total_cases/population)*100) as highest_percentage_affect_people
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY highest_percentage_affect_people DESC

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location,max(cast(total_deaths as int)) as DeathCount
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount DESC

----BREAKING DOWN THINGS WRT CONTINENT
SELECT continent,max(cast(total_deaths as int)) as DeathCount
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY DeathCount DESC

--GLOBAL NUMBERS
SELECT date,SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortFolioProject..CovidDeaths
WHERE continent is not null
--AND total_cases <> 0
GROUP BY date
ORDER BY 1,2

--TOTAL POPULATION  vs TOTAL VACCINATED
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM
PortFolioProject..CovidDeaths dea
JOIN
PortFolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USING CTE IN ABOVE QUERY
WITH PopVsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM
PortFolioProject..CovidDeaths dea
JOIN
PortFolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *
--,ROUND((RollingPeopleVaccinated/population)*100,2) AS Percentage_of_people_vaccinated
FROM PopVsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM
PortFolioProject..CovidDeaths dea
JOIN
PortFolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(Rolling_people_vaccinated/Population)*100 AS Percent_People_vaccinated
FROM #PercentPopulationVaccinated

--CREATING VIEW FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
FROM
PortFolioProject..CovidDeaths dea
JOIN
PortFolioProject..CovidVaccinations vac
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated