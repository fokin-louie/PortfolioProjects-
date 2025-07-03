-- Covid Deaths table
select *
from CovidDeaths

--Covid Vaccinations Table
select *
from CovidVaccinations


--looking at total cases vs total deaths. shows likelihood of dying if you contract covid in Ghana
select CONTINENT,location, date, total_cases , total_deaths, cast ((total_deaths/total_cases) AS DECIMAL (20,10)) * 100 as RiskofDeathPercentage 
from CovidDeaths
where location = 'ghana' and total_cases != 0
order by date

--Looking at total cases vs population
select continent,location, date, total_cases ,population, CAST((total_cases/population) AS DECIMAL (20,10)) * 100 as PopulationPercentagewithCovid
from CovidDeaths
where total_cases != 0 AND continent IS NOT NULL
ORDER BY 1,2 

--looking at countries with highest total number of infections
select continent,location, population, MAX(total_cases) as HighestInfectionCount
from CovidDeaths
where total_cases != 0 AND continent IS NOT NULL
group by continent,location, population
ORDER BY HighestInfectionCount desc

-- DEATH STATISTICS PER CONTINENT
select continent, max(total_cases) as TotalCases, max(total_deaths) as Totaldeaths, (max(total_deaths)/max(total_cases)) as TotalDeathPercentage
from CovidDeaths
where continent is not null
GROUP BY continent

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE PER POPULATION
select continent,location, population,max(total_cases/population) * 100 as PopulationPercentagewithCovid
from CovidDeaths
where total_cases != 0 AND continent IS NOT NULL
group by continent,location, population
ORDER BY PopulationPercentagewithCovid desc


--LOOKING AT CONTINENTS WITH HIGHEST DEATHCOUNT PER POPULATION
select CONTINENT, max(total_deaths) as Totaldeaths, (max(total_deaths/population)) as DeathCountPerPopulation
from CovidDeaths
where total_cases !=0 and continent is not null
GROUP BY continent
order by DeathCountPerPopulation desc


-- Continental NUMBERS on total cases and total deaths
select continent, max(total_cases) as TotalCases, max(total_deaths) as Totaldeaths
from CovidDeaths
where continent is not null
GROUP BY continent


--Looking at Total Population vs Vaccination
select cd.continent, cd.location, max(cd.population) as TotalPopulation, max(cv.people_fully_vaccinated) as TotalVaccinations,
(max(cv.people_fully_vaccinated)/max(cd.population))*100 as VaccinatedPercentage
from CovidDeaths cd
join CovidVaccinations cv on cd.continent = cv.continent and cd.location = cv.location and cd.date = cv.date
group by cd.continent, cd.location
order by VaccinatedPercentage desc

--Tracking cumulative vaccine doses administered over time per country
select cd.continent, cd.location,cd.date,cd.population, cv.new_vaccinations
,sum(convert(bigint, new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as TotalPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv on cd.continent = cv.continent and cd.location = cv.location and cd.date = cv.date
where new_vaccinations is not null
order by 2,3

--Top 10 Countries by Death Rate
select Top 10 location, (max(total_deaths)/max(total_cases))*100 as DeathRate
from CovidDeaths
where total_cases !=0 and continent is not null
group by location
order by DeathRate desc

--Countries with the Fastest Vaccination Rollout (reached 50% full vaccination first)
select cv.location, min(case when people_fully_vaccinated / cd.population >= 0.5 then cv.date end) as DateReached50Percent, max(cd.population) as Population, 
 max(people_fully_vaccinated) as TotalFullyVaccinated,
       (max(people_fully_vaccinated) / max(cd.population)) * 100 as FinalVaccinatedPercent
from CovidVaccinations cv
join CovidDeaths cd on cd.continent = cv.continent and cd.location = cv.location and cd.date = cv.date
where people_fully_vaccinated is not null
group by cv.location
having (max(people_fully_vaccinated) / max(cd.population)) >= 0.5
   and min(case when people_fully_vaccinated / cd.population >= 0.5 then cv.date end) is not null
order by DateReached50Percent


--Compare Vaccination and Death Rates
--Is there a relationship between high vaccination rates and low death rates?
select cd.continent,cd.location,max(cd.population) as TotalPopulation, max(cv.people_fully_vaccinated) as PeopleFullyVaccinated, 
max(cd.total_cases) as TotalCases, max(cd.total_deaths) as TotalDeaths,
(max(cv.people_fully_vaccinated)/max(cd.population))*100 as VaccinationRate, (max(cd.total_deaths)/max(cd.total_cases))*100 as DeathRate
from CovidVaccinations cv
join CovidDeaths cd on cd.continent = cv.continent and cd.location = cv.location and cd.date = cv.date
where (cv.people_fully_vaccinated) is not null and (cd.total_deaths) is not null and cd.total_cases is not null
group by cd.location,cd.continent
having max(cv.people_fully_vaccinated) > 0
and max(cd.total_deaths) > 0
order by VaccinationRate desc


--Vaccination Progress by Continent
--Total doses administered per continent over time.
SELECT cd.continent,cd.date,SUM(CAST(cv.new_vaccinations AS BIGINT)) AS TotalVaccinations
FROM CovidVaccinations cv
JOIN CovidDeaths cd 
  ON cv.location = cd.location AND cv.date = cd.date
WHERE cd.continent IS NOT NULL 
  AND cv.new_vaccinations IS NOT NULL
GROUP BY cd.continent, cd.date
ORDER BY cd.continent, cd.date

-- Peak Infection Dates per Country
--Show the date each country recorded its highest daily total cases.
SELECT location, date, new_cases
FROM (
    SELECT 
        location,
        date,
        new_cases,
        RANK() OVER (PARTITION BY location ORDER BY new_cases DESC) AS rank_per_country
    FROM CovidDeaths
    WHERE new_cases != 0 AND continent IS NOT NULL
) AS ranked_data
WHERE rank_per_country = 1
ORDER BY new_cases DESC


-- USE CTE to find  Continent, location,TotalPopulation, NewVaccinations ,TotalVaccinated, PercentageVaccinated
With PopVsVac (continent,location,TotalPopulation,NewVaccinations, TotalVaccinations, PercentageVaccinated)
as 
(
select cd.continent, cd.location, max(cd.population) as TotalPopulation,max(cv.new_vaccinations) as NewVaccinations, max(cv.people_fully_vaccinated) as TotalVaccinations,
(max(cv.people_fully_vaccinated)/max(cd.population))*100 as PercentageVaccinated
from CovidDeaths cd
join CovidVaccinations cv on cd.continent = cv.continent and cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 
group by cd.continent, cd.location
)
Select Continent, location, TotalPopulation, NewVaccinations, TotalVaccinations, PercentageVaccinated
from PopvsVac
group by Continent, location, TotalPopulation, NewVaccinations, TotalVaccinations, PercentageVaccinated
order by Continent, location

-- Temp Table to find  Continent, location,TotalPopulation, NewVaccinations ,TotalVaccinated, PercentageVaccinated

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
create view PopulationPercentageWithCovid as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
,sum(convert(bigint, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as TotalPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null and new_vaccinations is not null

select *
from PopulationPercentageWithCovid