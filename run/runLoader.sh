#!/usr/bin/env bash

if [ $# -lt 1 ] ; then
    echo "usage: $(basename $0) PROPS_FILE [ARGS]" >&2
    exit 2
fi

source funcs.sh $1
shift

setCP || exit 1

warehouses=$(getProp warehouses)
myOPTS=""
err=0
while [ $# -gt 0 ] ; do
    case $1 in
        numWarehouses)
	    warehouses=$2
	    shift
	    shift
	    ;;
	fileLocation)
	    myOPTS="$myOPTS $1 $2"
	    shift
	    shift
	    ;;
	*)
	    echo "unknown argument '$1'" >&2
	    err=1
	    shift
	    ;;
    esac
done
[ $err -eq 0 ] || exit 1

java -cp "$myCP" -Dprop=$PROPS LoadData numWarehouses $warehouses $myOPTS
