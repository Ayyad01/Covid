use Covid

-- Create table for total cases vs total deaths
CREATE TABLE TotalCasesVsTotalDeaths (
  location VARCHAR(255),
  date DATE,
  total_cases INT,
  total_deaths INT,
  DeathPercentage FLOAT
);

-- Create table for total cases vs population
CREATE TABLE TotalCasesVsPopulation (
  Location VARCHAR(255),
  date DATE,
  total_cases bigint,
  population bigint,
  infection_percentage FLOAT
);

-- Create table for highest rates in countries
CREATE TABLE HighestRatesInCountries (
  Location VARCHAR(255),
  highest_rates INT,
  population INT,
  infection_percentage FLOAT
);

-- Create table for highest deaths rates in countries
CREATE TABLE HighestDeathsRatesInCountries (
  location VARCHAR(255),
  death_rates BIGINT
);

-- Create table for highest deaths rates by continents
CREATE TABLE HighestDeathsRatesByContinents (
  continent VARCHAR(255),
  death_rates BIGINT
);

-- Create table for new cases vs new deaths
CREATE TABLE NewCasesVsNewDeaths (
  date DATE,
  total_new_cases FLOAT,
  total_new_deaths FLOAT,
  new_death_rates FLOAT
);

-- Create table for vaccinations used around the timeline of the infection
CREATE TABLE VaccinationsUsedAroundTimelineOfInfection (
  continent VARCHAR(255),
  location VARCHAR(255),
  date DATE,
  population INT,
  new_vaccinations INT,
  All_people_vaccinated BIGINT
);
------------------- Now filling those tables with the analysis  that we want -----------------------------------------

-- Insert data into TotalCasesVsTotalDeaths table
INSERT INTO TotalCasesVsTotalDeaths (
  location,
  date,
  total_cases,
  total_deaths,
  DeathPercentage
)
SELECT
  location,
  date,
  total_cases,
  ISNULL(CAST(total_deaths AS int), 0) AS total_deaths,
  CASE
    WHEN total_cases = 0 THEN NULL
    ELSE (ISNULL(CAST(total_deaths AS int), 0) / total_cases) * 100
  END AS DeathPercentage
FROM
  Covid..[owid-covid-data]
WHERE
  location LIKE '%states%' and continent is not null 
ORDER BY 1, 2;
--//select * from TotalCasesVsTotalDeaths// ---- it worked well 

-- Insert data into TotalCasesVsPopulation table
ALTER TABLE TotalCasesVsPopulation
ALTER COLUMN total_cases BIGINT;

ALTER TABLE TotalCasesVsPopulation
ALTER COLUMN population BIGINT;

UPDATE TotalCasesVsPopulation
SET infection_percentage = CAST(total_cases AS FLOAT) / population * 100;

insert into TotalCasesVsPopulation (
  Location,
  date,
  total_cases,
  population,
  infection_percentage
)
SELECT
  Location,
  date,
  CAST(total_cases AS BIGINT),
  population,
  (CAST(total_cases AS BIGINT) / population) * 100 AS infection_percentage
FROM
  Covid..[owid-covid-data]
WHERE
  continent IS NOT NULL
ORDER BY 1, 2;
-- Now to try to experiment that 
--select * from TotalCasesVsPopulation , it  worked well


-- Insert data into HighestRatesInCountries table
alter table HighestRatesInCountries 
alter  column highest_rates  float;

alter table HighestRatesInCountries
alter column population bigint;

INSERT INTO HighestRatesInCountries (
  Location,
  highest_rates,
  population,
  infection_percentage
)
SELECT
  Location,
  MAX(total_cases) AS highest_rates,
  population,
  (MAX(total_cases) * 100) / population AS infection_percentage
FROM
  Covid..[owid-covid-data]
WHERE
  continent IS NOT NULL
GROUP BY
  Location,
  population
ORDER BY
  infection_percentage DESC;




-- Insert data into HighestDeathsRatesInCountries table
INSERT INTO HighestDeathsRatesInCountries (
  location , death_rates
)
SELECT
  location , MAX(cast(total_deaths as bigint))as death_rates
FROM
  Covid..[owid-covid-data]
WHERE
  continent is not null
GROUP BY
  location
ORDER BY
  death_rates DESC;
  --// select * from HighestDeathsRatesInCountries// it works well


-- Insert data into HighestDeathsRatesByContinents table
INSERT INTO HighestDeathsRatesByContinents (
  continent, death_rates
)
SELECT
  continent, MAX(CAST(total_deaths AS bigint)) AS death_rates
FROM
  Covid..[owid-covid-data]
WHERE
  continent IS NOT NULL AND continent <> ''
GROUP BY
  continent 
ORDER BY
  death_rates DESC;
--  All works well now  
-- let's try it  on power  bi