/*
Covid-19 Data Exploration
Source: https://ourworldindata.org/covid-vaccinations
https://ourworldindata.org/covid-vdeaths

Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views

*/
SELECT * 
FROM CovidProject.coviddeaths;

-- Selecting the data to start: 

SELECT location, date, population, new_cases,total_deaths
FROM CovidProject.coviddeaths
ORDER BY 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country: USA, Canda, Mexico, Italy

-- USA:
SELECT location, date, total_cases, population, (total_deaths / total_cases ) * 100  AS LikelihoodOfDyingIfInfected
FROM CovidProject.coviddeaths
WHERE location = 'United States';

-- Canada:  
SELECT location, date, total_cases, population, (total_deaths / total_cases ) * 100  AS LikelihoodOfDyingIfInfected
FROM CovidProject.coviddeaths
WHERE location = 'Canada';

-- Mexico:
SELECT location, date, total_cases, population, (total_deaths / total_cases ) * 100  AS LikelihoodOfDyingIfInfected
FROM CovidProject.coviddeaths
WHERE location = 'Mexico';

-- Italy:
SELECT location, date, total_cases, population, (total_deaths / total_cases * 100)   AS LikelihoodOfDyingIfInfected
FROM CovidProject.coviddeaths
WHERE location = 'Italy';

-- Total Cases vs Population 
-- Shows what percentage of population got infected with Covid by country:

SELECT continent, location, date, population, total_cases, (total_cases/population * 100) AS PercentOFPopWithCovid
FROM CovidProject.coviddeaths
WHERE continent IS NOT NULL 
ORDER BY continent, location;

-- Countries with highest infection rate compared to population:

/*This code groups the data by country 
and uses the MAX() function to get the location, population, 
highest infection count and percentage of the population infected for each continent. 
The results are ordered by the percentage of the population infected in descending order, 
to show the continent and location with the highest infection rate first. */

SELECT MAX(location) AS location, MAX(population) AS population, MAX(total_cases) AS highest_infection_count,
MAX(total_cases/population) * 100 AS percent_population_infected
FROM CovidProject.coviddeaths
WHERE total_cases IS NOT NULL AND continent <> location
GROUP BY location
ORDER BY percent_population_infected DESC;

-- Country with lowest infection rate compared to population: 
/*This code groups the data by country, and uses the MIN() function to get the 
location, population, lowest infection count and percentage of the population infected for each continent. 
The results are ordered by the percentage of the population infected in ascending order. */

SELECT MIN(location) AS location, MIN(population) AS population, MIN(total_cases) AS lowest_infection_count, 
MIN(total_cases/population) * 100 AS percent_population_infected
FROM CovidProject.coviddeaths
WHERE total_cases IS NOT NULL AND continent <> location
GROUP BY location
ORDER BY percent_population_infected ASC;

-- Countries with the highest death count per population:

SELECT location, population, MAX(total_deaths/population) as highest_death_count
FROM CovidProject.coviddeaths
WHERE location <> continent
GROUP BY location, population 
ORDER BY highest_death_count DESC;

-- BREAKING THINGS DOWN BY CONTINENT
-- contintents with the highest death count per population:

SELECT continent, population, MAX(total_deaths/population) as highest_death_count
FROM CovidProject.coviddeaths
WHERE continent IS NOT NULL 
GROUP BY 1,2
ORDER BY highest_death_count DESC;


-- Global numbers:

/*This query is showing the total number of cases and deaths, 
as well as the death percentage, for each continent : */

SELECT continent, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases) *100 as DeathPercentage
FROM CovidProject.coviddeaths
WHERE continent IS NOT null
GROUP BY continent
ORDER BY 1,2 ;


-- Total population vs vaccinations
-- Shows percentage of population in each location that has recieved at least 1 covid vaccine: 

SELECT DISTINCT cv.location, cv.people_vaccinated, cv.date, cd.population, (cv.people_vaccinated/cd.population *100) AS PercentOfPopulationVaccinated
FROM CovidProject.covidvaccinations AS cv
JOIN CovidProject.coviddeaths AS cd 
	ON cv.location = cd.location
    AND cv.date = cd.date
WHERE cv.people_vaccinated IS NOT NULL AND cv.people_vaccinated >= 1;

-- Shows percentage of the population in the world that recieved at least 1 covid vaccine: 

SELECT DISTINCT cv.location, cv.people_vaccinated, cv.date, cd.population, (cv.people_vaccinated/cd.population *100) AS PercentOfPopulationVaccinated
FROM CovidProject.covidvaccinations AS cv
JOIN CovidProject.coviddeaths AS cd 
	ON cv.location = cd.location
    AND cv.date = cd.date
WHERE cv.people_vaccinated IS NOT NULL AND cv.people_vaccinated >= 1
AND cv.location = 'World';


-- Shows Percentage of Population that has recieved at least 1 Covid Vaccine Using CTE (common table expression): 

WITH vaccination_data 
AS 
(
SELECT DISTINCT cv.location, cv.people_vaccinated, cv.date, cd.population, (cv.people_vaccinated/cd.population *100) AS PopPercent
FROM CovidProject.covidvaccinations AS cv
JOIN CovidProject.coviddeaths AS cd 
	ON cv.location = cd.location
    AND cv.date = cd.date
WHERE cv.people_vaccinated IS NOT NULL AND cv.people_vaccinated >= 1
)

SELECT location, people_vaccinated, date, population, (people_vaccinated/population *100) AS PopPercent
FROM vaccination_data;


-- TEMP Table 
/* Using Temp Table to perform the calucation in previous query: */

DROP TABLE IF EXISTS CovidProject.PercentPopVaccinated;
CREATE TEMPORARY TABLE CovidProject.PercentPopVaccinated
AS 
SELECT DISTINCT cv.location, cv.people_vaccinated, cv.date, cd.population, (cv.people_vaccinated/cd.population *100) AS PercentOfPopulationVaccinated
FROM CovidProject.covidvaccinations AS cv
JOIN CovidProject.coviddeaths AS cd 
	ON cv.location = cd.location
    AND cv.date = cd.date
WHERE cv.people_vaccinated IS NOT NULL AND cv.people_vaccinated >= 1;

SELECT * FROM CovidProject.PercentPopVaccinated;


-- Creating Views to store data for later visualizations:
-- view 1: 

CREATE VIEW CovidProject.PopulationPercentVaccinated AS 
SELECT DISTINCT cv.location, cv.people_vaccinated, cv.date, cd.population, (cv.people_vaccinated/cd.population *100) AS PercentOfPopulationVaccinated
FROM CovidProject.covidvaccinations AS cv
JOIN CovidProject.coviddeaths AS cd 
	ON cv.location = cd.location
    AND cv.date = cd.date
WHERE cv.people_vaccinated IS NOT NULL AND cv.people_vaccinated >= 1;

-- view 2:

CREATE VIEW CovidProject.HighestDeathCountByContinent AS 
SELECT continent, population, MAX(total_deaths/population) as highest_death_count
FROM CovidProject.coviddeaths
WHERE continent IS NOT NULL 
GROUP BY 1,2
ORDER BY highest_death_count DESC;


