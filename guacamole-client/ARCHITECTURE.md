# Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         GITHUB REPOSITORY                            │
│                    github.com/d-two/hassio-addons                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ .github/workflows/build-guacamole-client.yml               │    │
│  │  - Triggers on push to main                                │    │
│  │  - Builds 4 architectures in parallel                      │    │
│  │  - Uses QEMU for cross-compilation                         │    │
│  │  - Pushes to GitHub Container Registry                     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                             │                                         │
│                             ▼                                         │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ guacamole-client/                                          │    │
│  │  ├── Dockerfile (Apache Guacamole 1.5.5 from source)      │    │
│  │  ├── config.json (Home Assistant addon config)            │    │
│  │  ├── build.yaml (Architecture definitions)                │    │
│  │  └── rootfs/ (Scripts and config files)                   │    │
│  │       ├── etc/cont-init.d/                                 │    │
│  │       │   ├── 05-system-tuning.sh (WiFi vs LAN)          │    │
│  │       │   ├── 10-postgresql.sh                            │    │
│  │       │   ├── 20-guacamole.sh                             │    │
│  │       │   └── 30-tomcat.sh                                │    │
│  │       └── etc/services.d/                                  │    │
│  │           ├── postgresql/run                               │    │
│  │           ├── guacd/run                                    │    │
│  │           └── tomcat/run                                   │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            │ GitHub Actions builds
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│               GITHUB CONTAINER REGISTRY (GHCR)                       │
│                  ghcr.io/d-two/hassio-guacamole-client-wifi          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  Docker Images (Multi-Architecture):                                 │
│  ┌───────────────┬──────────────────────────────────────────┐      │
│  │ Tag           │ Platform                                  │      │
│  ├───────────────┼──────────────────────────────────────────┤      │
│  │ latest        │ Multi-arch manifest (all architectures)  │      │
│  │ latest-amd64  │ linux/amd64 (Intel/AMD 64-bit)          │      │
│  │ latest-aarch64│ linux/arm64 (Pi 4 64-bit, ARM servers)  │      │
│  │ latest-armv7  │ linux/arm/v7 (Pi 3/4 32-bit)            │      │
│  │ latest-armhf  │ linux/arm/v6 (Pi Zero, Pi 1)            │      │
│  └───────────────┴──────────────────────────────────────────┘      │
│                                                                       │
│  ⚠️ Must be PUBLIC for Home Assistant to pull                       │
│                                                                       │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            │ Home Assistant pulls image
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      HOME ASSISTANT                                  │
│          Settings → Add-ons → Add-on Store                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  1. Add Repository:                                                  │
│     https://github.com/d-two/hassio-addons                          │
│                                                                       │
│  2. repository.json discovered:                                      │
│     ┌──────────────────────────────────────────────────────┐       │
│     │ {                                                     │       │
│     │   "name": "d-two Home Assistant Add-ons",           │       │
│     │   "url": "https://github.com/d-two/hassio-addons"   │       │
│     │ }                                                     │       │
│     └──────────────────────────────────────────────────────┘       │
│                                                                       │
│  3. Discovers guacamole-client/config.json:                          │
│     ┌──────────────────────────────────────────────────────┐       │
│     │ {                                                     │       │
│     │   "name": "Guacamole-Client-WiFi",                  │       │
│     │   "slug": "guacamole-client-wifi",                  │       │
│     │   "image": "ghcr.io/d-two/hassio-                   │       │
│     │             guacamole-client-wifi",                 │       │
│     │   "arch": ["aarch64","amd64","armhf","armv7"]       │       │
│     │ }                                                     │       │
│     └──────────────────────────────────────────────────────┘       │
│                                                                       │
│  4. Add-on appears in store                                          │
│  5. User clicks Install                                              │
│  6. HA pulls correct architecture image from GHCR                    │
│  7. Add-on installed and ready to start                              │
│                                                                       │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            │ User starts add-on
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                  RUNNING ADD-ON CONTAINER                            │
│                  (Inside Home Assistant)                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  Initialization Sequence:                                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 1. 05-system-tuning.sh                                      │   │
│  │    - Reads enable_wifi_optimization from config            │   │
│  │    - Applies TCP/network tuning (WiFi or LAN mode)         │   │
│  │    - Sets sysctl parameters                                │   │
│  │                                                              │   │
│  │ 2. 10-postgresql.sh                                         │   │
│  │    - Initializes PostgreSQL database                        │   │
│  │    - Creates guacamole schema                               │   │
│  │    - Starts PostgreSQL                                      │   │
│  │                                                              │   │
│  │ 3. 20-guacamole.sh                                          │   │
│  │    - Reads VNC/RDP settings from config                    │   │
│  │    - Creates guacamole.properties                           │   │
│  │    - Configures connection to PostgreSQL                    │   │
│  │    - Sets retry parameters                                  │   │
│  │                                                              │   │
│  │ 4. 30-tomcat.sh                                             │   │
│  │    - Reads java_opts from config                           │   │
│  │    - Generates server.xml (75 or 200 threads)              │   │
│  │    - Sets timeouts based on mode                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  Running Services:                                                   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ ┌─────────────────┐  ┌────────────┐  ┌──────────────────┐ │   │
│  │ │  PostgreSQL     │  │   guacd    │  │     Tomcat       │ │   │
│  │ │  (Port 5432)    │  │ (Port 4822)│  │   (Port 8080)    │ │   │
│  │ │                 │  │            │  │                  │ │   │
│  │ │  - User DB      │  │ - VNC      │  │ - Guacamole WAR  │ │   │
│  │ │  - Connection   │  │ - RDP      │  │ - Web UI         │ │   │
│  │ │    configs      │  │ - SSH      │  │ - REST API       │ │   │
│  │ └─────────────────┘  └────────────┘  └──────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                       │
│  Exposed Ports:                                                      │
│  - 8080: Web UI (accessible via Home Assistant ingress)             │
│  - 4822: guacd (internal only)                                      │
│                                                                       │
│  Configuration Flow:                                                 │
│  config.json → bashio config reader → init scripts → app configs    │
│                                                                       │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            │ User accesses Web UI
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    GUACAMOLE WEB INTERFACE                           │
│                   http://homeassistant:8080                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  User Flow:                                                          │
│  1. Login (guacadmin / guacadmin)                                   │
│  2. Change password ⚠️                                              │
│  3. Create connections:                                              │
│     ┌────────────────────────────────────────────────────────┐     │
│     │ VNC Connection                                         │     │
│     │  - Hostname: 192.168.1.100                            │     │
│     │  - Port: 5900                                         │     │
│     │  - Password: ****                                     │     │
│     │  - Compression: 5 (WiFi mode)                         │     │
│     │  - Quality: 6 (WiFi mode)                             │     │
│     │  - Color depth: 16-bit (WiFi mode)                    │     │
│     └────────────────────────────────────────────────────────┘     │
│  4. Connect to remote system                                         │
│  5. Use remote desktop in browser                                    │
│                                                                       │
└───────────────────────────┬───────────────────────────────────────────┘
                            │
                            │ Guacamole connects to target
                            ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     TARGET SYSTEMS                                   │
