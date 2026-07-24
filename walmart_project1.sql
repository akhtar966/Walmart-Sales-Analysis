-- Exploratory Data Analysis with sql
-- Walmart Project Queries

SELECT * FROM walmart;

-- DROP TABLE walmart;

-- DROP TABLE walmart;

-- 
SELECT COUNT(*) FROM walmart;

SELECT 
	 payment_method,
	 COUNT(*)
FROM walmart
GROUP BY payment_method


SELECT 
	COUNT(DISTINCT branch) 
FROM walmart;


SELECT MIN(quantity) FROM walmart;

-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold


SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method


-- Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1


-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT * 
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1

-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.



SELECT 
	 payment_method,
	 -- COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

--5. Determine the average,minimum, and maximum rating for each category in city.
--   List the city ,average_rating,min_rating,and max_rating.

select city,category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart 
group by 1,2

-- 6.calculate he total profit for each category by considering the total_profit as (uniy_price * quantity * profit_margin).
--   List category and total_profit, ordered from highest to lowest profit

select category, 
sum(total) as revenue_,
sum(total*profit_margin) as total_profit
from walmart 
group by category
order by  total_profit desc

--7. Determine the most common payment method for each branch
-- display branch and the preffered_payment_method.

with cte as (
select branch,payment_method,count(*) as total_trans,
rank() over(partition by branch order by count(*) desc) as rnk
from walmart
group by 1,2)
select * from cte
where rnk=1

--8.Categorize the sales into 3 group MORNING ,AFTERNOON,EVENING
-- FIND out which of the shift and number of invoices 

  select branch,case 
  when extract(hour from (time::time))<12 then 'MORNING'
  when extract(hour from (time::time)) between 12 and 17 then 'AFTERNOON'
  when extract(hour from (time::time))>17 then 'EVENING' end as day_time,
  count(*)
  from walmart
  group by 1,2
  order by 1,3 desc

--9. Identify 5 Branch with the highest decrease ratio in revenue campare to last year(current_year 2023 and last yr 2022)
-- rdr = (lyr-cyr)/lyr *100



SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5















