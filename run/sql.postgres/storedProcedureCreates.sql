CREATE OR REPLACE FUNCTION bmsql_cid_from_clast(
	in_c_w_id integer,
	in_c_d_id integer,
	in_c_last varchar(16))
RETURNS integer AS
$$
DECLARE
    cust_cursor CURSOR (
    		p_w_id integer, p_d_id integer, p_c_last varchar(16))
	FOR
    	SELECT c_id FROM bmsql_customer
	    WHERE c_w_id = p_w_id
	      AND c_d_id = p_d_id
	      AND c_last = p_c_last
	    ORDER BY c_first;
    num_cust integer;
    idx_cust integer;
    ret_c_id integer;
BEGIN
    -- Clause 2.5.2.2 Case 2, customer selected based on c_last.
    SELECT INTO num_cust count(*) 
    	FROM bmsql_customer
	WHERE c_w_id = in_c_w_id
	  AND c_d_id = in_c_d_id
	  AND c_last = in_c_last;
    IF num_cust = 0 THEN
        RAISE EXCEPTION 'Customer(s) for C_W_ID=% C_D_ID=% C_LAST=% not found',
		in_c_w_id, in_c_d_id, in_c_last;
    END IF;
    idx_cust = (num_cust + 1) / 2 - 1;

    OPEN cust_cursor(in_c_w_id, in_c_d_id, in_c_last);
    MOVE FORWARD idx_cust IN cust_cursor;
    FETCH FROM cust_cursor INTO ret_c_id;
    CLOSE cust_cursor;

    RETURN ret_c_id;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION bmsql_proc_new_order(
    IN in_w_id integer,
    IN in_d_id integer,
    IN in_c_id integer,
    IN in_ol_supply_w_id integer[],
    IN in_ol_i_id integer[],
    IN in_ol_quantity integer[],
    OUT out_w_tax decimal(4, 4),
    OUT out_d_tax decimal(4, 4),
    OUT out_o_id integer,
    OUT out_o_entry_d timestamp,
    OUT out_ol_cnt integer,
    OUT out_ol_amount decimal(12, 2)[],
    OUT out_total_amount decimal(12, 2),
    OUT out_c_last varchar(16),
    OUT out_c_credit char(2),
    OUT out_c_discount decimal(4, 4),
    OUT out_i_name varchar(24)[],
    OUT out_i_price decimal(5, 2)[],
    OUT out_s_quantity integer[],
    OUT out_brand_generic char[]
) AS
$$
DECLARE
    var_all_local integer := 1;
    var_x integer;
    var_y integer;
    var_tmp integer;
    var_seq integer[15];
    var_item_row record;
    var_stock_row record;
