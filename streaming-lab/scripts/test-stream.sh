#!/bin/bash
# =============================================================================
# 🍎 Streaming QoS Lab - Test Stream Generator
# =============================================================================
# Generates a test video stream using FFmpeg and sends it to the RTMP server.
#
# Usage:
#   ./test-stream.sh                    # Uses localhost
#   ./test-stream.sh 192.168.1.100      # Specify server IP
#   ./test-stream.sh 192.168.1.100 live # Specify stream name
#
# The test pattern includes:
# - SMPTE color bars
# - Timecode overlay
# - 440 Hz test tone
# =============================================================================

# Default values
SERVER_IP="${1:-localhost}"
STREAM_NAME="${2:-test}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           🍎 Streaming QoS Lab - Test Stream                  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo -e "  Server:      ${GREEN}rtmp://${SERVER_IP}:4001/live/${STREAM_NAME}${NC}"
echo -e "  Resolution:  ${GREEN}1280x720 @ 30fps${NC}"
echo -e "  Video:       ${GREEN}H.264, 2500 kbps${NC}"
echo -e "  Audio:       ${GREEN}AAC, 128 kbps, 440 Hz tone${NC}"
echo ""
echo -e "${YELLOW}Watch the stream:${NC}"
echo -e "  Player:      ${GREEN}http://${SERVER_IP}:4004${NC}"
echo -e "  HLS URL:     ${GREEN}http://${SERVER_IP}:4003/hls/${STREAM_NAME}.m3u8${NC}"
echo ""
echo -e "${RED}Press Ctrl+C to stop streaming${NC}"
echo ""

# Check if FFmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo -e "${RED}Error: FFmpeg is not installed${NC}"
    echo "Install with: sudo apt install ffmpeg"
    exit 1
fi

# Generate test stream
# Parameters explained:
# -re                      Read input at native frame rate (real-time)
# -f lavfi                 Use libavfilter virtual input
# -i testsrc=...           Generate test video pattern
# -f lavfi -i sine=...     Generate test audio tone
# -c:v libx264             Use H.264 video codec
# -preset ultrafast        Fastest encoding (low latency)
# -tune zerolatency        Optimize for low latency streaming
# -profile:v baseline      Most compatible H.264 profile
# -b:v 2500k               Video bitrate
# -maxrate/bufsize         Rate control for consistent bitrate
# -pix_fmt yuv420p         Standard pixel format for compatibility
# -g 60                    Keyframe every 2 seconds (at 30fps)
# -c:a aac                 Use AAC audio codec
# -f flv                   Output as FLV (required for RTMP)

ffmpeg -re \
  -f lavfi -i "testsrc=size=1280x720:rate=30" \
  -f lavfi -i "sine=frequency=440:sample_rate=48000" \
  -c:v libx264 \
  -preset ultrafast \
  -tune zerolatency \
  -profile:v baseline \
  -b:v 2500k \
  -maxrate 2500k \
  -bufsize 5000k \
  -pix_fmt yuv420p \
  -g 60 \
  -keyint_min 60 \
  -c:a aac \
  -b:a 128k \
  -ar 48000 \
  -f flv \
  "rtmp://${SERVER_IP}:4001/live/${STREAM_NAME}"

echo ""
echo -e "${YELLOW}Stream ended.${NC}"
