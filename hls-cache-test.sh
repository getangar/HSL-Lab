#!/bin/bash
# =============================================================================
# HLS Cache Test Script
# Usage: ./hls-cache-test.sh [stream_name]
# Example: ./hls-cache-test.sh test
# =============================================================================

SERVER="192.168.50.130"
STREAM="${1:-test}"

echo "📡 Fetching playlist for stream: $STREAM"
echo "=============================================="

# Fetch and display playlist
PLAYLIST=$(curl -s "http://${SERVER}:4003/hls/${STREAM}.m3u8")

if [ -z "$PLAYLIST" ]; then
    echo "❌ Error: No playlist found for stream '$STREAM'"
    exit 1
fi

echo "$PLAYLIST"
echo ""

# Extract .ts segments
SEGMENTS=($(echo "$PLAYLIST" | grep "\.ts$"))

if [ ${#SEGMENTS[@]} -eq 0 ]; then
    echo "❌ No .ts segments found in playlist"
    exit 1
fi

echo "=============================================="
echo "📁 Available segments:"
for i in "${!SEGMENTS[@]}"; do
    echo "  [$i] ${SEGMENTS[$i]}"
done
echo ""

# Ask user which segment to test
read -p "🎯 Select segment number [0-$((${#SEGMENTS[@]}-1))]: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -ge ${#SEGMENTS[@]} ]; then
    echo "❌ Invalid selection"
    exit 1
fi

SEGMENT="${SEGMENTS[$CHOICE]}"
URL="http://${SERVER}:4003/hls/${SEGMENT}"

echo ""
echo "🔍 Testing cache for: $SEGMENT"
echo "=============================================="

# First request
echo "Request 1:"
curl -I "$URL" 2>/dev/null | grep -E "X-Cache-Status|HTTP/"

echo ""

# Second request
echo "Request 2:"
curl -I "$URL" 2>/dev/null | grep -E "X-Cache-Status|HTTP/"

echo ""
echo "✅ Done! (First should be MISS or HIT, second should be HIT)"
