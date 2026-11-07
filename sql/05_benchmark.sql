-- Execute in SQL Developer with F5. Two passes alternate order to mitigate order effects.
-- DBMS_UTILITY.GET_TIME resolution is 10 ms. Timings are server-side PL/SQL timings.
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
 v_start NUMBER; v_elapsed NUMBER; v_rows NUMBER; v_revenue NUMBER;
BEGIN
 FOR pass IN 1..2 LOOP
  FOR i IN 1..5 LOOP
   FOR slot IN 1..2 LOOP
    v_start := DBMS_UTILITY.GET_TIME;
    IF (pass = 1 AND slot = 1) OR (pass = 2 AND slot = 2) THEN
     SELECT COUNT(*), SUM(revenue) INTO v_rows,v_revenue FROM (
      SELECT p.category,c.province,SUM(s.quantity*s.unit_price) revenue
      FROM sales s JOIN customers c ON c.customer_id=s.customer_id
      JOIN products p ON p.product_id=s.product_id
      WHERE EXTRACT(YEAR FROM s.sale_date)=2025 AND EXTRACT(MONTH FROM s.sale_date)=1
      GROUP BY p.category,c.province
     );
     v_elapsed := (DBMS_UTILITY.GET_TIME-v_start)*10;
     DBMS_OUTPUT.PUT_LINE('Pass='||pass||' Run='||i||' Variant=BASELINE Time_ms='||v_elapsed||' Rows='||v_rows||' Revenue='||v_revenue);
    ELSE
     SELECT COUNT(*), SUM(revenue) INTO v_rows,v_revenue FROM (
      SELECT p.category,c.province,SUM(s.quantity*s.unit_price) revenue
      FROM sales s JOIN customers c ON c.customer_id=s.customer_id
      JOIN products p ON p.product_id=s.product_id
      WHERE s.sale_date>=DATE '2025-01-01' AND s.sale_date<DATE '2025-02-01'
      GROUP BY p.category,c.province
     );
     v_elapsed := (DBMS_UTILITY.GET_TIME-v_start)*10;
     DBMS_OUTPUT.PUT_LINE('Pass='||pass||' Run='||i||' Variant=OPTIMIZED Time_ms='||v_elapsed||' Rows='||v_rows||' Revenue='||v_revenue);
    END IF;
   END LOOP;
  END LOOP;
 END LOOP;
END;
/
