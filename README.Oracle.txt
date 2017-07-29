
The following assumes a default installation of oracle-xe-11.2.0-1.0.

Creating the benchmarksql user run the following commands in sqlplus
under the sysdba account:

<<_EOF_

CREATE USER benchmarksql
	IDENTIFIED BY "bmsql1"
	DEFAULT TABLESPACE users
	TEMPORARY TABLESPACE temp;

GRANT CONNECT TO benchmarksql;
GRANT CREATE PROCEDURE TO benchmarksql;
GRANT CREATE SEQUENCE TO benchmarksql;
GRANT CREATE SESSION TO benchmarksql;
GRANT CREATE TABLE TO benchmarksql;
GRANT CREATE TRIGGER TO benchmarksql;
GRANT CREATE TYPE TO benchmarksql;
GRANT UNLIMITED TABLESPACE TO benchmarksql;

_EOF_

