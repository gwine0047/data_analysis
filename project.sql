select *
from [covid-deaths]
Where continent is not null
Order by 3

--Looking at Total cases vs population
--Displaying what oercentage got infected with Covid

Select location, date, population, total_cases, (total_cases / population)* 100 AS infected
from [covid-deaths]
Where continent = ''
--where location = 'Nigeria'
order by 2


--Looking at Countries with the highest infection rate

select location, population, MAX(total_cases) AS HighestInfectionCount, (total_cases / population) AS infection_rate
from [covid-deaths]
Where continent is not null

--where location = 'Nigeria'
order by 1, 2

--The 'GROUP BY' clause is used in conjunction with aggregate functions to group rows that have the same values inspecified columns into summary rows
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases / population) * 100 as infection_rate, SUM(total_cases) as OverallTotalCases
from [covid-deaths]
--where location = 'Nigeria'
Where continent is not null
GROUP BY population, location
Order by infection_rate desc;


--Showing the countries with the top death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [covid-deaths]
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


--GLOBAL NUMBERS
SELECT new_cases as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(cast(new_cases as int)) * 100 as DeathPercentage
FROM [covid-deaths]
Where continent is not null
GROUP BY new_cases
ORDER BY 1, 2

ALTER TABLE [covid-vaccination]
ALTER COLUMN new_vaccinations int;

-- Showing total population to total vaccination
Select cv.continent, cv.location, cd.date, cd.population,new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (PARTITION by cv.location Order by cv.location, cd.date) as AggPeopleVaccinated
From [covid-vaccination] cv
Join [covid-deaths] cd
	On cv.location = cd.location
	and cd.date = cv.date
Where cd.continent is not null
 Order by 2,3

 --USING CTE
 --No of columns in the CTE must be the same as the number in select
 With PopvsVac (continent, location, date, population, new_vaccinations, AggPeopleVaccinated)
 As
 (
 Select cv.continent, cv.location, cd.date, cd.population,new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (PARTITION by cv.location Order by cv.location, cd.date) as AggPeopleVaccinated
From [covid-vaccination] cv
Join [covid-deaths] cd
	On cv.location = cd.location
	and cd.date = cv.date
Where cd.continent is not null
 --Order by 2,3
 )
 Select *, (AggPeopleVaccinated / population) * 100
 from PopvsVac

 --TEMP TABLE
 DROP TABLE IF exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 AggPeopleVaccinated numeric
 )

 /*ALTER TABLE #PercentPopulationVaccinated
  AggPeopleVaccinated numeric */

 INSERT INTO #PercentPopulationVaccinated
  Select cv.continent, cv.location, cd.date, cd.population,new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (PARTITION by cv.location Order by cv.location, cd.date) as AggPeopleVaccinated
From [covid-vaccination] cv
Join [covid-deaths] cd
	On cv.location = cd.location
	and cd.date = cv.date
Where cd.continent is not null
 --Order by 2,3


 Select *, (AggPeopleVaccinated / population) * 100
 from #PercentPopulationVaccinated

 --Creating a view to store data later visualization

 create view PercentPopulationVaccinated as
   Select cv.continent, cv.location, cd.date, cd.population,new_vaccinations,
SUM(cast(new_vaccinations as float)) OVER (PARTITION by cv.location Order by cv.location, cd.date) as AggPeopleVaccinated
From [covid-vaccination] cv
Join [covid-deaths] cd
	On cv.location = cd.location
	and cd.date = cv.date
Where cd.continent is not null
 --Order by 2,3

