ARG BUILD_FROM=ghcr.io/hassio-addons/base:15.0.1
ARG GUACAMOLE_VERSION=1.5.5
ARG TOMCAT_VERSION=9.0.93
ARG POSTGRES_VERSION=15

FROM alpine:3.19 AS builder

ARG GUACAMOLE_VERSION

RUN apk add --no-cache \
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
    wget

WORKDIR /src

RUN set -eux; \
    wget -q "https://downloads.apache.org/guacamole/${GUACAMOLE_VERSION}/source/guacamole-server-${GUACAMOLE_VERSION}.tar.gz"; \
    tar xzf guacamole-server-${GUACAMOLE_VERSION}.tar.gz; \
    cd guacamole-server-${GUACAMOLE_VERSION}; \
    ./configure \
        --prefix=/usr \
        --disable-guaclog \
        --with-freerdp-plugin-dir=/usr/lib/freerdp2; \
    make -j$(nproc); \
    make DESTDIR=/build install

FROM ${BUILD_FROM}

ARG GUACAMOLE_VERSION
ARG TOMCAT_VERSION
ARG POSTGRES_VERSION

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ENV GUACAMOLE_VERSION=${GUACAMOLE_VERSION} \
    GUACAMOLE_HOME=/app/guacamole \
    CATALINA_HOME=/usr/local/tomcat \
    POSTGRES_VERSION=${POSTGRES_VERSION} \
    TOMCAT_VERSION=${TOMCAT_VERSION}

RUN apk add --no-cache \
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
    && rm -rf /var/cache/apk/*

COPY --from=builder /build/usr/ /usr/

RUN if command -v ldconfig >/dev/null 2>&1; then ldconfig /usr/lib; fi

WORKDIR /tmp

RUN wget -q "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
    && tar xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && mv apache-tomcat-${TOMCAT_VERSION} ${CATALINA_HOME} \
    && rm apache-tomcat-${TOMCAT_VERSION}.tar.gz \
    && rm -rf ${CATALINA_HOME}/webapps/* \
    && rm -rf ${CATALINA_HOME}/server/webapps/*

RUN wget -q "https://downloads.apache.org/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-${GUACAMOLE_VERSION}.war" -O ${CATALINA_HOME}/webapps/ROOT.war

RUN wget -q "https://jdbc.postgresql.org/download/postgresql-42.7.3.jar" -O /tmp/postgresql-jdbc.jar

RUN mkdir -p ${GUACAMOLE_HOME}/extensions \
    ${GUACAMOLE_HOME}/lib \
    /config/guacamole \
    /var/lib/postgresql/data

RUN wget -q "https://downloads.apache.org/guacamole/${GUACAMOLE_VERSION}/binary/guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz" \
    && tar xzf guacamole-auth-jdbc-${GUACAMOLE_VERSION}.tar.gz \
    && cp guacamole-auth-jdbc-${GUACAMOLE_VERSION}/postgresql/guacamole-auth-jdbc-postgresql-${GUACAMOLE_VERSION}.jar ${GUACAMOLE_HOME}/extensions/ \
    && cp /tmp/postgresql-jdbc.jar ${GUACAMOLE_HOME}/lib/ \
    && cp guacamole-auth-jdbc-${GUACAMOLE_VERSION}/postgresql/schema/*.sql /tmp/ \
    && rm -rf guacamole-auth-jdbc-${GUACAMOLE_VERSION}* \
    && rm -f /tmp/postgresql-jdbc.jar

COPY rootfs /

RUN chmod -R 755 /etc/cont-init.d \
    && chmod -R 755 /etc/services.d \
    && chmod +x /usr/local/bin/optimize-guacamole.sh

RUN if ! getent group postgres > /dev/null; then addgroup -S postgres; fi \
    && if ! id postgres > /dev/null 2>&1; then adduser -S -G postgres postgres; fi \
    && mkdir -p /run/postgresql \
    && chown -R postgres:postgres /run/postgresql \
    && chown -R postgres:postgres /var/lib/postgresql

RUN rm -rf /tmp/*

EXPOSE 8080 4822

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

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
