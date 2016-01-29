#!/usr/bin/env bash

if [ $# -ne 1 ] ; then
    echo "usage: $(basename $0) PROPS_FILE" >&2
    exit 2
fi

source funcs.sh $1

setCP || exit 1

myOPTS="-Dprop=$1"

java -cp "$myCP" $myOPTS jTPCC
