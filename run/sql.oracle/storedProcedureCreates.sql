-- {
CREATE OR REPLACE PACKAGE tpccc_oracle AS

    TYPE varchar50_array IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;

    TYPE rowidarray IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

    TYPE rec1 IS RECORD(
	name varchar2(24),
        price number,
	data varchar2(50)
    );

    TYPE rec2 IS RECORD(
	quantity integer,
        s_data varchar2(50),
	s_dist1 varchar2(24),
	s_dist2 varchar2(24),
	s_dist3 varchar2(24),
	s_dist4 varchar2(24),
	s_dist5 varchar2(24),
	s_dist6 varchar2(24),
	s_dist7 varchar2(24),
	s_dist8 varchar2(24),
	s_dist9 varchar2(24),
	s_dist10 varchar2(24)
    );

    TYPE rec3 IS RECORD(
	ol_i_id integer,
	ol_supply_w_id integer,
	ol_quantity integer,
	ol_amount number,
	ol_delivery_d timestamp
    );

    FUNCTION oracle_rowid_from_clast(
	in_c_w_id IN integer,
	in_c_d_id IN integer,
	in_c_last IN varchar
    ) RETURN ROWID;

    PROCEDURE oracle_proc_stock_level(
        in_w_id IN integer,
	in_d_id IN integer,
        in_threshold IN integer,
        out_low_stock OUT integer
    );

    PROCEDURE oracle_proc_new_order(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN integer,
        in_ol_supply_w_id IN int_array,
	in_ol_i_id IN int_array,
        in_ol_quantity IN int_array,
	out_ol_amount OUT num_array,
        out_i_name OUT varchar24_array,
	out_i_price OUT num_array,
        out_s_quantity OUT int_array,
	out_brand_generic OUT char_array,
        out_w_tax OUT number,
	out_d_tax OUT number,
        out_o_id OUT integer,
	out_o_entry_d OUT timestamp,
        out_ol_cnt OUT integer,
	out_total_amount OUT number,
        out_c_last OUT varchar2,
	out_c_credit OUT varchar2,
        out_c_discount OUT number
    );

    PROCEDURE oracle_proc_delivery_bg(
	in_w_id IN integer,
        in_o_carrier_id IN integer,
	in_ol_delivery_d IN timestamp,
        out_delivered_o_id OUT int_array
    );

    PROCEDURE oracle_proc_payment_clast(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN OUT integer,
        in_c_d_id IN integer,
	in_c_w_id IN integer,
        in_c_last IN OUT varchar2,
	in_h_amount IN number,
        out_w_name OUT varchar2,
	out_w_street_1 OUT varchar2,
        out_w_street_2 OUT varchar2,
	out_w_city OUT varchar2,
        out_w_state OUT varchar2,
	out_w_zip OUT varchar2,
        out_d_name OUT varchar2,
	out_d_street_1 OUT varchar2,
        out_d_street_2 OUT varchar2,
	out_d_city OUT varchar2,
        out_d_state OUT varchar2,
	out_d_zip OUT varchar2,
        out_c_first OUT varchar2,
	out_c_middle OUT varchar2,
        out_c_street_1 OUT varchar2,
	out_c_street_2 OUT varchar2,
        out_c_city OUT varchar2,
	out_c_state OUT varchar2,
        out_c_zip OUT varchar2,
	out_c_phone OUT varchar2,
	out_c_since OUT timestamp,
        out_c_credit OUT varchar2,
	out_c_credit_lim OUT number,
        out_c_discount OUT number,
	out_c_balance OUT number,
        out_c_data OUT varchar2,
	out_h_date OUT timestamp
    );

    PROCEDURE oracle_proc_payment_cid(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN OUT integer,
        in_c_d_id IN integer,
	in_c_w_id IN integer,
        in_c_last IN OUT varchar2,
	in_h_amount IN number,
        out_w_name OUT varchar2,
	out_w_street_1 OUT varchar2,
        out_w_street_2 OUT varchar2,
	out_w_city OUT varchar2,
        out_w_state OUT varchar2,
	out_w_zip OUT varchar2,
        out_d_name OUT varchar2,
	out_d_street_1 OUT varchar2,
        out_d_street_2 OUT varchar2,
	out_d_city OUT varchar2,
        out_d_state OUT varchar2,
	out_d_zip OUT varchar2,
        out_c_first OUT varchar2,
	out_c_middle OUT varchar2,
        out_c_street_1 OUT varchar2,
	out_c_street_2 OUT varchar2,
        out_c_city OUT varchar2,
	out_c_state OUT varchar2,
        out_c_zip OUT varchar2,
	out_c_phone OUT varchar2,
        out_c_since OUT timestamp,
	out_c_credit OUT varchar2,
	out_c_credit_lim OUT number,
        out_c_discount OUT number,
	out_c_balance OUT number,
        out_c_data OUT varchar2,
	out_h_date OUT timestamp
    );

    PROCEDURE oracle_proc_payment(
        in_w_id IN integer,
	in_d_id IN integer,
        in_c_id IN OUT integer,
	in_c_d_id IN integer,
        in_c_w_id IN integer,
	in_c_last IN OUT varchar2,
        in_h_amount IN number,
	out_w_name OUT varchar2,
        out_w_street_1 OUT varchar2,
	out_w_street_2 OUT varchar2,
        out_w_city OUT varchar2,
	out_w_state OUT varchar2,
        out_w_zip OUT varchar2,
	out_d_name OUT varchar2,
        out_d_street_1 OUT varchar2,
	out_d_street_2 OUT varchar2,
        out_d_city OUT varchar2,
	out_d_state OUT varchar2,
        out_d_zip OUT varchar2,
	out_c_first OUT varchar2,
        out_c_middle OUT varchar2,
	out_c_street_1 OUT varchar2,
        out_c_street_2 OUT varchar2,
	out_c_city OUT varchar2,
        out_c_state OUT varchar2,
	out_c_zip OUT varchar2,
        out_c_phone OUT varchar2,
	out_c_since OUT timestamp,
        out_c_credit OUT varchar2,
	out_c_credit_lim OUT number,
        out_c_discount OUT number,
	out_c_balance OUT number,
        out_c_data OUT varchar2,
	out_h_date OUT timestamp
    );

    PROCEDURE oracle_proc_order_status(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN OUT integer,
        in_c_last IN OUT varchar2,
	out_c_first OUT varchar2,
        out_c_middle OUT varchar2,
	out_c_balance OUT number,
        out_o_id OUT integer,
	out_o_entry_d OUT timestamp,
        out_o_carrier_id OUT integer,
	out_ol_supply_w_id OUT int_array,
        out_ol_i_id OUT int_array,
	out_ol_quantity OUT int_array,
        out_ol_amount OUT num_array,
	out_ol_delivery_d OUT varchar16_array
    );

END tpccc_oracle;
-- }

