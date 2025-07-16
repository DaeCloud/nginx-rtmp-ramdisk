# NGINX‑RTMP with optional RTMP push (relay) controlled by env vars
FROM alpine:3.20

# Install nginx, RTMP module, curl for healthcheck
RUN apk add --no-cache nginx nginx-mod-rtmp curl

# Directory for RAM HLS
RUN mkdir -p /mnt/ramdisk/hls && chown -R nginx:nginx /mnt/ramdisk

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 1935 8080

HEALTHCHECK CMD curl -fs http://localhost:8080/health || exit 1

ENTRYPOINT ["/entrypoint.sh"]
