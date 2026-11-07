WITH baseline AS (
 SELECT p.category, c.province, SUM(s.quantity*s.unit_price) revenue
 FROM sales s JOIN customers c ON c.customer_id=s.customer_id
 JOIN products p ON p.product_id=s.product_id
 WHERE EXTRACT(YEAR FROM s.sale_date)=2025 AND EXTRACT(MONTH FROM s.sale_date)=1
 GROUP BY p.category,c.province
), optimized AS (
 SELECT p.category, c.province, SUM(s.quantity*s.unit_price) revenue
 FROM sales s JOIN customers c ON c.customer_id=s.customer_id
 JOIN products p ON p.product_id=s.product_id
 WHERE s.sale_date>=DATE '2025-01-01' AND s.sale_date<DATE '2025-02-01'
 GROUP BY p.category,c.province
)
SELECT 'BASELINE_MINUS_OPTIMIZED' check_type, COUNT(*) differences
FROM (SELECT * FROM baseline MINUS SELECT * FROM optimized)
UNION ALL
SELECT 'OPTIMIZED_MINUS_BASELINE', COUNT(*)
FROM (SELECT * FROM optimized MINUS SELECT * FROM baseline);
