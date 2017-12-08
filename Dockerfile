FROM alpine:3.6
RUN apk add --no-cache socat

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
