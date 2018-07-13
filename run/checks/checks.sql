-- ----------------------------------------------------------------------
-- Test 1
--
-- All ORDER rows where O_CARRIER_ID is NULL must have a matching
-- row in NEW_ORDER.
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
	count(*) AS "count", 'Undelivered ORDERs not found in NEW_ORDER' AS "Description"
    FROM bmsql_oorder
    WHERE o_carrier_id IS NULL
    AND NOT EXISTS (
    	SELECT 1 FROM bmsql_new_order
	    WHERE no_w_id = o_w_id AND no_d_id = o_d_id AND no_o_id = o_id
    );

-- ----------------------------------------------------------------------
-- Test 2
--
-- All ORDER rows where O_CARRIER_ID is NOT NULL must not have a matching
-- row in NEW_ORDER.
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
	count(*) AS "count", 'Delivered ORDERs still found in NEW_ORDER' AS "Description"
    FROM bmsql_oorder
    WHERE o_carrier_id IS NOT NULL
    AND EXISTS (
    	SELECT 1 FROM bmsql_new_order
	    WHERE no_w_id = o_w_id AND no_d_id = o_d_id AND no_o_id = o_id
    );

-- ----------------------------------------------------------------------
-- Test 3
--
-- All NEW_ORDER rows must have a matching ORDER row.
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
	count(*) AS "count", 'Orphaned NEW_ORDER rows' AS "Description"
    FROM bmsql_new_order
    WHERE NOT EXISTS (
    	SELECT 1 FROM bmsql_oorder
	    WHERE no_w_id = o_w_id AND no_d_id = o_d_id AND no_o_id = o_id
    );

-- ----------------------------------------------------------------------
-- Test 4
--
-- ORDER_LINES must have a matching ORDER
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
	count(*) AS "count", 'Orphaned ORDER_LINE rows' AS "Description"
    FROM bmsql_order_line
    WHERE NOT EXISTS (
    	SELECT 1 FROM bmsql_oorder
	    WHERE ol_w_id = o_w_id AND ol_d_id = o_d_id AND ol_o_id = o_id
    );

-- ----------------------------------------------------------------------
-- Test 5
--
-- Check the ORDER.O_OL_CNT
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
	count(*) AS "count", 'ORDERs with wrong O_OL_CNT' AS "Description"
    FROM (
	SELECT o_w_id, o_d_id, o_id, o_ol_cnt, count(*) AS "actual"
	    FROM bmsql_oorder
	    LEFT JOIN bmsql_order_line ON ol_w_id = o_w_id AND ol_d_id = o_d_id
		    AND ol_o_id = o_id
	    GROUP BY o_w_id, o_d_id, o_id, o_ol_cnt
	    HAVING o_ol_cnt <> count(*)
	) AS X;

-- ----------------------------------------------------------------------
-- Test 6
--
-- The W_YTD must match the sum(D_YTD) for the 10 districts of the
-- Warehouse.
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
	count(*) AS "count", 'Warehouses where W_YTD <> sum(D_YTD)' AS "Description"
    FROM (
	SELECT w_id, w_ytd, sum(d_ytd) AS sum_d_ytd
	    FROM bmsql_warehouse
	    LEFT JOIN bmsql_district ON d_w_id = w_id
	    GROUP BY w_id, w_ytd
	    HAVING w_ytd <> sum(d_ytd)
	) AS X;

-- ----------------------------------------------------------------------
-- Test 7
--
-- The sum of all W_YTD must match the sum of all C_YTD_PAYMENT.
-- Because the PAYMENT can happen remote, we cannot match those
-- up by DISTRICT.
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
    CASE count(*) WHEN 0 THEN 'sum(w_ytd) = sum(c_ytd_payment)'
                  ELSE 'sum(w_ytd) <> sum(c_ytd_payment)' END AS "Description"
    FROM (
	SELECT sum_w_ytd, sum_c_ytd_payment
	    FROM (SELECT sum(w_ytd) AS sum_w_ytd FROM bmsql_warehouse) AS W,
	         (SELECT sum(c_ytd_payment) AS sum_c_ytd_payment FROM bmsql_customer) AS C
	    WHERE sum_w_ytd <> sum_c_ytd_payment
	) AS X;

-- ----------------------------------------------------------------------
-- Test 8
--
-- The C_BALANCE of a CUSTOMER must be equal to the sum(OL_AMOUNT) of
-- all delivered ORDER_LINES (where OL_DELIVERY_D IS NOT NULL) minus
-- the sum(H_AMOUNT).
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
	count(*) AS "count",
	'Customers where C_BALANCE <> sum(OL_AMOUNT) of undelivered orders minus sum(H_AMOUNT)' AS "Description"
    FROM (
	SELECT c_w_id, c_d_id, c_id, coalesce(sum_ol_amount, 0.0) AS sum_ol_amount,
	       coalesce(sum_h_amount, 0.0) AS sum_h_amount
	    FROM bmsql_customer
	    LEFT JOIN (
		SELECT o_w_id, o_d_id, o_c_id, sum(ol_amount) as sum_ol_amount
		    FROM bmsql_oorder
		    JOIN bmsql_order_line ON ol_w_id = o_w_id AND ol_d_id = o_d_id AND ol_o_id = o_id
		    WHERE o_carrier_id IS NOT NULL AND ol_delivery_d IS NOT NULL
		    GROUP BY o_w_id, o_d_id, o_c_id
	    ) AS OL ON o_w_id = c_w_id AND o_d_id = c_d_id AND o_c_id = c_id
	    LEFT JOIN (
	        SELECT h_c_w_id, h_c_d_id, h_c_id, sum(h_amount) AS sum_h_amount
		    FROM bmsql_history
		    GROUP BY h_c_w_id, h_c_d_id, h_c_id
	    ) AS H ON h_c_w_id = c_w_id AND h_c_d_id = c_d_id AND h_c_id = c_id
	    WHERE c_balance <> sum_ol_amount - sum_h_amount
	) AS X;

