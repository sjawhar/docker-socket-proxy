ARG ALPINE_VERSION=3.15.0
FROM alpine:${ALPINE_VERSION}

ARG SOCAT_VERSION=1.7.4.2-r0
RUN apk add --no-cache socat=${SOCAT_VERSION}

ENV DOCKER_SOCKET=/var/run/docker.sock \
    LISTEN_PORT=2376 \
    LISTEN_SECURE=true \
    CERTS_DIR=/run/secrets \
    SERVER_CERT=server-cert.pem \
    SERVER_KEY=server-key.pem \
    CA_FILE=ca.pem

EXPOSE $LISTEN_PORT

COPY run.sh /
RUN chmod +x /run.sh

ENTRYPOINT ["/run.sh"]
CMD ["-ddd"]
