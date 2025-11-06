#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Guacamole Client
# Configures Tomcat with performance optimizations
# ==============================================================================

declare catalina_home="/usr/local/tomcat"

bashio::log.info "Configuring Tomcat..."

# Get Java options from config or use defaults
JAVA_OPTS=$(bashio::config 'java_opts' '-Xms256m -Xmx384m -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:GCTimeRatio=9')
LOW_LATENCY=$(bashio::config 'enable_low_latency_mode' 'false')
WIFI_MODE=$(bashio::config 'enable_wifi_optimization' 'true')

bashio::log.info "Java Options: ${JAVA_OPTS}"
bashio::log.info "Low Latency Mode: ${LOW_LATENCY}"
bashio::log.info "WiFi Optimization: ${WIFI_MODE}"

# Build optimized CATALINA_OPTS based on mode
if bashio::var.true "${WIFI_MODE}"; then
    bashio::log.info "Applying WiFi-optimized settings (connection resilience priority)..."
    CATALINA_OPTS_BASE="${JAVA_OPTS} -Djava.awt.headless=true -XX:+UseStringDeduplication"
    # WiFi mode: focus on stability and bandwidth efficiency
elif bashio::var.true "${LOW_LATENCY}"; then
    bashio::log.info "Applying ultra-low latency optimizations..."
    CATALINA_OPTS_BASE="${JAVA_OPTS} -Djava.awt.headless=true -XX:+UseStringDeduplication -XX:+DisableExplicitGC"
    CATALINA_OPTS="${CATALINA_OPTS_BASE} -XX:+AlwaysPreTouch -XX:+UseNUMA -Djava.net.preferIPv4Stack=true -Djava.security.egd=file:/dev/./urandom"
else
    CATALINA_OPTS_BASE="${JAVA_OPTS} -Djava.awt.headless=true -XX:+UseStringDeduplication"
fi

CATALINA_OPTS="${CATALINA_OPTS:-$CATALINA_OPTS_BASE}"

# Export environment variables for Tomcat
export CATALINA_HOME="${catalina_home}"
export CATALINA_OPTS="${CATALINA_OPTS}"
export GUACAMOLE_HOME="/app/guacamole"

# Create setenv.sh for Tomcat
cat > "${catalina_home}/bin/setenv.sh" <<EOF
#!/bin/sh
export CATALINA_OPTS="${CATALINA_OPTS}"
export GUACAMOLE_HOME="${GUACAMOLE_HOME}"
export JAVA_OPTS="${JAVA_OPTS}"
EOF

chmod +x "${catalina_home}/bin/setenv.sh"

# Determine connection settings based on mode
if bashio::var.true "${WIFI_MODE}"; then
    # WiFi optimized: fewer threads, longer timeouts, more retries
    MAX_THREADS=75
    MIN_SPARE_THREADS=10
    ACCEPT_COUNT=50
    CONNECTION_TIMEOUT=60000
    KEEP_ALIVE_TIMEOUT=30000
    MAX_KEEP_ALIVE_REQUESTS=50
    bashio::log.info "WiFi Mode: Conservative settings for connection stability"
elif bashio::var.true "${LOW_LATENCY}"; then
    # Low latency: aggressive settings
    MAX_THREADS=200
    MIN_SPARE_THREADS=50
    ACCEPT_COUNT=150
    CONNECTION_TIMEOUT=10000
    KEEP_ALIVE_TIMEOUT=5000
    MAX_KEEP_ALIVE_REQUESTS=200
    bashio::log.info "Low Latency Mode: Aggressive settings for minimum delay"
else
    # Standard: balanced settings
    MAX_THREADS=150
    MIN_SPARE_THREADS=25
    ACCEPT_COUNT=100
    CONNECTION_TIMEOUT=20000
    KEEP_ALIVE_TIMEOUT=15000
    MAX_KEEP_ALIVE_REQUESTS=100
    bashio::log.info "Standard Mode: Balanced settings"
fi

# Configure Tomcat server.xml
cat > "${catalina_home}/conf/server.xml" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Server port="-1" shutdown="SHUTDOWN">
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="${CONNECTION_TIMEOUT}"
               keepAliveTimeout="${KEEP_ALIVE_TIMEOUT}"
               maxKeepAliveRequests="${MAX_KEEP_ALIVE_REQUESTS}"
               maxThreads="${MAX_THREADS}"
               minSpareThreads="${MIN_SPARE_THREADS}"
               maxConnections="10000"
               acceptCount="${ACCEPT_COUNT}"
               compression="on"
               compressionMinSize="1024"
               noCompressionUserAgents="gozilla, traviata"
               compressibleMimeType="text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/json"
               URIEncoding="UTF-8"
               enableLookups="false"
               disableUploadTimeout="true"
               maxHttpHeaderSize="8192"
               socketBuffer="65536"
               processorCache="${MAX_THREADS}" />

    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps"
            unpackWARs="true" autoDeploy="false"
            deployOnStartup="true">
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log" suffix=".txt"
               pattern="%h %l %u %t &quot;%r&quot; %s %b %D" 
               buffered="false" />
      </Host>
    </Engine>
  </Service>
</Server>
EOF

bashio::log.info "Tomcat configuration complete! (Threads: ${MAX_THREADS}, Timeout: ${CONNECTION_TIMEOUT}ms)"
