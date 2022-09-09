--SELECT * FROM PortfolioProject..CovidDeaths;
SELECT Location, date, total_cases, new_cases, total_deaths
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;

-- calculating death percentage 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2;

-- calculating what percentage of the total population is affected by covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage 
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2;

-- Finding the countries with highest infection rates
SELECT location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as CovidPercentage 
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY CovidPercentage

--Finding the continents with highest death rate
SELECT location, MAX(cast (total_deaths as int)) as deathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP By Location
Order By deathCount DESC

-- Extracting global values of new covid cases, new death values
SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP By date
order by 1,2

-- Getting total vaccinatons vs total population
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(Convert(int,vacc.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS totalvaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
ON dea.location = vacc.location and
dea.date = vacc.date
WHERE dea.continent is not null
order by 2,3

-- Creating a CTE
With PopVsVac (continent, location, date, population, new_vaccinations, total_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(Convert(int,vacc.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS totalvaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
ON dea.location = vacc.location and
dea.date = vacc.date
WHERE dea.continent is not null
)
Select *, (total_vaccinations/population)*100 as percent_vaccinated from PopVsVac

--Creating a temp table for the same thing above
Drop table if exists #percentvaccinated
Create table #percentvaccinated
(
continent nvarchar(200),
location nvarchar(200),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)
Insert into #percentvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(Convert(int,vacc.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS totalvaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
ON dea.location = vacc.location and
dea.date = vacc.date
WHERE dea.continent is not null
Select *, (total_vaccinations/population)*100 as percent_vaccinated from #percentvaccinated

-- Storing the same query date above as a view for later visualization
Create view percentvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, SUM(Convert(int,vacc.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS totalvaccinations
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
ON dea.location = vacc.location and
dea.date = vacc.date
WHERE dea.continent is not null
select * from percentvaccinated

Create view highestdeathrate as
SELECT location, MAX(cast (total_deaths as int)) as deathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP By Location
--Order By deathCount DESC
select * from highestdeathrate


Create view globalvalues as
SELECT date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 as DeathPercent
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP By date
select * from globalvalues