│               (Your computers/servers)                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │   Mac Mini       │  │ Windows Desktop  │  │  Linux Server    │ │
│  │   VNC Server     │  │   RDP Server     │  │   SSH Server     │ │
│  │   Port 5900      │  │   Port 3389      │  │   Port 22        │ │
│  │   192.168.1.100  │  │   192.168.1.101  │  │   192.168.1.102  │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘ │
│                                                                       │
│  Requirements:                                                       │
│  - VNC/RDP/SSH server enabled                                       │
│  - Firewall allows connections                                      │
│  - Network connectivity (WiFi or LAN)                               │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘


Configuration Modes:
═══════════════════

WiFi / Cross-Network Mode (Default)
────────────────────────────────────
Target: WiFi connections, VPN, cross-network, Raspberry Pi 4
Settings:
  - Compression: 5 (balanced)
  - Quality: 6 (bandwidth efficient)
  - Color: 16-bit
  - Memory: 256-384MB
  - Threads: 75
  - GC Pause: 100ms
  - TCP: Westwood congestion control
  - Retries: 5 attempts, 2s wait

Result: 15-25 FPS, 100-200ms latency, 3-15 Mbps bandwidth


Ultra-Low Latency Mode (Optional)
──────────────────────────────────
Target: Gigabit LAN, same network, x86_64 systems
Settings:
  - Compression: 0 (disabled)
  - Quality: 9 (lossless)
  - Color: 24-bit
  - Memory: 384-768MB
  - Threads: 200
  - GC Pause: 20ms
  - TCP: Cubic + fast open
  - Retries: Disabled

Result: 50-60 FPS, 35-50ms latency, 30-75 Mbps bandwidth


Data Flow:
═════════

Browser → Home Assistant Ingress → Tomcat (Port 8080)
                                        ↓
                                  Guacamole WAR
                                        ↓
                                  PostgreSQL (Connection Configs)
                                        ↓
                                   guacd (Protocol Handler)
                                        ↓
                              ┌─────────┼─────────┐
                              ↓         ↓         ↓
                            VNC       RDP       SSH
                              ↓         ↓         ↓
                        Target Systems (Your Computers)
```
