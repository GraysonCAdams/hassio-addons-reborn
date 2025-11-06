# Building Guacamole Client

This document describes how the custom Guacamole Client addon is built.

## Automated Builds

The addon is automatically built using GitHub Actions when:
- Changes are pushed to `main` branch affecting `guacamole-client/`
- A pull request modifies `guacamole-client/`
- Manually triggered via workflow dispatch

### Build Process

1. **Multi-Architecture Setup**
   - Uses QEMU for cross-platform emulation
   - Docker Buildx for multi-architecture support
   - Builds for: amd64, aarch64, armv7, armhf

2. **Source Download**
   - Apache Guacamole Server 1.5.5 source
   - Apache Guacamole Client 1.5.5 WAR
   - Apache Tomcat 9.0.93 binary
   - PostgreSQL JDBC driver 42.7.3
   - guacamole-auth-jdbc extension

3. **Compilation**
   - guacamole-server compiled with:
     - FreeRDP support
     - VNC (libvncserver) support
     - SSH (libssh2) support
     - Audio (PulseAudio) support
     - All protocol optimizations enabled

4. **Configuration**
   - Custom Tomcat server.xml with performance tuning
   - PostgreSQL initialization scripts
   - Guacamole properties templates
   - Environment variable handlers

5. **Packaging**
   - Final image layers:
     - Base: Home Assistant Add-on Base
     - Runtime: OpenJDK 17, PostgreSQL 15
     - Application: Tomcat, Guacamole, guacd
     - Scripts: Init and service management
     - Config: Optimized defaults

6. **Publishing**
   - Images pushed to GitHub Container Registry
   - Tagged as: `ghcr.io/d-two/hassio-guacamole-client:latest-{arch}`
   - Multi-arch manifest created for `latest` tag

## Manual Build

To build locally for testing:

```bash
# Clone the repository
git clone https://github.com/d-two/hassio-addons.git
cd hassio-addons/guacamole-client

# Build for current architecture
docker build -t guacamole-client:test \
  --build-arg BUILD_FROM=ghcr.io/hassio-addons/base:15.0.1 \
  --build-arg BUILD_ARCH=$(uname -m) \
  .

# Run locally
docker run -p 8080:8080 guacamole-client:test
```

### Build Times

Expected build times vary by platform:

| Platform | Architecture | Build Time | Notes |
|----------|-------------|------------|-------|
| GitHub Actions (x86) | Any (via QEMU) | 15-20 min | Cross-compilation |
| x86_64 PC | amd64 | 5-10 min | Native build |
| Raspberry Pi 4 | aarch64 | 30-45 min | Uses `-j2` for stability |
| Raspberry Pi 3 | armv7 | 60-90 min | Limited resources |

**Note**: The Dockerfile uses `make -j2` instead of `make -j$(nproc)` to prevent overwhelming ARM CPUs and ensure stable builds on Raspberry Pi devices.

### Raspberry Pi Build Tips

When building on Raspberry Pi:
```bash
# Increase swap if you have <4GB RAM
sudo dphys-swapfile swapoff
sudo nano /etc/dphys-swapfile
# Set CONF_SWAPSIZE=2048
sudo dphys-swapfile setup
sudo dphys-swapfile swapon

# Monitor temperature during build
watch vcgencmd measure_temp

# Ensure adequate cooling (heatsink + fan recommended)
```

## Build Arguments

| Argument | Description | Example |
|----------|-------------|---------|
| BUILD_FROM | Base image | `ghcr.io/hassio-addons/base:15.0.1` |
| BUILD_ARCH | Target architecture | `amd64`, `aarch64`, `armv7`, `armhf` |
| BUILD_DATE | Build timestamp | `2025-11-06T12:00:00Z` |
| BUILD_VERSION | Version tag | `1.5.5` |
| BUILD_REF | Git commit SHA | `abc123...` |
| BUILD_REPOSITORY | Git repository | `d-two/hassio-addons` |

## Version Updates

To update to a newer Guacamole version:

1. Update `GUACAMOLE_VERSION` in Dockerfile
2. Update `TOMCAT_VERSION` if needed
3. Update `POSTGRES_VERSION` if needed
4. Test build locally
5. Update CHANGELOG.md
6. Update version in config.json
7. Push to trigger automated build

## Dependencies

### Runtime Dependencies
- OpenJDK 17 JRE (Tomcat)
- PostgreSQL 15 (database)
- FreeRDP (RDP protocol)
- libvncserver (VNC protocol)
- libssh2 (SSH protocol)
- Cairo, Pango (rendering)
- libjpeg-turbo, libpng, libwebp (image encoding)

### Build Dependencies
- Build tools (gcc, make, autoconf, automake)
- Development headers for all runtime libs
- Maven (if building from source)
- OpenJDK 17 (full, not just JRE)

## Optimization Flags

The guacamole-server is compiled with:
```
./configure \
  --prefix=/usr \
  --disable-guaclog \
  --with-freerdp-plugin-dir=/usr/lib/freerdp2
```

Tomcat configured with:
- Max threads: 150
- Min spare threads: 25
- Connection timeout: 20s
- HTTP compression enabled
- Keep-alive enabled

PostgreSQL configured with:
- Max connections: 20
- Shared buffers: 64MB
- Work memory: 8MB
- Effective cache: 256MB

## Troubleshooting

### Build fails on specific architecture
- Check QEMU is properly set up
- Verify base image exists for that arch
- Check Alpine package availability

### Runtime issues
- Check logs: `docker logs <container>`
- Verify PostgreSQL started: Check `/var/lib/postgresql/data/`
- Test Tomcat: `curl localhost:8080`
- Test guacd: Check if port 4822 is listening

### Performance issues
- Increase Java heap in config: `java_opts`
- Check network latency
- Review connection parameters in Guacamole UI
- Monitor with: `docker stats <container>`

## CI/CD Workflow

The GitHub Actions workflow (`.github/workflows/build-guacamole-client.yml`):

1. Triggers on push/PR to relevant paths
2. Sets up build environment (QEMU, Buildx)
3. Logs into GitHub Container Registry
4. Builds each architecture in parallel
5. Pushes architecture-specific tags
6. Creates multi-arch manifest
7. Tags as `latest`

Secrets required:
- `GITHUB_TOKEN` (automatically provided by GitHub)

## Contributing

When contributing changes:

1. Test build locally first
2. Update documentation
3. Update CHANGELOG.md
4. Ensure all architectures build
5. Test on Home Assistant if possible
6. Submit PR with clear description

## License

This build configuration is provided as-is.
Apache Guacamole is licensed under Apache License 2.0.
