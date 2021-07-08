-- Select Data that we are going to be starting with
SELECT *
FROM PortfolioProject..CovidDeaths



Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths

order by 1,2,3

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in your country
Alter table CovidDeaths Alter column total_deaths float
Alter table CovidDeaths Alter column total_cases float
Alter table PortfolioProject..CovidDeaths Alter column new_cases float
Alter table CovidDeaths Alter column population float
Alter table  PortfolioProject..CovidDeaths Alter column date smalldatetime

Select Location, date, total_cases,total_deaths,population,(total_deaths/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2

Select Location, date, total_cases,total_deaths,population,(total_deaths/total_cases)*100 
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2

Select Location, date, total_cases,total_deaths,population,(total_cases/population)*100 as infection_persantage
From PortfolioProject..CovidDeaths
Where location like '%india%'
and continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT * 
FROM PortfolioProject..CovidDeaths
Where population = 0

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE population != 0
--Where location like '%india%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent <> ''
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent = '' 
Group by location
order by TotalDeathCount desc


SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
GROUP by continent
ORDER by TotalDeathCount desc

SELECT date 
From PortfolioProject..CovidDeaths
WHERE date <> '' 

Select cast(date as datetime2(7)), SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent  <> '' AND new_cases <> '' AND date
Group By date
order by 1,2 desc


SELECT *
FROM PortfolioProject..CovidVaccinations 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> '' ANd dea.population <> 0
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent <> '' ANd dea.population <> 0
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent <> ''


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
