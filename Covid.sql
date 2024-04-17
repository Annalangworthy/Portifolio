SELECT *
FROM coviddeaths ORDER BY 3, 4;
SELECT *
FROM covidvaccination ORDER BY 3, 4;

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
ORDER BY 1, 2;

SELECT Location,population, MAX(total_cases) as HighestInfcount, MAX((total_cases/population)*100) as InfectionPercentage
FROM coviddeaths
GROUP BY location, population
ORDER BY 1, 2;

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM coviddeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount;


    -- CTE
WITH PopVac (Continent, Location, Date, Population,New_Vaccinations, TotalPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is NOT NULL
);
SELECT *, (TotalPeopleVaccinated/Population)*100
FROM PopVac;


    -- TABLE
DROP TABLE IF EXISTS PERCENTVACCINATED
CREATE TABLE PERCENTVACCINATED (
    Continent VARCHAR (250),
    Location VARCHAR (250),
    Date DATETIME,
    Population INT,
    New_vaccinations INT,
    TotalPeopleVaccinated INT
);

INSERT INTO PERCENTVACCINATED

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (TotalPeopleVaccinated/Population)*100
FROM PERCENTVACCINATED;

    -- CREATE VIEW
CREATE VIEW PERCENTVACCINATED as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as TotalPeopleVaccinated
FROM coviddeaths dea
JOIN covidvaccination vac
    ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2, 3
