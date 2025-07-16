#!/bin/sh
set -e

# Example env:
#   PASS_STREAM=true
#   PASS_URL="rtmp://edge1/live,rtmp://edge2/live , rtmp://edge3/live"

############################################
# 1. Begin the fixed part of nginx.conf
############################################
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

############################################
# 2. Conditionally add one or many push targets
############################################
if [ "$PASS_STREAM" = "true" ] && [ -n "$PASS_URL" ]; then
    # Temporarily set IFS to comma and whitespace
    OLD_IFS=$IFS
    IFS=','
    for TARGET in $PASS_URL; do
        # Trim leading/trailing whitespace
        TARGET=$(echo "$TARGET" | xargs)
        [ -n "$TARGET" ] && echo "            push $TARGET;" >> /etc/nginx/nginx.conf
    done
    IFS=$OLD_IFS
fi

############################################
# 3. Close the RTMP / HTTP blocks
############################################
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

        location / {
            types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /mnt/ramdisk/hls;
            add_header Cache-Control no-cache;
        }

        location /stat {
            rtmp_stat all;

            # Use this stylesheet to view XML as web page
            # in browser
            rtmp_stat_stylesheet stat.xsl;
        }

        location /stat.xsl {
            # XML stylesheet to view RTMP stats.
            # Copy stat.xsl wherever you want
            # and put the full directory path here
            root /stat.xsl/;
        }

        location /health {
            access_log off;
            default_type text/plain;
            return 200 'OK';
        }
    }
}
NGINX_CONF

# 4. Start nginx in foreground
exec nginx -g 'daemon off;'
