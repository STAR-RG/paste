#!/bin/bash

mvn -fn -B -Drat.skip=true test 2>&1 | tee _test.out.txt
