USE PortfolioProject
/* Check column in two tables
select * from CovidDeath;

select * from CovidVaccine;
*/

--Read this before getting into querying
/*
Because in datasets: there is some row that location = continent and the continent is null
You can find it by this query:

Select continent,location
from CovidDeath
where continent is null

So in some queries that containt Location column in Select stament
we need to check if you need to filter continent is not null or not to get the right answer
*/


/*
The data type of total_deaths is nvarhcar(255)
so we need to cast it into int every time we use Total_deaths column for aggregating data
*/

--Basic Query with CovidDeath
--1. Looking total_cases,total,death_rate death in different location by date in my country
SELECT location,date,total_cases,total_deaths,round((cast(total_deaths as int)/total_cases*100),2) as death_rate
FROM CovidDeath
where location like 'VietNam'
order by total_cases desc, death_rate desc;

--2. Find the rate of covid infection in the community by date in my country
SELECT location,date,total_cases,population,round((total_cases/population*100),3) as Covid_rate
FROM CovidDeath
where location like 'VietNam'
order by total_cases desc,Covid_rate desc;

--3. Find the country with top 20 highest covid infection rate and total_case
SELECT top 20 location,max(total_cases) as total_cases,population,MAX(round((total_cases/population*100),2)) as Covid_rate
FROM CovidDeath
where continent is not null
GROUP BY location,population
order by Covid_rate desc;

--4. Find what location has highest total_cases
Select location,max(cast(total_deaths as int)) as max_total_cases
from CovidDeath
where continent is not null
group by location
order by max_total_cases desc;


--5. Find what continent has highest death rate
Select continent,max(cast(total_deaths as int)) as max_total_cases
from CovidDeath
where continent is not null
group by continent
order by max_total_cases desc;

/* As you can see the result in North America in the query above is equal with the result in United State in 4 = 713227
 so we need to check again

 Remember what i have mentioned:
 Because in datasets: there is some row that location = continent and the continent is null

 So let change continent to location and set the continent is null to check if the answer is correct or not
 */
Select location,max(cast(total_deaths as int)) as max_total_cases
from CovidDeath
where continent is null
group by location
order by max_total_cases desc;
-- The answer now is more reasonable
-- To fix the misleading between location and continent is not in this project


--6. Find total_new_cases and total_death in the world
select sum(new_cases) as total_cases,
sum(cast(total_deaths as int)) as total_deaths,
round((sum(new_cases)/sum(cast(total_deaths as int)))*100,2) as deaths_rate
from CovidDeath
where continent is not null;

--Combination with CovidVaccine
--1. Get the total_vaccinations vs population in every locations by date
SELECT 
	CD.location,CD.DATE,CD.population,CC.new_vaccinations,
	SUM(CAST(CC.new_vaccinations AS INT)) 
	OVER(PARTITION BY CD.location ORDER BY CD.location,CD.DATE) AS TOTAL_VACCINATIONS
FROM CovidDeath AS CD JOIN CovidVaccine AS CC
ON CD.location = CC.location AND CD.DATE = CC.DATE
WHERE CD.continent IS NOT NULL
ORDER BY CD.location,CD.DATE;


--Let's define CTE:
WITH VACCINE_POPULATION AS
(SELECT 
	CD.location,CD.DATE,CD.population,CC.new_vaccinations,
	SUM(CAST(CC.new_vaccinations AS INT)) 
	OVER(PARTITION BY CD.location ORDER BY CD.location,CD.DATE) AS TOTAL_VACCINATIONS
FROM CovidDeath AS CD JOIN CovidVaccine AS CC
	ON CD.location = CC.location AND CD.DATE = CC.DATE
WHERE CD.continent IS NOT NULL
-- ORDER BY CD.location,CD.DATE
-- ORDER BY IS NOT VALID IN CTE
)
-- Let's use CTE to find vaccine_rate in population IN VIET NAM by date
SELECT VACCINE_POPULATION.location,VACCINE_POPULATION.date,ROUND((VACCINE_POPULATION.TOTAL_VACCINATIONS/VACCINE_POPULATION.population)*100,2) 
AS VACCINE_RATE
FROM VACCINE_POPULATION
WHERE VACCINE_POPULATION.location LIKE 'VIETNAM'
ORDER BY VACCINE_RATE DESC;


--2. CREATE VIEW CONTAIN VACCINE_RATE FOR LATER VISUALIZING
CREATE VIEW RATE_VACCINE_POPULATION AS
SELECT 
	CD.continent,CD.location,CD.DATE,CD.population,CC.new_vaccinations,
	SUM(CAST(CC.new_vaccinations AS INT)) 
	OVER(PARTITION BY CD.location ORDER BY CD.location,CD.DATE) AS TOTAL_VACCINATIONS,
	ROUND((TOTAL_VACCINATIONS/CD.population)*100,2) AS VACCINE_RATE
FROM CovidDeath AS CD JOIN CovidVaccine AS CC
ON CD.location = CC.location AND CD.DATE = CC.DATE
WHERE CD.continent IS NOT NULL;

SELECT * FROM RATE_VACCINE_POPULATION;
