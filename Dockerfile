FROM ubuntu:20.04

RUN apt-get update && apt-get -y install curl git python3-pip

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
