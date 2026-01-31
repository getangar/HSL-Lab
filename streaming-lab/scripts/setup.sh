#!/bin/bash
# =============================================================================
# 🍎 Streaming QoS Lab - Initial Setup Script
# =============================================================================
# Run this script ONCE after extracting to configure your server's IP address.
# This is required because some components use host networking.
#
# Usage: ./scripts/setup.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo -e "${CYAN}${BOLD}"
echo "╔═══════════════════════════════════════════════════════════════════════════╗"
echo "║                    🍎 Streaming QoS Lab - Setup                            ║"
echo "╚═══════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"
cd "$LAB_DIR"

# Detect server IP
DETECTED_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

if [ -z "$DETECTED_IP" ]; then
    DETECTED_IP="192.168.1.100"
fi

echo -e "${YELLOW}Detected server IP: ${GREEN}${DETECTED_IP}${NC}"
echo ""
read -p "Use this IP? [Y/n] or enter different IP: " USER_INPUT

if [ -z "$USER_INPUT" ] || [ "$USER_INPUT" = "Y" ] || [ "$USER_INPUT" = "y" ]; then
    SERVER_IP="$DETECTED_IP"
elif [ "$USER_INPUT" = "n" ] || [ "$USER_INPUT" = "N" ]; then
    read -p "Enter server IP: " SERVER_IP
else
    SERVER_IP="$USER_INPUT"
fi

echo ""
echo -e "${CYAN}Configuring lab for IP: ${GREEN}${BOLD}${SERVER_IP}${NC}"
echo ""

# Update nginx-edge config
echo -e "${YELLOW}[1/4] Updating nginx-edge/nginx.conf...${NC}"
sed -i "s/server [0-9.]*:4002;/server ${SERVER_IP}:4002;/" nginx-edge/nginx.conf
sed -i "s/server HOST_IP:4002;/server ${SERVER_IP}:4002;/" nginx-edge/nginx.conf
echo -e "${GREEN}✓ Done${NC}"

# Update prometheus config
echo -e "${YELLOW}[2/4] Updating prometheus/prometheus.yml...${NC}"

# Update grafana datasource
echo -e "${YELLOW}[2.5/4] Updating grafana/provisioning/datasources/datasources.yml...${NC}"
sed -i "s/HOST_IP/${SERVER_IP}/g" grafana/provisioning/datasources/datasources.yml
sed -i "s|http://[0-9.]*:4005|http://${SERVER_IP}:4005|g" grafana/provisioning/datasources/datasources.yml
echo -e "${GREEN}✓ Done${NC}"
sed -i "s/HOST_IP/${SERVER_IP}/g" prometheus/prometheus.yml
sed -i "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:4007/${SERVER_IP}:4007/g" prometheus/prometheus.yml
sed -i "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:9114/${SERVER_IP}:9114/g" prometheus/prometheus.yml
sed -i "s/[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}:4008/${SERVER_IP}:4008/g" prometheus/prometheus.yml
echo -e "${GREEN}✓ Done${NC}"

# Update docker-compose for origin exporter
echo -e "${YELLOW}[3/4] Updating docker-compose.yml...${NC}"
sed -i "s/HOST_IP/${SERVER_IP}/g" docker-compose.yml
sed -i "s|http://[0-9.]*:4002/stub_status|http://${SERVER_IP}:4002/stub_status|g" docker-compose.yml
echo -e "${GREEN}✓ Done${NC}"

# Make scripts executable
echo -e "${YELLOW}[4/4] Making scripts executable...${NC}"
chmod +x scripts/*.sh
echo -e "${GREEN}✓ Done${NC}"

# Check prerequisites
echo ""
echo -e "${CYAN}Checking prerequisites...${NC}"

if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${RED}✗ Docker not found. Install: curl -fsSL https://get.docker.com | sh${NC}"
    exit 1
fi

if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${RED}✗ Docker Compose not found${NC}"
    exit 1
fi

if command -v ffmpeg &> /dev/null; then
    echo -e "${GREEN}✓ FFmpeg installed${NC}"
else
    echo -e "${YELLOW}⚠ FFmpeg not found. Install: sudo apt install ffmpeg${NC}"
fi

echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}Setup complete!${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo -e "  1. Start the lab:        ${GREEN}docker-compose up -d${NC}"
echo -e "  2. Wait 30 seconds for services to initialize"
echo -e "  3. Start a test stream:  ${GREEN}./scripts/test-stream.sh${NC}"
echo -e "  4. Open the player:      ${GREEN}http://${SERVER_IP}:4004${NC}"
echo -e "  5. Open Grafana:         ${GREEN}http://${SERVER_IP}:4006${NC} (admin/streaming123)"
echo ""
echo -e "Run ${CYAN}./scripts/info.sh${NC} for all URLs and commands."
echo ""
