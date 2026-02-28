# AGENTS.md

## Cursor Cloud specific instructions

This is a Dockerized Trojan proxy client project. The container bundles `trojan-go` (Trojan SOCKS5 client) and Privoxy (HTTP proxy).

### Prerequisites

- **Docker** is required. The cloud VM does not come with Docker pre-installed; it must be installed with the fuse-overlayfs storage driver and iptables-legacy workarounds (see system prompt Docker installation instructions).

### Build & Run

- **Build**: `docker build -t proxy-client .` from the repo root.
- **Run**: See `README.md` for `docker run` examples. The container accepts Trojan server configuration via environment variables (`TROJAN_REMOTE_ADDR`, `TROJAN_REMOTE_PORT`, `TROJAN_PASSWORD`, etc.) or a mounted config file at `/etc/trojan-go/config.json`.
- For local testing without a real Trojan server, use dummy values — trojan-go will start but fail to connect, while Privoxy will still respond on port 8118.
- **Verify Privoxy**: `curl --proxy http://localhost:8118 http://config.privoxy.org/` should return HTTP 200.

### Key Ports

| Port | Service | Protocol |
|------|---------|----------|
| 1080 | trojan-go | SOCKS5 |
| 8118 | Privoxy | HTTP |

### Notes

- There are no automated tests or linters in this repo. Verification is done by building the Docker image and confirming both Privoxy and trojan-go start inside the container.
- The `Makefile` has an `install` target that copies the `proxy` helper script to `~/bin`.
- The entrypoint auto-generates `/etc/trojan-go/config.json` from environment variables unless the file is already mounted.
