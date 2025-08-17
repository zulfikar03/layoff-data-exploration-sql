SELECT *
FROM layoffs;

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- Remove Duplicate Data
WITH layoff_CTE AS
(
SELECT *,
ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, stage, country, 
funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM layoff_CTE
WHERE row_num > 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing Data
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- NULL VALUES

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Juul';

SELECT *
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
	AND t1.location = t2.location
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;