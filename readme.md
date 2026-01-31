# 🍎 Streaming QoS Lab

A complete local lab environment simulating professional video streaming infrastructure similar to **Apple TV+**, **Netflix**, or other major streaming platforms.

Perfect for learning HLS streaming, CDN caching, and QoS monitoring — ideal preparation for Site Reliability Engineer or Operations Engineer roles at streaming companies.

![Architecture](https://img.shields.io/badge/Architecture-Origin%20%2B%20Edge%20CDN-blue)
![Docker](https://img.shields.io/badge/Docker-Required-2496ED?logo=docker)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Usage](#-usage)
- [Monitoring](#-monitoring)
- [Scripts](#-scripts)
- [Troubleshooting](#-troubleshooting)
- [Learn More](#-learn-more)

---

## ✨ Features

- **RTMP Ingest** — Receive live streams from FFmpeg, OBS, or any RTMP encoder
- **HLS Packaging** — Automatic conversion from RTMP to HTTP Live Streaming
- **CDN Simulation** — Edge caching layer with `X-Cache-Status` headers (HIT/MISS)
- **Web Player** — Browser-based HLS player with real-time metrics
- **Full Observability** — Prometheus + Grafana with pre-configured dashboards
- **Cache Analytics** — Compare Origin vs Edge traffic to understand CDN efficiency

---

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              YOUR SERVER                                    │
│                                                                             │
│  ┌──────────────┐     ┌─────────────────┐     ┌─────────────────┐           │
│  │   Encoder    │     │  NGINX-RTMP     │     │   NGINX-Edge    │           │
│  │  (FFmpeg/OBS)│────▶│    (Origin)     │────▶│ (CDN Simulator) │           │
│  │              │RTMP │  HLS Packaging  │HTTP │   with Cache    │           │
│  └──────────────┘     └─────────────────┘     └─────────────────┘           │
│        :4001                :4002                    :4003                  │
│                                                        │                    │
│                                                        ▼                    │
│                               ┌─────────────────────────────────┐           │
│                               │      HLS Player (Browser)       │           │
│                               │    with Telemetry & Metrics     │           │
│                               └─────────────────────────────────┘           │
│                                             :4004                           │
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                         Monitoring Stack                             │   │
│  │                                                                      │   │
│  │    Prometheus ◀──── Origin Exporter (:4007)                          │   │
│  │      :4005    ◀──── Edge Exporter   (:9114)     ────▶  Grafana       │   │
│  │               ◀──── Node Exporter   (:4008)            :4006         │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Component Overview

| Component | Port | Description |
|-----------|------|-------------|
| **NGINX-RTMP** | 4001 (RTMP), 4002 (HTTP) | Origin server — receives RTMP, outputs HLS |
| **NGINX-Edge** | 4003 | CDN simulator — caches HLS content |
| **Web Player** | 4004 | Browser-based HLS player with metrics |
| **Prometheus** | 4005 | Time-series metrics database |
| **Grafana** | 4006 | Visualization dashboards |
| **Origin Exporter** | 4007 | NGINX metrics for Origin |
| **Node Exporter** | 4008 | System metrics (CPU, memory, network) |
| **Edge Exporter** | 9114 | NGINX metrics for Edge |

### Data Flow

1. **Encoder** sends RTMP stream to Origin (`:4001`)
2. **Origin** packages RTMP into HLS segments (`.ts`) and playlist (`.m3u8`)
3. **Edge** caches content from Origin and serves to clients
4. **Player** fetches HLS from Edge, displays video with metrics
5. **Prometheus** scrapes metrics from all exporters
6. **Grafana** visualizes Origin vs Edge performance

---

## 📋 Prerequisites

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 2 cores | 4+ cores |
| RAM | 4 GB | 8+ GB |
| Disk | 10 GB free | 20+ GB free |
| OS | Ubuntu 22.04 / Debian 11 | Ubuntu 24.04 |

### Required Software

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
# ⚠️ Log out and back in for group changes to take effect

# Install Docker Compose (usually included with Docker)
sudo apt install docker-compose-plugin

# Install FFmpeg (for test streams)
sudo apt install ffmpeg
```

---

## 🚀 Quick Start

```bash
# 1. Clone or extract the project
git clone <repository-url>
cd streaming-lab

# 2. Run setup (REQUIRED — configures your server's IP)
chmod +x scripts/*.sh
./scripts/setup.sh

# 3. Start all services
docker-compose up -d

# 4. Wait for services to initialize
sleep 30

# 5. Start a test stream (in another terminal)
./scripts/test-stream.sh

# 6. Open in browser
#    Player:  http://YOUR_IP:4004
#    Grafana: http://YOUR_IP:4006 (admin / streaming123)
```

---

## 🎬 Usage

### Starting a Stream

#### Option 1: Test Pattern (no file needed)

```bash
./scripts/test-stream.sh
```

#### Option 2: FFmpeg with Test Pattern

```bash
ffmpeg -re \
  -f lavfi -i "testsrc=size=1280x720:rate=30" \
  -f lavfi -i "sine=frequency=440:sample_rate=48000" \
  -c:v libx264 -preset ultrafast -tune zerolatency -b:v 2000k \
  -c:a aac -b:a 128k \
  -f flv rtmp://YOUR_IP:4001/live/test
```

#### Option 3: Stream a Video File

```bash
ffmpeg -re -i /path/to/video.mp4 \
  -c:v libx264 -preset veryfast -b:v 2500k \
  -c:a aac -b:a 128k \
  -f flv rtmp://YOUR_IP:4001/live/test
```

#### Option 4: Loop a Video File

```bash
ffmpeg -re -stream_loop -1 -i /path/to/video.mp4 \
  -c:v libx264 -preset veryfast -b:v 2500k \
  -c:a aac -b:a 128k \
  -f flv rtmp://YOUR_IP:4001/live/test
```

#### Option 5: OBS Studio

| Setting | Value |
|---------|-------|
| Server | `rtmp://YOUR_IP:4001/live` |
| Stream Key | `test` (or any name) |

### Watching the Stream

| Method | URL |
|--------|-----|
| **Web Player** | `http://YOUR_IP:4004` |
| **VLC** | `http://YOUR_IP:4003/hls/test.m3u8` |
| **ffplay** | `ffplay http://YOUR_IP:4003/hls/test.m3u8` |
| **Safari (direct)** | `http://YOUR_IP:4003/hls/test.m3u8` |

### Understanding Cache Behavior

The Edge server adds `X-Cache-Status` headers:

| Status | Meaning |
|--------|---------|
| `MISS` | Not in cache — fetched from Origin |
| `HIT` | Served from Edge cache |
| `EXPIRED` | Was cached but expired — refreshed from Origin |
| `STALE` | Serving stale content while refreshing |

#### Test with curl

```bash
# Check playlist (usually MISS — must stay fresh)
curl -I http://YOUR_IP:4003/hls/test.m3u8 2>/dev/null | grep X-Cache

# Check segment (first MISS, then HIT)
curl -I http://YOUR_IP:4003/hls/test-100.ts 2>/dev/null | grep X-Cache
curl -I http://YOUR_IP:4003/hls/test-100.ts 2>/dev/null | grep X-Cache
```

#### Why Live Streams Show MISS

For **live streaming**, you'll often see MISS on `.ts` segments because each segment is newly created. The CDN value becomes clear with multiple viewers:

| Viewers | Origin Load | Edge Load | Cache Efficiency |
|---------|-------------|-----------|------------------|
| 1 | 1 req/s | 1 req/s | 0% (no benefit) |
| 100 | 1 req/s | 100 req/s | 99% |
| 10,000 | 1 req/s | 10,000 req/s | 99.99% |

---

## 📊 Monitoring

### Grafana Dashboard

**URL:** `http://YOUR_IP:4006`  
**Login:** `admin` / `streaming123`

Navigate to: **Dashboards → Streaming Lab → Streaming QoS Overview**

The dashboard shows:
- ✅ Origin & Edge Status (UP/DOWN)
- 📈 Request Rate comparison (Origin vs Edge)
- 🔗 Active Connections (Origin vs Edge)
- 💻 System CPU & Memory Usage
- 🌐 Network Throughput

### Prometheus Queries

**URL:** `http://YOUR_IP:4005`

Useful queries:

```promql
# Request rate comparison
rate(nginx_http_requests_total{instance="origin"}[1m])
rate(nginx_http_requests_total{instance="edge"}[1m])

# Active connections
nginx_connections_active{instance="origin"}
nginx_connections_active{instance="edge"}

# CPU usage percentage
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage percentage
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

### RTMP Statistics

**URL:** `http://YOUR_IP:4002/stat`

Shows active streams, connected clients, bitrates, and stream metadata.

---

## 📜 Scripts

| Script | Description |
|--------|-------------|
| `./scripts/setup.sh` | **Required** — Configures server IP in all config files |
| `./scripts/test-stream.sh` | Starts FFmpeg test pattern stream |
| `./scripts/info.sh` | Shows all URLs and useful commands |

### Cache Test Scripts

Test HLS cache behavior interactively:

```bash
# Bash version
./hls-cache-test.sh test

# Python version
python3 hls-cache-test.py test
```

---

## 🛠 Troubleshooting

### Setup Not Run

**Symptom:** Prometheus targets DOWN, Grafana shows "No data"

```bash
./scripts/setup.sh
docker-compose down
docker-compose up -d
```

### Docker Network Issues

**Symptom:** "context deadline exceeded" errors

```bash
sudo systemctl restart docker
docker-compose down
docker-compose up -d
```

### Stream Not Playing

```bash
# Check RTMP is receiving
curl http://localhost:4002/stat

# Check HLS segments exist
curl http://localhost:4002/hls/test.m3u8

# Check Edge can reach Origin
curl http://localhost:4003/hls/test.m3u8

# Check container logs
docker-compose logs nginx-rtmp | tail -20
docker-compose logs nginx-edge | tail -20
```

### Port Already in Use

```bash
sudo lsof -i :4003
sudo netstat -tlnp | grep 4003
```

### Grafana Data Source Error

1. Go to **Settings → Data Sources → Prometheus**
2. Set URL to: `http://YOUR_IP:4005`
3. Click **Save & Test**

---

## 🐳 Docker Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v

# View logs
docker-compose logs -f
docker-compose logs -f nginx-rtmp
docker-compose logs -f nginx-edge

# Restart specific service
docker-compose restart nginx-edge
docker-compose restart prometheus

# Check status
docker-compose ps
```

---

## 📚 Learn More

### HLS Protocol

- [Apple HLS Authoring Specification](https://developer.apple.com/documentation/http-live-streaming)
- [HTTP Live Streaming (Wikipedia)](https://en.wikipedia.org/wiki/HTTP_Live_Streaming)

### Technologies Used

- [NGINX RTMP Module](https://github.com/arut/nginx-rtmp-module)
- [hls.js](https://github.com/video-dev/hls.js) — JavaScript HLS client
- [Prometheus](https://prometheus.io/docs)
- [Grafana](https://grafana.com/docs)

### CDN & Streaming Concepts

- [How Video Streaming Works](https://howvideo.works/)
- [CDN Caching Strategies](https://www.cloudflare.com/learning/cdn/what-is-caching/)

---

## 📄 License

MIT License — Feel free to use, modify, and distribute.

---

## 🙏 Acknowledgments

Built for learning and interview preparation. Good luck with your streaming journey! 🍀