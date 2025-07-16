# nginx‑rtmp‑ramdisk (env‑push version)

Production‑ready NGINX‑RTMP container that:
1. Accepts RTMP ingest at **rtmp://HOST/live/STREAM_KEY**
2. Generates HLS playlists/segments in a RAM disk and serves them over HTTP `:8080`
3. **Optionally relays** (pushes) the same stream to another RTMP endpoint, controlled by environment variables.

## Environment variables

| Variable | Purpose | Example |
| -------- | ------- | ------- |
| `PASS_STREAM` | `"true"` to enable RTMP push, anything else / unset disables it | `true` |
| `PASS_URL` | Destination RTMP URL | `rtmp://edge.example.com/live` |

If `PASS_STREAM=true` **and** `PASS_URL` is set, the container inserts:  
```nginx
push $PASS_URL;
```
into the `application live` block at runtime.

## Build

```bash
docker build -t nginx-rtmp-ramdisk:latest .
```

## Run quick test (with relay)

```bash
docker run -d --name rtmp \
  -p 1935:1935 -p 8080:8080 \
  --tmpfs /mnt/ramdisk:rw,size=512m \
  -e PASS_STREAM=true \
  -e PASS_URL=rtmp://relay.example.com/live \
  nginx-rtmp-ramdisk:latest
```

## Docker‑compose

`docker-compose.yml` is included with placeholders for the env vars.

## Streaming

| Action | URL |
| ------ | --- |
| **Publish** | `rtmp://HOST/live/stream1` |
| **Watch HLS** | `http://HOST:8080/hls/stream1.m3u8` |

When relay is enabled, NGINX pushes whatever is published to `$PASS_URL` as well.

---

*Generated 2025-07-16T07:48:06.165180*
