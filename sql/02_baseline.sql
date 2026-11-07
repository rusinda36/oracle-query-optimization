-- Original analytical query; January 2025 revenue by category and province.
SELECT /*+ GATHER_PLAN_STATISTICS */
       p.category, c.province,
       SUM(s.quantity * s.unit_price) AS revenue
FROM sales s
JOIN customers c ON c.customer_id = s.customer_id
JOIN products p ON p.product_id = s.product_id
WHERE EXTRACT(YEAR FROM s.sale_date) = 2025
  AND EXTRACT(MONTH FROM s.sale_date) = 1
GROUP BY p.category, c.province;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
