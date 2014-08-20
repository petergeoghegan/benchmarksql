
props_file=$1

if [ "$props_file" == "props.pg" ]; then
  cp="../lib/postgresql-9.3-1102.jdbc41.jar"
elif [ "$props_file" == "props.ora" ]; then
  cp="../lib/orajdbc.jar"
elif [ "$props_file" == "props.cas" ]; then
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
  cp=".:$jdbc:$sl4j:$sl4ja:$log4j:$clientutil:$thrift:$libthrift:$guava"
  if [ ! -f "$jdbc" ]; then
    echo "CASSANDRA_HOME environment not properly configured"
    exit 1
  fi
else
  echo "ERROR: Invalid property file"
  exit 1
fi

export MY_CP=$cp:../dist/BenchmarkSQL-4.1.jar

echo " "
echo "running with cp = $MY_CP"
echo " "

