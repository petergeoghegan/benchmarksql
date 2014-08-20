source setCP.sh $1

java -cp .:$MY_CP:../lib/log4j-1.2.17.jar:../lib/apache-log4j-extras-1.1.jar -Dprop=$1 jTPCC
