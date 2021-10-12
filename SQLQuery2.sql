
--select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from Covid_Project..covid_Deaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in UK

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from Covid_Project..covid_Deaths
Where location like '%United Kingdom%'
order by 1,2

--looking at toal cases vs population

select location, date, population, total_cases, (total_cases/population)*100 as Case_percentage_population
from Covid_Project..covid_Deaths
Where location like '%United Kingdom%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highest_infection_count, max((total_cases/population))*100 as percent_population_infected
from Covid_Project..covid_Deaths
--Where location like '%United Kingdom%'
group by location, population
order by percent_population_infected desc

--looking at countries with highest death count compared to population

select location, MAX(cast(total_deaths as int)) as total_death_count
from Covid_Project..covid_Deaths
--Where location like '%United Kingdom%'
where continent is not null
group by location
order by total_death_count desc

--breaking things down by continent
--showing continents with highest death count

select continent, MAX(cast(total_deaths as int)) as total_death_count
from Covid_Project..covid_Deaths
--Where location like '%United Kingdom%'
where continent is not null
group by continent
order by total_death_count desc


--global numbers


select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage--, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from Covid_Project..covid_Deaths
--Where location like '%United Kingdom%'
where continent is not null
--group by date
order by 1,2


--looking at total pop vs vac

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Covid_Project..covid_Deaths dea
join Covid_Project..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE

with pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Covid_Project..covid_Deaths dea
join Covid_Project..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (rolling_people_vaccinated/population)*100 as percentage_rolling_vaccinated from pop_vs_vac


--temp table

DROP table if exists percentpopulationvaccinated
create table percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Covid_Project..covid_Deaths dea
join Covid_Project..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

select *, (rolling_people_vaccinated/population)*100 as percentage_rolling_vaccinated from percentpopulationvaccinated


--creating view to store data for later visualisations

create view percentpopulationvaccinatedview as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from Covid_Project..covid_Deaths dea
join Covid_Project..covid_vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from percentpopulationvaccinatedview