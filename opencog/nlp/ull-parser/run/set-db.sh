#!/bin/bash
#
# set-db.sh [<option>] <db_name>  
#
# Support script for creating or reseting a database.
#

if [ $# -lt 1 ]
then 
  echo "Usage: ./set-db.sh [<option>] <db_name>"
  exit 0
fi

db_name=$1
if [[ "$1" == "-r" ]]
then
	if [ $# -ne 2 ]
	then
		echo "Usage: ./set-db.sh [<option>] <db_name>"
      	echo "[<option>] can only be -r"
      	exit 1
	fi
  db_name=$2
  dropdb $db_name
fi

createdb $db_name
cat $ATOMSPACE_SOURCE_DIR/opencog/persist/sql/multi-driver/atom.sql | psql $db_name
