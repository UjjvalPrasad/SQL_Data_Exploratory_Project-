select * from coviddeaths;

select * from covidvaccinations;

-- Total Cases vs Total Deaths
with deathvscases as
(
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 casesvsdeath
from coviddeaths
order by 1,2
)
select *
from deathvscases;

-- Percentage of Deaths wrt Number of cases
select location, sum(total_cases), sum(total_deaths), sum(total_deaths)/sum(total_cases) * 100 as death_percentage
from coviddeaths
group by location
order by location, death_percentage;

-- Total Cases vs Population
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From coviddeaths
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population
Select Location, round(MAX(ceil(Total_deaths)),2) as TotalDeathCount
From coviddeaths
Where continent is not null and continent != ''
Group by Location
order by TotalDeathCount desc;

-- Showing contintents with the highest death count per population
Select continent, round(MAX(ceil(Total_deaths)),2) as TotalDeathCount
From CovidDeaths
Where continent is not null or continent != ''
Group by continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
select sum(new_cases) total_cases, sum(new_deaths) total_deaths, sum(new_deaths)/sum(new_cases) * 100 as world_death_percentage
from coviddeaths
where continent is not null or continent != ''
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.continent is not null and vac.continent != '' and dea.continent != ''
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null;