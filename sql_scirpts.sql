/*
	ANALYZING SUPERMARKET DATA AND EXTRACTING INSINGHTS THAT MAY HELP BUSSINESS TO UNDERSTAND MARKET TRENDS AND 
    IN TERMS OF TAKING DECISION FOR FUTURE PRODIUCT LUNCHES AND MAKING BETTER DECISIONS.
*/

WITH TEMP AS (
	SELECT
		ï»¿order_id,
		order_date,
		ship_date,
		ship_mode,
		segment,
		state,
		country,
		market,
		region,
		product_id,
		category,
		CASE 
			WHEN 
				SUBSTRING(PRODUCT_NAME,1,INSTR(product_name,',')-1) IS NOT NULL
			THEN 
				SUBSTRING(PRODUCT_NAME,1,INSTR(product_name,',')-1)
			ELSE
				'UNKNOWN'
		END PRODUCT_NAME,
		sales,
		quantity,
		profit,
		year
	FROM superstoreorders
    )

/*
	PERFORMING ANALISYS ON DATA.
*/

-- TOP SALING CATEGORY IN EACH COUNTRY.
SELECT
	country,
	category,
	total_sold
FROM (
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY country ORDER BY total_sold DESC) AS top_category
	FROM (
		SELECT
			country,
			category,
			sum(quantity) as total_sold
		FROM temp
		GROUP BY 
			country,
			category
		ORDER BY
			country,
			total_sold DESC
		) T1
	) T2
WHERE top_category = 1;

-- EXTRACTING MARKET 
WITH TEMP AS (
	SELECT
		ï»¿order_id,
		order_date,
		ship_date,
		ship_mode,
		segment,
		state,
		country,
		market,
		region,
		product_id,
		category,
		CASE 
			WHEN 
				SUBSTRING(PRODUCT_NAME,1,INSTR(product_name,',')-1) IS NOT NULL
			THEN 
				SUBSTRING(PRODUCT_NAME,1,INSTR(product_name,',')-1)
			ELSE
				'UNKNOWN'
		END PRODUCT_NAME,
		sales,
		quantity,
		profit,
		year
	FROM superstoreorders
    )
    
-- SALING PERFORMENCE OF ALL CATEGORY IN EACH COUNTRY.
SELECT
	country,
	category,
	sum(quantity) as total_sold
FROM temp
GROUP BY 
	country,
	category
ORDER BY
	country,
	total_sold DESC;

/*
	CATEGORIES AND THERE PERFORMENCE BASED ON TWO CONDITIONS FOR EACH COUNTRY -
    1. REVENUE.
    2. PROFIT
*/

-- BASED ON SALES.
SELECT
	country,
    category,
    sum(sales) AS total_sales
FROM superstoreorders
GROUP BY 
	country,
    category;
    
-- BASED ON PROFIT.
SELECT
	country,
    category,
    ROUND(sum(profit),2) AS total_profit
FROM superstoreorders
GROUP BY 
	country,
    category;


/*
	SALES TREND ON TOP OF YEAR.
*/

-- CALCULATING TOTAL SALES,AVGERAGE SALE.
SELECT
	year(new_order_date) AS year,
    SUM(sales) AS sale_per_year,
    ROUND(AVG(sales),2) AS avg_sale_year
FROM superstoreorders
GROUP BY
	year(new_order_date)
ORDER BY
	year;


-- COMPARING SALE INCREAMENT BASED ON PRE_YEAR SALE.
SELECT
	year,
    sale_per_year AS curr_year_sale,
    IFNULL(LAG(sale_per_year) OVER(ORDER BY year),0) AS pre_year_sale,
    IFNULL(ROUND(
        (
            (sale_per_year - LAG(sale_per_year) OVER(ORDER BY year))
            / NULLIF(LAG(sale_per_year) OVER(ORDER BY year), 0)
        ) * 100,
        2
    ),0) AS sales_growth_pct
FROM (
	SELECT
		year(new_order_date) AS year,
		SUM(sales) AS sale_per_year
	FROM superstoreorders
	GROUP BY
		year(new_order_date)
	ORDER BY
		year
	) T;



--











