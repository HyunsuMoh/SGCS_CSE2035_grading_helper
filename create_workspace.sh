#!/bin/bash
targetdir=$(dirname $0)
if [ $# -eq 1 ]
then
	if [ -f $1 ]
	then
		echo "The file $1 exists."
	else
		mkdir $1
		mkdir $1/codes
		mkdir $1/testcases
		mkdir $1/executables
		mkdir $1/results
		mkdir $1/answers
		cp $targetdir/resources/grade.sh $1
		cp $targetdir/resources/compare.py $1
	fi

else
	echo "Usage: sh create_workspace <workspace_name>"
fi
