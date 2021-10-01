rm -f total.result
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
		echo "$testcase" >> results/$id.result
		executables/$id.out < testcases/$testcase >> results/$id.result
		echo "" >> results/$id.result
	done
	cat results/$id.result >> total.result
	echo "Source code:" >> total.result
	cat codes/$code >> total.result
	echo "\n" >> total.result
done
