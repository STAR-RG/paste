#!/bin/bash

rm -rf results
mkdir results

for i in `ls projects`;
do
	echo "evaluating... [$i]"
	cp -r src/* projects/$i
	cd projects/$i

	mvn clean
	bash install.sh
	bash test-install.sh

	bash runme.sh

	cd ../..
	echo "copying results for... [$i] to results/$i"
	mkdir results/$i
	
	cp -r projects/$i/PASTE_PROJlogs results/$i # individual execution logs of PASTE, in detail.
	cp -r projects/$i/PASTE_PROJlogs/testSuiteSize.info results/$i # full test-suite size (#inputs to stage 1 of PASTE)
done
