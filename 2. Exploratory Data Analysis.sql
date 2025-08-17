SELECT *
FROM layoffs_staging2;

-- Looking for average, max, and min for total_laid_off
SELECT AVG(total_laid_off), MAX(total_laid_off), MIN(total_laid_off)
FROM layoffs_staging2;

-- Looking for average, max, min percentage_laid_off
SELECT AVG(percentage_laid_off), MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_staging2;

-- Looking for average, max, min funds_raised_millions
SELECT AVG(funds_raised_millions), MAX(funds_raised_millions), MIN(funds_raised_millions)
FROM layoffs_staging2;

-- Exploring data with percentage_laid_off is equal 1 and order by funds_raised_millions
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- sum total_laid_off by company
SELECT company, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY company
HAVING sum_total_laid_off IS NOT NULL
ORDER BY sum_total_laid_off DESC;

-- sum total_laid_off by country
SELECT country, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY country
HAVING sum_total_laid_off IS NOT NULL
ORDER BY sum_total_laid_off DESC;

-- sum total_laid_off by stage
SELECT stage, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY stage
HAVING sum_total_laid_off IS NOT NULL
ORDER BY sum_total_laid_off DESC;

-- sum total_laid_off by industry
SELECT industry, SUM(total_laid_off) AS sum_total_laid_off
FROM layoffs_staging2
GROUP BY industry
HAVING sum_total_laid_off IS NOT NULL
ORDER BY sum_total_laid_off DESC;

-- Sum funds_raised_millions by company
SELECT company, SUM(funds_raised_millions) AS sum_funds
FROM layoffs_staging2
GROUP BY company
HAVING sum_funds IS NOT NULL
ORDER BY sum_funds DESC;

-- Sum funds_raised_millions by industry
SELECT industry, SUM(funds_raised_millions) AS sum_funds
FROM layoffs_staging2
GROUP BY industry
HAVING sum_funds IS NOT NULL
ORDER BY sum_funds DESC;

-- Sum total_laid_off by year_month
SELECT SUBSTRING(`date`, 1,7) AS `year_month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `year_month`
ORDER BY 1;

-- Rolling_total sum_total_laid_off by year month
WITH Rolling_total(`year_month`, sum_total_laid_off) AS
(
SELECT SUBSTRING(`date`, 1,7) , SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY SUBSTRING(`date`, 1,7)
)
SELECT *, SUM(sum_total_laid_off) OVER(ORDER BY `year_month`) AS rolling_total
FROM Rolling_total;

-- Rolling total sum funds_raised_millions by year month
WITH Rolling_total(`year_month`, sum_funds) AS
(
SELECT SUBSTRING(`date`, 1,7) , SUM(funds_raised_millions)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY SUBSTRING(`date`, 1,7)
)
SELECT *, SUM(sum_funds) OVER(ORDER BY `year_month`) AS rolling_total
FROM Rolling_total;

-- Ranking sum total_laid_off by company per year
WITH Company_year (company, `year`, sum_total_laid_off) AS 
(SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY company, YEAR(`date`)
), Company_year_rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY `year` ORDER BY sum_total_laid_off DESC) AS ranking
FROM Company_year)
SELECT *
FROM Company_year_rank
WHERE ranking <= 5
;