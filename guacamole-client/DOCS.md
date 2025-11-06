## Default User

The default username is `guacadmin` with password `guacadmin`.

**⚠️ Security**: Change the default password immediately after first login via Settings → Users.

## Configuration

This addon includes configurable performance options optimized for low-latency connections to macOS targets.

### Option: `vnc_compression_level`

Controls VNC compression level (0-9).
- **0** = No compression (lowest latency, highest bandwidth) - **Recommended for LAN**
- **9** = Maximum compression (higher latency, lowest bandwidth)

**Default**: `0` (optimized for LAN)

```yaml
vnc_compression_level: 0
```

### Option: `vnc_image_quality`

Controls VNC JPEG image quality (0-9).
- **0** = Lowest quality
- **9** = Highest quality (less re-encoding overhead) - **Recommended**

**Default**: `9`

```yaml
vnc_image_quality: 9
```

### Option: `rdp_disable_compression`

Disables RDP compression for lower CPU overhead.

**Default**: `true` (compression disabled for lowest latency)

```yaml
rdp_disable_compression: true
```

### Option: `rdp_bitmap_cache`

Enables RDP bitmap caching to reduce redundant screen updates.

**Default**: `true`

```yaml
rdp_bitmap_cache: true
```

### Option: `rdp_offscreen_cache`

Enables RDP offscreen bitmap caching for better window movement performance.

**Default**: `true`

```yaml
rdp_offscreen_cache: true
```

### Option: `rdp_glyph_cache`

Enables RDP glyph caching for faster text rendering.

**Default**: `true`

```yaml
rdp_glyph_cache: true
```

### Option: `color_depth`

Sets the default color depth in bits.

**Understanding Color Depth vs Latency:**

- **16-bit (65K colors)** - **LOWEST LATENCY**
  - ~33% less bandwidth than 24-bit
  - Faster encoding/decoding
  - **Best for**: Gigabit LAN with lowest latency priority
  - Slight color banding on gradients
  
- **24-bit (16.7M colors)** - **BALANCED** ⭐ Recommended
  - Good color accuracy
  - Reasonable bandwidth (~75 Mbps @ 1080p60)
  - **Best for**: Fast LAN, most use cases
  - Sweet spot for latency vs quality
  
- **32-bit (16.7M + alpha)** - **HIGHEST QUALITY**
  - Same colors as 24-bit + alpha channel
  - ~33% more bandwidth than 24-bit
  - **Best for**: Quality priority, slow-changing content
  - Use only on gigabit with quality > speed

**Latency Impact (1080p60, raw encoding):**
- 16-bit: ~3-5ms encoding + 30 Mbps bandwidth
- 24-bit: ~4-6ms encoding + 45 Mbps bandwidth
- 32-bit: ~5-8ms encoding + 60 Mbps bandwidth

**Default**: `24` (best balance)

```yaml
color_depth: 24  # 16 for absolute lowest latency, 32 for quality
```

### Option: `guacd_log_level`

Sets the guacd (proxy daemon) log verbosity.

Options: `trace`, `debug`, `info`, `warning`, `error`

**Default**: `info`

```yaml
guacd_log_level: info
```

### Option: `java_opts`

Custom JVM options for Tomcat. Advanced users only.

**Default**: `-Xms384m -Xmx768m -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:G1ReservePercent=20`

```yaml
java_opts: "-Xms384m -Xmx768m -XX:+UseG1GC -XX:MaxGCPauseMillis=20"
```

### Option: `enable_low_latency_mode`

Enables aggressive low-latency optimizations at system, network, and application levels.

When enabled:
- **JVM**: 20ms max GC pause (vs 100ms), AlwaysPreTouch, NUMA awareness
- **Tomcat**: 200 threads (vs 75), 10s timeout (vs 60s), TCP_NODELAY
- **Network**: TCP fast open, optimized buffers, reduced delayed ACK
- **Use case**: Gigabit LAN, x86_64 systems, latency-critical work

**Default**: `false` (WiFi mode is default)

```yaml
enable_low_latency_mode: false  # true for LAN ultra-performance
```

### Option: `enable_wifi_optimization`

Enables WiFi and cross-network optimizations for connection stability and bandwidth efficiency.

When enabled:
- **Network**: Westwood/Cubic congestion control, SACK/FACK for packet loss recovery
- **Buffers**: Larger for jitter tolerance, 10 retransmission attempts
- **Keepalive**: Aggressive (120s) to detect WiFi drops quickly
- **Tomcat**: 75 threads, 60s timeout, optimized for reliability
- **Memory**: 256-384MB (suitable for Raspberry Pi 4)
- **Use case**: WiFi networks, VPN/cross-network, Raspberry Pi 4

**Default**: `true` (optimized for WiFi by default)

```yaml
enable_wifi_optimization: true  # false to disable WiFi optimizations
```

**Note**: Cannot enable both `enable_low_latency_mode` and `enable_wifi_optimization`. WiFi mode takes priority if both are true.

### Option: `connection_retry_count`

Number of times to retry failed connections. Higher values improve reliability on unstable networks.

**Default**: `5` (suitable for WiFi)

```yaml
connection_retry_count: 5  # 1-10, increase for unreliable networks
```

### Option: `connection_retry_wait`

Milliseconds to wait between connection retry attempts.

**Default**: `2000` (2 seconds)

```yaml
connection_retry_wait: 2000  # 1000-10000ms
```

## Example Configuration

### WiFi / Cross-Network / Raspberry Pi 4 (Default - Recommended)

