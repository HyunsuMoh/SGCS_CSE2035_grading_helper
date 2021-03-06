#!/bin/bash

# Get options & construct FIFO queues for file I/O
inputIdx=0
outputIdx=0
while getopts "i:o:c" opt
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
		c)
			rm -f executables/*
			rm -f results/*
			rm -f report.result
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

	echo -e "ID: $id\n" >> report.result
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
			cat testcases/files/$tcname\_$file > $file &
		done
		for file in ${outputFile[@]}
		do
			cat $file > results/$id\_$tcname\_$file &
		done
		executables/$id.out < testcases/$tcname > results/$id\_$tcname
		value=$(python3 compare.py answers/$tcname < results/$id\_$tcname)
		for file in ${outputFile[@]}
		do
			echo -e "" >> results/$id\_$tcname
			echo -e "$file:" >> results/$id\_$tcname
			cat results/$id\_$tcname\_$file >> results/$id\_$tcname
			temp=$(python3 compare.py answers/files/$tcname\_$file < results/$id\_$tcname\_$file)
			value=$((value * temp))
		done
		varname=score_${tcname%.*}
		eval "$varname"='$value'
		score=$((score + value))
		max_score=$((max_score + 1))
	done
	echo -e "Score: $score/$max_score" >> results/$id.result
	echo -e "" >> results/$id.result
	echo -e "Results:" >> report.result
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
		echo -e "$tcname: $value" >> results/$id.result
		echo -e "" >> results/$id.result
		cat results/$id\_$tcname >> results/$id.result
		echo -e "" >> results/$id.result
	done
	cat results/$id.result >> report.result
	echo -e "Source code:" >> report.result
	cat $code >> report.result
	echo -e "\n" >> report.result
done

for queue in ${inputFile[@]}
do
	rm $queue
done
for queue in ${outputFile[@]}
do
	rm $queue
done
