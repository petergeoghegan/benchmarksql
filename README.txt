*********************************************************************
Change Log:

Version 4.1.0 2014-03-13 lussman
   - Upgrade to using JDK 7
   - Upgrade to PostgreSQL JDBC 4.1 version 1101 driver
   - Stop claiming to support DB2 (only Postgres & Oracle are well tested)

Version 4.0.9 2013-11-04 cadym
   - Incorporate new PostgreSQL JDBC 4 version 1100 driver
   - Changed default user from postgres to benchmarksql
   - Added id column as primary key to history table
   - Renamed schema to benchmarksql
   - Changed log4j format to be more readable
   - Created the "benchmark" schema to contain all tables 
   - Incorporate new PostgreSQL JDBC4 version 1003 driver
   - Transaction rate pacing mechanism 
   - Correct error with loading customer table from csv file 
   - Status line report dynamically shown on terminal
   - Fix lookup by name in PaymentStatus and Delivery Transactions 
     (in order to be more compatible with the TPC-C spec)
   - Rationalized the variable naming in the input parameter files
     (now that the GUI is gone, variable names still make sense)
   - Default log4j settings only writes to file (not terminal)

Version 4.0.2  2013-06-06   lussman & cadym
   - Removed Swing & AWT GUI so that this program is runnable from
     the command line
   - Remove log4j usage from runSQL & runLoader (only used now for 
     the actual running of the Benchmark)
   - Fix truncation problem with customer.csv file
   - Comment out "BadCredit" business logic that was not working 
     and throwing stack traces
   - Fix log4j messages to always show the terminal name
   - Remove bogus log4j messages

Version 3.0.9 2013-03-21  lussman
   - Config log4j for rotating log files once per minute
   - Default flat file location to '/tmp/csv/' in
     table copies script
   - Drop incomplete & untested Windoze '.bat' scripts
   - Standardize logging with log4j
   - Improve Logging with meaningful DEBUG and INFO levels
   - Simplify "build.xml" to eliminate nbproject dependency
   - Defaults read in from propeerties
   - Groudwork laid to eliminate the GUI
   - Default GUI console to PostgreSQL and 10 Warehouses

Version 2.3.5  2013-01-29  lussman
   - Default build is now with JDK 1.6 and JDBC 4 Postgres 9.2 driver
   - Remove outdated JDBC 3 drivers (for JDK 1.5).  You can run as 
     before by a JDBC4 driver from any supported vendor.
   - Remove ExecJDBC warning about trying to rollback when in 
     autocommit mode
   - Remove the extraneous COMMIT statements from the DDL scripts 
     since ExecJDBC runs in autocommit mode
   - Fix the version number displayed in the console

Version 2.3.3  2010-11-19 sjm  
   - Added DB2 LUW V9.7 support, and supercedes patch 2983892
   - No other changes from 2.3.2

*********************************************************************
