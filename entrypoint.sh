#!/bin/sh
set -e

# Build nginx.conf dynamically to insert optional RTMP push target
cat > /etc/nginx/nginx.conf <<'NGINX_CONF'
load_module modules/ngx_rtmp_module.so;

worker_processes auto;
events { worker_connections 1024; }

rtmp {
    server {
        listen 1935;
        chunk_size 4096;

        application live {
            live on;
            record off;

            hls on;
            hls_path /mnt/ramdisk/hls;
            hls_fragment 3s;
            hls_playlist_length 60s;
            hls_cleanup on;
NGINX_CONF

# Append push directive if requested
if [ "$PASS_STREAM" = "true" ] && [ -n "$PASS_URL" ]; then
    echo "                push $PASS_URL;" >> /etc/nginx/nginx.conf
fi

# Close the RTMP and main blocks
cat >> /etc/nginx/nginx.conf <<'NGINX_CONF'
        }
    }
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile      on;
    keepalive_timeout  65;

    server {
        listen 8080;
        server_name _;

        location /hls/ {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /mnt/ramdisk;
            add_header Cache-Control no-cache;
        }

        location /health {
            access_log off;
            default_type text/plain;
            return 200 'OK';
        }

        location / {
            return 200 "NGINX‑RTMP HLS server running\n";
        }
    }
}
NGINX_CONF

# Launch nginx
exec nginx -g 'daemon off;'
