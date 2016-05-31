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


CREATE OR REPLACE FUNCTION bmsql_proc_stock_level(
    IN in_w_id integer,
    IN in_d_id integer,
    IN in_threshold integer,
    OUT out_low_stock integer
) AS
$$
BEGIN
    SELECT INTO out_low_stock
	count(*) AS low_stock FROM (
	SELECT s_w_id, s_i_id, s_quantity
	FROM bmsql_stock
	WHERE s_w_id = in_w_id AND s_quantity < in_threshold AND s_i_id IN (
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
