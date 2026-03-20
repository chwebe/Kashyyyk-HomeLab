FROM python:3.14-alpine3.23
RUN pip install --no-cache-dir ansible==13.2.0 && \
    apk add --no-cache curl openssh-client 