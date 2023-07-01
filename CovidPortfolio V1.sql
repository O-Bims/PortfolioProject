USE PortfolioProject1

SELECT * FROM covidDeathB

---To describe the component/ data type of the table, I used this
EXEC SP_COLUMNS covidDeathB

--- To change my datatype
ALTER TABLE covidDeathB ALTER COLUMN total_cases FLOAT
ALTER TABLE covidDeathB ALTER COLUMN total_deaths FLOAT
ALTER TABLE covidDeathB ALTER COLUMN total_cases_per_million FLOAT
ALTER TABLE covidDeathB ALTER COLUMN total_deaths_per_million FLOAT

SELECT *
FROM PortfolioProject1..covidDeathB
WHERE continent is NOT NULL
ORDER BY 3, 4

---Looking at Total cases vs Total Deaths
---Shows the Likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, new_cases, population, (total_deaths / total_cases)*100 as DeathPercentage
FROM covidDeathB
WHERE location LIKE '%nigeria%'
AND continent is NOT NULL
ORDER BY 1,2


--- Looking at the Total cases vs Population
---Shows what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
FROM covidDeathB
WHERE location LIKE '%africa%'
ORDER BY 1,2


---Looking at countries with highest infection rate, compared to population
SELECT Location,  population, MAX(total_cases) AS HighestInfectionCount, 
		MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM covidDeathB
WHERE continent is NOT NULL
GROUP BY Population, location
ORDER BY PercentagePopulationInfected DESC


---Showing the countries with the highest death count per population
SELECT Location,   MAX(total_deaths) AS TotalDeathCount 
FROM covidDeathB
WHERE continent is NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC


--Lets break things down by continent
SELECT location, MAX(total_deaths) AS TotalDeathCount 
FROM covidDeathB
WHERE continent is NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC


---Showing the continent with the highest death count
SELECT continent, MAX(total_deaths) AS TotalDeathCount 
FROM covidDeathB
WHERE continent is NOT NULL
GROUP BY  continent
ORDER BY TotalDeathCount DESC


--- Global Numbers
--will give the total total cases and deaths that occured per day
SELECT date, Sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, Sum(total_deaths / total_cases)*100 as DeathPercentage
FROM covidDeathB
---WHERE location LIKE '%nigeria%'
WHERE continent is NOT NULL
GROUP BY DATE
ORDER BY 1,2

--will give the cummulative of the total cases and deaths that occured
SELECT Sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, Sum(total_deaths / total_cases)*100 as DeathPercentage
FROM covidDeathB
---WHERE location LIKE '%nigeria%'
WHERE continent is NOT NULL
--GROUP BY DATE
ORDER BY 1,2


USE PortfolioProject1

SELECT * FROM CovidVaccinationB

---To describe the component/ data type of the table, I used this
EXEC SP_COLUMNS covidvaccinationB

--- To change my datatype
ALTER TABLE covidVaccinationB ALTER COLUMN total_tests FLOAT
ALTER TABLE covidVaccinationB ALTER COLUMN new_tests FLOAT
ALTER TABLE covidVaccinationB ALTER COLUMN new_vaccinations FLOAT
ALTER TABLE covidVaccinationB ALTER COLUMN total_vaccinations FLOAT



---LOOKING at Total Population vs Total Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeathB Dea
Join CovidVaccinationB Vac
ON Dea.Location = Vac.Location
AND Dea.Date = Vac.Date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


--USE CTE
WITH PopvsVac (continenct, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeathB Dea
Join CovidVaccinationB Vac
ON Dea.Location = Vac.Location
AND Dea.Date = Vac.Date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
Select * , (RollingPeopleVaccinated/ Population)*100
From PopvsVac


--Temp Table
DROP TABLE IF EXISTs #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date Datetime, 
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeathB Dea
Join CovidVaccinationB Vac
ON Dea.Location = Vac.Location
AND Dea.Date = Vac.Date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3

Select * , (RollingPeopleVaccinated/ Population)*100
From #PercentPopulationVaccinated


--Creating views to store data for later visualizations

Create View PercentPopulationVaccinated as

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeathB Dea
Join CovidVaccinationB Vac
ON Dea.Location = Vac.Location
AND Dea.Date = Vac.Date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

Select * 
FRom PercentPopulationVaccinated