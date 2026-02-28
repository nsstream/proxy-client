FROM ubuntu:22.04
LABEL maintainer="proxy-client"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        privoxy \
        wget \
        unzip \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ARG TROJAN_GO_VERSION=v0.10.6
RUN wget -q -O /tmp/trojan-go.zip \
        "https://github.com/p4gefau1t/trojan-go/releases/download/${TROJAN_GO_VERSION}/trojan-go-linux-amd64.zip" && \
    unzip /tmp/trojan-go.zip -d /tmp/trojan-go && \
    install -m 755 /tmp/trojan-go/trojan-go /usr/local/bin/trojan-go && \
    rm -rf /tmp/trojan-go.zip /tmp/trojan-go

RUN mkdir -p /etc/trojan-go

ADD config /etc/privoxy/config
ADD entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

EXPOSE 1080 8118

ENTRYPOINT ["/root/entrypoint.sh"]
