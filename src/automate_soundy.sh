#!/bin/bash

rm -rf PASTE_PROJlogs
mkdir PASTE_PROJlogs
rm -rf xPASTE_PROJ
mkdir xPASTE_PROJ
cp pom.xml xPASTE_PROJ

runs=5
timebound=3h

for j in `seq 1 ${runs}`;
do
	printf "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<< Run $j started with RetestAll_seq >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
	timeout ${timebound} bash RetestAll_seq.sh 2>&1 | tee PASTE_PROJlogs/seq_${j}.txt
	printf "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<< Run $j completed with RetestAll_seq >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
done

for i in `ls PASTE_PROJconfigs`;
do
	cp PASTE_PROJconfigs/$i/launch.sh xPASTE_PROJ
	
	for j in `seq 1 ${runs}`;
	do
		printf "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<< Run $j started with $i/launch.sh >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
		rm -f *.fails xPASTE_PROJ/*.report
		timeout ${timebound} bash PASTE_PROJ.sh 2 2>&1 | tee PASTE_PROJlogs/${i}_${j}.txt
		cp xPASTE_PROJ/unified.report PASTE_PROJlogs/unified_${i}_${j}.report 2>/dev/null
		mv stage1.fails PASTE_PROJlogs/stage1_${i}_${j}.fails 2>/dev/null
		mv stage2.fails PASTE_PROJlogs/stage2_${i}_${j}.fails 2>/dev/null
		printf "\n<<<<<<<<<<<<<<<<<<<<<<<<<<<< Run $j completed with $i/launch.sh >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\n"
	done
done
