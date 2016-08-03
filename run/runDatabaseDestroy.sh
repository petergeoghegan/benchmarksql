#!/bin/sh

if [ $# -ne 1 ] ; then
    echo "usage: $(basename $0) PROPS" >&2
    exit 2
fi

PROPS="$1"
if [ ! -f "${PROPS}" ] ; then
    echo "${PROPS}: no such file or directory" >&2
    exit 1
fi

DB="$(grep '^db=' $PROPS | sed -e 's/^db=//')"
USER="$(grep '^user=' $PROPS | sed -e 's/^user=//' )"
PASSWORD="$(grep '^password=' $PROPS | sed -e 's/^password=//' )"

if [ $DB == "oracle" ] ; then
STEPS="tableDrops"
else
STEPS="tableDrops storedProcedureDrops"
fi

for step in ${STEPS} ; do
    ./runSQL.sh "${PROPS}" $step
done

if [ $DB == "oracle" ] ; then
sqlplus -s $USER/$PASSWORD@XE << EOF
@$PWD/sql.oracle/storedProcedureDrops.sql
exit
EOF
echo "Procedures dropped successfully."
echo " "
fi
