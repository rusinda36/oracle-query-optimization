-- Index created during investigation (Oracle still chose full scan):
-- CREATE INDEX IDX_SALES_DATE ON SALES (SALE_DATE);
SELECT /*+ GATHER_PLAN_STATISTICS */
       p.category, c.province,
       SUM(s.quantity * s.unit_price) AS revenue
FROM sales s
JOIN customers c ON c.customer_id = s.customer_id
JOIN products p ON p.product_id = s.product_id
WHERE s.sale_date >= DATE '2025-01-01'
  AND s.sale_date < DATE '2025-02-01'
GROUP BY p.category, c.province;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
