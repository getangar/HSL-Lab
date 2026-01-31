<?xml version="1.0" encoding="UTF-8"?>
<!--
  RTMP Statistics Stylesheet
  
  This XSL transforms the NGINX RTMP module's XML statistics into a
  human-readable HTML page. Access it at http://localhost:4002/stat
  
  Useful for:
  - Verifying stream is being received
  - Checking stream metadata (resolution, bitrate, codec)
  - Monitoring connected clients
  - Debugging stream issues
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes"/>

<xsl:template match="/">
<html>
<head>
    <title>RTMP Statistics - Streaming QoS Lab</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
            margin: 20px; 
            background: #f5f5f7; 
            color: #1d1d1f;
        }
        h1, h2 { color: #1d1d1f; }
        h1 { border-bottom: 2px solid #007AFF; padding-bottom: 10px; }
        table { 
            border-collapse: collapse; 
            margin: 20px 0; 
            background: white; 
            border-radius: 8px; 
            overflow: hidden; 
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            width: 100%;
            max-width: 800px;
        }
        th { 
            background: #007AFF; 
            color: white; 
            padding: 12px 16px; 
            text-align: left; 
        }
        td { 
            padding: 10px 16px; 
            border-bottom: 1px solid #e5e5e5; 
        }
        tr:hover { background: #f0f0f0; }
        .live { color: #34C759; font-weight: bold; }
        .offline { color: #8e8e93; }
        .badge { 
            display: inline-block; 
            padding: 4px 12px; 
            border-radius: 12px; 
            font-size: 12px; 
            font-weight: 600; 
        }
        .badge-live { background: #34C759; color: white; }
        .badge-idle { background: #8e8e93; color: white; }
        .info-box {
            background: #e3f2fd;
            border: 1px solid #007AFF;
            border-radius: 8px;
            padding: 15px;
            margin: 20px 0;
            max-width: 800px;
        }
        code {
            background: #f5f5f5;
            padding: 2px 6px;
            border-radius: 4px;
            font-family: 'SF Mono', Monaco, monospace;
            font-size: 13px;
        }
    </style>
    <meta http-equiv="refresh" content="3"/>
</head>
<body>
    <h1>🍎 Streaming QoS Lab - RTMP Statistics</h1>
    <p>Auto-refresh every 3 seconds</p>
    
    <xsl:for-each select="rtmp/server">
        <h2>Server Status</h2>
        <table>
            <tr><th style="width:200px">Metric</th><th>Value</th></tr>
            <tr><td>Uptime</td><td><xsl:value-of select="uptime"/> seconds</td></tr>
            <tr><td>Accepted Connections</td><td><xsl:value-of select="naccepted"/></td></tr>
            <tr><td>Bandwidth In</td><td><xsl:value-of select="format-number(bw_in div 1024, '#.##')"/> KB/s</td></tr>
            <tr><td>Bandwidth Out</td><td><xsl:value-of select="format-number(bw_out div 1024, '#.##')"/> KB/s</td></tr>
            <tr><td>Total Bytes In</td><td><xsl:value-of select="format-number(bytes_in div 1048576, '#.##')"/> MB</td></tr>
            <tr><td>Total Bytes Out</td><td><xsl:value-of select="format-number(bytes_out div 1048576, '#.##')"/> MB</td></tr>
        </table>
        
        <xsl:for-each select="application">
            <h2>Application: <xsl:value-of select="name"/></h2>
            
            <xsl:if test="live/stream">
                <h3>Active Streams</h3>
                <table>
                    <tr>
                        <th>Stream</th>
                        <th>Status</th>
                        <th>Clients</th>
                        <th>Video</th>
                        <th>Audio</th>
                        <th>BW In</th>
                        <th>Duration</th>
                    </tr>
                    <xsl:for-each select="live/stream">
                        <tr>
                            <td><strong><xsl:value-of select="name"/></strong></td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test="publishing">
                                        <span class="badge badge-live">● LIVE</span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span class="badge badge-idle">○ IDLE</span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td><xsl:value-of select="nclients"/></td>
                            <td>
                                <xsl:value-of select="meta/video/width"/>x<xsl:value-of select="meta/video/height"/>
                                @ <xsl:value-of select="meta/video/frame_rate"/>fps
                            </td>
                            <td>
                                <xsl:value-of select="meta/audio/codec"/> 
                                <xsl:value-of select="meta/audio/sample_rate"/>Hz
                            </td>
                            <td><xsl:value-of select="format-number(bw_in div 1024, '#.##')"/> KB/s</td>
                            <td><xsl:value-of select="format-number(time div 1000, '#')"/>s</td>
                        </tr>
                    </xsl:for-each>
                </table>
            </xsl:if>
            
            <xsl:if test="not(live/stream)">
                <div class="info-box">
                    <p><strong>No active streams.</strong></p>
                    <p>Start streaming with:</p>
                    <p><code>ffmpeg -re -f lavfi -i testsrc=size=1280x720:rate=30 -f lavfi -i sine=frequency=440 -c:v libx264 -preset ultrafast -b:v 2000k -c:a aac -f flv rtmp://localhost:4001/live/test</code></p>
                </div>
            </xsl:if>
        </xsl:for-each>
    </xsl:for-each>
    
    <h2>Quick Reference</h2>
    <table>
        <tr><th>Action</th><th>URL / Command</th></tr>
        <tr><td>Stream with FFmpeg</td><td><code>rtmp://YOUR_IP:4001/live/test</code></td></tr>
        <tr><td>Watch via Edge (CDN)</td><td><code>http://YOUR_IP:4003/hls/test.m3u8</code></td></tr>
        <tr><td>Watch via Origin</td><td><code>http://YOUR_IP:4002/hls/test.m3u8</code></td></tr>
        <tr><td>Web Player</td><td><code>http://YOUR_IP:4004</code></td></tr>
        <tr><td>Grafana</td><td><code>http://YOUR_IP:4006</code> (admin/streaming123)</td></tr>
    </table>
</body>
</html>
</xsl:template>
</xsl:stylesheet>
