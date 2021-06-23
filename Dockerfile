FROM maven:3.8-openjdk-8

ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && apt-get install -y python3 python3-pip

RUN pip3 install --upgrade pip

COPY . /home/paste

WORKDIR /home/paste

RUN chmod +x ./get_projects.sh && ./get_projects.sh


