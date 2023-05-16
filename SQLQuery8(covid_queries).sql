USE Portfolio_Project;
--SELECT *
--FROM Portfolio_Project.dbo.covid_deaths_final
--ORDER BY 3,4;

--SELECT *
--FROM Portfolio_Project.dbo.covid_vacs_final
--ORDER BY 3,4;

/*
SELECT data that we will be using
*/

SELECT 
	death.location,
	death.date,
	death.population,
	death.total_cases,
	death.new_cases,
	death.total_deaths
FROM Portfolio_Project.dbo.covid_deaths_final AS death
ORDER BY 1,2;

/*
Total cases vs Total deaths
Finding the probability death if a person becomes infected with COVID-19
*/

SELECT 
	death.location,
	death.date,
	death.total_cases,
	death.total_deaths,
	(death.total_deaths/death.total_cases)*100 AS death_percent
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE death.total_cases <> 0
	AND UPPER(location) LIKE ('%STATES%')
ORDER BY 1,2;

/*
Total cases vs Total deaths
Finding the probability of a person becoming infected with COVID-19 based on population
*/
SELECT 
	death.location,
	death.date,
	death.population,
	death.total_cases,
	(death.total_cases/death.population)*100 AS infection_percent
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE death.total_cases <> 0
	AND UPPER(location) LIKE ('%STATES%')
	AND LOWER(death.continent) IS NOT NULL
ORDER BY 1,2;

/*
Deaths via Location
Showing countries highest death count for each location
*/

SELECT 
	death.location,
	MAX(death.total_deaths) AS total_death_count
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE UPPER(death.location) NOT LIKE('%INCOME%')
	AND LOWER(death.continent) IS NOT NULL
GROUP BY death.location
ORDER BY total_death_count DESC;

-- Max deaths by continent
SELECT 
	death.continent,
	MAX(death.total_deaths) AS total_death_count
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE UPPER(death.location) NOT LIKE('%INCOME%')
	AND LOWER(death.continent) IS NOT NULL
GROUP BY death.continent
ORDER BY total_death_count DESC;

--This may be more accurate
SELECT 
	death.location,
	MAX(death.total_deaths) AS total_death_count
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE UPPER(death.location) NOT LIKE('%INCOME%')
	AND LOWER(death.continent) IS NULL
GROUP BY death.location
ORDER BY total_death_count DESC;


/*
Global Numbers
*/

-- Total covid cases and deaths across the world
SELECT 
	death.date,
	SUM(death.new_cases) AS global_total_cases,
	SUM(death.new_deaths) AS global_total_deaths
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE UPPER(death.location) NOT LIKE('%INCOME%')
	AND LOWER(death.continent) IS NOT NULL
GROUP BY death.date
ORDER BY 1;


SELECT 
	death.date,
	SUM(death.new_cases) AS global_total_cases,
	SUM(death.new_deaths) AS global_total_deaths,
	(SUM(death.new_deaths) /SUM(death.new_cases) )*100 AS global_total_death_percentage
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE UPPER(death.location) NOT LIKE('%INCOME%')
	AND LOWER(death.continent) IS NOT NULL
GROUP BY death.date
ORDER BY 1;

--SUM of New vaccinations by location and date
-- USE CTE
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vacs.new_vaccinations,
	SUM(vacs.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vacs_per_location
FROM Portfolio_Project.dbo.covid_vacs_final AS vacs
JOIN Portfolio_Project.dbo.covid_deaths_final AS dea
	ON dea.location = vacs.location
	AND dea.date = vacs.date
WHERE UPPER(dea.continent) IS NOT NULL
	AND vacs.new_vaccinations IS NOT NULL
ORDER BY 2,3;

WITH pops_vs_vacs
AS 
(
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vacs.new_vaccinations,
	SUM(vacs.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vacs_per_location
FROM Portfolio_Project.dbo.covid_vacs_final AS vacs
JOIN Portfolio_Project.dbo.covid_deaths_final AS dea
	ON dea.location = vacs.location
	AND dea.date = vacs.date
WHERE UPPER(dea.continent) IS NOT NULL
	AND vacs.new_vaccinations IS NOT NULL
)

SELECT *,(rolling_vacs_per_location/population)*100 AS rolling_vacs_percent
FROM pops_vs_vacs;

--Temp Table

DROP TABLE IF EXISTS tempdb.dbo.#PercentPopulationVaccinated ;
CREATE TABLE tempdb.dbo.#PercentPopulationVaccinated(
    continent VARCHAR(150),
	location VARCHAR(150),
	date DATE,
	population INT,
	new_vaccinations FLOAT,
	rolling_vacs_per_location FLOAT
)
INSERT INTO tempdb.dbo.#PercentPopulationVaccinated
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vacs.new_vaccinations,
	SUM(vacs.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.date) AS rolling_vacs_per_location
FROM Portfolio_Project.dbo.covid_vacs_final AS vacs
JOIN Portfolio_Project.dbo.covid_deaths_final AS dea
	ON dea.location = vacs.location
	AND dea.date = vacs.date
WHERE UPPER(dea.continent) IS NOT NULL
	AND vacs.new_vaccinations IS NOT NULL;


SELECT *
FROM tempdb.dbo.#PercentPopulationVaccinated;


-- CREATE VIEW to store later for vizualizations
USE Portfolio_Project;


DROP VIEW IF EXISTS PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vacs.new_vaccinations,
	SUM(vacs.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_vacs_per_location
FROM Portfolio_Project.dbo.covid_vacs_final AS vacs
JOIN Portfolio_Project.dbo.covid_deaths_final AS dea
	ON dea.location = vacs.location
	AND dea.date = vacs.date
WHERE UPPER(dea.continent) IS NOT NULL
	AND vacs.new_vaccinations IS NOT NULL;


DROP VIEW IF EXISTS US_CovidDeathPercent;
CREATE VIEW US_CovidDeathPercent AS
SELECT 
	death.location,
	death.date,
	death.total_cases,
	death.total_deaths,
	(death.total_deaths/death.total_cases)*100  AS death_percent
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE death.total_cases <> 0
	AND UPPER(location) LIKE ('%STATES%');

DROP VIEW IF EXISTS CovidDeathByLocation;
CREATE VIEW CovidDeathByLocation AS
SELECT 
	death.location,
	MAX(death.total_deaths) AS total_death_count
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE UPPER(death.location) NOT LIKE('%INCOME%')
	AND LOWER(death.continent) IS NOT NULL
GROUP BY death.location;

SELECT *
FROM Portfolio_Project.dbo.CovidDeathByLocation;


DROP VIEW IF EXISTS global_total_death_percentage;
CREATE VIEW global_total_death_percentage AS
SELECT 
	death.date,
	SUM(death.new_cases) AS global_total_cases,
	SUM(death.new_deaths) AS global_total_deaths,
	(SUM(death.new_deaths) /SUM(death.new_cases) )*100 AS global_total_death_percentage
FROM Portfolio_Project.dbo.covid_deaths_final AS death
WHERE UPPER(death.location) NOT LIKE('%INCOME%')
	AND LOWER(death.continent) IS NOT NULL
GROUP BY death.date;

SELECT *
FROM global_total_death_percentage;