#!/bin/sh
# ----
# Script to generate the detail graphs of a BenchmarkSQL run.
#
# Copyright (C) 2016, Denis Lussier
# Copyright (C) 2016, Jan Wieck
# ----

if [ $# -lt 1 ] ; then
    echo "usage: $(basename $0) RESULT_DIR [...]" >&2
    exit 2
fi

GRAPHS="tpm_nopm latency"

for resdir in $* ; do
    cd "${resdir}" || exit 1

    for graph in $GRAPHS ; do
	echo -n "Generating ${resdir}/${graph}.png ... "
	out=$(R --no-save <../misc/${graph}.R 2>&1)
	if [ $? -ne 0 ] ; then
	    echo "ERROR"
	    echo "$out" >&2
	    exit 3
	fi
	echo "OK"
    done

    cd ..
done
