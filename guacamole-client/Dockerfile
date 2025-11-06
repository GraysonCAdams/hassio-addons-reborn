ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.1
FROM ${BUILD_FROM}

# Set shell options for better error handling
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# Set Guacamole version (update this to latest stable version)
ENV GUACAMOLE_VERSION=1.5.5 \
    GUACAMOLE_HOME=/app/guacamole \
    CATALINA_HOME=/usr/local/tomcat \
    POSTGRES_VERSION=15

# Install all dependencies (runtime + build) in a single layer to avoid version conflicts
# Strip version pins from /etc/apk/world so musl/libssl upgrades are allowed, then upgrade base before installing
RUN apk update && \
    awk '{gsub(/=.*/,""); print}' /etc/apk/world > /tmp/world && \
    mv /tmp/world /etc/apk/world && \
    apk upgrade --no-cache && \
    apk add --no-cache \
    postgresql${POSTGRES_VERSION} \
    postgresql${POSTGRES_VERSION}-client \
    openjdk17-jre-headless \
    freerdp \
    libssh2 \
    libvncserver \
    pango \
    terminus-font \
    ttf-dejavu \
    ttf-liberation \
    cairo \
    libjpeg-turbo \
    libpng \
    libwebp \
    libwebsockets \
    libpulse \
    su-exec \
    build-base \
    cairo-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libwebsockets-dev \
    freerdp-dev \
    pango-dev \
    libssh2-dev \
    libvncserver-dev \
    pulseaudio-dev \
    libtool \
    autoconf \
    automake \
    wget \
    openjdk17 \
    maven \
    && rm -rf /var/cache/apk/*

# Download and build guacamole-server
WORKDIR /tmp
RUN wget -q "https://downloads.apache.org/guacamole/${GUACAMOLE_VERSION}/source/guacamole-server-${GUACAMOLE_VERSION}.tar.gz" \
    && tar xzf guacamole-server-${GUACAMOLE_VERSION}.tar.gz \
    && cd guacamole-server-${GUACAMOLE_VERSION} \
    && ./configure \
        --prefix=/usr \
        --disable-guaclog \
        --with-freerdp-plugin-dir=/usr/lib/freerdp2 \
    && make -j2 \
    && make install \
    && ldconfig /usr/lib \
    && cd /tmp \
    && rm -rf guacamole-server-${GUACAMOLE_VERSION}*

# Download Tomcat
ENV TOMCAT_VERSION=9.0.93
RUN wget -q "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
    && tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && mv apache-tomcat-${TOMCAT_VERSION} ${CATALINA_HOME} \
    && rm apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && rm -rf ${CATALINA_HOME}/webapps/* \
    && rm -rf ${CATALINA_HOME}/server/webapps/*

# Download and install guacamole-client
RUN wget -q "https://downloads.apache.org/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-${GUACAMOLE_VERSION}.war" -O ${CATALINA_HOME}/webapps/ROOT.war

# Download JDBC driver for PostgreSQL
RUN wget -q "https://jdbc.postgresql.org/download/postgresql-42.7.3.jar" -O /tmp/postgresql-jdbc.jar

# Create guacamole directories
RUN mkdir -p ${GUACAMOLE_HOME}/extensions \
    ${GUACAMOLE_HOME}/lib \
    /config/guacamole \
    /var/lib/postgresql/data

# Download guacamole-auth-jdbc extension
RUN wget -q "https://downloads.apache.org/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz" \
    && tar xzf guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz \
    && cp guacamole-auth-jdbc-${GUACAMOLE_VERSION}/postgresql/guacamole-auth-jdbc-postgresql-${GUACAMOLE_VERSION}.jar ${GUACAMOLE_HOME}/extensions/ \
    && cp /tmp/postgresql-jdbc.jar ${GUACAMOLE_HOME}/lib/ \
    && cp guacamole-auth-jdbc-${GUACAMOLE_VERSION}/postgresql/schema/*.sql /tmp/ \
    && rm -rf guacamole-auth-jdbc-${GUACAMOLE_VERSION}*

# Cleanup build dependencies and temp files
RUN apk del \
    build-base \
    cairo-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libwebsockets-dev \
    freerdp-dev \
    pango-dev \
    libssh2-dev \
    libvncserver-dev \
    pulseaudio-dev \
    libtool \
    autoconf \
    automake \
    wget \
    openjdk17 \
    maven \
    && rm -rf /tmp/* /var/cache/apk/*

# Copy root filesystem
COPY rootfs /

# Set permissions
RUN chmod -R 755 /etc/cont-init.d \
    && chmod -R 755 /etc/services.d \
    && chmod +x /usr/local/bin/optimize-guacamole.sh

# Create postgres user if not already provisioned by base image
RUN if ! getent group postgres > /dev/null; then addgroup -S postgres; fi \
    && if ! id postgres > /dev/null 2>&1; then adduser -S -G postgres postgres; fi \
    && mkdir -p /run/postgresql \
    && chown -R postgres:postgres /run/postgresql \
    && chown -R postgres:postgres /var/lib/postgresql

# Expose ports
EXPOSE 8080 4822

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="Grayson Adams <graysoncadams@gmail.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Grayson Adams" \
    org.opencontainers.image.authors="Grayson Adams <graysoncadams@gmail.com>" \
    org.opencontainers.image.licenses="Apache-2.0" \
    org.opencontainers.image.url="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}"
