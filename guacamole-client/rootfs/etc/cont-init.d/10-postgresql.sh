#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Guacamole Client
# Configures PostgreSQL database
# ==============================================================================

declare postgres_dir="/var/lib/postgresql/data"
declare config_dir="/config/guacamole"

bashio::log.info "Initializing PostgreSQL database..."

# Initialize PostgreSQL if needed
if [ ! -d "${postgres_dir}/base" ]; then
    bashio::log.info "Creating new PostgreSQL database..."
    
    mkdir -p "${postgres_dir}"
    chown -R postgres:postgres "${postgres_dir}"
    chmod 700 "${postgres_dir}"
    
    su-exec postgres initdb -D "${postgres_dir}" \
        --encoding=UTF8 \
        --locale=en_US.UTF-8 \
        --username=postgres
    
    # Configure PostgreSQL
    cat >> "${postgres_dir}/postgresql.conf" <<EOF
listen_addresses = 'localhost'
max_connections = 20
shared_buffers = 64MB
effective_cache_size = 256MB
work_mem = 8MB
maintenance_work_mem = 32MB
random_page_cost = 1.1
effective_io_concurrency = 200
wal_buffers = 2MB
min_wal_size = 80MB
max_wal_size = 1GB
EOF

    # Allow local connections
    cat > "${postgres_dir}/pg_hba.conf" <<EOF
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust
EOF
fi

bashio::log.info "Starting PostgreSQL..."
su-exec postgres pg_ctl -D "${postgres_dir}" -w start

# Wait for PostgreSQL to be ready
bashio::log.info "Waiting for PostgreSQL to be ready..."
for i in {1..30}; do
    if su-exec postgres pg_isready -q; then
        bashio::log.info "PostgreSQL is ready!"
        break
    fi
    sleep 1
done

# Check if database exists
if ! su-exec postgres psql -lqt | cut -d \| -f 1 | grep -qw guacamole_db; then
    bashio::log.info "Creating Guacamole database..."
    
    # Create database and user
    su-exec postgres psql -c "CREATE DATABASE guacamole_db;" || true
    su-exec postgres psql -c "CREATE USER guacamole_user WITH PASSWORD 'guacamole_pass';" || true
    su-exec postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE guacamole_db TO guacamole_user;" || true
    
    # Initialize schema
    su-exec postgres psql -d guacamole_db -f /tmp/001-create-schema.sql
    su-exec postgres psql -d guacamole_db -f /tmp/002-create-admin-user.sql
    
    bashio::log.info "Database initialized successfully!"
else
    bashio::log.info "Database already exists, skipping initialization."
fi

# Stop PostgreSQL (will be started by service script)
bashio::log.info "Stopping PostgreSQL initialization instance..."
su-exec postgres pg_ctl -D "${postgres_dir}" -w stop

bashio::log.info "PostgreSQL initialization complete!"
