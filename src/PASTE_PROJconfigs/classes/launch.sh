#!/bash/bin

STAGE=$1

if (($STAGE == 3)); then
	printf "\n[RUN MODE ($STAGE stages)] (par-->par-->seq)\n"
elif (($STAGE == 2)); then
	printf "\n[RUN MODE ($STAGE stages)] (par-->seq)\n"
else
	printf "\nBad command: Format is [bash PASTE_PROJ.sh #stages]\n"
	printf "\n #stages\n -------\n 2: (par-->seq) {obvious treatment}\n 3: (par-->par-->par) {diminising aggressiveness}\n\n"
	exit -1
fi

rm -f *.report *.time ../*.fails
cd ..
collection=$(find . -type d -name 'surefire-reports')
for i in $collection;
do
	rm -rf $i/*
done
cp xPASTE_PROJ/pom.xml .

MAVEN_SKIPS="-Drat.skip=true -Dmaven.javadoc.skip=true \
-Djacoco.skip=true -Dcheckstyle.skip=true \
-Dfindbugs.skip=true -Dcobertura.skip=true \
-Dpmd.skip=true -Dcpd.skip=true -DfailIfNoTests=false"

#mvn clean dependency:go-offline
#mvn test-compile install -DskipTests $MAVEN_SKIPS \
#&> /dev/null

#RetestAll

mvn -B -o -fn -DforkCount=1C -DreuseForks=true -Dparallel=classes -DthreadCount=7 $MAVEN_SKIPS test &>> xPASTE_PROJ/tot.time #stage 1 (classes only)
#mvn -B -o -fn -DforkCount=1C -DreuseForks=true -Dparallel=methods -DthreadCount=7 $MAVEN_SKIPS test &>> xPASTE_PROJ/tot.time #stage 1 (methods only)
#mvn -B -o -fn -DforkCount=1C -DreuseForks=true -Dparallel=classesAndMethods -DthreadCount=7 $MAVEN_SKIPS test &>> xPASTE_PROJ/tot.time #stage 1 (classes+methods)

hold=$(cat testSuiteSize.info) # read pre-recorded count as maven test-count in parallel is buggy!

cd xPASTE_PROJ

ret=0
ret1=0
tot=0
flakes=0
flakes1=0
s1_r=0
s2_r=0
s3_r=0
s1_t=0
s2_t=0
s3_t=0
s1_f=0
s2_f=0
s3_f=0
xtime=0
ytime=0
ttime=0
fp=0
xtot=0
xflakes=0
ldangling=
gdangling=
meth=
temp1=
temp2=

collection=$(find ../ -type d -name 'surefire-reports')
for i in $collection;
do
	for j in `ls $i/*.txt 2> /dev/null`;
	do
		h=$(grep -e "Tests run: [0-9]*" $j | awk '{print $3}' | sed 's/.$//')
		if [[ $h != *"."* ]]; then
			s1_r=$((${s1_r}+h));
		fi
		ret=$(grep -e "Failures: [1-9][0-9]*" -e "Errors: [1-9][0-9]*" $j | wc -l)
		if ((${ret} == 1)); then
			tot=$((${tot}+1));
			x=$(grep -e "Failures: [1-9][0-9]*" $j | awk '{print $5}' | sed 's/.$//')
			y=$(grep -e "Errors: [1-9][0-9]*" $j | awk '{print $7}' | sed 's/.$//')
			flakes=$((${flakes}+x));
			flakes=$((${flakes}+y));
			cat ${j} >> unified.report

			if((x == 0)); then
				if((y > 0)); then
					ldangling=$(grep -e "Test set:" $j | awk '{print $3}')
					meth_temp=$(grep -e "<<< ERROR!" $j | grep -v "Tests run:" | awk '{print $1}')
					meth=($meth_temp)
					lim=${#meth[@]}
					lim=$((${lim}-1))
				
					for m in `seq 0 $lim`;
					do
						if [[ ${meth[$m]} != *"."* ]]; then
							meth[$m]=$(echo "${ldangling}#${meth[$m]}")
						else
							meth[$m]=$(echo "${meth[$m]}" | sed -e 's/\(.*\)\./\1#/')
						fi
					done

					ldangling=$(printf "%s," ${meth[@]} | sed 's/\(.*\),/\1 /')
					
					if [ -z "${gdangling}" ]; then
						gdangling=${ldangling}
					else
						ldangling=$(echo ${ldangling} | sed 's/\(.*\) /\1 /')
						if ! [ -z "${ldangling}" ]; then
							gdangling=${gdangling},${ldangling}
						fi
					fi
				fi				
			fi
		fi
	done
done

if ((${tot} > 0)); then
	printf "\n***********************************<Summary of test-failures>***************************************\n"
	cat unified.report
	
	cd ..

	#mvn clean dependency:go-offline
	#mvn test-compile install -DskipTests $MAVEN_SKIPS \
	#&> /dev/null
	collection=$(find ../ -type d -name 'surefire-reports')
	for i in $collection;
	do
		rm -rf $i/*
	done	

	# re-run ONLY the flaky tests sequentially

	aux=$(grep -e "<<< FAILURE!" -e "<<< ERROR!" --text xPASTE_PROJ/unified.report | grep -v "Tests run:" | awk '{print $1}')
	failed_set=($aux)
	bound=${#failed_set[@]}
	bound=$((${bound}-1))
	
	for k in `seq 0 $bound`;
	do
		if [[ ${failed_set[$k]} == *"("* ]]; then
			failed_set[$k]=$(echo ${failed_set[$k]} | sed -e 's/[()]/@/g' | tr "@" " " | sed 's/ *$//' | awk '{printf("%s.%s\n",$2,$1)}' | sed -e 's/\(.*\)\./\1#/')
		else
			failed_set[$k]=$(echo ${failed_set[$k]} | sed -e 's/\(.*\)\./\1#/')
		fi
	done

	failed_set=$(printf "%s," ${failed_set[@]} | sed 's/\(.*\),/\1 /')

	if ! [ -z "${gdangling}" ]; then

		gdangling=(${gdangling})
		lbound=${#gdangling[@]}
		lbound=$((${lbound}-1))

		for kk in `seq 0 $lbound`;
		do
			if [[ ${gdangling[${kk}]} == *"("* ]]; then
				gdangling[${kk}]=PASTE_PROJ_PAR
			else
				gdangling[${kk}]=$(echo ${gdangling[${kk}]})
			fi
		done

		token=PASTE_PROJ_PAR
		gdangling=( "${gdangling[@]/$token}" )
		gdangling=$(printf "%s," ${gdangling[@]} | sed 's/\(.*\),/\1 /')

		failed_set=$(printf "%s,%s" ${failed_set},${gdangling})
	fi

	failed_set=$(echo ${failed_set} | sed "s/ //g" | sed "s/,,/,/g")
	temp=$(echo ${failed_set} | sed "s/,/\n/g" | awk '!seen[$0]++')
	failed_set=$(echo ${temp} | tr '\n' ',')
	if [[ ${failed_set} == *"," ]]; then
		failed_set=$(echo ${failed_set} | sed 's/\(.*\),/\1 /')
	fi

	if [[ ${failed_set} == *" "* ]]; then
		failed_set=$(echo ${failed_set} | tr ' ' ',')
	fi

	if [[ ${failed_set} == *"," ]]; then
		failed_set=$(echo ${failed_set} | sed 's/\(.*\),/\1 /')
	fi

	temp=$(printf ${failed_set} | tr ',' '\n' | awk 'END{print NR}')
	catch=$(echo ${failed_set} | sed "s/,/\n/g")
	printf "${catch}" > stage1.fails

	if (($STAGE == 3)); then
		mvn -B -o -fn -DforkCount=1C -DreuseForks=true -Dparallel=classes -DthreadCount=1 -Dtest=${failed_set} $MAVEN_SKIPS test &>> xPASTE_PROJ/tot.time #stage 2
	elif (($STAGE == 2)); then
		mvn -B -o -fn -Dtest=${failed_set} $MAVEN_SKIPS test &>> xPASTE_PROJ/tot.time #stage 2 (sequential)
	fi
	
	cd xPASTE_PROJ

	time1=$(grep --text "\[INFO\] Total time:" tot.time | awk '{print $(NF-1)}')
	time2=$(grep --text "\[INFO\] Total time:" tot.time | awk '{print $NF}')

	time1=($time1)
	time2=($time2)

	len=${#time1[@]}
		
	if((${len} > 0)); then
		len=$((${len}-1));
	fi

	#convert all time to secs.

	for k in `seq 0 $len`;
	do
		if [[ ${time2[$k]} == *"m"* ]]; then
			x=$(echo ${time1[$k]} | awk '{split($0,a,":"); print a[1], a[2]}')
			x=($x)
			p=$(echo ${x[0]}*60+${x[1]} | bc)
			time1[$k]=$p
		elif [[ ${time2[$k]} == *"h"* ]]; then
			x=$(echo ${time1[$k]} | awk '{split($0,a,":"); print a[1], a[2]}')
			x=($x)
			p=$(echo ${x[0]}*60*60+${x[1]}*60 | bc)
			time1[$k]=$p
		fi
	done

	time_vec=${time1[@]}
	ct=0;
	for i in $time_vec
	do
		ct=$((${ct}+1));
		if ((${ct} == 1)); then
			xtime=$i
		else
			ytime=$(echo $ytime+$i | bc);
		fi
	done
	
	ttime=$(echo $xtime+$ytime | bc);

	collection=$(find ../ -type d -name 'surefire-reports')
	for i in $collection;
	do
		for j in `ls $i/*.txt 2> /dev/null`;
		do
			h=$(grep -e "Tests run: [0-9]*" $j | awk '{print $3}' | sed 's/.$//')
			
			if [[ $h != *"."* ]]; then
				s2_r=$((${s2_r}+h));
			fi
			
			ret1=$(grep -e "Failures: [1-9][0-9]*" -e "Errors: [1-9][0-9]*" $j | wc -l)
			if ((${ret1} == 1)); then
				tot1=$((${tot1}+1));
				x=$(grep -e "Failures: [1-9][0-9]*" $j | awk '{print $5}' | sed 's/.$//')
				y=$(grep -e "Errors: [1-9][0-9]*" $j | awk '{print $7}' | sed 's/.$//')
				flakes1=$((${flakes1}+x));
				flakes1=$((${flakes1}+y));
			fi
		done
	done

	fp=$((${flakes}-${flakes1})); # count of flaky tests that passed when isolated and executed sequentially (after parallel execution).
	s1_f=$flakes
	s1_t=$xtime
	s2_t=$ytime

	s2_r=${temp} # corrected count
	flakes=${s2_r} # corrected count
	s1_r=${hold} # corrected inflation bug
	
	if(($flakes1 == 0)); then
		printf "\n#Tests run (stage 1 in ${s1_t} secs.): ${s1_r}" | tee -a unified.report
		printf "\n#Failed tests (stage 1): $flakes" | tee -a unified.report
		printf "\n#Tests run (stage 2 in ${s2_t} secs.): ${s2_r}" | tee -a unified.report
		printf "\n#Failed tests (stage 2): ${flakes1}" | tee -a unified.report
		#printf "\nPar time (stage 1): $xtime secs." | tee -a unified.report
		#printf "\nPar time (stage 2): $ytime secs." | tee -a unified.report
		printf "\nEnd-to-end time: $ttime secs.\n\n" | tee -a unified.report
	else
		#printf "\n#Tests run (stage 1 in ${s1_t} secs.): ${s1_r}" | tee -a unified.report
		#printf "\n#Failed tests (stage 1): $flakes" | tee -a unified.report
		#printf "\n#Tests run (stage 2 in ${s2_t} secs.): ${s2_r}" | tee -a unified.report
		#printf "\n#Failed tests (stage 2): ${flakes1}" | tee -a unified.report
		#printf "\nPar time (stage 1): $xtime secs." | tee -a unified.report
		#printf "\nPar time (stage 2): $ytime secs." | tee -a unified.report
		#printf "\nEnd-to-end time: $ttime secs.\n\n" | tee -a unified.report
		
		#printf "I have entered else......................."
		
		ldangling=
		gdangling=
		meth=
		rm -f unifiedi.report toti.time
		collection=$(find ../ -type d -name 'surefire-reports')
		for i in $collection;
		do
			for j in `ls $i/*.txt 2> /dev/null`;
			do
				ret=$(grep -e "Failures: [1-9][0-9]*" -e "Errors: [1-9][0-9]*" $j | wc -l)
				if ((${ret} == 1)); then
					xtot=$((${xtot}+1));
					x=$(grep -e "Failures: [1-9][0-9]*" $j | awk '{print $5}' | sed 's/.$//')
					y=$(grep -e "Errors: [1-9][0-9]*" $j | awk '{print $7}' | sed 's/.$//')
					xflakes=$((${xflakes}+x));
					xflakes=$((${xflakes}+y));
					cat ${j} >> unifiedi.report

					if((x == 0)); then
						if((y > 0)); then
							ldangling=$(grep -e "Test set:" $j | awk '{print $3}')
							meth_temp=$(grep -e "<<< ERROR!" $j | grep -v "Tests run:" | awk '{print $1}')
							meth=($meth_temp)
							lim=${#meth[@]}
							lim=$((${lim}-1))
				
							for m in `seq 0 $lim`;
							do
								if [[ ${meth[$m]} != *"."* ]]; then
									meth[$m]=$(echo "${ldangling}#${meth[$m]}")
								else
									meth[$m]=$(echo "${meth[$m]}" | sed -e 's/\(.*\)\./\1#/')
								fi
							done

							ldangling=$(printf "%s," ${meth[@]} | sed 's/\(.*\),/\1 /')
					
							if [ -z "${gdangling}" ]; then
								gdangling=${ldangling}
							else
								ldangling=$(echo ${ldangling} | sed 's/\(.*\) /\1 /')
								if ! [ -z "${ldangling}" ]; then
									gdangling=${gdangling},${ldangling}
								fi
							fi
						fi				
					fi
				fi
			done
		done

		cd ..

		#mvn clean dependency:go-offline
		#mvn test-compile install -DskipTests $MAVEN_SKIPS \
		#&> /dev/null
		collection=$(find ../ -type d -name 'surefire-reports')
		for i in $collection;
		do
			rm -rf $i/*
		done

		# report manifest failures in stage 2

		aux=$(grep -e "<<< FAILURE!" -e "<<< ERROR!" --text xPASTE_PROJ/unifiedi.report | grep -v "Tests run:" | awk '{print $1}')
		failed_set=($aux)
		bound=${#failed_set[@]}
		bound=$((${bound}-1))

		for k in `seq 0 $bound`;
		do
			if [[ ${failed_set[$k]} == *"("* ]]; then
				failed_set[$k]=$(echo ${failed_set[$k]} | sed -e 's/[()]/@/g' | tr "@" " " | sed 's/ *$//' | awk '{printf("%s.%s\n",$2,$1)}' | sed -e 's/\(.*\)\./\1#/')
			else
				failed_set[$k]=$(echo ${failed_set[$k]} | sed -e 's/\(.*\)\./\1#/')
			fi
		done

		failed_set=$(printf "%s," ${failed_set[@]} | sed 's/\(.*\),/\1 /')

		if ! [ -z "${gdangling}" ]; then

			gdangling=(${gdangling})
			lbound=${#gdangling[@]}
			lbound=$((${lbound}-1))

			for kk in `seq 0 $lbound`;
			do
				if [[ ${gdangling[${kk}]} == *"("* ]]; then
					gdangling[${kk}]=PASTE_PROJ_PAR
				else
					gdangling[${kk}]=$(echo ${gdangling[${kk}]})
				fi
			done

			token=PASTE_PROJ_PAR
			gdangling=( "${gdangling[@]/$token}" )
			gdangling=$(printf "%s," ${gdangling[@]} | sed 's/\(.*\),/\1 /')

			failed_set=$(printf "%s,%s" ${failed_set},${gdangling})
		fi

		failed_set=$(echo ${failed_set} | sed "s/ //g" | sed "s/,,/,/g")
		temp=$(echo ${failed_set} | sed "s/,/\n/g" | awk '!seen[$0]++')
		failed_set=$(echo ${temp} | tr '\n' ',')
		if [[ ${failed_set} == *"," ]]; then
			failed_set=$(echo ${failed_set} | sed 's/\(.*\),/\1 /')
		fi

		if [[ ${failed_set} == *" "* ]]; then
			failed_set=$(echo ${failed_set} | tr ' ' ',')
		fi

		if [[ ${failed_set} == *"," ]]; then
			failed_set=$(echo ${failed_set} | sed 's/\(.*\),/\1 /')
		fi

		temp=$(printf ${failed_set} | tr ',' '\n' | awk 'END{print NR}')
		catch=$(echo ${failed_set} | sed "s/,/\n/g")
		printf "${catch}" > stage2.fails

		cd xPASTE_PROJ
		rm -f *.time unifiedi.report
		cd ..

		#cat stage2.fails

		#keep only class names

		failed_set=$(awk -F# '{print $1}' stage2.fails | awk '!seen[$0]++' | tr '\n' ',' | sed "s/ //g" | sed "s/,,/,/g" | sed 's/\(.*\),/\1 /')

		#mvn -B -o -fn -DforkCount=1C -DreuseForks=false -Dtest=${failed_set} $MAVEN_SKIPS test &>> xPASTE_PROJ/toti.time #stage 3 (par)
		mvn -B -o -fn -Dtest=${failed_set} $MAVEN_SKIPS test &>> xPASTE_PROJ/toti.time #stage 3 (seq)

		cd xPASTE_PROJ

		time1=$(grep --text "\[INFO\] Total time:" toti.time | awk '{print $(NF-1)}')
		time2=$(grep --text "\[INFO\] Total time:" toti.time | awk '{print $NF}')

		time1=($time1)
		time2=($time2)

		len=${#time1[@]}
		
		if((${len} > 0)); then
			len=$((${len}-1));
		fi

		#convert all time to secs.
		for k in `seq 0 $len`;
		do
			if [[ ${time2[$k]} == *"m"* ]]; then
				x=$(echo ${time1[$k]} | awk '{split($0,a,":"); print a[1], a[2]}')
				x=($x)
				p=$(echo ${x[0]}*60+${x[1]} | bc)
				time1[$k]=$p
			elif [[ ${time2[$k]} == *"h"* ]]; then
				x=$(echo ${time1[$k]} | awk '{split($0,a,":"); print a[1], a[2]}')
				x=($x)
				p=$(echo ${x[0]}*60*60+${x[1]}*60 | bc)
				time1[$k]=$p
			fi
		done

		time_vec=${time1[@]}
		xtime=0;
		ytime=0;
		tot1=0;
		ct=0;
		for i in $time_vec
		do
			ct=$((${ct}+1));
			if ((${ct} == 1)); then
				xtime=$i
			else
				ytime=$(echo $ytime+$i | bc);
			fi
		done
	
		ttime=$(echo $ttime+$xtime+$ytime | bc);
		flakes1=0;
		collection=$(find ../ -type d -name 'surefire-reports')
		for i in $collection;
		do
			for j in `ls $i/*.txt 2> /dev/null`;
			do
				h=$(grep -e "Tests run: [0-9]*" $j | awk '{print $3}' | sed 's/.$//')
				
				if [[ $h != *"."* ]]; then
					s3_r=$((${s3_r}+h));
				fi
				
				ret1=$(grep -e "Failures: [1-9][0-9]*" -e "Errors: [1-9][0-9]*" $j | wc -l)
				if ((${ret1} == 1)); then
					tot1=$((${tot1}+1));
					x=$(grep -e "Failures: [1-9][0-9]*" $j | awk '{print $5}' | sed 's/.$//')
					y=$(grep -e "Errors: [1-9][0-9]*" $j | awk '{print $7}' | sed 's/.$//')
					flakes1=$((${flakes1}+x));
					flakes1=$((${flakes1}+y));
				fi
			done
		done

		fp=$((${xflakes}-${flakes1})); # count of flaky tests that passed when isolated and executed sequentially (after parallel execution).
		s2_f=${temp}
		s3_f=$flakes1
		if(($ytime == 0)); then
			s3_t=$xtime	
		fi

		s1_f=${s2_r} # corrected count

		#if(($flakes1 == 0)); then
			printf "\n#Tests run (stage 1 in ${s1_t} secs.): ${s1_r}" | tee -a unified.report
			printf "\n#Failed tests (stage 1): ${s1_f}" | tee -a unified.report
			printf "\n#Tests run (stage 2 in ${s2_t} secs.): ${s2_r}" | tee -a unified.report
			printf "\n#Failed tests (stage 2): ${s2_f}" | tee -a unified.report
			printf "\n#Tests run (stage 3 in ${s3_t} secs.): ${s3_r}" | tee -a unified.report
			printf "\n#Failed tests (stage 3): ${s3_f}" | tee -a unified.report
			#printf "\nPar time (stage 2): $xtime secs." | tee -a unified.report
			#printf "\nPar time (stage 3): $ytime secs." | tee -a unified.report
			printf "\nEnd-to-end time: $ttime secs.\n\n" | tee -a unified.report
		#fi
	fi
else
	time1=$(grep --text "\[INFO\] Total time:" tot.time | awk '{print $(NF-1)}')
	time2=$(grep --text "\[INFO\] Total time:" tot.time | awk '{print $NF}')

	time1=($time1)
	time2=($time2)

	len=${#time1[@]}
		
	if((${len} > 0)); then
		len=$((${len}-1));
	fi

	#convert all time to secs.

	for k in `seq 0 $len`;
	do
		if [[ ${time2[$k]} == *"m"* ]]; then
			x=$(echo ${time1[$k]} | awk '{split($0,a,":"); print a[1], a[2]}')
			x=($x)
			p=$(echo ${x[0]}*60+${x[1]} | bc)
			time1[$k]=$p
		elif [[ ${time2[$k]} == *"h"* ]]; then
			x=$(echo ${time1[$k]} | awk '{split($0,a,":"); print a[1], a[2]}')
			x=($x)
			p=$(echo ${x[0]}*60*60+${x[1]}*60 | bc)
			time1[$k]=$p
		fi
	done

	time_vec=${time1[@]}
	ct=0;
	for i in $time_vec
	do
		ct=$((${ct}+1));
		if ((${ct} == 1)); then
			xtime=$i
		else
			ytime=$(echo $ytime+$i | bc);
		fi
	done
	
	ttime=$(echo $xtime+$ytime | bc);

	printf "\nFailed tests (in par.): $flakes" | tee -a unified.report
	printf "\nPar time: $xtime secs." | tee -a unified.report
	printf "\nSeq-flk time: $ytime secs." | tee -a unified.report
	printf "\nEnd-to-end time: $ttime secs.\n\n" | tee -a unified.report
fi

rm -f *.time unifiedi.report
exit 0
