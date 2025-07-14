# Simple, production‑ready NGINX + RTMP image with HLS to tmpfs
FROM alpine:3.20

# Install nginx and RTMP dynamic module
RUN apk add --no-cache nginx nginx-mod-rtmp curl         && mkdir -p /mnt/ramdisk/hls         && chown -R nginx:nginx /mnt/ramdisk

# Copy custom configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose RTMP and HTTP ports
EXPOSE 1935 8080

# Health‑check
HEALTHCHECK CMD curl -fs http://localhost:8080/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
