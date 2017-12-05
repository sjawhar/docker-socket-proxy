#!/bin/sh

if [ "$LISTEN_SECURE" == "false" ]; then
    socat "$@" TCP-LISTEN:"$LISTEN_PORT",reuseaddr,fork UNIX-CLIENT:"$DOCKER_SOCKET"
else
    socat "$@" \
        OPENSSL-LISTEN:"$LISTEN_PORT",reuseaddr,fork,certificate="$CERTS_DIR/$SERVER_CERT",key="$CERTS_DIR/$SERVER_KEY",cafile="$CERTS_DIR/$CA_FILE" \
        UNIX-CLIENT:"$DOCKER_SOCKET"
fi