For WiFi connections, different networks (VPN), or Raspberry Pi 4:

```yaml
vnc_compression_level: 5
vnc_image_quality: 6
rdp_disable_compression: false
color_depth: 16
guacd_log_level: warning
enable_low_latency_mode: false
enable_wifi_optimization: true
connection_retry_count: 5
connection_retry_wait: 2000
java_opts: "-Xms256m -Xmx384m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"
```
**Result**: 15-25 FPS, 100-200ms latency, 3-15 Mbps, excellent stability, Pi 4 compatible

### Gigabit LAN / Ultra-Low Latency (x86_64 only)

For same local network, wired connections, x86_64 systems:

```yaml
vnc_compression_level: 0
vnc_image_quality: 9
rdp_disable_compression: true
color_depth: 16  # Or 24 for better colors
guacd_log_level: warning
enable_low_latency_mode: true
enable_wifi_optimization: false
java_opts: "-Xms384m -Xmx768m -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35"
```
**Result**: 50-60 FPS, 35-50ms latency, 30-50 Mbps, requires >4GB RAM

## Low Latency Optimization for macOS Targets

This addon has been configured with low-latency Java/Tomcat settings to minimize processing overhead:

### Container-Level Optimizations (Pre-configured)

The following environment variables are set in the addon configuration:

- **TOMCAT_JAVA_OPTS**: Optimized JVM settings
  - G1 Garbage Collector with 50ms max pause time target
  - Heap size: 256MB-512MB (reduces memory management overhead)
  - These settings ensure minimal GC pauses during remote desktop sessions

- **GUACD_LOG_LEVEL**: Set to `info` (reduce logging overhead)

### Connection-Level Settings (Configure per-connection)

After logging into Guacamole (username: `guacadmin`, password: `guacadmin`), create your connections with these **macOS-optimized settings**:

#### For VNC (Recommended for macOS):

macOS has built-in Screen Sharing (VNC server). This is the recommended protocol for lowest latency.

**Connection Settings:**
- **Protocol**: VNC
- **Hostname**: Your macOS IP address
- **Port**: 5900 (default macOS Screen Sharing)
- **Username/Password**: Your macOS credentials

**Performance Settings (in connection parameters):**
- **Color Depth**: True color (24-bit) or higher
- **Swap red/blue**: Unchecked
- **Cursor**: Local (render cursor client-side for zero latency)
- **Read-only**: Unchecked
- **Force lossless**: Checked (for lowest latency on fast networks)

**Advanced Settings for Lowest Latency:**
- **Encoding**: 
  - `raw` - No compression, lowest latency (LAN only)
  - `tight` - Moderate compression (if bandwidth limited)
  - Avoid `zlib` and `zrle` - too much CPU overhead
- **Image Quality**: 9 (highest) - reduces re-encoding
- **Compression Level**: 0 (disabled) - eliminates compression overhead
- **Disable audio**: Yes (reduces bandwidth and processing)

**Enable these for better performance:**
- **Enable clipboard**: As needed
- **Disable desktop wallpaper**: Yes (reduces data transfer)
- **Disable animations**: Yes (reduces data transfer)
- **Disable bitmap caching**: Yes (raw mode needs no caching)

#### For RDP (If using Microsoft Remote Desktop on macOS):

If you've installed Microsoft Remote Desktop server on macOS (enterprise feature):

**Connection Settings:**
- **Protocol**: RDP
- **Hostname**: Your macOS IP address
- **Port**: 3389
- **Security**: NLA or RDP
- **Ignore server certificate**: Yes (for local network)

**Performance Settings:**
- **Color Depth**: True color (32-bit)
- **Disable bitmap caching**: No (Enable for RDP)
- **Disable offscreen caching**: No (Enable for RDP)
- **Disable glyph caching**: No (Enable for RDP)
- **Disable wallpaper**: Yes
- **Disable theming**: Yes
- **Disable full-window drag**: Yes
- **Disable menu animations**: Yes
- **Disable desktop composition**: No (macOS handles this well)

**Audio:**
- **Audio**: Disabled (unless needed)

**Drives/Printing:**
- Disable unless specifically needed

### Network Recommendations

For absolute lowest latency:

1. **Use Wired Connections**: Both client and macOS target
2. **Same Subnet**: Avoid routing through multiple network hops
3. **Quality of Service (QoS)**: Prioritize ports 5900 (VNC) or 3389 (RDP)
4. **Disable WiFi Power Saving** on macOS:
   ```bash
   sudo pmset -a womp 0
   ```
5. **Close Background Apps** on macOS target (reduces screen updates)
6. **Static IP**: Assign static IP to macOS for reliable connections

### macOS Screen Sharing Setup

Enable Screen Sharing on your macOS target:

1. **System Settings** → **General** → **Sharing**
2. Enable **Screen Sharing**
3. Click **(i)** info button
4. Set **VNC viewers may control screen with password**: [your password]
5. Note the connection address shown

### Troubleshooting

**High latency or lag:**
- Switch VNC encoding to `raw` (LAN) or `tight` (WAN)
- Disable compression (level 0)
- Reduce color depth to 16-bit if on slow network
- Check network latency: `ping [macOS-IP]`
- Ensure no QoS throttling on your network

**Connection drops:**
- Increase connection timeout (not currently configurable in this addon)
- Check firewall rules on macOS
- Verify Screen Sharing is enabled

**Image quality issues:**
- Increase image quality setting to 9
- Use `raw` or `tight` encoding
- Ensure sufficient bandwidth (100Mbps+ recommended for 4K)
