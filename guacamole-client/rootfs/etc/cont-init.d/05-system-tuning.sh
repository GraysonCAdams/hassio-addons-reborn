#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Guacamole Client
# System-level network and performance tuning
# ==============================================================================

declare low_latency
declare wifi_mode

low_latency=$(bashio::config 'enable_low_latency_mode' 'false')
wifi_mode=$(bashio::config 'enable_wifi_optimization' 'true')

if bashio::var.true "${wifi_mode}"; then
    bashio::log.info "Applying WiFi-optimized network settings..."
    
    # WiFi optimization: focus on reliability and retransmission handling
    
    # Increase TCP buffer sizes for better handling of WiFi jitter
    if [ -w /proc/sys/net/core/rmem_max ]; then
        echo 8388608 > /proc/sys/net/core/rmem_max || true
        echo 8388608 > /proc/sys/net/core/wmem_max || true
    fi
    
    if [ -w /proc/sys/net/ipv4/tcp_rmem ]; then
        echo "8192 87380 8388608" > /proc/sys/net/ipv4/tcp_rmem || true
        echo "8192 87380 8388608" > /proc/sys/net/ipv4/tcp_wmem || true
    fi
    
    # Increase retransmission attempts for unreliable WiFi
    if [ -w /proc/sys/net/ipv4/tcp_retries2 ]; then
        echo 10 > /proc/sys/net/ipv4/tcp_retries2 || true
    fi
    
    # Enable TCP timestamps for better RTT estimation over WiFi
    if [ -w /proc/sys/net/ipv4/tcp_timestamps ]; then
        echo 1 > /proc/sys/net/ipv4/tcp_timestamps || true
    fi
    
    # Enable SACK for better recovery from packet loss
    if [ -w /proc/sys/net/ipv4/tcp_sack ]; then
        echo 1 > /proc/sys/net/ipv4/tcp_sack || true
    fi
    
    # Enable FACK for better handling of reordering
    if [ -w /proc/sys/net/ipv4/tcp_fack ]; then
        echo 1 > /proc/sys/net/ipv4/tcp_fack || true
    fi
    
    # Increase reordering tolerance (common on WiFi)
    if [ -w /proc/sys/net/ipv4/tcp_reordering ]; then
        echo 5 > /proc/sys/net/ipv4/tcp_reordering || true
    fi
    
    # More aggressive keepalive for detecting WiFi drops
    if [ -w /proc/sys/net/ipv4/tcp_keepalive_time ]; then
        echo 120 > /proc/sys/net/ipv4/tcp_keepalive_time || true
        echo 30 > /proc/sys/net/ipv4/tcp_keepalive_intvl || true
        echo 5 > /proc/sys/net/ipv4/tcp_keepalive_probes || true
    fi
    
    # Enable TCP window scaling for better throughput
    if [ -w /proc/sys/net/ipv4/tcp_window_scaling ]; then
        echo 1 > /proc/sys/net/ipv4/tcp_window_scaling || true
    fi
    
    # Moderate congestion control (better for WiFi than aggressive)
    if [ -w /proc/sys/net/ipv4/tcp_congestion_control ]; then
        echo westwood > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || \
        echo cubic > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null || true
    fi
    
    # Increase max backlog for burst handling
    if [ -w /proc/sys/net/core/netdev_max_backlog ]; then
        echo 2000 > /proc/sys/net/core/netdev_max_backlog || true
    fi
    
    # Longer FIN timeout to handle WiFi delays
    if [ -w /proc/sys/net/ipv4/tcp_fin_timeout ]; then
        echo 60 > /proc/sys/net/ipv4/tcp_fin_timeout || true
    fi
    
    bashio::log.info "WiFi network optimizations applied!"
    
elif bashio::var.true "${low_latency}"; then
    bashio::log.info "Applying system-level low-latency optimizations..."
    
    # TCP tuning for low latency (LAN optimized)
    if [ -w /proc/sys/net/ipv4/tcp_low_latency ]; then
        echo 1 > /proc/sys/net/ipv4/tcp_low_latency || true
    fi
    
    # Reduce TCP delayed ACK timeout
    if [ -w /proc/sys/net/ipv4/tcp_delack_min ]; then
        echo 1 > /proc/sys/net/ipv4/tcp_delack_min || true
    fi
    
    # Enable TCP fast open
    if [ -w /proc/sys/net/ipv4/tcp_fastopen ]; then
        echo 3 > /proc/sys/net/ipv4/tcp_fastopen || true
    fi
    
    # Optimize TCP buffer sizes for low latency
    if [ -w /proc/sys/net/core/rmem_max ]; then
        echo 16777216 > /proc/sys/net/core/rmem_max || true
        echo 16777216 > /proc/sys/net/core/wmem_max || true
    fi
    
    if [ -w /proc/sys/net/ipv4/tcp_rmem ]; then
        echo "4096 87380 16777216" > /proc/sys/net/ipv4/tcp_rmem || true
        echo "4096 87380 16777216" > /proc/sys/net/ipv4/tcp_wmem || true
    fi
    
    # Reduce keepalive time for faster detection
    if [ -w /proc/sys/net/ipv4/tcp_keepalive_time ]; then
        echo 600 > /proc/sys/net/ipv4/tcp_keepalive_time || true
        echo 10 > /proc/sys/net/ipv4/tcp_keepalive_intvl || true
        echo 3 > /proc/sys/net/ipv4/tcp_keepalive_probes || true
    fi
    
    # Disable TCP slow start after idle
    if [ -w /proc/sys/net/ipv4/tcp_slow_start_after_idle ]; then
        echo 0 > /proc/sys/net/ipv4/tcp_slow_start_after_idle || true
    fi
    
    # Enable TCP window scaling
    if [ -w /proc/sys/net/ipv4/tcp_window_scaling ]; then
        echo 1 > /proc/sys/net/ipv4/tcp_window_scaling || true
    fi
    
    # Increase max backlog
    if [ -w /proc/sys/net/core/netdev_max_backlog ]; then
        echo 5000 > /proc/sys/net/core/netdev_max_backlog || true
    fi
    
    bashio::log.info "Low-latency network optimizations applied!"
else
    bashio::log.info "Standard network configuration active."
fi

bashio::log.info "System tuning complete!"
