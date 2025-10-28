CREATE DATABASE vendor;
USE vendor;
SELECT * FROM vendor_table;
SELECT COUNT(*) FROM vendor_table;

# 1. Total Revenue generated genderwise
SELECT gender, SUM(purchase_amount) AS revenue
FROM vendor_table
GROUP BY gender;

# 2. List the customers who used discount but still spent more than average purchase amount
SELECT customer_id, location, purchase_amount FROM vendor_table
WHERE purchase_amount > (SELECT AVG(purchase_amount) FROM vendor_table) 
AND discount_applied = 'Yes';

# 3. Top 5 products with highest average review ratings
SELECT item_purchased , ROUND(AVG(review_rating),2) AS avg_review_rating
FROM vendor_table
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;

# 4. Average purchase amounts between Standard and Express shipping
SELECT AVG(purchase_amount) avg_purchase_amount , shipping_type
FROM vendor_table
WHERE shipping_type IN ('Standard','Express')
GROUP BY shipping_type;

# 5. Compare average spend and total revenue between subscribers and non-subscribers
SELECT subscription_status, COUNT(customer_id) AS customers,
AVG(purchase_amount) AS avg_spend, 
SUM(purchase_amount) AS total_revenue
FROM vendor_table
GROUP BY subscription_status;

# 6. Top 5 products with highest percentage of purchases with discounts applied
SELECT item_purchased,
100 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*) 
AS percentage_of_purchase
FROM vendor_table
GROUP BY item_purchased
ORDER BY percentage_of_purchase DESC
LIMIT 5;

# 7. Segment customers into New, Returning and Loyal based on their previous purchases and 
# share the count of their purchases as well.
WITH customer_type AS(
	SELECT customer_id, previous_purchases,
    CASE
		WHEN previous_purchases = 1 THEN 'New'
        WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
        ELSE 'Loyal'
        END AS customer_segment
	FROM vendor_table
)

SELECT customer_segment, COUNT(*) AS customers_count
FROM customer_type
GROUP BY customer_segment
ORDER BY customers_count;

# 8. Category-wise top 3 most purchased product
WITH item_counts AS (
	SELECT category, item_purchased, COUNT(customer_id) AS total_orders,
    ROW_NUMBER() OVER(PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS ranking
    FROM vendor_table
    GROUP BY category, item_purchased
)

SELECT category, item_purchased, total_orders, ranking
FROM item_counts
WHERE ranking<=3;

# 9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
SELECT COUNT(customer_id) AS repeat_buyers,
subscription_status
FROM vendor_table
WHERE previous_purchases>5
GROUP BY subscription_status;

# 10. Revenue contribution of each age-group
SELECT age_group, SUM(purchase_amount) AS revenue
FROM vendor_table
GROUP BY age_group
ORDER BY revenue DESC;