# nginx‑rtmp‑ramdisk

**Live‑streaming stack in one container.**  
* RTMP ingest on **rtmp://YOUR_HOST/live/STREAM_KEY**  
* Automatic HLS playlist/segment generation  
* Play via **http://YOUR_HOST:8080/hls/STREAM_KEY.m3u8**  
* All `.m3u8` playlists and `.ts` segments are written to a RAM‑disk (`tmpfs`) and automatically cleaned up.

## Folder layout

```
├── Dockerfile
├── docker-compose.yml   # optional convenience wrapper
└── nginx.conf
```

## Build

```bash
docker build -t nginx-rtmp-ramdisk .
```

## Run

**Bare `docker run`:**

```bash
docker run -d --name rtmp \
  -p 1935:1935 -p 8080:8080 \
  --tmpfs /mnt/ramdisk:rw,size=512m \
  nginx-rtmp-ramdisk
```

**With `docker‑compose`:**

```bash
docker compose up -d
```

## Streaming

1. **Ingest** (e.g. OBS):  
   `rtmp://YOUR_HOST/live/stream1`  (any name works)

2. **Playback:**  
   `http://YOUR_HOST:8080/hls/stream1.m3u8`

## Tuning

* Change `hls_fragment` (seconds per segment) and `hls_playlist_length` in `nginx.conf`.
* Adjust `size=` on the `tmpfs` mount (both in `docker run` and `docker-compose.yml`).
* Consider fronting with a CDN or reverse‑proxy for production traffic.

## Persistence & Recovery

* **All HLS artefacts live only in RAM** and are removed continuously (`hls_cleanup on`).  
  They disappear on container restart or memory pressure – ideal for low‑latency live streams without disk wear.

## Security hardening

* Container runs as **nginx** user by default.
* Health‑check on `http://localhost:8080/` for orchestration systems.
* Expose only required ports (1935, 8080). Use a firewall if needed.

---

*Generated on 2025-07-14T07:25:34.506680*
