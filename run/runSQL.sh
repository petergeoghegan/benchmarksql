
source setCP.sh $1

myOPTS="-Dprop=$1"
myOPTS="$myOPTS -DcommandFile=$2"

java -cp .:$MY_CP $myOPTS ExecJDBC
