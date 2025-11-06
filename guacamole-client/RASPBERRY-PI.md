# Raspberry Pi 4 Compatibility Guide

## Overview

This add-on is **fully compatible** with Raspberry Pi 4 and optimized for its ARM architecture. The default configuration prioritizes WiFi stability and efficient resource usage perfect for Pi deployments.

## Architecture Support

The add-on builds for all Raspberry Pi architectures:
- **aarch64** (64-bit ARM) - Recommended for Pi 4 with 64-bit OS
- **armv7** (32-bit ARM) - For Pi 4 with 32-bit OS
- **armhf** (ARM hard-float) - For older Pi models

## Resource Requirements

### Minimum Requirements (Pi 4 - 2GB Model)
- **RAM**: 2GB (512MB available for add-on)
- **Storage**: 1GB free space
- **CPU**: 4 cores @ 1.5GHz (Pi 4)

### Recommended Requirements (Pi 4 - 4GB+ Model)
- **RAM**: 4GB or more
- **Storage**: 2GB free space for builds
- **Network**: WiFi 5 (802.11ac) or better

## Default Configuration for Pi 4

The add-on comes pre-configured for optimal Pi 4 performance:

```yaml
vnc_compression_level: 5          # Balanced compression for WiFi
vnc_image_quality: 6              # Reduced quality for lower bandwidth
color_depth: 16                   # 16-bit color saves bandwidth
enable_wifi_optimization: true    # WiFi-first tuning
java_opts: "-Xms256m -Xmx384m"   # Conservative memory usage
```

## Build Times

When building from source on different platforms:
- **GitHub Actions (x86_64)**: ~15-20 minutes per architecture with QEMU
- **Local Pi 4 build**: ~30-45 minutes (using -j2 for stability)
- **Local x86_64**: ~5-10 minutes with full parallelism

The Dockerfile uses `-j2` (2 parallel jobs) during compilation to prevent overwhelming ARM CPUs and running out of memory during the build process.

## Performance Characteristics

### WiFi Mode (Default)
- **Latency**: 50-80ms typical over WiFi
- **Memory Usage**: 250-350MB under load
- **CPU Usage**: 15-30% on Pi 4
- **Network**: Handles 10-20 Mbps comfortably

### Wired Mode (Optional)
If you disable WiFi optimization for wired connections:
- **Latency**: 25-40ms typical over Ethernet
- **Memory Usage**: 400-600MB under load
- **CPU Usage**: 25-45% on Pi 4
- **Network**: Can handle 50+ Mbps

## Installation Tips

### 1. Use 64-bit OS
For best performance on Pi 4, use Home Assistant OS 64-bit:
```
Architecture: aarch64
```

### 2. Adequate Cooling
Ensure proper cooling during compilation:
- Use a heatsink or fan
- Monitor temperature: `vcgencmd measure_temp`
- Builds generate significant heat

### 3. Stable Power Supply
Use official 3A USB-C power supply:
- Prevents under-voltage during compilation
- Ensures stable operation under load

### 4. Network Configuration
For WiFi setups across networks:
- Use 5GHz WiFi when possible
- Ensure strong signal (-60 dBm or better)
- Consider powerline adapters for challenging WiFi

## Troubleshooting

### Build Fails with "Out of Memory"
If building locally on Pi 4:
```yaml
# Increase swap space
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Set CONF_SWAPSIZE=2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon
```

### Add-on Crashes on 2GB Pi 4
Reduce memory further in config:
```yaml
java_opts: "-Xms128m -Xmx256m -XX:+UseG1GC -XX:MaxGCPauseMillis=100"
```

### High CPU Usage
Enable WiFi optimization if not already:
```yaml
enable_wifi_optimization: true
enable_low_latency_mode: false
```

### Slow Performance
Check available resources:
```bash
# SSH into Home Assistant
free -h
top -b -n 1 | head -20
```

Consider disabling other resource-intensive add-ons.

## Optimization for Pi 4

### Storage
Use fast SD card or SSD:
- **Recommended**: Class 10 SD or A2-rated
- **Best**: USB 3.0 SSD via USB boot
- Improves database performance

### Network
Optimize WiFi settings:
```yaml
# For stable but slower connections
vnc_compression_level: 7
vnc_image_quality: 4
color_depth: 16

# For faster WiFi (5GHz, close proximity)
vnc_compression_level: 3
vnc_image_quality: 7
color_depth: 24
```

### Background Services
Minimize other services:
- Disable unused add-ons
- Reduce recorder history days
- Consider external database for HA

## Monitoring

Check add-on performance:
```bash
# View logs
docker logs addon_<addon_id>

# Check resource usage
docker stats addon_<addon_id>

# Monitor network
sudo iftop -i wlan0
```

## Best Practices

1. **Start Conservative**: Use default WiFi-optimized settings first
2. **Test Incrementally**: Adjust one setting at a time
3. **Monitor Resources**: Watch CPU/RAM usage during use
4. **Network First**: Ensure stable network before tuning
5. **Regular Updates**: Keep OS and add-ons current

## Known Limitations

- **4K Remote Desktop**: Not recommended over WiFi on Pi 4
  - Limit to 1920x1080 for smooth performance
- **Multiple Connections**: 2-3 concurrent users maximum
- **Heavy Applications**: Video editing on remote may struggle
- **Network Variability**: WiFi performance depends on environment

## Recommended Use Cases

✅ **Excellent for:**
- Accessing home server over WiFi
- SSH terminal sessions
- Light desktop work (browsing, documents)
- Home automation interfaces
- Development work (coding, scripts)

⚠️ **Challenging for:**
- 4K video playback on remote
- Gaming with low input lag requirements
- Multiple simultaneous HD video streams
- Heavy photo/video editing

## Support

For Pi-specific issues, include in bug reports:
- Raspberry Pi model and RAM
- OS version (32-bit vs 64-bit)
- Network type (WiFi vs Ethernet)
- Output of `vcgencmd get_throttled`
- Add-on logs showing memory usage

## Additional Resources

- [WiFi Optimization Guide](WIFI-OPTIMIZATION.md)
- [Performance Tuning](PERFORMANCE.md)
- [Build Instructions](BUILD.md)
- [Quick Start Guide](QUICKSTART.md)
