targetdir=$(dirname $0)
if [ $# -eq 1 ]
then
	if [ -f $targetdir/$1 ]
	then
		echo "The file $1 exists."
	else
		mkdir $targetdir/$1
		mkdir $targetdir/$1/codes
		cp $targetdir/resources/Makefile $targetdir/$1/
		cp $targetdir/resources/student_list.txt $targetdir/$1
	fi

else
	echo "Usage: sh create_workspace <workspace_name>"
fi

echo "$0 $1"
