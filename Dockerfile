FROM python:3

RUN pip3 install --upgrade cloudsmith-cli

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
