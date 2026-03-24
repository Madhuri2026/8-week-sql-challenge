-- Case Study 1: Danny's Diner
-- Tool used: BigQuery

-- Q1. Total amount each customer spent at the restaurant

SELECT s.customer_id,
       SUM(m.price) AS total_amt_spent
FROM `dannys_diner.sales` s JOIN `dannys_diner.menu` m
ON s.product_id = m.product_id
GROUP BY s.customer_id


-- Q2. Total number of days each customer has visited the restaurant

SELECT customer_id,
       COUNT(DISTINCT order_date) AS number_of_days
FROM `dannys_diner.sales`
GROUP BY customer_id


-- Q3. The first item from the menu purchased by each customer?

SELECT s.customer_id,
       m.product_name
FROM (SELECT s.customer_id,
       m.product_name,
       ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
FROM `dannys_diner.sales` s JOIN `dannys_diner.menu` m  
ON s.product_id = m.product_id)
WHERE rnk = 1


-- Q4. The most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name,
       COUNT(*) AS total_purchases_made
FROM `dannys_diner.sales` s JOIN `dannys_diner.menu` m  
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY total_purchases_made DESC
LIMIT 1;


-- Q5. The most popular item for each customer?

SELECT customer_id,
       product_name,
       order_count
FROM
       (SELECT s.customer_id,
               m.product_name,
               COUNT(*) order_count,
               RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rnk
FROM `dannys_diner.sales`s JOIN `dannys_diner.menu` m  
ON s.product_id = m.product_id
GROUP BY s.customer_id,
         m.product_name)
WHERE rnk = 1


-- Q6. The first item purchased by each customer after they became a member?

SELECT customer_id,
       order_date,
       product_name
FROM (
    SELECT s.customer_id,
           s.order_date,
           s.product_id,
           m.product_name,
           me.join_date,
           RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
FROM `dannys_diner.sales` s JOIN `dannys_diner.members` me  
ON s.customer_id = me.customer_id
JOIN `dannys_diner.menu` m  
ON s.product_id = m.product_id
WHERE s.order_date >= me.join_date)
WHERE rnk = 1;


-- Q7. The item which was purchased by each customer just before the customer became a member?

SELECT customer_id,
       order_date,
       product_name
FROM (
    SELECT s.customer_id,
           s.order_date,
           s.product_id,
           m.product_name,
           me.join_date,
           RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
FROM `dannys_diner.sales` s JOIN `dannys_diner.members` me  
ON s.customer_id = me.customer_id
JOIN `dannys_diner.menu` m  
ON s.product_id = m.product_id
WHERE s.order_date < me.join_date)
WHERE rnk = 1;


-- Q8. The total items and amount spent for each member before they became a member?

SELECT s.customer_id,
       COUNT(s.product_id) AS total_items,
       SUM(m.price) AS amt_spt
FROM `dannys_diner.sales` s JOIN `dannys_diner.menu` m  
ON s.product_id = m.product_id
JOIN `dannys_diner.members` me  
ON s.customer_id = me.customer_id
WHERE s.order_date < me.join_date
GROUP BY s.customer_id;


-- Q9. Total points for each customer, if each $1 spent equates to 10 points and sushi has a 2x points multiplier

SELECT s.customer_id,
       SUM(CASE
           WHEN LOWER(m.product_name) = "sushi" THEN m.price * 20
           ELSE m.price * 10
       END) AS points
FROM `dannys_diner.sales` s JOIN `dannys_diner.menu` m  
ON s.product_id = m.product_id
GROUP BY s.customer_id

  
-- Q10. Points earned in the first week after joining. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi. How many points do customer A and B have at the end of January?

SELECT s.customer_id,
       SUM
          (CASE
              WHEN s.order_date BETWEEN me.join_date AND DATE_ADD (me.join_date, INTERVAL 6 DAY)
              THEN m.price * 20

              WHEN LOWER(m.product_name) = 'sushi'
              THEN m.price * 20
  
              ELSE m.price * 10
          END) AS total_points
FROM `dannys_diner.sales` s JOIN `dannys_diner.menu` m  
ON s.product_id = m.product_id
JOIN `dannys_diner.members` me  
ON s.customer_id = me.customer_id
WHERE s.order_date <= '2021-01-31'
GROUP BY s.customer_id;
