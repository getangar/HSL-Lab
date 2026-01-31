#!/usr/bin/env python3
"""
HLS Cache Test Script
Usage: python3 hls-cache-test.py [stream_name]
Example: python3 hls-cache-test.py test
"""

import sys
import re
import urllib.request
import urllib.error

SERVER = "192.168.50.130"

def fetch_playlist(stream: str) -> str:
    """Fetch the HLS playlist"""
    url = f"http://{SERVER}:4003/hls/{stream}.m3u8"
    try:
        with urllib.request.urlopen(url, timeout=5) as response:
            return response.read().decode('utf-8')
    except urllib.error.URLError as e:
        print(f"❌ Error fetching playlist: {e}")
        sys.exit(1)

def extract_segments(playlist: str) -> list:
    """Extract .ts segment names from playlist"""
    return re.findall(r'^[^\s#]+\.ts$', playlist, re.MULTILINE)

def check_cache(segment: str) -> dict:
    """Make HEAD request and return cache status"""
    url = f"http://{SERVER}:4003/hls/{segment}"
    request = urllib.request.Request(url, method='HEAD')
    
    try:
        with urllib.request.urlopen(request, timeout=5) as response:
            return {
                'status': response.status,
                'cache': response.headers.get('X-Cache-Status', 'N/A')
            }
    except urllib.error.URLError as e:
        return {'status': 'Error', 'cache': str(e)}

def main():
    # Get stream name from argument or use default
    stream = sys.argv[1] if len(sys.argv) > 1 else "test"
    
    print(f"📡 Fetching playlist for stream: {stream}")
    print("=" * 50)
    
    # Fetch playlist
    playlist = fetch_playlist(stream)
    print(playlist)
    print()
    
    # Extract segments
    segments = extract_segments(playlist)
    
    if not segments:
        print("❌ No .ts segments found in playlist")
        sys.exit(1)
    
    print("=" * 50)
    print("📁 Available segments:")
    for i, seg in enumerate(segments):
        print(f"  [{i}] {seg}")
    print()
    
    # Ask user
    try:
        choice = input(f"🎯 Select segment number [0-{len(segments)-1}]: ")
        choice = int(choice)
        if choice < 0 or choice >= len(segments):
            raise ValueError()
    except (ValueError, KeyboardInterrupt):
        print("\n❌ Invalid selection")
        sys.exit(1)
    
    segment = segments[choice]
    
    print()
    print(f"🔍 Testing cache for: {segment}")
    print("=" * 50)
    
    # First request
    print("Request 1:")
    result1 = check_cache(segment)
    print(f"  HTTP {result1['status']} - X-Cache-Status: {result1['cache']}")
    
    print()
    
    # Second request
    print("Request 2:")
    result2 = check_cache(segment)
    print(f"  HTTP {result2['status']} - X-Cache-Status: {result2['cache']}")
    
    print()
    print("✅ Done! (First should be MISS or HIT, second should be HIT)")

if __name__ == "__main__":
    main()
