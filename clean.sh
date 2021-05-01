for i in `ls projects`;
do
	echo "cleaning... [$i]"
	cd projects/$i
	mvn clean
	cd ../..
done
