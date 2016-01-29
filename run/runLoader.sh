source funcs.sh $1

java -cp .:$MY_CP -Dprop=$1 LoadData $2 $3 $4 $5
