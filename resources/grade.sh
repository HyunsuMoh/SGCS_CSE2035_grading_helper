rm -f total.result

# Remove the name tag
OIFS=$IFS
IFS="\t"
for code in $(ls codes/\[*\]*.c)
do
	tmp=codes/${code##codes/\[*\]}
	newname=${tmp%-?.c}.c
	mv $code $newname 
done
IFS=$OIFS

for code in $(ls codes)
do
# Build
	id=${code%.c}
	gcc -o executables/$id.out codes/$code

# Show the result
	echo "ID: $id\n" >> total.result
	echo "Results:" >> total.result
	rm -f results/$id.result
	for testcase in $(ls testcases)
	do
		echo "$testcase: " >> results/$id.result
		executables/$id.out < testcases/$testcase > results/$id\_$testcase
		python3 compare.py answers/$testcase < results/$id\_$testcase >> results/$id.result
		echo "" >> results/$id.result
		cat results/$id\_$testcase >> results/$id.result
		echo "" >> results/$id.result
	done
	cat results/$id.result >> total.result
	echo "Source code:" >> total.result
	cat codes/$code >> total.result
	echo "\n" >> report.result
done
