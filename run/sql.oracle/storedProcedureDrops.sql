BEGIN
    EXECUTE IMMEDIATE 'drop procedure oracle_proc_stock_level';
    EXECUTE IMMEDIATE 'drop procedure oracle_proc_payment';
    EXECUTE IMMEDIATE 'drop procedure oracle_proc_new_order';
    EXECUTE IMMEDIATE 'drop procedure oracle_proc_delivery_bg';
    EXECUTE IMMEDIATE 'drop procedure oracle_proc_order_status';
    EXECUTE IMMEDIATE 'drop function oracle_cid_from_clast';
    EXECUTE IMMEDIATE 'drop type int_array';
    EXECUTE IMMEDIATE 'drop type dec_array';
    EXECUTE IMMEDIATE 'drop type varchar24_array';
    EXECUTE IMMEDIATE 'drop type varchar16_array';
    EXECUTE IMMEDIATE 'drop type varchar50_array';
    EXECUTE IMMEDIATE 'drop type timestamp_array';
    EXECUTE IMMEDIATE 'drop type rec1';
    EXECUTE IMMEDIATE 'drop type rec2';
    EXECUTE IMMEDIATE 'drop type rec3';
EXCEPTION
    WHEN others THEN
	NULL;
END;
/
