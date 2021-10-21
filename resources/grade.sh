#!/bin/bash

# Get options & construct FIFO queues for file I/O
inputIdx=0
outputIdx=0
while getopts "i:o:" opt
do
	case $opt in
		i)
			inputFile[inputIdx]=$OPTARG
			mkfifo $OPTARG
			inputIdx=$((inputIdx + 1))
			;;
		o)
			outputFile[outputIdx]=$OPTARG
			mkfifo $OPTARG
			outputIdx=$((outputIdx + 1))
			;;
		\?)
			exit
			;;
		:)
			exit
			;;
	esac
done

rm -f report.result

# Remove the name tag
OIFS=$IFS
IFS=$'\n'
for code in codes/\[*\]*.c
do
	tmp=codes/${code##codes/\[*\]}
	newname=${tmp%-?.c}.c
	mv $code $newname 
done
IFS=$OIFS

for code in codes/*
do
# Build
	tmp=${code#codes/}
	id=${tmp%.c}
	gcc -o executables/$id.out $code

	echo "ID: $id\n" >> report.result
	rm -f results/$id.result
	score=0
	max_score=0
# Run the program and evaluate the result
	for testcase in testcases/*
	do
		if [[ -d $testcase ]]
		then
			continue
		fi
		tcname=${testcase#testcases/}
		for file in ${inputFile[@]}
		do
			cat testcases/file/$tcname\_$file > $file &
		done
		for file in ${outputFile[@]}
		do
			cat $file > results/$id\_$tcname\_$file &
		done
		executables/$id.out < testcases/$tcname > results/$id\_$tcname
		value=$(python3 compare.py answers/$tcname < results/$id\_$tcname)
		for file in ${outputFile[@]}
		do
			echo "" >> results/$id\_$tcname
			echo "$file:" >> results/$id\_$tcname
			cat results/$id\_$tcname\_$file >> results/$id\_$tcname
			temp=$(python3 compare.py answers/file/$tcname\_$file < results/$id\_$tcname\_$file)
			value=$((value * temp))
		done
		varname=score_${tcname%.*}
		eval "$varname"='$value'
		score=$((score + value))
		max_score=$((max_score + 1))
	done
	echo "Score: $score/$max_score" >> results/$id.result
	echo "" >> results/$id.result
	echo "Results:" >> report.result
# Show the result
	for testcase in testcases/*
	do
		if [[ -d $testcase ]]
		then
			continue
		fi
		tcname=${testcase#testcases/}
		varname=score_${tcname%.*}
		eval value=\$$varname
		echo "$tcname: $value" >> results/$id.result
		echo "" >> results/$id.result
		cat results/$id\_$tcname >> results/$id.result
		echo "" >> results/$id.result
	done
	cat results/$id.result >> report.result
	echo "Source code:" >> report.result
	cat $code >> report.result
	echo "\n" >> report.result
done

for queue in ${inputFile[@]}
do
	rm $queue
done
for queue in ${outputFile[@]}
do
	rm $queue
done
