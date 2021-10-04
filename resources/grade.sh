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
		tcname=${testcase#testcases/}
		executables/$id.out < testcases/$tcname > results/$id\_$tcname
		varname=score_${tcname%.*}
		eval "$varname"='$(python3 compare.py answers/$tcname < results/$id\_$tcname)'
		eval value=\$$varname
		score=$((score + value))
		max_score=$((max_score + 1))
	done
	echo "Score: $score/$max_score" >> results/$id.result
	echo "" >> results/$id.result
	echo "Results:" >> report.result
# Show the result
	for testcase in testcases/*
	do
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
