# AGENTS.md

## Cursor Cloud specific instructions

This is a Dockerized Shadowsocks client project. The entire product is a Docker container that bundles `sslocal` (Shadowsocks SOCKS5 client) and Privoxy (HTTP proxy).

### Prerequisites

- **Docker** is required. The cloud VM does not come with Docker pre-installed; it must be installed with the fuse-overlayfs storage driver and iptables-legacy workarounds (see system prompt Docker installation instructions).

### Build & Run

- **Build**: `docker build -t shadowsocks-client .` from the repo root.
- **Run**: See `README.md` for `docker run` examples. The container requires Shadowsocks server connection parameters (`-s`, `-p`, `-k`, `-m`). For local testing without a real server, use dummy values (e.g., `-s 127.0.0.1 -p 8388 -k testpassword -m aes-256-cfb`).
- **Verify Privoxy**: `curl --proxy http://localhost:8118 http://config.privoxy.org/` should return HTTP 200.

### Key Ports

| Port | Service | Protocol |
|------|---------|----------|
| 1080 | sslocal (Shadowsocks) | SOCKS5 |
| 8118 | Privoxy | HTTP |

### Notes

- There are no automated tests, linters, or CI test suites in this repo. Verification is done by building the Docker image and confirming both Privoxy and sslocal start inside the container.
- The `Makefile` has an `install` target that copies the `proxy` helper script to `~/bin`.
- The `proxy` helper script contains `gsettings` calls that will fail in headless environments; this is expected and non-blocking.
- The Dockerfile uses a legacy `MAINTAINER` instruction (deprecated in favor of `LABEL`); Docker emits a warning during build but it does not affect functionality.