BEGIN
    -- The o_entry_d is now.
    out_o_entry_d := CURRENT_TIMESTAMP;
    out_total_amount := 0.00;

    -- When processing the order lines we must select the STOCK rows
    -- FOR UPDATE. This is because we must perform business logic
    -- (the juggling with the S_QUANTITY) here in the application
    -- and cannot do that in an atomic UPDATE statement while getting
    -- the original value back at the same time (UPDATE ... RETURNING
    -- may not be vendor neutral). This can lead to possible deadlocks
    -- if two transactions try to lock the same two stock rows in
    -- opposite order. To avoid that we process the order lines in
    -- the order of the order of ol_supply_w_id, ol_i_id.
    out_ol_cnt := 0;
    FOR var_x IN 1 .. array_length(in_ol_i_id, 1) LOOP
	IF in_ol_i_id[var_x] IS NOT NULL AND in_ol_i_id[var_x] <> 0 THEN
	    out_ol_cnt := out_ol_cnt + 1;
	    var_seq[var_x] = var_x;
	    IF in_ol_supply_w_id[var_x] <> in_w_id THEN
		var_all_local := 0;
	    END IF;
	END IF;
    END LOOP;
    FOR var_x IN 1 .. out_ol_cnt - 1 LOOP
	FOR var_y IN var_x + 1 .. out_ol_cnt LOOP
	    IF in_ol_supply_w_id[var_seq[var_y]] < in_ol_supply_w_id[var_seq[var_x]] THEN
	        var_tmp = var_seq[var_x];
		var_seq[var_x] = var_seq[var_y];
		var_seq[var_y] = var_tmp;
	    ELSE
	        IF in_ol_supply_w_id[var_seq[var_y]] = in_ol_supply_w_id[var_seq[var_x]]
		AND in_ol_i_id[var_seq[var_y]] < in_ol_i_id[var_seq[var_x]] THEN
		    var_tmp = var_seq[var_x];
		    var_seq[var_x] = var_seq[var_y];
		    var_seq[var_y] = var_tmp;
		END IF;
	    END IF;
	END LOOP;
    END LOOP;

    -- Retrieve the required data from DISTRICT
    SELECT INTO out_d_tax, out_o_id
    	d_tax, d_next_o_id
	FROM bmsql_district
	WHERE d_w_id = in_w_id AND d_id = in_d_id
	FOR UPDATE;

    -- Retrieve the required data from CUSTOMER and WAREHOUSE
    SELECT INTO out_w_tax, out_c_last, out_c_credit, out_c_discount
        w_tax, c_last, c_credit, c_discount
	FROM bmsql_customer
	JOIN bmsql_warehouse ON (w_id = c_w_id)
	WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_id = in_c_id;

    -- Update the DISTRICT bumping the D_NEXT_O_ID
    UPDATE bmsql_district
        SET d_next_o_id = d_next_o_id + 1
	WHERE d_w_id = in_w_id AND d_id = in_d_id;

    -- Insert the ORDER row
    INSERT INTO bmsql_oorder (
        o_id, o_d_id, o_w_id, o_c_id, o_entry_d,
	o_ol_cnt, o_all_local)
    VALUES (
        out_o_id, in_d_id, in_w_id, in_c_id, out_o_entry_d,
	out_ol_cnt, var_all_local);

    -- Insert the NEW_ORDER row
    INSERT INTO bmsql_new_order (
        no_o_id, no_d_id, no_w_id)
    VALUES (
        out_o_id, in_d_id, in_w_id);

    -- Per ORDER_LINE
    FOR var_x IN 1 .. out_ol_cnt LOOP
	-- We process the lines in the sequence orderd by warehouse, item.
	var_y = var_seq[var_x];
	SELECT INTO var_item_row
		i_name, i_price, i_data
	    FROM bmsql_item
	    WHERE i_id = in_ol_i_id[var_y];
        IF NOT FOUND THEN
	    RAISE EXCEPTION 'Item number is not valid';
	END IF;
	-- Found ITEM
	out_i_name[var_y] = var_item_row.i_name;
	out_i_price[var_y] = var_item_row.i_price;

        SELECT INTO var_stock_row
	        s_quantity, s_data,
		s_dist_01, s_dist_02, s_dist_03, s_dist_04, s_dist_05,
		s_dist_06, s_dist_07, s_dist_08, s_dist_09, s_dist_10
	    FROM bmsql_stock
	    WHERE s_w_id = in_ol_supply_w_id[var_y]
	    AND s_i_id = in_ol_i_id[var_y]
	    FOR UPDATE;
        IF NOT FOUND THEN
	    RAISE EXCEPTION 'STOCK not found: %,%', in_ol_supply_w_id[var_y],
	    	in_ol_i_id[var_y];
	END IF;

	out_s_quantity[var_y] = var_stock_row.s_quantity;
	out_ol_amount[var_y] = out_i_price[var_y] * in_ol_quantity[var_y];
	IF var_item_row.i_data LIKE '%ORIGINAL%'
	AND var_stock_row.s_data LIKE '%ORIGINAL%' THEN
	    out_brand_generic[var_y] := 'B';
	ELSE
	    out_brand_generic[var_y] := 'G';
	END IF;
	out_total_amount = out_total_amount +
		out_ol_amount[var_y] * (1.0 - out_c_discount)
		* (1.0 + out_w_tax + out_d_tax);

	-- Update the STOCK row.
	UPDATE bmsql_stock SET
	    	s_quantity = CASE
		WHEN var_stock_row.s_quantity >= in_ol_quantity[var_y] + 10 THEN
		    var_stock_row.s_quantity - in_ol_quantity[var_y]
		ELSE
		    var_stock_row.s_quantity + 91
		END,
		s_ytd = s_ytd + in_ol_quantity[var_y],
		s_order_cnt = s_order_cnt + 1,
		s_remote_cnt = s_remote_cnt + CASE
		WHEN in_w_id <> in_ol_supply_w_id[var_y] THEN
		    1
		ELSE
		    0
		END
	    WHERE s_w_id = in_ol_supply_w_id[var_y]
	    AND s_i_id = in_ol_i_id[var_y];

	-- Insert the ORDER_LINE row.
	INSERT INTO bmsql_order_line (
	    ol_o_id, ol_d_id, ol_w_id, ol_number,
	    ol_i_id, ol_supply_w_id, ol_quantity,
	    ol_amount, ol_dist_info)
	VALUES (
	    out_o_id, in_d_id, in_w_id, var_y,
	    in_ol_i_id[var_y], in_ol_supply_w_id[var_y], in_ol_quantity[var_y],
	    out_ol_amount[var_y],
	    CASE
		WHEN in_d_id = 1 THEN var_stock_row.s_dist_01
		WHEN in_d_id = 2 THEN var_stock_row.s_dist_02
		WHEN in_d_id = 3 THEN var_stock_row.s_dist_03
		WHEN in_d_id = 4 THEN var_stock_row.s_dist_04
		WHEN in_d_id = 5 THEN var_stock_row.s_dist_05
		WHEN in_d_id = 6 THEN var_stock_row.s_dist_06
		WHEN in_d_id = 7 THEN var_stock_row.s_dist_07
		WHEN in_d_id = 8 THEN var_stock_row.s_dist_08
		WHEN in_d_id = 9 THEN var_stock_row.s_dist_09
		WHEN in_d_id = 10 THEN var_stock_row.s_dist_10
	    END);

    END LOOP;

    RETURN;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION bmsql_proc_payment(
	IN in_w_id integer,
	IN in_d_id integer,
	INOUT in_c_id integer,
	IN in_c_d_id integer,
	IN in_c_w_id integer,
	IN in_c_last varchar(16),
	IN in_h_amount decimal(6,2),
	OUT out_w_name varchar(10),
	OUT out_w_street_1 varchar(20),
	OUT out_w_street_2 varchar(20),
	OUT out_w_city varchar(20),
	OUT out_w_state char(2),
	OUT out_w_zip char(9),
	OUT out_d_name varchar(10),
	OUT out_d_street_1 varchar(20),
	OUT out_d_street_2 varchar(20),
	OUT out_d_city varchar(20),
	OUT out_d_state char(2),
	OUT out_d_zip char(9),
	OUT out_c_first varchar(16),
	OUT out_c_middle char(2),
	OUT out_c_street_1 varchar(20),
	OUT out_c_street_2 varchar(20),
	OUT out_c_city varchar(20),
	OUT out_c_state char(2),
	OUT out_c_zip char(9),
	OUT out_c_phone char(16),
	OUT out_c_since timestamp,
	OUT out_c_credit char(2),
	OUT out_c_credit_lim decimal(12,2),
	OUT out_c_discount decimal(4,4),
	OUT out_c_balance decimal(12,2),
	OUT out_c_data varchar(500),
	OUT out_h_date timestamp
) AS
$$
BEGIN
	out_h_date := CURRENT_TIMESTAMP;

	--Update the DISTRICT
	UPDATE bmsql_district
		SET d_ytd = d_ytd + in_h_amount
		WHERE d_w_id = in_w_id AND d_id = in_d_id;

	--Select the DISTRICT
	SELECT INTO out_d_name, out_d_street_1, out_d_street_2, 
		    out_d_city, out_d_state, out_d_zip
		d_name, d_street_1, d_street_2, d_city, d_state, d_zip
	    FROM bmsql_district
	    WHERE d_w_id = in_w_id AND d_id = in_d_id
	    FOR UPDATE;

	--Update the WAREHOUSE
	UPDATE bmsql_warehouse
	    SET w_ytd = w_ytd + in_h_amount
	    WHERE w_id = in_w_id;

	--Select the WAREHOUSE
	SELECT INTO out_w_name, out_w_street_1, out_w_street_2,
		    out_w_city, out_w_state, out_w_zip
		w_name, w_street_1, w_street_2, w_city, w_state, w_zip
	    FROM bmsql_warehouse
	    WHERE w_id = in_w_id
	    FOR UPDATE;

	--If C_Last is given instead of C_ID (60%), determine the C_ID.
	IF in_c_last IS NOT NULL THEN
	    in_c_id = bmsql_cid_from_clast(in_c_w_id, in_c_d_id, in_c_last);
	END IF;

	--Select the CUSTOMER
	SELECT INTO out_c_first, out_c_middle, in_c_last, out_c_street_1,
		    out_c_street_2, out_c_city, out_c_state, out_c_zip,
		    out_c_phone, out_c_since, out_c_credit, out_c_credit_lim,
		    out_c_discount, out_c_balance
		c_first, c_middle, c_last, c_street_1,
		c_street_2, c_city, c_state, c_zip,
		c_phone, c_since, c_credit, c_credit_lim,
		c_discount, c_balance
	    FROM bmsql_customer
	    WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = in_c_id
	    FOR UPDATE;

	--Update the CUSTOMER
	out_c_balance = out_c_balance-in_h_amount;
	IF out_c_credit = 'GC' THEN
	    --Customer with good credit, don't update C_DATA
	    UPDATE bmsql_customer
		SET c_balance = c_balance - in_h_amount,
		    c_ytd_payment = c_ytd_payment + in_h_amount,
		    c_payment_cnt = c_payment_cnt + 1
		WHERE c_w_id = in_c_w_id AND c_d_id=in_c_d_id AND c_id=in_c_id;
	    out_c_data := '';
	ELSE
	--Customer with bad credit, need to do the C_DATA work.
	    SELECT INTO out_c_data
		    c_data
		FROM bmsql_customer
		WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id
		  AND c_id = in_c_id;
	    out_c_data := substring('C_ID=' || in_c_id::text ||
				    ' C_D_ID=' || in_c_d_id::text ||
				    ' C_W_ID=' || in_c_w_id::text ||
				    ' D_ID=' || in_d_id::text ||
				    ' W_ID=' || in_w_id::text ||
				    ' H_AMOUNT=' || round(in_h_amount,2)::text || '   ' ||
				    out_c_data from 1 for 500);

	    UPDATE bmsql_customer
		SET c_balance = c_balance - in_h_amount,
		    c_ytd_payment = c_ytd_payment + in_h_amount,
		    c_payment_cnt = c_payment_cnt + 1,
		    c_data = out_c_data
		WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id
		  AND c_id = in_c_id;
	END IF;

	--Insert the HISTORY row
	INSERT INTO bmsql_history (
		    h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id,
		    h_date, h_amount, h_data)
	VALUES (
		    in_c_id, in_c_d_id, in_c_w_id, in_d_id, in_w_id,
		    out_h_date, in_h_amount, out_w_name||'    '|| out_d_name
	);
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION bmsql_proc_order_status(
    IN in_w_id integer,
    IN in_d_id integer,
    INOUT in_c_id integer,
    IN in_c_last varchar(16),
    OUT out_c_first varchar(16),
    OUT out_c_middle char(2),
    OUT out_c_balance decimal(12,2),
    OUT out_o_id integer,
    OUT out_o_entry_d varchar(24),
    OUT out_o_carrier_id integer,
    OUT out_ol_supply_w_id integer[],
    OUT out_ol_i_id integer[],
    OUT out_ol_quantity integer[],
    OUT out_ol_amount decimal(12,2)[],
    OUT out_ol_delivery_d timestamp[]
) AS
$$
DECLARE
	v_order_line	record;
	v_ol_idx		integer := 1;
