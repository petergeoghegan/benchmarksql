drop function if exists bmsql_proc_new_order (integer, integer, integer, integer[], integer[], integer[]);
drop function if exists bmsql_proc_stock_level(integer, integer, integer);
drop function if exists bmsql_proc_payment(integer, integer, integer, integer, integer, varchar(16), decimal(6,2));
drop function if exists bmsql_cid_from_clast(integer, integer, varchar(16));
