FROM alpine:latest

WORKDIR /surfshark_proxy

HEALTHCHECK --interval=30s --timeout=20s --start-period=30s CMD curl -L 'https://ipinfo.io'

RUN apk add --update --no-cache \
    wget \
    bash \
    curl\
    coreutils \
    openvpn \
    unzip \
    privoxy

COPY . /surfshark_proxy/

CMD ["./bin/entrypoint.sh"]
