#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Guacamole Client
# Configures Guacamole with performance optimizations
# ==============================================================================

declare guacamole_home="/app/guacamole"
declare config_dir="/config/guacamole"

bashio::log.info "Configuring Guacamole..."

# Create config directory if it doesn't exist
mkdir -p "${config_dir}"

# Get configuration options
VNC_COMPRESSION=$(bashio::config 'vnc_compression_level' '5')
VNC_QUALITY=$(bashio::config 'vnc_image_quality' '6')
RDP_COMPRESSION=$(bashio::config 'rdp_disable_compression' 'false')
RDP_BITMAP_CACHE=$(bashio::config 'rdp_bitmap_cache' 'true')
RDP_OFFSCREEN_CACHE=$(bashio::config 'rdp_offscreen_cache' 'true')
RDP_GLYPH_CACHE=$(bashio::config 'rdp_glyph_cache' 'true')
COLOR_DEPTH=$(bashio::config 'color_depth' '16')
WIFI_MODE=$(bashio::config 'enable_wifi_optimization' 'true')
RETRY_COUNT=$(bashio::config 'connection_retry_count' '5')
RETRY_WAIT=$(bashio::config 'connection_retry_wait' '2000')

bashio::log.info "Performance settings:"
bashio::log.info "  VNC Compression Level: ${VNC_COMPRESSION}"
bashio::log.info "  VNC Image Quality: ${VNC_QUALITY}"
bashio::log.info "  RDP Compression Disabled: ${RDP_COMPRESSION}"
bashio::log.info "  Color Depth: ${COLOR_DEPTH}-bit"
bashio::log.info "  WiFi Optimization: ${WIFI_MODE}"
if bashio::var.true "${WIFI_MODE}"; then
    bashio::log.info "  Connection Retries: ${RETRY_COUNT}"
    bashio::log.info "  Retry Wait: ${RETRY_WAIT}ms"
fi

# Create guacamole.properties
cat > "${guacamole_home}/guacamole.properties" <<EOF
# PostgreSQL properties
postgresql-hostname: localhost
postgresql-port: 5432
postgresql-database: guacamole_db
postgresql-username: guacamole_user
postgresql-password: guacamole_pass

# Default connection settings for performance
postgresql-default-max-connections: 10
postgresql-default-max-connections-per-user: 2

# Auto-create drive if not exists
postgresql-auto-create-accounts: true

# WiFi/Network resilience settings
EOF

if bashio::var.true "${WIFI_MODE}"; then
    cat >> "${guacamole_home}/guacamole.properties" <<EOF
# WiFi optimization enabled
guacd-timeout: 60000
socket-timeout: 60000
EOF
fi

# Create performance tuning properties file
cat > "${guacamole_home}/performance.properties" <<EOF
# Performance tuning for WiFi/cross-network connections

# VNC Performance Settings (WiFi optimized)
vnc-compression-level: ${VNC_COMPRESSION}
vnc-image-quality: ${VNC_QUALITY}

# RDP Performance Settings  
rdp-disable-compression: ${RDP_COMPRESSION}
rdp-enable-bitmap-caching: ${RDP_BITMAP_CACHE}
rdp-enable-offscreen-caching: ${RDP_OFFSCREEN_CACHE}
rdp-enable-glyph-caching: ${RDP_GLYPH_CACHE}
rdp-color-depth: ${COLOR_DEPTH}

# Connection resilience (WiFi mode)
connection-retry-count: ${RETRY_COUNT}
connection-retry-wait: ${RETRY_WAIT}

# Bandwidth optimization
disable-audio: true
disable-printing: true
resize-method: display-update

# Network mode
wifi-optimization: ${WIFI_MODE}
EOF

# Set GUACAMOLE_HOME environment variable
export GUACAMOLE_HOME="${guacamole_home}"
echo "GUACAMOLE_HOME=${guacamole_home}" >> /etc/environment

# Configure guacd
mkdir -p /etc/guacamole

bashio::log.info "Guacamole configuration complete!"
