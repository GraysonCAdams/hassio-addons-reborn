# Guacamole Client WiFi - Home Assistant Add-on

[![GitHub Release][releases-shield]][releases]
[![License][license-shield]](LICENSE)

Apache Guacamole 1.5.5 - WiFi-optimized, Raspberry Pi 4 ready, clientless remote desktop gateway for Home Assistant.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]

## About

This Home Assistant add-on provides **Apache Guacamole 1.5.5**, a clientless remote desktop gateway supporting VNC, RDP, and SSH protocols over HTML5. Built from official Apache sources with custom optimizations for WiFi/cross-network scenarios and Raspberry Pi 4.

**Key Features:**
- 🌐 **WiFi Optimized (Default)** - Compression, quality tuning, connection retries
- 🍓 **Raspberry Pi 4 Ready** - Conservative memory usage (256-384MB), tested on ARM
- ⚡ **Ultra-Low Latency Mode** - Optional LAN mode for <50ms total latency
- 🔧 **Fully Configurable** - 14 performance options via Home Assistant UI
- 🏗️ **Custom Built** - Compiled from Apache sources, not a pre-built image
- 🤖 **Auto-Updated** - GitHub Actions builds for all architectures

> 🔧 **Raspberry Pi Users**: See [RASPBERRY-PI.md](RASPBERRY-PI.md) for Pi-specific optimization tips, build times, and troubleshooting.

## Performance Modes

### WiFi / Cross-Network Mode (Default ⭐)
**Best for**: WiFi connections, VPN/Tailscale, Raspberry Pi 4, different networks

- ✅ **Connection stability** - 5 automatic retries, long timeouts
- ✅ **Low bandwidth** - 3-15 Mbps (compression enabled)
- ✅ **Pi 4 friendly** - 256-384MB RAM, 15-30% CPU
- ✅ **Resilient** - Handles packet loss, jitter, WiFi drops
- ⚡ **Performance**: 15-25 FPS, 100-200ms latency

### Ultra-Low Latency Mode (Optional)
**Best for**: Gigabit LAN, x86_64 systems, same network, latency-critical work

- ✅ **Minimal latency** - 35-50ms total
- ✅ **High frame rate** - 50-60 FPS
- ✅ **Best quality** - Lossless with raw encoding
- ⚠️ **Requirements**: >4GB RAM, wired connection, 30-75 Mbps
- ⚡ **Performance**: Suitable for gaming, video editing


## Installation

### 1. Add Repository to Home Assistant

In Home Assistant:
1. Navigate to **Settings** → **Add-ons** → **Add-on Store**
2. Click the **⋮** menu (top right) → **Repositories**
3. Add this URL:
   ```
   https://github.com/graysoncadams/hassio-guacamole-client
   ```
4. Click **Add** → **Close**

### 2. Install Add-on

1. Refresh the Add-on Store page
2. Find **Guacamole Client WiFi** in the list
3. Click on it → **Install**
4. Wait for installation to complete (2-5 minutes)

### 3. Configure & Start

**For WiFi/Pi4 Users (Default - Recommended):**
- No configuration needed! Default settings are optimized
- Just click **Start**

**For Gigabit LAN Users:**
```yaml
enable_wifi_optimization: false
enable_low_latency_mode: true
vnc_compression_level: 0
vnc_image_quality: 9
color_depth: 24
```

### 4. Access Web UI

- Click **Open Web UI** or use Home Assistant Ingress
- Login with: `guacadmin` / `guacadmin`
- **⚠️ Change password immediately!**

## Quick Start

See **[QUICKSTART.md](QUICKSTART.md)** for a 5-minute setup guide including:
- macOS Screen Sharing setup
- Creating VNC connections
- Optimal performance settings
- Troubleshooting tips

## Documentation

- 📱 **[QUICKSTART.md](QUICKSTART.md)** - 5-minute setup guide
- 🚀 **[SETUP-GUIDE.md](SETUP-GUIDE.md)** - Complete installation walkthrough
- 🍓 **[RASPBERRY-PI.md](RASPBERRY-PI.md)** - Pi 4 optimization guide
- 📡 **[WIFI-OPTIMIZATION.md](WIFI-OPTIMIZATION.md)** - Cross-network tuning
- ⚡ **[PERFORMANCE.md](PERFORMANCE.md)** - Benchmarks and latency reduction
- � **[DOCS.md](DOCS.md)** - Configuration reference
- 🏗️ **[BUILD.md](BUILD.md)** - Build from source instructions
- 📐 **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture diagram

