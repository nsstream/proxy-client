#!/usr/bin/env bash
set -e

CONFIG_FILE="/etc/trojan-go/config.json"

if [ ! -f "$CONFIG_FILE" ]; then
    TROJAN_REMOTE_ADDR="${TROJAN_REMOTE_ADDR:-example.com}"
    TROJAN_REMOTE_PORT="${TROJAN_REMOTE_PORT:-443}"
    TROJAN_PASSWORD="${TROJAN_PASSWORD:-password}"
    TROJAN_SNI="${TROJAN_SNI:-$TROJAN_REMOTE_ADDR}"
    TROJAN_SSL_VERIFY="${TROJAN_SSL_VERIFY:-true}"
    TROJAN_WS_ENABLED="${TROJAN_WS_ENABLED:-false}"
    TROJAN_WS_PATH="${TROJAN_WS_PATH:-/}"
    TROJAN_WS_HOST="${TROJAN_WS_HOST:-$TROJAN_SNI}"
    TROJAN_MUX_ENABLED="${TROJAN_MUX_ENABLED:-false}"
    LOCAL_ADDR="${LOCAL_ADDR:-0.0.0.0}"
    LOCAL_PORT="${LOCAL_PORT:-1080}"

    cat > "$CONFIG_FILE" <<-EOF
	{
	    "run_type": "client",
	    "local_addr": "${LOCAL_ADDR}",
	    "local_port": ${LOCAL_PORT},
	    "remote_addr": "${TROJAN_REMOTE_ADDR}",
	    "remote_port": ${TROJAN_REMOTE_PORT},
	    "password": ["${TROJAN_PASSWORD}"],
	    "ssl": {
	        "verify": ${TROJAN_SSL_VERIFY},
	        "verify_hostname": true,
	        "sni": "${TROJAN_SNI}",
	        "session_ticket": true,
	        "reuse_session": true,
	        "fingerprint": "chrome"
	    },
	    "websocket": {
	        "enabled": ${TROJAN_WS_ENABLED},
	        "path": "${TROJAN_WS_PATH}",
	        "host": "${TROJAN_WS_HOST}"
	    },
	    "mux": {
	        "enabled": ${TROJAN_MUX_ENABLED},
	        "concurrency": 8,
	        "idle_timeout": 60
	    }
	}
	EOF

    echo "Generated trojan-go config:"
    cat "$CONFIG_FILE"
fi

service privoxy start

exec /usr/local/bin/trojan-go -config "$CONFIG_FILE"
