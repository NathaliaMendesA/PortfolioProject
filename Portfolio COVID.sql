SELECT *
From Portfolio..CovidDeaths
ORDER BY 3, 4;

--SELECT *
--From Portfolio..CovidVaccination
--Order by 3, 4;

-- Select the date that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
From Portfolio..CovidDeaths
ORDER BY 1, 2;


-- Looking at Total Cases vs Total Deaths in Brazil

SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like 'Brazil'
ORDER BY 1, 2;


-- Looking at Total Cases vs Population in Brazil

SELECT location, date, Population, total_cases, (Total_cases/population)*100 as CasesPercentage
From Portfolio..CovidDeaths
Where location like 'Brazil' 
ORDER BY 1, 2;

-- Looking at Countries with Highest Infection Rates compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX(Total_cases/population)*100 
as PercentPopulationInfected
From Portfolio..CovidDeaths
Group by location, Population
ORDER BY PercentPopulationInfected DESC;

-- Showing Countries with Highest Death count per Population

SELECT location, MAX(Cast(total_deaths as int)) as TotalDeathCount 
From Portfolio..CovidDeaths
Where continent is not null
Group by location
ORDER BY TotalDeathCount DESC;

-- Breaking Down by Continente

SELECT continent, MAX(Cast(total_deaths as int)) as TotalDeathCount 
From Portfolio..CovidDeaths
Where continent is not null
Group by Continent
ORDER BY TotalDeathCount DESC;




-- Showing continents with the highest death count per population

SELECT continent, MAX(Cast(total_deaths as int)) as TotalDeathCount 
From Portfolio..CovidDeaths
Where continent is not null
Group by continent
ORDER BY TotalDeathCount DESC;

-- Global Number

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_Deaths as int))/SUM(new_cases)*100
as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null
group by date
order by 1, 2;

-- Total Numbers Global 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_Deaths as int))/SUM(new_cases)*100
as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null
order by 1, 2;

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast( vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location is not null
order by 2, 3;


-- USE CTE
With PopVSvac (Continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
As (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast( vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.location is not null
--order by 2, 3;
)
Select *, (rollingpeoplevaccinated/population)*100 as PercentVaccinated
FROM Popvsvac;

--TEMP Table
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast( vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
                         
Select *, (RollingPeopleVaccinated/Population)*100 as Percentage
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View Percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast( vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
join Portfolio..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;