## Performance Modes

### WiFi / Cross-Network Mode ⭐ (Default)
**Best for:** WiFi, VPN, different networks, Raspberry Pi 4

- ✅ 15-25 FPS, 100-200ms latency
- ✅ 3-15 Mbps bandwidth
- ✅ 256-384MB RAM usage
- ✅ Automatic connection retries
- ✅ Handles packet loss gracefully

### Ultra-Low Latency Mode (Optional)
**Best for:** Gigabit LAN, same network, x86_64 systems

- ✅ 50-60 FPS, 35-50ms latency
- ✅ 30-75 Mbps bandwidth
- ✅ 384-768MB RAM usage
- ✅ TCP fast open, nodelay
- ✅ 20ms GC pause target

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `vnc_compression_level` | 5 | 0-9, compression (0=none, 9=max) |
| `vnc_image_quality` | 6 | 0-9, quality (0=low, 9=high) |
| `color_depth` | 16 | 16/24/32-bit color |
| `enable_wifi_optimization` | true | WiFi mode on/off |
| `enable_low_latency_mode` | false | LAN ultra-mode on/off |
| `connection_retry_count` | 5 | Retry attempts |
| `connection_retry_wait` | 2000 | Wait between retries (ms) |

See **[DOCS.md](DOCS.md)** for all options.

## Supported Protocols

- **VNC** - For macOS Screen Sharing, TigerVNC, TightVNC
- **RDP** - For Windows Remote Desktop
- **SSH** - For terminal access

## Architecture Support

| Architecture | Status | Example Devices |
|--------------|--------|-----------------|
| amd64 | ✅ Tested | Intel NUC, Desktop PC |
| aarch64 | ✅ Tested | Raspberry Pi 4 (64-bit), Odroid |
| armv7 | ✅ Built | Raspberry Pi 3/4 (32-bit) |
| armhf | ✅ Built | Raspberry Pi Zero, Pi 1 |

## System Requirements

### Minimum (Raspberry Pi 4 - 2GB)
- RAM: 2GB total (512MB available for add-on)
- Storage: 1GB free
- Network: WiFi 5 or better

### Recommended (x86_64 / Pi 4 4GB+)
- RAM: 4GB+ total
- Storage: 2GB+ free
- Network: Gigabit Ethernet or WiFi 6

## Build Information

- **Guacamole Version:** 1.5.5
- **Tomcat Version:** 9.0.93
- **PostgreSQL Version:** 15
- **OpenJDK Version:** 17
- **Base Image:** Home Assistant Add-on Base 15.0.1

## Image Source

The Docker image is built from this repository and published to:
```
ghcr.io/graysoncadams/hassio-guacamole-client-wifi:latest-{arch}
```

Available architectures:
- `latest-amd64` - Intel/AMD 64-bit
- `latest-aarch64` - ARM 64-bit (Raspberry Pi 4, Apple Silicon)
- `latest-armv7` - ARM 32-bit v7
- `latest-armhf` - ARM 32-bit v6 (older Raspberry Pi)

## Build Status

Images are automatically built via GitHub Actions for all architectures. Build time varies:
- **x86_64 with QEMU**: ~15-20 minutes per arch
- **Native ARM (Pi 4)**: ~30-45 minutes

## License

- **Guacamole:** Apache License 2.0
- **This Add-on Configuration:** MIT License

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## Support

- **Issues:** [GitHub Issues](https://github.com/graysoncadams/hassio-guacamole-client/issues)
- **Discussions:** [GitHub Discussions](https://github.com/graysoncadams/hassio-guacamole-client/discussions)
- **Documentation:** See docs listed above

## Acknowledgments

- [Apache Guacamole](https://guacamole.apache.org/) - The amazing clientless remote desktop gateway
- [Home Assistant](https://www.home-assistant.io/) - Open source home automation platform
- Home Assistant community for testing and feedback

---

**Maintainer:** Grayson Adams  
**Repository:** [graysoncadams/hassio-guacamole-client](https://github.com/graysoncadams/hassio-guacamole-client)

[releases-shield]: https://img.shields.io/github/release/graysoncadams/hassio-guacamole-client.svg
[releases]: https://github.com/graysoncadams/hassio-guacamole-client/releases
[license-shield]: https://img.shields.io/github/license/graysoncadams/hassio-guacamole-client.svg
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
See [BUILD.md](BUILD.md) for local build instructions.

## License

Apache Guacamole is licensed under the Apache License 2.0.
This addon configuration is provided as-is for use with Home Assistant.
