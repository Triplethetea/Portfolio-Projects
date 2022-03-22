SELECT Location,Date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2


-- Looking at Total cases vs Total deaths
--Shows the likelyhood of dying if you contract COVID in your country

SELECT Location,Date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location like 'Australia'
ORDER BY 1,2


--Look at total cases vs population
SELECT Location,Date,total_cases, Population,total_deaths, (total_cases/Population)*100 AS InfectedPopulation
FROM CovidDeaths
WHERE location like 'Australia'
ORDER BY 1,2

--What countries have the highest infections rates compared to population?

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

--- Countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) AS HighestDeathcount
FROM CovidDeaths
Where continent is not null
GROUP BY Location
ORDER BY HighestDeathcount DESC


-- LET's BREAK THINGS DOWN BY COUNTRY

SELECT Location, MAX(cast(total_deaths as int)) AS HighestDeathcount
FROM CovidDeaths
Where continent is not null
GROUP BY Location
ORDER BY HighestDeathcount DESC


SELECT Continent, MAX(cast(total_deaths as int)) AS HighestDeathcount
FROM CovidDeaths
Where continent is not null
GROUP BY Continent
ORDER BY HighestDeathcount DESC


--Global numbers

SELECT Date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--JOINING VACCINATIONS TABLE
--Looking at total populationn vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	ORDER BY 2,3


--CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
	--ORDER BY 2,3
	)

	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM PopvsVac


--TEMP TABLE

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

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM #PercentPopulationVaccinated



	--Creating view for data  for later visualisation

	CREATE VIEW PercentPopulationVaccinated as
	SELECT dea.continent, dea.Location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as RollingPeopleVaccinated
FROM CovidDeaths dea
Join CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated
