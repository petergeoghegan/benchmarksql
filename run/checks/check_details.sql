-- ----------------------------------------------------------------------
-- Test 1
--
-- All ORDER rows where O_CARRIER_ID is NULL must have a matching
-- row in NEW_ORDER.
-- ----------------------------------------------------------------------
SELECT CASE count(*) WHEN 0 THEN 'OK   ' ELSE 'ERROR' END AS "check",
	count(*) AS "count", 'Undelivered ORDERs not found in NEW_ORDER' AS "Problem"
    FROM bmsql_oorder
    WHERE o_carrier_id IS NULL
    AND NOT EXISTS (
    	SELECT 1 FROM bmsql_new_order
	    WHERE no_w_id = o_w_id AND no_d_id = o_d_id AND no_o_id = o_id
    );

-- Detail information
SELECT 'Undelivered ORDER' AS "_", O_W_ID, O_D_ID, O_ID,
	'not found in NEW_ORDER' AS "__"
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
	count(*) AS "count", 'Delivered ORDERs still found in NEW_ORDER' AS "Problem"
    FROM bmsql_oorder
    WHERE o_carrier_id IS NOT NULL
    AND EXISTS (
    	SELECT 1 FROM bmsql_new_order
	    WHERE no_w_id = o_w_id AND no_d_id = o_d_id AND no_o_id = o_id
    );

-- Detail information
SELECT 'Delivered ORDER' AS "_", O_W_ID, O_D_ID, O_ID,
	'still found in NEW_ORDER' AS "__"
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
	count(*) AS "count", 'Orphaned NEW_ORDER rows' AS "Problem"
    FROM bmsql_new_order
    WHERE NOT EXISTS (
    	SELECT 1 FROM bmsql_oorder
	    WHERE no_w_id = o_w_id AND no_d_id = o_d_id AND no_o_id = o_id
    );

-- Detail information
SELECT 'Orphaned NEW_ORDER row' AS "_", no_w_id, no_d_id, no_o_id
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
	count(*) AS "count", 'Orphaned ORDER_LINE rows' AS "Problem"
    FROM bmsql_order_line
    WHERE NOT EXISTS (
    	SELECT 1 FROM bmsql_oorder
	    WHERE ol_w_id = o_w_id AND ol_d_id = o_d_id AND ol_o_id = o_id
    );

-- Detail information
SELECT 'Orphaned ORDER_LINE row' AS "_", ol_w_id, ol_d_id, ol_o_id
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
	count(*) AS "count", 'ORDERs with wrong O_OL_CNT' AS "Problem"
    FROM (
	SELECT o_w_id, o_d_id, o_id, o_ol_cnt, count(*) AS "actual"
	    FROM bmsql_oorder
	    LEFT JOIN bmsql_order_line ON ol_w_id = o_w_id AND ol_d_id = o_d_id
		    AND ol_o_id = o_id
	    GROUP BY o_w_id, o_d_id, o_id, o_ol_cnt
	    HAVING o_ol_cnt <> count(*)
	) AS X;

-- Detail information
SELECT 'Wrong O_OL_CNT' AS "Problem", o_w_id, o_d_id, o_id, o_ol_cnt, count(*) AS "actual"
    FROM bmsql_oorder
    LEFT JOIN bmsql_order_line ON ol_w_id = o_w_id AND ol_d_id = o_d_id
            AND ol_o_id = o_id
    GROUP BY "Problem", o_w_id, o_d_id, o_id, o_ol_cnt
    HAVING o_ol_cnt <> count(*);

