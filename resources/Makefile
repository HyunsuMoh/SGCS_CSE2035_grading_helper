for code in $(ls codes)
do
	id=${code%c}
	gcc -o executables/$id.out codes/$code
	executables/$id.out > results/$id.result
	echo "id \n" >> total.result
	cat codes/$code >> total.result
	cat results/$id.result >> total.result
	echo "\n" >> total.result
done
