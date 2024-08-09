
SELECT * 
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
Where continent is not null
ORDER BY 3, 4;




--SELECT *
--FROM `portfolio-project-426300.PortfolioCovidProj.Vac`
--ORDER BY 3, 4;


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
order by 1, 2;


--Looking at the Total Cases vs Total Deaths
--shows the prob of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
WHERE location = 'United States'
ORDER BY 1, 2;


--looking at the total cases vs population 
--shows what perc of pop has gotten covid
SELECT location, date, population, total_cases, (total_cases / population) * 100 AS PercentagePop
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
WHERE location = 'United States'
ORDER BY 1, 2;


--countriers with highest infect rate vs pop
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopInfected
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
GROUP BY location, population
ORDER BY PercentPopInfected desc;

SELECT location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population)) * 100 AS PercentPopInfected
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
GROUP BY location, population, date
ORDER BY PercentPopInfected desc;


--showing the countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

--showing by continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;






--Global numbers
SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage
FROM `portfolio-project-426300.PortfolioCovidProj.Death`
Where continent is not null
--Group by date
ORDER BY 1, 2;


select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From `portfolio-project-426300.PortfolioCovidProj.Death`
where continent is null
and location not in ('World','European Union', 'International')
GROUP BY location 
order by TotalDeathCount desc;



--looking at total pop vs vaccinations

WITH PopVsVac
AS 
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM `portfolio-project-426300.PortfolioCovidProj.Death` dea
  JOIN `portfolio-project-426300.PortfolioCovidProj.Vac` vac
  ON 
    dea.location = vac.location
    AND dea.date = vac.date

  WHERE dea.continent IS NOT NULL
)

--USE CTE
SELECT *, (RollingPeopleVaccinated/population) * 100 as Percentage
FROM PopVsVac;









-- Create Temporary Table
CREATE TEMP TABLE PercentPopulationVaccinated (
  continent STRING,
  location STRING,
  date TIMESTAMP,
  population NUMERIC,
  new_vaccinations INT64,
  RollingPeopleVaccinated INT64
);

INSERT INTO PercentPopulationVaccinated (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
SELECT 
  dea.continent, 
  dea.location, 
  dea.date, 
  dea.population, 
  vac.new_vaccinations, 
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
  `portfolio-project-426300.PortfolioCovidProj.Death` dea
JOIN 
  `portfolio-project-426300.PortfolioCovidProj.Vac` vac
ON 
  dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL;


SELECT 
  continent, 
  location, 
  date, 
  population, 
  new_vaccinations, 
  RollingPeopleVaccinated, 
  (RollingPeopleVaccinated / population) * 100 AS Percentage
FROM 
  PercentPopulationVaccinated;


