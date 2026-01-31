# 🍎 Streaming QoS Lab

A complete local lab environment for practicing video streaming monitoring, simulating Apple-like streaming infrastructure with Origin, Edge (CDN), and QoS monitoring.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              YOUR SERVER                                     │
│                                                                              │
│  ┌──────────────┐     ┌─────────────────┐     ┌─────────────────┐           │
│  │   Encoder    │     │  NGINX-RTMP     │     │   NGINX-Edge    │           │
│  │  (FFmpeg/OBS)│────▶│    (Origin)     │────▶│ (CDN Simulator) │           │
│  │              │RTMP │  HLS Packaging  │HTTP │   with Cache    │           │
│  └──────────────┘     └─────────────────┘     └─────────────────┘           │
│        :4001                :4002                    :4003                   │
│                                                        │                     │
│                                                        ▼                     │
│                               ┌─────────────────────────────────┐           │
│                               │      HLS Player (Browser)       │           │
│                               │    with Telemetry & Metrics     │           │
│                               └─────────────────────────────────┘           │
│                                             :4004                            │
│                                                                              │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │                         Monitoring Stack                              │   │
│  │  ┌────────────┐    ┌────────────┐    ┌────────────┐                  │   │
│  │  │ Prometheus │◀───│  Exporters │    │  Grafana   │                  │   │
│  │  │   :4005    │    │ :4007,9114 │    │   :4006    │                  │   │
│  │  └────────────┘    └────────────┘    └────────────┘                  │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 📋 Ports Used

| Port | Service | Description |
|------|---------|-------------|
| 4001 | RTMP Ingest | Send your stream here |
| 4002 | HLS Origin | Direct origin access (HTTP) |
| 4003 | HLS Edge | CDN-cached access (host network) |
| 4004 | Player UI | Web-based HLS player with metrics |
| 4005 | Prometheus | Metrics database |
| 4006 | Grafana | Dashboards (admin/streaming123) |
| 4007 | Origin Exporter | NGINX metrics for origin |
| 4008 | Node Exporter | System metrics |
| 9114 | Edge Exporter | NGINX metrics for edge (host network) |

## 🚀 Quick Start

```bash
# 1. Extract
tar -xzvf streaming-lab.tar.gz
cd streaming-lab

# 2. Run setup (REQUIRED - configures your IP)
chmod +x scripts/*.sh
./scripts/setup.sh

# 3. Start the lab
docker-compose up -d

# 4. Wait for services to start
sleep 30

# 5. Start test stream (in another terminal)
./scripts/test-stream.sh

# 6. Open in browser
# Player: http://YOUR_IP:4004
# Grafana: http://YOUR_IP:4006 (admin/streaming123)
```

## 🔧 Prerequisites

- **OS**: Ubuntu 22.04+ / Debian 11+
- **Docker**: 20.10+
- **Docker Compose**: v1.29+ or v2
- **FFmpeg**: For test streams

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Install FFmpeg
sudo apt install ffmpeg
```

## 📊 Understanding the Metrics

### CDN Cache Behavior

The Edge server adds `X-Cache-Status` headers:

| Status | Meaning |
|--------|---------|
| MISS | Not in cache, fetched from origin |
| HIT | Served from edge cache |
| EXPIRED | Was cached but expired |
| STALE | Serving stale while refreshing |

Test with curl:
```bash
curl -I http://YOUR_IP:4003/hls/test.m3u8 | grep X-Cache
curl -I http://YOUR_IP:4003/hls/test-1.ts | grep X-Cache
```

### Origin vs Edge Comparison

In the Grafana dashboard, you can compare:
- **Request Rate**: Edge should have more requests than Origin (cache hits)
- **Connections**: Edge handles client connections, Origin handles cache misses

**Example with good cache efficiency:**
```
Origin requests:  10/sec
Edge requests:   100/sec
→ 90% cache hit ratio
```

## 🛠️ Commands

```bash
# Start/Stop
docker-compose up -d
docker-compose down

# View logs
docker-compose logs -f
docker-compose logs -f nginx-rtmp
docker-compose logs -f nginx-edge

# Restart specific service
docker-compose restart nginx-edge
docker-compose restart prometheus

# Check status
docker-compose ps
./scripts/info.sh
```

## ⚠️ Troubleshooting

### Docker Network / iptables Issues

This lab uses `network_mode: host` for some containers to work around Docker bridge networking issues with iptables on some Linux systems.

If you see "context deadline exceeded" errors:
```bash
sudo systemctl restart docker
docker-compose down
docker-compose up -d
```

### Prometheus Targets DOWN

Check that setup.sh was run and IPs are configured:
```bash
grep "HOST_IP" prometheus/prometheus.yml  # Should show no results
cat prometheus/prometheus.yml | grep targets  # Should show your IP
```

### Stream Not Playing

```bash
# Check RTMP is receiving
curl http://localhost:4002/stat

# Check HLS exists
curl http://localhost:4002/hls/test.m3u8

# Check Edge can reach Origin
curl http://localhost:4003/hls/test.m3u8
```

### Grafana Shows "No Data"

1. Check Prometheus targets: http://YOUR_IP:4005/targets (all should be UP)
2. Check Grafana datasource: Settings → Data Sources → Prometheus → Save & Test
3. Update datasource URL to use your IP: `http://YOUR_IP:4005`

## 📚 Further Reading

- [Apple HLS Specification](https://developer.apple.com/documentation/http-live-streaming)
- [NGINX RTMP Module](https://github.com/arut/nginx-rtmp-module)
- [hls.js Documentation](https://github.com/video-dev/hls.js)
- [Prometheus Documentation](https://prometheus.io/docs)

---

Good luck with your streaming journey! 🍀
