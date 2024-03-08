-- This is answer of this question asked by mamagement
use retail_events_db;
-- Q1- PROVID A LIST OF PRODUCTS WITH THE BASE PEICE GREATER THAN 500 AND  THAT ARE FEATURED IN PROMO TYPE 'BOGOF'(BUY ONE GET ONE FREE)

SELECT DISTINCT
    (Product_name), base_price, promo_type
FROM
    products p
        JOIN
    fact_events fe ON fe.product_code = p.product_code
WHERE
    base_price > 500
        AND promo_type = 'bogof';
        
	
-- Q2- Generate a report that provide an overview of  the number of  stores in each city thats result will be stored in desc order of store counts allowing us to identify 
-- the cities with highest store presence.

select city , count(store_id) as 'Number of store'
from stores
group by city 
order by count(store_id)desc;


-- Q3- Generate a report that displays each campaign along with the total revenue renerated before and after the campaign

SELECT 
    campaign_name,
    SUM(base_price * quantity_sold_before_promo) AS 'Total revenue before promotion',
    SUM(base_price * quantity_sold_after_promo) AS 'Total revenue after promotion'
FROM
    campaigns c
        JOIN
    fact_events fe ON fe.campaign_id = c.campaign_id
GROUP BY campaign_name
ORDER BY campaign_name , SUM(base_price * quantity_sold_before_promo) , SUM(base_price * quantity_sold_after_promo) DESC;


-- Q4- PRODUCE A REPORT THAT CALCULATES THE INCERMENTAL SOLD QUANTITY (ISU %) FOR EACH CATAGORY DURING THE ' DIWALI ' CAMPAIGN ADDITIONALLY PROVIDE 
-- RANKING FOR THE CATAGORY BASED  ON THEIR ISU %


with campaignData as (
select p.category,
		c.campaign_name,
        sum(quantity_sold_before_promo) as sale_before_promo,
        sum(quantity_sold_after_promo) as sale_after_promo
from fact_events F
        join products p on p.product_code=f.product_code
        join campaigns C on C.campaign_id=f.campaign_id
group by
        p.category,	c.campaign_name)
select
    category,
    campaign_name,
    sale_before_promo,
    sale_after_promo,
    round((( sale_after_promo-sale_before_promo)/sale_before_promo)*100,2) as ISU_PERCENTAGE,
    RANK() OVER(ORDER BY  (( sale_after_promo-sale_before_promo)/sale_before_promo)*100 DESC) AS CATEGORY_RANK
    FROM CAMPAIGNDATA
    where campaign_name= 'DIWALI';
SELECT* from campaigns;
-- NOTE ISU REFERCE TO INCREMENTAL SOLD UNIT 

-- Q5- CREATE a report featuring the top 5 products ranked by incrimental revenue percentage IR% across all campaigns

with product_rank as (
select p.category,
		p.product_name,
		c.campaign_name,
        sum(quantity_sold_before_promo*base_price) as revenue_before_promo,
        sum(quantity_sold_after_promo*base_price) as revenue_after_promo
from fact_events F
        join products p on p.product_code=f.product_code
        join campaigns C on C.campaign_id=f.campaign_id
group by
        p.category,	c.campaign_name,product_name)
select
    product_name,
    category,
    round((( revenue_after_promo-revenue_before_promo)/revenue_before_promo)*100,2) as IR_PERCENTAGE,
    RANK() OVER(ORDER BY  (( revenue_after_promo-revenue_before_promo)/revenue_before_promo)*100 DESC) AS product_RANK
    FROM Product_rank limit 5;

-- NOTE- IR_PERCENTAGE referce to 'incremental 


