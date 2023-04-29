/*
Covid-19 Data Exploration
Source: https://ourworldindata.org/covid-vaccinations
https://ourworldindata.org/covid-vdeaths

Skills used: Joins, CTE's, Temp Tables, Aggregate Functions, Creating Views

*/

-- looking at Data: 
select *
from covidproject.coviddeaths;

select *
from covidproject.covidvaccinations;

-- looking at how many people received at least 1 Covid vaccine by Country: 
-- iso_code contains Country codes in the ISO 3166-1 alpha-3 format 
select cv.iso_code, max(cv.date) as date, sum(cv.people_vaccinated) as people_vaccinated , max(cd.population) as population, 
max(cv.people_vaccinated/cd.population) * 100 AS percent_of_pop_vaccinated
from covidproject.covidvaccinations as cv
join covidproject.coviddeaths as cd
	on cv.iso_code = cd.iso_code
    and cv.date = cd.date
where people_vaccinated is not null and people_vaccinated >=1 
group by iso_code
order by 2 ASC;

-- looking at same query for the World: 
select cv.location, max(cv.date) as date, sum(cv.people_vaccinated) as people_vaccinated , max(cd.population) as population, 
max(cv.people_vaccinated/cd.population) * 100 AS percent_of_pop_vaccinated
from covidproject.covidvaccinations as cv
join covidproject.coviddeaths as cd
	on cv.location = cd.location
    and cv.date = cd.date
-- where people_vaccinated is not null and people_vaccinated >=1 
where cv.location = 'World' ;

-- looking at same query : each Continent that has received 1 Covid vaccine: 
select cv.continent, max(cv.date) as date, sum(cv.people_vaccinated) as people_vaccinated , max(cd.population) as population, 
max(cv.people_vaccinated/cd.population) * 100 AS percent_of_pop_vaccinated
from covidproject.covidvaccinations as cv
join covidproject.coviddeaths as cd
	on cv.continent = cd.continent
    and cv.date = cd.date
where people_vaccinated is not null and people_vaccinated >=1 
group by continent 
order by 2 ASC;

-- looking at the Countries with the highest rate of Covid infections normalized by population size: 
select cv. iso_code, max(cv.date) as date, max(cv.positive_rate) as positive_rate, max(cd.population) as population
from covidproject.covidvaccinations as cv
join covidproject.coviddeaths as cd
	on cv.iso_code = cd.iso_code
    and cv.date = cd.date 
where positive_rate is not null
group by iso_code
order by 3 DESC;


-- looking at Countries with highest Covid fatalities normalized by population size 
select iso_code, max(total_deaths) as fatalities_count, max(population) as population
from covidproject.coviddeaths
where total_deaths is not null
group by iso_code
order by 2 desc;

-- same query by Continent normalized by population size: 
select continent, max(total_deaths) as fatalities_count, max(population) as population  
from covidproject.coviddeaths
where total_deaths is not null and continent is not null 
group by continent
order by 2 desc;


-- same query using CTE (common table expression): 
/*created a CTE named "cte_continent_stats" that contains the aggregated statistics for each continent. 
We then can reference this CTE in the SELECT statement to retrieve the output. 
The result set is ordered by the fatalities count in descending order. */

WITH cte_continent_stats AS (
  SELECT continent, max(total_deaths) as fatalities_count, max(population) as population  
  FROM covidproject.coviddeaths
  WHERE total_deaths IS NOT NULL AND continent IS NOT NULL 
  GROUP BY continent
)
SELECT * FROM cte_continent_stats
ORDER BY fatalities_count DESC;

-- same query using temp table: 

CREATE TEMPORARY TABLE temp_continent_stats AS (
  SELECT continent, max(total_deaths) as fatalities_count, max(population) as population  
  FROM covidproject.coviddeaths
  WHERE total_deaths IS NOT NULL AND continent IS NOT NULL 
  GROUP BY continent
);

SELECT * FROM temp_continent_stats
ORDER BY fatalities_count DESC;

-- Views for Tableau
 -- V#1 :  number of people who have receieved at least one vaccine per Continent: 
create view covidproject.at_least_one_vaccine_by_continent
as
select cv.continent, max(cv.date) as date, sum(cv.people_vaccinated) as people_vaccinated , max(cd.population) as population, 
max(cv.people_vaccinated/cd.population) * 100 AS percent_of_pop_vaccinated
from covidproject.covidvaccinations as cv
join covidproject.coviddeaths as cd
	on cv.continent = cd.continent
    and cv.date = cd.date
where people_vaccinated is not null and people_vaccinated >=1 
group by continent 
order by 2 ASC;


-- v2: -- World population that has received at least 1 Covid vaccine:

create view covidproject.at_least_one_vaccine_world
as
select cv.location, max(cv.date) as date, sum(cv.people_vaccinated) as people_vaccinated , max(cd.population) as population, 
max(cv.people_vaccinated/cd.population) * 100 AS percent_of_pop_vaccinated
from covidproject.covidvaccinations as cv
join covidproject.coviddeaths as cd
	on cv.location = cd.location
    and cv.date = cd.date
-- where people_vaccinated is not null and people_vaccinated >=1 
where cv.location = 'World' ;


-- V#3:looking at the countries with the highest rate of Covid infections normalized by population size: 
create view covidproject.high_infection_rate_by_countries
as
select cv. iso_code, max(cv.date) as date, max(cv.positive_rate) as positive_rate, max(cd.population) as population
from covidproject.covidvaccinations as cv
join covidproject.coviddeaths as cd
	on cv.iso_code = cd.iso_code
    and cv.date = cd.date 
where positive_rate is not null
group by iso_code
order by 4 DESC;


-- v4: looking at Countries with highest Covid fatalities normalized by population size:
create view covidproject.fatality_count_by_country
as
select iso_code, max(total_deaths) as fatalities_count, max(population) as population
from covidproject.coviddeaths
where total_deaths is not null
group by iso_code
order by 2 desc;

-- v5: -- highest Covid fatalities per Continent normalized by population size:
create view covidproject.fatality_count_by_continent 
as
select continent, max(total_deaths) as fatalities_count, max(population) as population  
from covidproject.coviddeaths
where total_deaths is not null and continent is not null 
group by continent
order by 2 desc;





