# proxy-client

Dockerized Trojan proxy client with HTTP and SOCKS5 proxy support.

Uses [trojan-go](https://github.com/p4gefau1t/trojan-go) as the Trojan client and
[Privoxy](https://www.privoxy.org/) as the HTTP proxy, supporting WebSocket and MUX.

## Architecture

```
Browser / App
      │
      ├──→ HTTP  proxy  (Privoxy,  port 8118)
      │         │
      │         └──→ SOCKS5 (trojan-go, port 1080) ──→ Trojan Server
      │
      └──→ SOCKS5 proxy (trojan-go, port 1080) ──→ Trojan Server
```

## Quick Start

### Docker Compose（推荐）

1. 编辑 `docker-compose.yml`，填入你的 Trojan 节点信息
2. 启动：

```bash
docker compose up -d
```

查看日志：

```bash
docker compose logs -f
```

停止：

```bash
docker compose down
```

#### 使用自定义配置文件

如果你需要完全自定义 trojan-go 配置，创建 `trojan-config.json` 然后修改 `docker-compose.yml`：

```yaml
services:
  proxy-client:
    build: .
    container_name: proxy-client
    restart: unless-stopped
    ports:
      - "1080:1080"
      - "8118:8118"
    volumes:
      - ./trojan-config.json:/etc/trojan-go/config.json
```

### Docker Run

```bash
docker build -t proxy-client .

docker run -d \
    --name proxy-client \
    -p 1080:1080 \
    -p 8118:8118 \
    -e TROJAN_REMOTE_ADDR=your-server.com \
    -e TROJAN_REMOTE_PORT=443 \
    -e TROJAN_PASSWORD=your-password \
    proxy-client
```

挂载自定义配置文件：

```bash
docker run -d \
    --name proxy-client \
    -p 1080:1080 \
    -p 8118:8118 \
    -v /path/to/config.json:/etc/trojan-go/config.json \
    proxy-client
```

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `TROJAN_REMOTE_ADDR` | `example.com` | Trojan server address |
| `TROJAN_REMOTE_PORT` | `443` | Trojan server port |
| `TROJAN_PASSWORD` | `password` | Trojan password |
| `TROJAN_SNI` | Same as `TROJAN_REMOTE_ADDR` | TLS SNI hostname |
| `TROJAN_SSL_VERIFY` | `true` | Verify server TLS certificate |
| `TROJAN_WS_ENABLED` | `false` | Enable WebSocket transport |
| `TROJAN_WS_PATH` | `/` | WebSocket path |
| `TROJAN_WS_HOST` | Same as `TROJAN_SNI` | WebSocket Host header |
| `TROJAN_MUX_ENABLED` | `false` | Enable connection multiplexing |
| `LOCAL_ADDR` | `0.0.0.0` | Local SOCKS5 listen address |
| `LOCAL_PORT` | `1080` | Local SOCKS5 listen port |

## Exposed Ports

| Port | Protocol | Service |
|---|---|---|
| 1080 | SOCKS5 | trojan-go local proxy |
| 8118 | HTTP | Privoxy HTTP proxy |

## Helper Script

Install the helper script:

```bash
$ vi ./proxy              # Fill in your trojan server details at the top
$ echo `make` >> ~/.bashrc
```

Usage:

```bash
$ eval `proxy on`     # Start container and set http_proxy env vars
$ eval `proxy off`    # Stop container and unset env vars
```

Run a proxied Docker container:

```bash
$ docker run -it `proxy docker` ubuntu:22.04 bash
```

## WebSocket Example

For CDN-proxied Trojan nodes:

```bash
docker run -d \
    --name proxy-client \
    -p 1080:1080 \
    -p 8118:8118 \
    -e TROJAN_REMOTE_ADDR=cdn-node.example.com \
    -e TROJAN_REMOTE_PORT=443 \
    -e TROJAN_PASSWORD=your-password \
    -e TROJAN_SNI=your-domain.com \
    -e TROJAN_WS_ENABLED=true \
    -e TROJAN_WS_PATH=/ws \
    proxy-client
```

## Using the Proxy

HTTP proxy:

```bash
curl -x http://localhost:8118 https://httpbin.org/ip
```

SOCKS5 proxy:

```bash
curl --socks5 localhost:1080 https://httpbin.org/ip
```

Set system-wide:

```bash
export http_proxy=http://localhost:8118
export https_proxy=http://localhost:8118
```