BEGIN
    --If C_LAST is given instead of C_ID (60%), determine the C_ID.
    IF in_c_last IS NOT NULL THEN
		in_c_id = bmsql_cid_from_clast(in_w_id, in_d_id, in_c_last);
    END IF;

    --Select the CUSTOMER
    SELECT INTO out_c_first, out_c_middle, in_c_last, out_c_balance
			c_first, c_middle, c_last, c_balance
		FROM bmsql_customer
		WHERE c_w_id=in_w_id AND c_d_id=in_d_id AND c_id = in_c_id;

    --Select the last ORDER for this customer.
    SELECT INTO out_o_id, out_o_entry_d, out_o_carrier_id
			o_id, o_entry_d, coalesce(o_carrier_id, -1)
		FROM bmsql_oorder
		WHERE o_w_id = in_w_id AND o_d_id = in_d_id AND o_c_id = in_c_id
		AND o_id = (
			SELECT max(o_id)
				FROM bmsql_oorder
				WHERE o_w_id = in_w_id AND o_d_id = in_d_id AND o_c_id = in_c_id
			);

	FOR v_order_line IN SELECT ol_i_id, ol_supply_w_id, ol_quantity,
				ol_amount, ol_delivery_d
			FROM bmsql_order_line
			WHERE ol_w_id = in_w_id AND ol_d_id = in_d_id AND ol_o_id = out_o_id
			ORDER BY ol_w_id, ol_d_id, ol_o_id, ol_number
			LOOP
	    out_ol_i_id[v_ol_idx] = v_order_line.ol_i_id;
	    out_ol_supply_w_id[v_ol_idx] = v_order_line.ol_supply_w_id;
	    out_ol_quantity[v_ol_idx] = v_order_line.ol_quantity;
	    out_ol_amount[v_ol_idx] = v_order_line.ol_amount;
	    out_ol_delivery_d[v_ol_idx] = v_order_line.ol_delivery_d;
		v_ol_idx = v_ol_idx + 1;
	END LOOP;

    WHILE v_ol_idx < 16 LOOP
		out_ol_i_id[v_ol_idx] = 0;
		out_ol_supply_w_id[v_ol_idx] = 0;
		out_ol_quantity[v_ol_idx] = 0;
		out_ol_amount[v_ol_idx] = 0.0;
		out_ol_delivery_d[v_ol_idx] = NULL;
		v_ol_idx = v_ol_idx +1;
    END LOOP;
