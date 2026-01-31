#!/bin/bash
# =============================================================================
# 🍎 Streaming QoS Lab - Information Script
# =============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "YOUR_IP")

echo -e "${BLUE}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                    🍎 Streaming QoS Lab - Quick Reference                  ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}Server IP: ${GREEN}${BOLD}${SERVER_IP}${NC}"
echo ""

echo -e "${BLUE}${BOLD}═══ Service URLs ═══${NC}"
echo -e "  📺 ${CYAN}Player UI${NC}        ${GREEN}http://${SERVER_IP}:4004${NC}"
echo -e "  📊 ${CYAN}Grafana${NC}          ${GREEN}http://${SERVER_IP}:4006${NC}  ${YELLOW}(admin/streaming123)${NC}"
echo -e "  📈 ${CYAN}Prometheus${NC}       ${GREEN}http://${SERVER_IP}:4005${NC}"
echo -e "  📡 ${CYAN}RTMP Stats${NC}       ${GREEN}http://${SERVER_IP}:4002/stat${NC}"
echo -e "  🎬 ${CYAN}HLS Origin${NC}       ${GREEN}http://${SERVER_IP}:4002/hls/test.m3u8${NC}"
echo -e "  🌐 ${CYAN}HLS Edge (CDN)${NC}   ${GREEN}http://${SERVER_IP}:4003/hls/test.m3u8${NC}"
echo ""

echo -e "${BLUE}${BOLD}═══ Exporters ═══${NC}"
echo -e "  Origin Exporter:  ${GREEN}http://${SERVER_IP}:4007/metrics${NC}"
echo -e "  Edge Exporter:    ${GREEN}http://${SERVER_IP}:9114/metrics${NC}"
echo -e "  Node Exporter:    ${GREEN}http://${SERVER_IP}:4008/metrics${NC}"
echo ""

echo -e "${BLUE}${BOLD}═══ Start Test Stream ═══${NC}"
echo -e "${YELLOW}FFmpeg Test Pattern:${NC}"
echo -e "  ffmpeg -re -f lavfi -i testsrc=size=1280x720:rate=30 \\"
echo -e "    -f lavfi -i sine=frequency=440 \\"
echo -e "    -c:v libx264 -preset ultrafast -b:v 2000k \\"
echo -e "    -c:a aac -f flv rtmp://${SERVER_IP}:4001/live/test"
echo ""

echo -e "${YELLOW}OBS Studio:${NC}"
echo -e "  Server:     ${GREEN}rtmp://${SERVER_IP}:4001/live${NC}"
echo -e "  Stream Key: ${GREEN}test${NC}"
echo ""

echo -e "${BLUE}${BOLD}═══ Verify Cache Behavior ═══${NC}"
echo -e "  curl -I http://${SERVER_IP}:4003/hls/test.m3u8 | grep X-Cache"
echo -e "  curl -I http://${SERVER_IP}:4003/hls/test-1.ts | grep X-Cache"
echo ""

echo -e "${BLUE}${BOLD}═══ Docker Commands ═══${NC}"
echo -e "  Start:    ${GREEN}docker-compose up -d${NC}"
echo -e "  Stop:     ${GREEN}docker-compose down${NC}"
echo -e "  Logs:     ${GREEN}docker-compose logs -f${NC}"
echo -e "  Status:   ${GREEN}docker-compose ps${NC}"
echo ""
