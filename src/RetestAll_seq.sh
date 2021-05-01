#1/bin/bash
rm -f *.time *.fails
collection=$(find . -type d -name 'surefire-reports')
for i in $collection;
do
	rm -rf $i/*
done

MAVEN_SKIPS="-Drat.skip=true -Dmaven.javadoc.skip=true \
-Djacoco.skip=true -Dcheckstyle.skip=true \
-Dfindbugs.skip=true -Dcobertura.skip=true \
-Dpmd.skip=true -Dcpd.skip=true -DfailIfNoTests=false"

s_r=0

#mvn clean dependency:go-offline
#mvn test-compile install -DskipTests $MAVEN_SKIPS \
#&> /dev/null

mvn -B -o -fn $MAVEN_SKIPS test 2>&1 | tee tot.time

grep --text "Tests run" tot.time | grep -v "Time elapsed" > testSuiteSize.info
hold=$(cat testSuiteSize.info | awk '{if($4 == "Failures:") {print $3} else {print $4}}' | sed 's/.$//' | paste -sd+ | bc)
s_r=${hold} # corrected inflation bug
echo ${hold} > testSuiteSize.info

printf "\n#Tests run (RetestAll seq.): ${s_r}\n\n"
rm -f *.time
exit 0
