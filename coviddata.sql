/* Covid-19 Data Exploration project
Source: https://ourworldindata.org/covid-deaths
This data set contains Covid deaths and vaccination information 

Skills used: aggregated functions, temp table, creating views for tableau
*/

select * 
from covid_data_project.owid_covid_data;

-- Percentage of the World Population with at least 1 Covid vaccine: 
select location, max(date) as date, max(people_vaccinated) as vaccinated, max(population) as population,
	max(people_vaccinated)/max(population) * 100 as Percentage_vaccinated
from covid_data_project.owid_covid_data
where location = "World"
group by location; 

-- Percentage of the World Population with Booster Vaccine:
select location, max(date) as date, max(total_boosters) as booster_vaccinated, max(population) as population,
	max(total_boosters)/max(population) * 100 as Percentage_booster_vaccinated
from covid_data_project.owid_covid_data
where location = "World"
group by location; 

-- Country with the highest Covid Cases 2023:
select iso_code, max(date) as date, max(total_cases) as covid_cases
from covid_data_project.owid_covid_data
group by iso_code
having max(total_cases) is not null;


-- Total Covid cases in United States year to date:
select iso_code, max(date) as date, max(total_cases) as covid_cases
from covid_data_project.owid_covid_data
where iso_code = "USA"
having max(total_cases) is not null;


-- ----------------------------- Tableau Views -----------------------------------------
-- View: Percentage of the World population with at least 1 Covid Vaccine: 
create view covid_data_project.world_pop_vaccine
as
select location, max(date) as date, max(people_vaccinated) as vaccinated, max(population) as population,
	max(people_vaccinated)/max(population) * 100 as Percentage_vaccinated
from covid_data_project.owid_covid_data
where location = "World"
group by location; 


-- View: Percentage of the World Population with Booster Vaccine:
create view covid_data_project.world_pop_booster
as
select location, max(date) as date, max(total_boosters) as booster_vaccinated, max(population) as population,
	max(total_boosters)/max(population) * 100 as Percentage_booster_vaccinated
from covid_data_project.owid_covid_data
where location = "World"
group by location; 

-- View: Country with the highest Covid Cases 2023:
create view covid_data_project.country_highest_case_count_23
as
select iso_code, max(date) as date, max(total_cases) as covid_cases
from covid_data_project.owid_covid_data
group by iso_code
having max(total_cases) is not null;


-- Total Covid cases in United States year to date:
create view covid_data_project.USA_case_count_23
as
select iso_code, max(date) as date, max(total_cases) as covid_cases
from covid_data_project.owid_covid_data
where iso_code = "USA"
having max(total_cases) is not null 