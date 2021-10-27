# Surfshark proxy

Docker container that exposes an HTTP proxy that pushes all traffic through [Surfshark VPN](https://surfshark.com/)

> NOTE: The project is still in progress. A lot of things need improvements...

### Container environment configuration

The container can be configured with the following environment variables.

| Name                         | Required | Description                                                          |
| ---------------------------- | -------- | -------------------------------------------------------------------- | 
| SURFSHARK_USERNAME           | True     | Surfshark [username](https://my.surfshark.com/vpn/manual-setup/main) | 
| SURFSHARK_PASSWORD           | True     | Surfshark [password](https://my.surfshark.com/vpn/manual-setup/main) | 
| CONNECTION_TYPE              | False    | Connection type (TCP or UDP) - defaults to: `UDP`                    | 

### Usage

When the container is up and running you can connect to the HTTP server running on: `http://127.0.0.1:8888`

```bash
# start the container
docker-compose up surfshark-proxy -d
curl --proxy http://127.0.0.1:8888 https://ipinfo.io/ip
```