-- {
CREATE OR REPLACE PACKAGE BODY tpccc_oracle AS

    FUNCTION oracle_rowid_from_clast(
        in_c_w_id IN integer,
	in_c_d_id IN integer,
        in_c_last IN varchar
    ) RETURN ROWID AS
	rowArr rowidarray;
        rowNumber rowid;
	rowCnt integer;
        customer integer;
    BEGIN
	-- Clause 2.5.2.2 Case 2, customer selected based on c_last.
	SELECT rowid
            BULK COLLECT INTO rowARR
	FROM bmsql_customer
        WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_last = in_c_last
	ORDER BY c_first;

	rowCnt := SQL%ROWCOUNT;
        rowNumber := rowArr((rowCnt + 1 )/ 2);

	RETURN rowNumber;
    END;

    PROCEDURE oracle_proc_stock_level(
        in_w_id IN integer,
	in_d_id IN integer,
        in_threshold IN integer,
	out_low_stock OUT integer
    ) AS
    BEGIN
	--Selects and counts the number of recently sold items that have
        --a stock level below the specified threshold.
	SELECT count(*)
        INTO out_low_stock
	    FROM(
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
	        );
    END;

    PROCEDURE oracle_proc_new_order(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN integer,
        in_ol_supply_w_id IN int_array,
	in_ol_i_id IN int_array,
        in_ol_quantity IN int_array,
	out_ol_amount OUT num_array,
        out_i_name OUT varchar24_array,
	out_i_price OUT num_array,
        out_s_quantity OUT int_array,
	out_brand_generic OUT char_array,
        out_w_tax OUT number,
	out_d_tax OUT number,
        out_o_id OUT integer,
	out_o_entry_d OUT timestamp,
        out_ol_cnt OUT integer,
	out_total_amount OUT number,
        out_c_last OUT varchar2,
	out_c_credit OUT varchar2,
        out_c_discount OUT number
    ) AS
	var_all_local integer := 1;
        var_x integer;
	var_y integer;
        var_tmp integer;
	var_seq int_array := int_array();
        var_item_row rec1;
	var_stock_row rec2;
        CURSOR item_cursor IS
	    SELECT i_name, i_price, i_data
	        FROM bmsql_item
		WHERE i_id = in_ol_i_id(var_y);
	CURSOR stock_cursor IS
            SELECT s_quantity, s_data, s_dist_01, s_dist_02,
	           s_dist_03, s_dist_04, s_dist_05, s_dist_06,
		   s_dist_07, s_dist_08, s_dist_09, s_dist_10
                FROM bmsql_stock
	        WHERE s_w_id = in_ol_supply_w_id(var_y)
	          AND s_i_id = in_ol_i_id(var_y)
		FOR UPDATE;
	item_not_found Exception;
        stock_not_found Exception;
	PRAGMA EXCEPTION_INIT (item_not_found, -20001);
	PRAGMA EXCEPTION_INIT (stock_not_found, -20002);
    BEGIN
	out_brand_generic := char_array();
	out_s_quantity := int_array();
	out_i_price := num_array();
	out_i_name := varchar24_array();
	out_ol_amount := num_array();
	-- The o_entry_d is now.
        out_o_entry_d := CURRENT_TIMESTAMP;
	out_total_amount := 0.00;

        -- When processing the order lines we must select the STOCK rows
	-- FOR UPDATE. This is because we must perform business logic
        -- (the juggling with the S_QUANTITY) here in the application
	-- and cannot do that in an atomic UPDATE statement while getting
        -- the original value back at the same time (UPDATE ... RETURNING
	-- may not vendor neutral). This can lead to possible deadlocks
        -- if two transactions try to lock the same two stock rows in
	-- opposite order. To avoid that we process the order lines in
        -- the order of the order of ol_supply_w_id, ol_i_id.
	out_ol_cnt := 0;

        FOR var_x IN 1 .. in_ol_i_id.COUNT LOOP
	    IF in_ol_i_id(var_x) IS NOT NULL AND in_ol_i_id(var_x) <> 0 THEN
		var_seq.EXTEND;
                out_ol_cnt := out_ol_cnt + 1;
	        var_seq(var_x) := var_x;
	        IF in_ol_supply_w_id(var_x) <> in_w_id THEN
		    var_all_local := 0;
                END IF;
	    END IF;
        END LOOP;

	FOR var_x IN 1 .. out_ol_cnt - 1 LOOP
	    FOR var_y IN var_x + 1 .. out_ol_cnt LOOP
                IF in_ol_supply_w_id(var_seq(var_y)) < in_ol_supply_w_id(var_seq(var_x)) THEN
	            var_tmp := var_seq(var_x);
	            var_seq(var_x) := var_seq(var_y);
		    var_seq(var_y) := var_tmp;
                ELSE
	            IF in_ol_supply_w_id(var_seq(var_y)) = in_ol_supply_w_id(var_seq(var_x))
		     AND in_ol_i_id(var_seq(var_y)) < in_ol_i_id(var_seq(var_x)) THEN
		        var_tmp := var_seq(var_x);
                        var_seq(var_x) := var_seq(var_y);
                        var_seq(var_y) := var_tmp;
		    END IF;
		END IF;
	    END LOOP;
	END LOOP;

        -- Retrieve the required data from DISTRICT
	SELECT d_tax, d_next_o_id
        INTO out_d_tax, out_o_id
	    FROM bmsql_district
	    WHERE d_w_id = in_w_id AND d_id = in_d_id
            FOR UPDATE;

	-- Retrieve the required data for CUSTOMER and WAREHOUSE
        SELECT w_tax, c_last, c_credit, c_discount
	INTO out_w_tax, out_c_last, out_c_credit, out_c_discount
	    FROM bmsql_customer
            JOIN bmsql_warehouse ON (w_id = c_w_id)
            WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_id = in_c_id;

	-- Update the district bumping the D_NEXT_O_ID
	UPDATE bmsql_district
	    SET d_next_o_id = d_next_o_id + 1
        WHERE d_w_id = in_w_id AND d_id = in_d_id;

	-- Insert the ORDER row
        INSERT INTO bmsql_oorder (
	        o_id, o_d_id, o_w_id, o_c_id,
	        o_entry_d, o_ol_cnt, o_all_local)
	VALUES (
	        out_o_id, in_d_id, in_w_id, in_c_id,
		out_o_entry_d, out_ol_cnt, var_all_local);

        -- Insert the NEW_ORER row
	INSERT INTO bmsql_new_order (
                no_o_id, no_d_id, no_w_id)
	VALUES (
	        out_o_id, in_d_id, in_w_id);

        -- Per ORDER_LINE
	FOR var_x in 1 .. out_ol_cnt LOOP
	    -- We process the lines in the sequence ordered by warehouse, item.
            var_y := var_seq(var_x);

	    out_i_name.EXTEND(var_y);
	    out_i_price.EXTEND(var_y);
	    out_s_quantity.EXTEND(var_y);
	    out_ol_amount.EXTEND(var_y);
	    out_brand_generic.EXTEND(var_y);

	    OPEN item_cursor;
	    FETCH item_cursor INTO var_item_row;
	    IF item_cursor%NOTFOUND THEN
		RAISE item_not_found;
	    END IF;
	    CLOSE item_cursor;

	    -- Found ITEM
            out_i_name(var_y) := var_item_row.name;
	    out_i_price(var_y) := var_item_row.price;

	    OPEN stock_cursor;
            FETCH stock_cursor INTO var_stock_row;
	    IF stock_cursor%NOTFOUND THEN
	        RAISE stock_not_found;
            END IF;
	    CLOSE stock_cursor;

	    out_s_quantity(var_y) := var_stock_row.quantity;
            out_ol_amount(var_y) := out_i_price(var_y) * in_ol_quantity(var_y);
            IF var_item_row.data LIKE '%ORIGINAL%'
	      AND var_stock_row.s_data LIKE '%ORIGINAL%' THEN
	        out_brand_generic(var_y) := 'B';
	    ELSE
		out_brand_generic(var_y) := 'G';
	    END IF;
            out_total_amount := out_total_amount + out_ol_amount(var_y) * (1.0 - out_c_discount) * (1.0 + out_w_tax + out_d_tax);

	    -- Update the STOCK row.
	    UPDATE bmsql_stock SET
                s_quantity = CASE
		    WHEN var_stock_row.quantity >= in_ol_quantity(var_y) + 10 THEN
	                var_stock_row.quantity - in_ol_quantity(var_y)
	            ELSE
		        var_stock_row.quantity + 91
		    END,
                s_ytd = s_ytd + in_ol_quantity(var_y),
                s_order_cnt = s_order_cnt + 1,
                s_remote_cnt = s_remote_cnt + CASE
		    WHEN in_w_id <> in_ol_supply_w_id(var_y) THEN
			1
		    ELSE
			0
		    END
		WHERE s_w_id = in_ol_supply_w_id(var_y)
                  AND s_i_id = in_ol_i_id(var_y);

	    --Insert the ORDER_LINE row.
	    INSERT INTO bmsql_order_line (
		    ol_o_id, ol_d_id, ol_w_id, ol_number,
		    ol_i_id, ol_supply_w_id, ol_quantity,
		    ol_amount, ol_dist_info)
	    VALUES (
		    out_o_id, in_d_id, in_w_id, var_y,
                    in_ol_i_id(var_y), in_ol_supply_w_id(var_y),
                    in_ol_quantity(var_y), out_ol_amount(var_y),
	            CASE
	                WHEN in_d_id = 1 THEN var_stock_row.s_dist1
		        WHEN in_d_id = 2 THEN var_stock_row.s_dist2
		        WHEN in_d_id = 3 THEN var_stock_row.s_dist3
			WHEN in_d_id = 4 THEN var_stock_row.s_dist4
                        WHEN in_d_id = 5 THEN var_stock_row.s_dist5
	                WHEN in_d_id = 6 THEN var_stock_row.s_dist6
	                WHEN in_d_id = 7 THEN var_stock_row.s_dist7
		        WHEN in_d_id = 8 THEN var_stock_row.s_dist8
		        WHEN in_d_id = 9 THEN var_stock_row.s_dist9
			WHEN in_d_id = 10 THEN var_stock_row.s_dist10
                    END
	        );
	END LOOP;
    EXCEPTION
	WHEN item_not_found THEN
	    RAISE_APPLICATION_ERROR(-20001, 'Item number is not valid');
	WHEN stock_not_found THEN
	    RAISE_APPLICATION_ERROR(-20002, 'STOCK not found');
    END;

    PROCEDURE oracle_proc_delivery_bg(
	in_w_id IN integer,
        in_o_carrier_id IN integer,
	in_ol_delivery_d IN timestamp,
        out_delivered_o_id OUT int_array
    ) AS
	sums num_array;
        var_d_id int_array;
	var_o_c_id int_array;
        var_dist int_array;
	var_x integer;
        order_count integer;
    BEGIN
	var_dist := int_array();
        FOR var_x IN 1..10 LOOP
	    var_dist.EXTEND;
	    var_dist(var_x) := var_x;
        END LOOP;

	FORALL i in 1..10
	    DELETE FROM bmsql_new_order N
            WHERE no_d_id = var_dist(i)
	      AND no_w_id = in_w_id
	      AND no_o_id = (SELECT min(no_o_id)
		                FROM bmsql_new_order
		             WHERE no_d_id = N.no_d_id
			       AND no_w_id = N.no_w_id)
            RETURNING no_d_id, no_o_id
	    BULK COLLECT INTO var_d_id, out_delivered_o_id;

        order_count := SQL%ROWCOUNT;

	FORALL i IN 1..order_count
	    UPDATE bmsql_oorder
		SET o_carrier_id = in_o_carrier_id
	    WHERE o_id = out_delivered_o_id(i)
	      AND o_d_id = var_d_id(i)
	      AND o_w_id = in_w_id
	    RETURNING o_c_id
	    BULK COLLECT INTO var_o_c_id;

        FORALL i IN 1..order_count
	    UPDATE bmsql_order_line
	        SET ol_delivery_d = CURRENT_TIMESTAMP
            WHERE ol_w_id = in_w_id
	      AND ol_d_id = var_d_id(i)
	      AND ol_o_id = out_delivered_o_id(i)
            RETURNING sum(ol_amount)
	    BULK COLLECT INTO sums;

        FORALL i IN 1..order_count
	    UPDATE bmsql_customer
	        SET c_balance = c_balance + sums(i),
		    c_delivery_cnt = c_delivery_cnt + 1
            WHERE c_w_id = in_w_id
	      AND c_d_id = var_d_id(i)
	      AND c_id = var_o_c_id(i);
    END;

    -- Stored procedure to be called if the customer last name is given rather
    -- than the customer id for the payment transaction.
    PROCEDURE oracle_proc_payment_clast(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN OUT integer,
        in_c_d_id IN integer,
	in_c_w_id IN integer,
        in_c_last IN OUT varchar2,
	in_h_amount IN number,
        out_w_name OUT varchar2,
	out_w_street_1 OUT varchar2,
        out_w_street_2 OUT varchar2,
	out_w_city OUT varchar2,
        out_w_state OUT varchar2,
	out_w_zip OUT varchar2,
        out_d_name OUT varchar2,
	out_d_street_1 OUT varchar2,
        out_d_street_2 OUT varchar2,
	out_d_city OUT varchar2,
        out_d_state OUT varchar2,
	out_d_zip OUT varchar2,
        out_c_first OUT varchar2,
	out_c_middle OUT varchar2,
        out_c_street_1 OUT varchar2,
	out_c_street_2 OUT varchar2,
        out_c_city OUT varchar2,
	out_c_state OUT varchar2,
        out_c_zip OUT varchar2,
	out_c_phone OUT varchar2,
        out_c_since OUT timestamp,
	out_c_credit OUT varchar2,
        out_c_credit_lim OUT number,
	out_c_discount OUT number,
        out_c_balance OUT number,
	out_c_data OUT varchar2,
        out_h_date OUT timestamp
    ) IS
	row_id rowid;
    BEGIN

	out_h_date := CURRENT_TIMESTAMP;

	--Update and Select the WAREHOUSE
        UPDATE bmsql_warehouse
	    SET w_ytd = w_ytd + in_h_amount
	    WHERE w_id = in_w_id
        RETURNING w_name, w_street_1, w_street_2, w_city,
	          w_state, w_zip
	INTO out_w_name, out_w_street_1, out_w_street_2,
             out_w_city, out_w_state, out_w_zip;

        row_id := oracle_rowid_from_clast(in_c_w_id, in_c_d_id, in_c_last);

	--Update and Select the DISTRICT
        UPDATE bmsql_district
	    SET d_ytd = d_ytd + in_h_amount
	    WHERE d_w_id = in_w_id AND d_id = in_d_id
        RETURNING d_name, d_street_1, d_street_2,
	          d_city, d_state, d_zip
	INTO out_d_name, out_d_street_1, out_d_street_2,
             out_d_city, out_d_state, out_d_zip;

        -- Update and Select the CUSTOMER
	UPDATE bmsql_customer
	    SET c_balance = c_balance - in_h_amount,
		c_ytd_payment = c_ytd_payment + in_h_amount,
                c_payment_cnt = c_payment_cnt + 1
	    WHERE rowid = row_id
        RETURNING c_id, c_first, c_middle, c_last, c_street_1,
	          c_street_2, c_city, c_state, c_zip,
	          c_phone, c_since, c_credit, c_credit_lim,
		  c_discount, c_balance
        INTO in_c_id, out_c_first, out_c_middle, in_c_last,
             out_c_street_1, out_c_street_2, out_c_city,
             out_c_state, out_c_zip, out_c_phone, out_c_since,
             out_c_credit, out_c_credit_lim, out_c_discount,
             out_c_balance;

        out_c_balance := out_c_balance - in_h_amount;
	out_c_data := ' ';

        --Customer with bad credit, need to do the C_DATA work.
	IF out_c_credit = 'BC' THEN
            UPDATE bmsql_customer
	        SET c_data = SUBSTR('C_ID='   || TO_CHAR(in_c_id)   ||
	                         ' C_D_ID='   || TO_CHAR(in_c_d_id) ||
		                 ' C_W_ID='   || TO_CHAR(in_c_w_id) ||
		                 ' D_ID='     || TO_CHAR(in_d_id)   ||
			         ' W_ID='     || TO_CHAR(in_w_id)   ||
			         ' H_AMOUNT=' || ROUND(in_h_amount,2), 1, 500)
                WHERE rowid = row_id
	    RETURNING c_data
            INTO out_c_data;
        END IF;

	--Insert the HISTORY row
        INSERT INTO bmsql_history (
	        h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id,
	        h_date, h_amount, h_data)
        VALUES (
	        in_c_id, in_c_d_id, in_c_w_id, in_d_id, in_w_id,
	        out_h_date, in_h_amount, out_w_name||'    '||out_d_name);
    END;

    -- Stored procedure to be called if the custoemr id is given rather
    -- than the customer last name.
    PROCEDURE oracle_proc_payment_cid(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN OUT integer,
        in_c_d_id IN integer,
	in_c_w_id IN integer,
        in_c_last IN OUT varchar2,
	in_h_amount IN number,
        out_w_name OUT varchar2,
	out_w_street_1 OUT varchar2,
        out_w_street_2 OUT varchar2,
	out_w_city OUT varchar2,
        out_w_state OUT varchar2,
	out_w_zip OUT varchar2,
        out_d_name OUT varchar2,
	out_d_street_1 OUT varchar2,
        out_d_street_2 OUT varchar2,
	out_d_city OUT varchar2,
        out_d_state OUT varchar2,
	out_d_zip OUT varchar2,
        out_c_first OUT varchar2,
	out_c_middle OUT varchar2,
        out_c_street_1 OUT varchar2,
	out_c_street_2 OUT varchar2,
        out_c_city OUT varchar2,
	out_c_state OUT varchar2,
        out_c_zip OUT varchar2,
	out_c_phone OUT varchar2,
        out_c_since OUT timestamp,
	out_c_credit OUT varchar2,
        out_c_credit_lim OUT number,
	out_c_discount OUT number,
        out_c_balance OUT number,
	out_c_data OUT varchar2,
        out_h_date OUT timestamp
    ) IS
	var_c_rowid rowid;
    BEGIN

	out_h_date := CURRENT_TIMESTAMP;

	--Update and Select the WAREHOUSE
        UPDATE bmsql_warehouse
	    SET w_ytd = w_ytd + in_h_amount
	    WHERE w_id = in_w_id
        RETURNING w_name, w_street_1, w_street_2, w_city,
	          w_state, w_zip
        INTO out_w_name, out_w_street_1, out_w_street_2,
             out_w_city, out_w_state, out_w_zip;

        --Update and Select the DISTRICT
        UPDATE bmsql_district
	    SET d_ytd = d_ytd + in_h_amount
	    WHERE d_w_id = in_w_id AND d_id = in_d_id
        RETURNING d_name, d_street_1, d_street_2,
	          d_city, d_state, d_zip
        INTO out_d_name, out_d_street_1, out_d_street_2,
             out_d_city, out_d_state, out_d_zip;

        -- Update and Select the CUSTOMER
	UPDATE bmsql_customer
	    SET c_balance = c_balance - in_h_amount,
		c_ytd_payment = c_ytd_payment + in_h_amount,
	        c_payment_cnt = c_payment_cnt + 1
            WHERE c_w_id = in_c_w_id AND c_d_id = in_c_d_id AND c_id = in_c_id
	RETURNING rowid, c_first, c_middle, c_last, c_street_1,
	          c_street_2, c_city, c_state, c_zip,
		  c_phone, c_since, c_credit, c_credit_lim,
		c_discount, c_balance
        INTO var_c_rowid, out_c_first, out_c_middle, in_c_last,
             out_c_street_1, out_c_street_2, out_c_city,
             out_c_state, out_c_zip, out_c_phone, out_c_since,
             out_c_credit, out_c_credit_lim, out_c_discount,
             out_c_balance;

        out_c_balance := out_c_balance - in_h_amount;
	out_c_data := ' ';

        --Customer with bad credit, need to do the C_DATA work.
	IF out_c_credit = 'BC' THEN
            UPDATE bmsql_customer
	        SET c_data = SUBSTR('C_ID='      || TO_CHAR(in_c_id)   ||
				    ' C_D_ID='   || TO_CHAR(in_c_d_id) ||
				    ' C_W_ID='   || TO_CHAR(in_c_w_id) ||
				    ' D_ID='     || TO_CHAR(in_d_id)   ||
				    ' W_ID='     || TO_CHAR(in_w_id)   ||
				    ' H_AMOUNT=' || ROUND(in_h_amount,2), 1, 500)
                WHERE rowid = var_c_rowid
	    RETURNING c_data
            INTO out_c_data;
        END IF;

	--Insert the HISTORY row
        INSERT INTO bmsql_history (
	        h_c_id, h_c_d_id, h_c_w_id, h_d_id, h_w_id,
	        h_date, h_amount, h_data)
        VALUES (
	        in_c_id, in_c_d_id, in_c_w_id, in_d_id, in_w_id,
	        out_h_date, in_h_amount, out_w_name||'    '||out_d_name);
    END;

    PROCEDURE oracle_proc_payment(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN OUT integer,
        in_c_d_id IN integer,
	in_c_w_id IN integer,
        in_c_last IN OUT varchar2,
	in_h_amount IN number,
        out_w_name OUT varchar2,
	out_w_street_1 OUT varchar2,
        out_w_street_2 OUT varchar2,
	out_w_city OUT varchar2,
        out_w_state OUT varchar2,
	out_w_zip OUT varchar2,
        out_d_name OUT varchar2,
	out_d_street_1 OUT varchar2,
        out_d_street_2 OUT varchar2,
	out_d_city OUT varchar2,
        out_d_state OUT varchar2,
	out_d_zip OUT varchar2,
        out_c_first OUT varchar2,
	out_c_middle OUT varchar2,
        out_c_street_1 OUT varchar2,
	out_c_street_2 OUT varchar2,
        out_c_city OUT varchar2,
	out_c_state OUT varchar2,
        out_c_zip OUT varchar2,
	out_c_phone OUT varchar2,
        out_c_since OUT timestamp,
	out_c_credit OUT varchar2,
        out_c_credit_lim OUT number,
	out_c_discount OUT number,
        out_c_balance OUT number,
	out_c_data OUT varchar2,
        out_h_date OUT timestamp
    ) IS
BEGIN
	IF in_c_last is NOT NULL THEN
            oracle_proc_payment_clast(in_w_id, in_d_id, in_c_id, in_c_d_id, in_c_w_id, in_c_last, in_h_amount,
			                out_w_name, out_w_street_1, out_w_street_2, out_w_city, out_w_state, out_w_zip,
			                out_d_name, out_d_street_1, out_d_street_2, out_d_city, out_d_state, out_d_zip,
		                        out_c_first, out_c_middle, out_c_street_1, out_c_street_2, out_c_city, out_c_state,
		                        out_c_zip, out_c_phone, out_c_since, out_c_credit, out_c_credit_lim, out_c_discount,
	                                out_c_balance, out_c_data, out_h_date);
	ELSE
            oracle_proc_payment_cid(in_w_id, in_d_id, in_c_id, in_c_d_id, in_c_w_id, in_c_last, in_h_amount,
			                out_w_name, out_w_street_1, out_w_street_2, out_w_city, out_w_state, out_w_zip,
			                out_d_name, out_d_street_1, out_d_street_2, out_d_city, out_d_state, out_d_zip,
		                        out_c_first, out_c_middle, out_c_street_1, out_c_street_2, out_c_city, out_c_state,
		                        out_c_zip, out_c_phone, out_c_since, out_c_credit, out_c_credit_lim, out_c_discount,
	                                out_c_balance, out_c_data, out_h_date);
	END IF;
    END;

    PROCEDURE oracle_proc_order_status(
	in_w_id IN integer,
        in_d_id IN integer,
	in_c_id IN OUT integer,
        in_c_last IN OUT varchar2,
	out_c_first OUT varchar2,
        out_c_middle OUT varchar2,
	out_c_balance OUT number,
        out_o_id OUT integer,
	out_o_entry_d OUT timestamp,
        out_o_carrier_id OUT integer,
	out_ol_supply_w_id OUT int_array,
        out_ol_i_id OUT int_array,
	out_ol_quantity OUT int_array,
        out_ol_amount OUT num_array,
	out_ol_delivery_d OUT varchar16_array
    ) AS
	var_ol_delivery_d timestamp_array;
	cust_row_id rowid;
        v_order_line rec3;
	v_order_line_check integer;
        v_ol_idx integer := 1;
	var_cnt integer;
        CURSOR cursor_1 IS
	    SELECT ol_i_id, ol_supply_w_id, ol_quantity,
	           ol_amount, ol_delivery_d
		FROM bmsql_order_line
                WHERE ol_w_id = in_w_id AND ol_d_id = in_d_id
	          AND ol_o_id = out_o_id
	        ORDER BY ol_w_id, ol_d_id, ol_o_id, ol_number;
    BEGIN

	out_ol_supply_w_id := int_array();
	out_ol_i_id := int_array();
	out_ol_quantity := int_array();
	out_ol_amount := num_array();
	out_ol_delivery_d := varchar16_array();
	var_ol_delivery_d := timestamp_array();

	out_ol_supply_w_id.EXTEND(15);
	out_ol_i_id.EXTEND(15);
	out_ol_quantity.EXTEND(15);
	out_ol_amount.EXTEND(15);
	out_ol_delivery_d.EXTEND(15);
	var_ol_delivery_d.EXTEND(15);

        IF in_c_last IS NOT NULL THEN
	    --If C_LAST is given instead of C_ID (60%), determine the C_ID and
	    --Select the CUSTOMER using the ROWID.
            cust_row_id := oracle_rowid_from_clast(in_w_id, in_d_id, in_c_last);
	    SELECT c_first, c_middle, c_balance, c_id
	        INTO out_c_first, out_c_middle, out_c_balance, in_c_id
            FROM bmsql_customer
	    WHERE rowid = cust_row_id;
	ELSE
            --If C_ID is given instead of C_LAST, select the CUSTOMER.
	    SELECT c_first, c_middle, c_last, c_balance
	        INTO out_c_first, out_c_middle, in_c_last, out_c_balance
            FROM bmsql_customer
	    WHERE c_w_id = in_w_id AND c_d_id = in_d_id AND c_id = in_c_id;
        END IF;

	--Select the last ORDER for this customer.
        SELECT o_id, o_entry_d, coalesce(o_carrier_id, -1)
	    INTO out_o_id, out_o_entry_d, out_o_carrier_id
        FROM bmsql_oorder
        WHERE o_w_id = in_w_id AND o_d_id = in_d_id AND o_c_id = in_c_id
          AND o_id = (
		    SELECT max(o_id)
                    FROM bmsql_oorder
	                WHERE o_w_id = in_w_id AND o_d_id = in_d_id AND o_c_id = in_c_id
	            );

        v_order_line_check := 1;

	OPEN cursor_1;
        FETCH cursor_1 INTO v_order_line;

	WHILE cursor_1%found LOOP
            out_ol_i_id(v_ol_idx) := v_order_line.ol_i_id;
            out_ol_supply_w_id(v_ol_idx) := v_order_line.ol_supply_w_id;
	    out_ol_quantity(v_ol_idx) := v_order_line.ol_quantity;
            out_ol_amount(v_ol_idx) := v_order_line.ol_amount;
	    var_ol_delivery_d(v_ol_idx) := v_order_line.ol_delivery_d;
	    v_ol_idx := v_ol_idx + 1;
            FETCH cursor_1 INTO v_order_line;
	END LOOP;

        CLOSE cursor_1;

	WHILE v_ol_idx < 16 LOOP
            out_ol_i_id (v_ol_idx) := 0;
	    out_ol_supply_w_id(v_ol_idx) := 0;
	    out_ol_quantity(v_ol_idx) := 0;
            out_ol_amount(v_ol_idx) := 0.0;
	    var_ol_delivery_d(v_ol_idx) := NULL;
	    v_ol_idx := v_ol_idx + 1;
        END LOOP;

	FOR var_cnt IN 1..15 LOOP
	    out_ol_delivery_d(var_cnt) := TO_CHAR(var_ol_delivery_d(var_cnt), 'YYYY-MM-DD');
        END LOOP;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	    v_order_line_check := 0;
    END;

END tpccc_oracle;
-- }

-- {
CREATE OR REPLACE TYPE num_array IS TABLE OF NUMBER;
-- }

-- {
CREATE OR REPLACE TYPE char_array IS TABLE OF char(1);
-- }

-- {
CREATE OR REPLACE TYPE varchar24_array IS TABLE OF VARCHAR2(24);
-- }

-- {
CREATE OR REPLACE TYPE int_array IS TABLE OF INTEGER;
-- }

-- {
CREATE OR REPLACE TYPE varchar16_array IS TABLE OF VARCHAR2(16);
-- }

-- {
CREATE OR REPLACE TYPE timestamp_array IS TABLE OF timestamp;
-- }

