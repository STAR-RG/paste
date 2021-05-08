# PASTE
Artefacts for the PASTE project on test-parallelization.

PASTE implementation
--------------------
All scripts in the directort `src`.

Projects included
-----------------
| \#  | Name                                            | \# Stars | \# Tests   | SHA     |
| --: | :---------------------------------------------- | -------: | ---------: | ------: |
| 1   | [accumulo](https://github.com/apache/accumulo)              | 861      | 514        | 76247b1 |
| 2   | [atlas](https://github.com/apache/atlas)                 | 839      | 1422       | acb9880 |
| 3   | [avro](https://github.com/apache/avro/)                 | 1807     | 10446      | 5bd7cfe |
| 4   | [biojava](https://github.com/biojava/biojava)              | 438      | 811        | 4d1cf58 |
| 5   | [cayenne](https://github.com/apache/cayenne)               | 250      | 2084       | 54cb1f9 |
| 6   | [Chronicle-Queue](https://github.com/OpenHFT/Chronicle-Queue)      | 2291     | 328        | 8754ad3 |
| 7   | [commons-collections](https://github.com/apache/commons-collections)   | 475      | 16923      | 3aae82c |
| 8   | [commons-io](https://github.com/apache/commons-io/)           | 767      | 1840       | c1ee777 |
| 9   | [datasketches-java](https://github.com/apache/datasketches-java/)    | 706      | 1490       | dab9542 |
| 10  | [dubbo](https://github.com/apache/dubbo)                 | 34954    | 3519       | b5c81d8 |
| 11  | [httpcomponents-client](https://github.com/apache/httpcomponents-client) | 1040     | 1865       | bde58d6 |
| 12  | [iotdb](https://github.com/apache/iotdb)                 | 1255     | 422        | 6f7eac8 |
| 13  | [kylin](https://github.com/apache/kylin/)                | 3015     | 1057       | d6073d2 |
| 14  | [maven](https://github.com/apache/maven/)                | 2490     | 1053       | 276c6a8 |
| 15  | [mina](https://github.com/apache/mina)                  | 776      | 371        | daf2a33 |
| 16  | [mina-sshd](https://github.com/apache/mina-sshd)             | 394      | 1790       | a0bbdf9 |
| 17  | [opennlp](https://github.com/apache/opennlp)               | 1024     | 791        | 7286f9c |
| 18  | [pdfbox](https://github.com/apache/pdfbox)                | 1403     | 1849       | 9daeaf6 |
| 19  | [ranger](https://github.com/apache/ranger)                | 489      | 552        | 58b51a3 |
| 20  | [ratis](https://github.com/apache/ratis/)                | 460      | 444        | 0c9913f |
| 21  | [rocketmq](https://github.com/apache/rocketmq/)             | 13740    | 372        | 3ae2517 |
| 22  | [shiro](https://github.com/apache/shiro)                 | 3419     | 856        | a85dfcd |
| 23  | [Strata](https://github.com/OpenGamma/Strata/)            | 603      | 16277      | 050745d |
| 24  | [soul](https://github.com/dromara/soul/)                | 3666     | 1081       | a99c9fc |
| 25  | [wicket](https://github.com/apache/wicket)                | 551      | 2699       | 34f78c8 |
|     |                                                 | -        | **70856**  | -       |


Dependencies
-------------------------
1. Java 8
2. Maven 3.6.3
3. Python3
4. Python3 gdown (if you do not have it will be installed automatically)

Steps to replicate results
--------------------------
```bash
cd src
bash get_projects.sh # downloads the above projects (and customized pom.xml) used in the experiments.
bash start.sh        # replication starts here.
```
Directory layout after the replication is completed
---------------------------------------------------
Directory `results` contains detailed (project-wise) execution logs of PASTE.

Artefacts tested on
-------------------
Processor: Tenth Generation Intel(R) Core(TM) i5-1035G1 CPU @ 1.00GHz<br>
CPUs: 8<br>
RAM: 8 GB<br>
Hard-disk: 512 GB SSD<br>
OS: Ubuntu 20.04.2 LTS<br>
Kernel: 5.4.0-42-generic<br>
Java: OpenJDK 1.8.0_282<br>
Maven: 3.6.3<br>
GNU bash: 5.0.17(1)-release

Known issues
------------
Installation (build) of a project may fail on a different system if the `~/.m2` directory (hidden) does not have the required dependencies (libraries)<br>
already present while the `mvn` build system explicitly assumes their presence. Currently, [cayenne](https://github.com/apache/cayenne) has installation issues.

Contact us
----------
paste.project.parallel@gmail.com
