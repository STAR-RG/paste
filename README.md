# PASTE
Artefacts for the PASTE project on test-parallelization.

PASTE implementation
--------------------
All scripts in the directort [src].

Projects included
-----------------
accumulo-76247b1739dd3042cb2d959a7a99f0cf1bcb1324<br>
avro-5bd7cfe0bf742d0482bf6f54b4541b4d22cc87d9<br>
Chronicle-Queue-8754ad3c6320cf79816b769e56f1a27a6b5ae753<br>
commons-collections-3aae82cbaaaf539bf3f54cd6a0679efc123f2c8e<br>
commons-io-c1ee77787f74ce9b660bf377462059d084458fef<br>
datasketches-java-dab95426fe4d3c568850750852f5e57cf2aa146d<br>
httpcomponents-client-bde58d6addd4d693aa5aedfafc1406e9952ff22b<br>
maven-276c6a8dc445cbaffb2bc2a6344f54abeb9b4311<br>
mina-daf2a33fed5fccb096ce75ab9263ec9a48561942<br>
ratis-0c9913f602a49231621323bc903d91d5bbb06cb7<br>
rocketmq-3ae251751586b940b7467284966ec4fe93f86be1<br>
Strata-050745da318a85033b243f4b45f98f2486c7c02a<br>
wicket-34f78c853500356135918ef16356bd669bb96422<br>

Steps to replicate results
--------------------------
```bash get_projects.sh``` # downloads the above projects (and customized pom.xml) used in the experiments.<br>
```bash clean.sh``` # clean up<br>
```bash start.sh``` # replication starts here<br>

Directory layout after the replication is completed
---------------------------------------------------
Directory [results] contains detailed (project-wise) execution logs of PASTE.

Artefacts tested on
-------------------
Processor: Intel(R) Core(TM) i5-1035G1 CPU @ 1.00GHz<br>
CPUs: 8<br>
RAM: 8 GB<br>
Hard-disk: 512 GB SSD<br>
OS: Ubuntu 20.04.2 LTS<br>
Kernel: 5.4.0-42-generic<br>
Java: OpenJDK 1.8.0_282<br>
Maven: 3.6.3<br>
GNU bash: 5.0.17(1)-release

Contact us
----------
paste.project.parallel@gmail.com
