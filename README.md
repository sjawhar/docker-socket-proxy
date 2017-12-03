## Docker Socket Secure Proxy
This simple Docker image uses socat to securely proxy TCP requests to the Docker daemon socket without having to reconfigure and relaunch the Docker daemon. It is designed to be highly configureable, and is compatible with both single-host and swarm mode Docker.

By default, it uses port 2376, though this is also configurable simply by forwarding a different port on the host to the container. This image can also be run without TLS (see below), though that is obviously not so much with the security.

Comments, issues, and PRs are always welcome. If this image doesn't quite fulfill your needs, let me know and maybe we can improve it!

## Usage
1. If you don't already have CA, server, and client certs and keys, you can find helpful instructions to create them in [the Docker docs](https://docs.docker.com/engine/security/https). When doing so, make sure you use a `$HOST` value that is the FQDN clients will be using to access the Docker host.
2. Back these files up, then either:
    - Place `ca.pem`, `server-cert.pem`, and `server-key.pem` in a folder somewhere you can mount in the container.
    - Add these files as secrets in the swarm.
3. Run the container! See below for environment variables and additional commands, but in general it will look something like:
```bash
docker run -d -p 2376:2376 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $HOST_CERTS_DIR:$CERTS_DIR:ro -e $CERTS_DIR \
    sjawhar/docker-socket-proxy
```
4. Copy `ca.pem`, `cert.pem`, and `key.pem` to your client machine.
5. Run commands against the host:
```bash
docker -H tcp://$HOST:2376 --tlsverify --tlscacert=ca.pem --tlscert=cert.pem --tlskey=key.pem info
```
You can also use either of the provided docker-compose files as a starting point:
    - [docker-compose.yml](https://github.com/sjawhar/docker-socket-proxy/blob/master/docker-compose.yml)
    - [docker-compose.swarm.yml](https://github.com/sjawhar/docker-socket-proxy/blob/master/docker-compose.swarm.yml)


## Why?  
Maybe you want to test something out and don't want to risk messing up your Docker machine when reconfiguring the daemon. Maybe you want an easy way to randomly change the port on which the Docker socket can be reached, just to keep people on their toes. Maybe (like me) you just like the idea of _everything_ being in a container.

Personally, I use it so that CI/CD build agents running on the intranet can securely deploy to production and staging environments.

## Environment Variables
- `DOCKER_SOCKET`: The location of the Docker socket inside the container. Defaults to `/var/run/docker.sock`.
- `CERTS_DIR`: The file path inside the container containing the certs. Defaults to `/run/secrets` for compatibility with swarm secrets.
- `SERVER_CERT`: The name of the server certificate file inside `CERTS_DIR`. Defaults to `server-cert.pem`.
- `SERVER_KEY`: The name of the server key file inside `CERTS_DIR`. Defaults to `server-key.pem`.
- `CA_FILE`: The name of the CA certs inside `CERTS_DIR`. Defaults to `ca.pem`.
- `LISTEN_PORT`: The port on which socat will listen. Defaults to 2376, and you probably won't need to change it since you can just forward a different port from the host.
- `LISTEN_SECURE`: Defaults to `true`, which enabled TLS. If `false`, disables TLS and uses `TCP-LISTEN`. **If you set `LISTEN_SECURE=false` and ingress traffic can reach this container, you make it much more likely that you're going to have a bad time.**

## Additional Commands
Any commands using in `docker run` will be passed as options to socat. You can use this to customize things like verbosity (`-ddd`), log format (`-lmlocal2`), timeout interval (`-t 1000000`), and more. See the [socat docs](http://www.dest-unreach.org/socat/doc/socat.html) for more info.


