# =============================================================================
# NGINX-RTMP Origin Server
# =============================================================================
# This container serves as the "origin" in our streaming architecture.
# It receives RTMP streams from encoders and converts them to HLS format.
#
# Components:
# - NGINX with RTMP module for ingest
# - HLS packaging (2-second segments)
# - HTTP server for HLS delivery
# =============================================================================

FROM alpine:3.19

# Install NGINX with RTMP module and utilities
RUN apk add --no-cache \
    nginx \
    nginx-mod-rtmp \
    curl \
    ffmpeg

# Create required directories
RUN mkdir -p /tmp/hls /var/log/nginx /run/nginx

# Expose ports
# 1935 = RTMP ingest
# 8080 = HTTP for HLS
EXPOSE 1935 8080

# Start NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]
