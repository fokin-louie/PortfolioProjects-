select *
from CovidVaccinations
order by 3,4

select *
from CovidDeaths
order by 3,4


select continent, location, date, total_cases, total_deaths, population
from CovidDeaths
order by continent, location, date

--looking at total cases vs total deaths. shows likelihood of dying if you contract covid in Ghana

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where total_cases != 0 and location = 'Ghana'
order by location, date

--Looking at total cases vs population

select continent, location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentageWithCovid
from CovidDeaths
where total_cases != 0 and location = 'Ghana'
order by continent,location, date

--looking at countries with highest infection rate compared to population
select continent,location, population, MAX(total_cases) AS HighestInfectionCount, Max(total_cases/population)*100 as PopulationPercentageWithCovid
from CovidDeaths
where total_cases != 0
Group by continent, location, population 
order by PopulationPercentageWithCovid desc

--LOOKING AT COUNTRIES WITH HIGHEST DEATHCOUNT PER POPULATION
select CONTINENT, location, population, MAX(total_deaths) AS TotalDeathCount, Max(total_deaths/population)*100 as DeathCountPerPopulation
from CovidDeaths
where total_cases != 0 and continent is not null
Group by CONTINENT, location, population 
order by TotalDeathCount desc

--LOOKING AT CONTINENTS WITH HIGHEST DEATHCOUNT PER POPULATION

select continent, MAx(total_deaths) AS TotalDeathCount
from CovidDeaths
where total_cases != 0 and continent is not null
Group by continent 
order by TotalDeathCount DESC


-- GLOBAL NUMBERS
Select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths
,(sum(new_deaths)/sum(new_cases)) *100 as DeathPercentage
from CovidDeaths
where continent is not null 
and new_cases !=0
group by  date 
order by 1,2

--Looking at Total Population vs Vaccination
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as TotalPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null 
order by 2,3


-- USE CTE
WITH PopvsVac (Continent, location, date, Population, new_vaccinations, TotalPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as TotalPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null 
--order by 2,3
)
Select Continent, location, max (Population) as TotalPopulation, max(new_vaccinations) as NewVaccinations , Max (TotalPeopleVaccinated) as TotalVaccinated,(max(TotalPeopleVaccinated)/max(Population))*100 as PercentageVaccinated
from PopvsVac
group by Continent, location
order by Continent, location


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as TotalPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null 
order by 2,3

Select Continent, location, max (Population) as TotalPopulation, max(new_vaccinations) as NewVaccinations , Max (TotalPeopleVaccinated) as TotalVaccinated,(max(TotalPeopleVaccinated)/max(Population))*100 as PercentageVaccinated
from #PercentPopulationVaccinated
group by Continent, location
order by Continent, location

--creating view to store data for later visualization
create view percentpolationwithcovid as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as TotalPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null 
--order by 2,3

select *
from percentpolationwithcovid