FROM ubuntu:latest

RUN apt-get update && apt-get -y install curl git python3-pip pipx

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
