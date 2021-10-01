rm total.result
for code in $(ls codes)
do
# Build & Run
	id=${code%.c}
	gcc -o executables/$id.out codes/$code
	executables/$id.out > results/$id.result

# Show the result
	echo "ID: $id\n" >> total.result
	echo "Source code:" >> total.result
	cat codes/$code >> total.result
	echo "\nResults:" >> total.result
	cat results/$id.result >> total.result
	echo "\n" >> total.result
done
