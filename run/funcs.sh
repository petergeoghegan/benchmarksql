# ----
# $1 is the properties file
# ----
PROPS=$1
if [ ! -f ${PROPS} ] ; then
    echo "${PROPS}: no such file" >&2
    exit 1
fi

# ----
# getProp()
#
#   Get a config value from the properties file.
# ----
function getProp()
{
    grep "^${1}=" ${PROPS} | sed -e "s/^${1}=//"
}

# ----
# getCP()
#
#   Determine the CLASSPATH based on the database system.
# ----
function setCP()
{
    case "$(getProp db)" in
        cassandra)
	    csLib="$CASSANDRA_HOME/lib"
	    jdbc=`ls $csLib/cassandra2-jdbc-*.jar`
	    #jdbc=`ls $csLib/cassandra-jdbc-*.jar`
	    sl4j=`ls $csLib/slf4j-log4j*.jar`
	    sl4ja=`ls $csLib/slf4j-api*.jar`
	    log4j=`ls $csLib/log4j*.jar`
	    clientutil=`ls $csLib/apache-cassandra-clientutil*`
	    thrift=`ls $csLib/apache-cassandra-thrift*`
	    libthrift=`ls $csLib/libthrift*`
	    guava=`ls $csLib/guava*.jar`
	    cp="$jdbc:$sl4j:$sl4ja:$log4j:$clientutil:$thrift:$libthrift:$guava"
	    if [ ! -f "$jdbc" ]; then
		echo "CASSANDRA_HOME environment not properly configured" >&2
		exit 1
	    fi
	    ;;
	oracle)
	    cp="../lib/*"
	    if [ ! -z "${ORACLE_HOME}" -a -d ${ORACLE_HOME}/lib ] ; then
		cp="${ORACLE_HOME}/lib/*:${cp}"
	    fi
	    ;;
	postgres)
	    cp="../lib/*"
	    ;;
    esac
    myCP="${cp}:../dist/*"
    export myCP
}

# ----
# Make sure that the properties file does have db= and the value
# is a database, we support.
# ----
case "$(getProp db)" in
    cassandra|oracle|postgres)
	;;
    "")	echo "ERROR: missing db= config option in ${PROPS}" >&2
	exit 1
	;;
    *)	echo "ERROR: unsupported database type 'db=$(getProp db)' in ${PROPS}" >&2
	exit 1
	;;
esac