END;
$$
Language plpgsql;


CREATE OR REPLACE FUNCTION bmsql_proc_stock_level(
    IN in_w_id integer,
    IN in_d_id integer,
    IN in_threshold integer,
    OUT out_low_stock integer
) AS
$$
BEGIN
    SELECT INTO out_low_stock
			count(*) AS low_stock
		FROM (
			SELECT s_w_id, s_i_id, s_quantity
			FROM bmsql_stock
			WHERE s_w_id = in_w_id AND s_quantity < in_threshold
			  AND s_i_id IN (
				SELECT ol_i_id
					FROM bmsql_district
					JOIN bmsql_order_line ON ol_w_id = d_w_id
					 AND ol_d_id = d_id
					 AND ol_o_id >= d_next_o_id - 20
					 AND ol_o_id < d_next_o_id
					WHERE d_w_id = in_w_id AND d_id = in_d_id
				)
			) AS L;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION bmsql_proc_delivery_bg(
	IN in_w_id integer,
	IN in_o_carrier_id integer,
	IN in_ol_delivery_d timestamp,
	OUT out_delivered_o_id integer[]
) AS
$$
DECLARE
	var_d_id integer;
	var_o_id integer;
	var_c_id integer;
	var_sum_ol_amount decimal(12, 2);
