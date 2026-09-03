FROM python:3.14-alpine3.23

RUN pip install --no-cache-dir ansible==13.2.0 && \
    apk add --no-cache curl openssh-client && \
    addgroup -g 1000 ansible && \
    adduser -D -u 1000 -G ansible -h /home/ansible -s /bin/sh ansible

ENV HOME=/home/ansible

USER ansible
WORKDIR /home/ansible