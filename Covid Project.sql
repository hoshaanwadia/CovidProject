-- Tables to be worked on

select *
from PortfolioProject..Covid_death
order by 3,4


select *
from PortfolioProject..Covid_vaccine
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Covid_death
order by 1, 2


-- Total Cases vs Total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..Covid_death
--where location like '%Canada%'
order by 1, 2

-- Total Cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as percentage_infected
from PortfolioProject..Covid_death
--where location like '%Canada%'
order by 1, 2


-- Countries with highest infection rate compared to population


select location, date, population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as percentage_infected
from PortfolioProject..Covid_death
--where location like '%Canada%'
group by location, population, date
order by percentage_infected desc

-- Countries with highest death counts

select location, max(cast(total_deaths as int)) as highest_deaths
from PortfolioProject..Covid_death
where continent is not null
group by location
order by highest_deaths desc

-- Continents with highest death counts

select continent, max(cast(total_deaths as int)) as highest_deaths
from PortfolioProject..Covid_death
where continent is not null
group by continent
order by highest_deaths desc

-- Daily Global Numbers

select date, sum(new_cases) as total_new_cases, sum(cast(new_deaths as int)) as total_new_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortfolioProject..Covid_death
where continent is not null
group by date
order by date

-- Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from PortfolioProject..Covid_death
where continent is not null

-- Join two tables

select *
from PortfolioProject..Covid_death dea
join PortfolioProject..Covid_vaccine vac
on dea.location = vac.location
and dea.date = vac.date
order by 3, 4

-- Total population vs new vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..Covid_death dea
join PortfolioProject..Covid_vaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Rolling vaccine count

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccine_count
from PortfolioProject..Covid_death dea
join PortfolioProject..Covid_vaccine vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
order by 2, 3

--Temp Table

drop table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccine_count numeric
)

insert into #percent_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as rolling_vaccine_count
from PortfolioProject..Covid_death dea
join PortfolioProject..Covid_vaccine vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

select *, (rolling_vaccine_count/population)*100 as vaccine_percentage
from #percent_population_vaccinated