BEGIN
	FOR var_d_id IN 1..10 LOOP
		var_o_id = -1;
		/*
		 * Try to find the oldest undelivered order for this
		 * DISTRICT. There may not be one, which is a case
		 * that needs to be reported.
		*/
		WHILE var_o_id < 0 LOOP
			SELECT INTO var_o_id
					no_o_id
				FROM bmsql_new_order
			WHERE no_w_id = in_w_id AND no_d_id = var_d_id
			ORDER BY no_o_id ASC;
			IF NOT FOUND THEN
			    var_o_id = -1;
				EXIT;
			END IF;

			DELETE FROM bmsql_new_order
				WHERE no_w_id = in_w_id AND no_d_id = var_d_id
				  AND no_o_id = var_o_id;
			IF NOT FOUND THEN
			    var_o_id = -1;
			END IF;
		END LOOP;

		IF var_o_id < 0 THEN
			-- No undelivered NEW_ORDER found for this District.
			var_d_id = var_d_id + 1;
			CONTINUE;
		END IF;

		/*
		 * We found out oldert undelivered order for this DISTRICT
		 * and the NEW_ORDER line has been deleted. Process the
		 * rest of the DELIVERY_BG.
		*/

		-- Update the ORDER setting the o_carrier_id.
		UPDATE bmsql_oorder
			SET o_carrier_id = in_o_carrier_id
			WHERE o_w_id = in_w_id AND o_d_id = var_d_id AND o_id = var_o_id;

		-- Get the o_c_id from the ORDER.
		SELECT INTO var_c_id
				o_c_id
			FROM bmsql_oorder
			WHERE o_w_id = in_w_id AND o_d_id = var_d_id AND o_id = var_o_id;

		-- Update ORDER_LINE setting the ol_delivery_d.
		UPDATE bmsql_order_line
			SET ol_delivery_d = in_ol_delivery_d
			WHERE ol_w_id = in_w_id AND ol_d_id = var_d_id
			  AND ol_o_id = var_o_id;

		-- SELECT the sum(ol_amount) from ORDER_LINE.
		SELECT INTO var_sum_ol_amount
				sum(ol_amount) AS sum_ol_amount
			FROM bmsql_order_line
			WHERE ol_w_id = in_w_id AND ol_d_id = var_d_id
			  AND ol_o_id = var_o_id;

		-- Update the CUSTOMER.
		UPDATE bmsql_customer
			SET c_balance = c_balance + var_sum_ol_amount,
				c_delivery_cnt = c_delivery_cnt + 1
			WHERE c_w_id = in_w_id AND c_d_id = var_d_id and c_id = var_c_id;

		out_delivered_o_id[var_d_id] = var_o_id;

		var_d_id = var_d_id +1 ;
	END LOOP;
END;
$$
LANGUAGE plpgsql;
