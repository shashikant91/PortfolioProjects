USE Project_Portfolio;
SELECT * FROM Project_Portfolio.dbo.CovidDeaths
WHERE continent IS NOT NULL;
SELECT * FROM Project_Portfolio.dbo.CovidVaccination


SELECT location,date, total_cases,new_cases,total_deaths,population
FROM Project_Portfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows liklihood of dying if anyone contract covid-19 in India

SELECT location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Project_Portfolio..CovidDeaths
WHERE location like '%India%' AND WHERE continent IS NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid-19


SELECT location,date, population,total_cases, (total_cases/population)*100 AS Percent_Population_Infected
FROM Project_Portfolio..CovidDeaths
WHERE location like '%India%'AND WHERE continent IS NOT NULL
ORDER BY 2


-- Looking at Countries with highest infection rate compared to population


SELECT location, population,MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
FROM Project_Portfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY Percent_Population_Infected DESC


--Showing Countries with highest Death count per Population



SELECT location,MAX(total_deaths) AS Total_Deaths_Counts
FROM Project_Portfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Deaths_Counts DESC



-- LET'S BREAK THINGS BY CONTINENT


-- Showing Highest deaths by Continent

SELECT continent,MAX(total_deaths) AS Total_Deaths_Counts
FROM Project_Portfolio..CovidDeaths
GROUP BY continent
ORDER BY Total_Deaths_Counts DESC

-- GLOBAL NUMBERS


--Daily Covid-19 Updates

SELECT date,SUM(new_cases) AS Total_Cases,SUM(new_deaths) AS Total_Deaths,(SUM(new_deaths))/SUM(new_cases)) * 100 AS Death_Percentage
FROM Project_Portfolio..CovidDeaths
WHERE new_deaths >0
GROUP BY date
ORDER BY 1

--JOINING COVID_VACCINATION TABLE WITH COVID_DEATHS TABLE

-- Looking at total population vs Vaccination

SELECT Deaths.continent,Deaths.location,Deaths.date,Deaths.population,Vacc.new_vaccinations
FROM Project_Portfolio.dbo.CovidDeaths AS Deaths
JOIN
Project_Portfolio.dbo.CovidVaccination AS Vacc
ON Deaths.location = Vacc.location



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (Partition by deaths.Location Order by deaths.location, deaths.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	On deaths.location = vacc.location
	and deaths.date = vacc.date
where deaths.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations)) OVER (Partition by deaths.Location Order by  deaths.location,  deaths.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vacc
	On dea.location = vac.location
	and deaths.date = vacc.date
where deaths.continent is not null 

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
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (Partition by  deaths.Location Order by  deaths.location,  deaths.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths deaths
Join PortfolioProject..CovidVaccinations vacc
	On deaths.location = vacc.location
	and deaths.date = vacc.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select  deaths.continent,  deaths.location, deaths.date,  deaths.population, vacc.new_vaccinations
, SUM(vacc.new_vaccinations) OVER (Partition by  deaths.Location Order by  deaths.location,  deaths.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  deaths
Join PortfolioProject..CovidVaccinations vacc
	On  deaths.location = vacc.location
	and  deaths.date = vacc.date
where deaths.continent is not null 
