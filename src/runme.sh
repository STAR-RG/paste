#!/bin/bash

rm -f *.log
bash automate_soundy.sh 2>&1 | tee automate.log
