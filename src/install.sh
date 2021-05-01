#!/bin/bash

mvn clean -fn -U -B install -Drat.skip=true -DskipTests 2>&1 | tee _install.out.txt
