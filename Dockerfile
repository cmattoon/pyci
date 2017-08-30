FROM gliderlabs/alpine:3.4
MAINTAINER Curtis Mattoon <cmattoon@cmattoon.com>
RUN apk add --update --no-cache \
    ca-certificates \
    python3 \
    && pip3 install --upgrade pip setuptools pylint pytest pytest-cov

RUN python3 -m venv /env \
    && source /env/bin/activate

ADD docker-entrypoint.sh /docker-entrypoint.sh
ADD pylintrc /etc/pylintrc

WORKDIR /test
VOLUME ["/test"]

ENTRYPOINT ["/docker-entrypoint.sh"]
