#!/bin/bash
###############################################################################
# install-ai-platform.sh - Install AI platform tools
#
# This script installs and configures AI platform components:
# - Ollama (Local LLM inference)
# - n8n (Workflow automation)
# - Supabase (Database + Auth platform)
# - Monitoring tools (Grafana, Prometheus)
#
# Installation location: /opt/ai-platform/
#
# Usage: sudo ./install-ai-platform.sh [--component=all|ollama|n8n|supabase|monitoring]
###############################################################################

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
INSTALL_DIR="/opt/ai-platform"
COMPOSE_DIR="$INSTALL_DIR/compose"
DATA_DIR="$INSTALL_DIR/data"

# Component flags
INSTALL_ALL=false
INSTALL_OLLAMA=false
INSTALL_N8N=false
INSTALL_SUPABASE=false
INSTALL_MONITORING=false

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

error_exit() {
    log_error "$1"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root (use sudo)"
    fi
}

# Parse command line arguments
parse_args() {
    if [ $# -eq 0 ]; then
        INSTALL_ALL=true
        return
    fi

    for arg in "$@"; do
        case $arg in
            --component=all)
                INSTALL_ALL=true
                ;;
            --component=ollama)
                INSTALL_OLLAMA=true
                ;;
            --component=n8n)
                INSTALL_N8N=true
                ;;
            --component=supabase)
                INSTALL_SUPABASE=true
                ;;
            --component=monitoring)
                INSTALL_MONITORING=true
                ;;
            --help)
                usage
                ;;
            *)
                log_error "Unknown argument: $arg"
                usage
                ;;
        esac
    done
}

# Usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Install AI platform components in /opt/ai-platform/

Options:
  --component=all          Install all components (default)
  --component=ollama       Install only Ollama
  --component=n8n          Install only n8n
  --component=supabase     Install only Supabase
  --component=monitoring   Install only monitoring tools

Examples:
  $0                              # Install everything
  $0 --component=ollama           # Install only Ollama
  $0 --component=n8n --component=monitoring  # Install n8n and monitoring
EOF
    exit 1
}

# Create base directories
create_directories() {
    log_step "Creating installation directories..."

    mkdir -p "$INSTALL_DIR"/{ollama,n8n,supabase,monitoring}
    mkdir -p "$COMPOSE_DIR"
    mkdir -p "$DATA_DIR"/{ollama,n8n,supabase,grafana,prometheus}

    log_info "Directories created"
}

# Install Ollama
install_ollama() {
    log_step "Installing Ollama..."

    if command -v ollama &> /dev/null; then
        log_warn "Ollama already installed, skipping..."
        return 0
    fi

    # Download and install Ollama
    curl -fsSL https://ollama.com/install.sh | sh || error_exit "Failed to install Ollama"

    # Create systemd service
    cat > /etc/systemd/system/ollama.service << 'EOF'
[Unit]
Description=Ollama Service
After=network.target

[Service]
Type=simple
User=root
Environment="OLLAMA_HOST=0.0.0.0:11434"
Environment="OLLAMA_MODELS=/opt/ai-platform/data/ollama"
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

    # Start and enable service
    systemctl daemon-reload
    systemctl enable ollama
    systemctl start ollama

    # Wait for Ollama to start
    sleep 5

    # Pull default models
    log_info "Pulling default Ollama models..."
    ollama pull llama3:8b || log_warn "Failed to pull llama3:8b"
    ollama pull nomic-embed-text || log_warn "Failed to pull nomic-embed-text"

    log_info "Ollama installed and running on http://localhost:11434"
}

# Install n8n
install_n8n() {
    log_step "Installing n8n..."

    # Create docker-compose file for n8n
    cat > "$COMPOSE_DIR/n8n-compose.yml" << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=admin123
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
      - WEBHOOK_URL=http://localhost:5678/
    volumes:
      - $DATA_DIR/n8n:/home/node/.n8n
      - /var/run/docker.sock:/var/run/docker.sock

  postgres:
    image: postgres:15-alpine
    container_name: n8n_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: n8n
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: n8n_password
    volumes:
      - $DATA_DIR/n8n/postgres:/var/lib/postgresql/data

volumes:
  n8n_data:
  postgres_data:
EOF

    # Start n8n
    docker-compose -f "$COMPOSE_DIR/n8n-compose.yml" up -d || error_exit "Failed to start n8n"

    log_info "n8n installed and running on http://localhost:5678"
    log_info "Default credentials - User: admin, Password: admin123"
}

# Install Supabase
install_supabase() {
    log_step "Installing Supabase..."

    # Clone Supabase if not exists
    if [ ! -d "$INSTALL_DIR/supabase/docker" ]; then
        cd "$INSTALL_DIR/supabase"
        git clone --depth 1 https://github.com/supabase/supabase.git docker || error_exit "Failed to clone Supabase"
    fi

    cd "$INSTALL_DIR/supabase/docker/docker"

    # Copy example env file
    if [ ! -f .env ]; then
        cp .env.example .env
        log_info "Created .env file - please review and update configurations"
    fi

    # Start Supabase
    docker-compose up -d || error_exit "Failed to start Supabase"

    log_info "Supabase installed and running"
    log_info "Studio: http://localhost:3000"
    log_info "API: http://localhost:8000"
    log_info "Check .env file for credentials"
}

# Install Monitoring Stack
install_monitoring() {
    log_step "Installing monitoring stack (Prometheus + Grafana)..."

    # Create Prometheus configuration
    cat > "$INSTALL_DIR/monitoring/prometheus.yml" << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node_exporter:9100']

  - job_name: 'ollama'
    static_configs:
      - targets: ['host.docker.internal:11434']
EOF

    # Create docker-compose file for monitoring
    cat > "$COMPOSE_DIR/monitoring-compose.yml" << EOF
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - $INSTALL_DIR/monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - $DATA_DIR/prometheus:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: unless-stopped
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=admin123
      - GF_INSTALL_PLUGINS=redis-datasource
    volumes:
      - $DATA_DIR/grafana:/var/lib/grafana
    depends_on:
      - prometheus

  node_exporter:
    image: prom/node-exporter:latest
    container_name: node_exporter
    restart: unless-stopped
    ports:
      - "9100:9100"
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro

volumes:
  prometheus_data:
  grafana_data:
EOF

    # Start monitoring stack
    docker-compose -f "$COMPOSE_DIR/monitoring-compose.yml" up -d || error_exit "Failed to start monitoring stack"

    log_info "Monitoring stack installed and running"
    log_info "Prometheus: http://localhost:9090"
    log_info "Grafana: http://localhost:3001 (admin/admin123)"
}

# Create management script
create_management_script() {
    log_step "Creating management script..."

    cat > "$INSTALL_DIR/manage-platform.sh" << 'EOF'
#!/bin/bash
# AI Platform Management Script

COMPOSE_DIR="/opt/ai-platform/compose"

case "$1" in
    start)
        echo "Starting AI platform services..."
        docker-compose -f "$COMPOSE_DIR/n8n-compose.yml" up -d
        docker-compose -f "$COMPOSE_DIR/monitoring-compose.yml" up -d
        systemctl start ollama
        echo "Services started"
        ;;
    stop)
        echo "Stopping AI platform services..."
        docker-compose -f "$COMPOSE_DIR/n8n-compose.yml" down
        docker-compose -f "$COMPOSE_DIR/monitoring-compose.yml" down
        systemctl stop ollama
        echo "Services stopped"
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    status)
        echo "=== Ollama Status ==="
        systemctl status ollama --no-pager
        echo ""
        echo "=== Docker Services ==="
        docker ps --filter "name=n8n|grafana|prometheus"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
EOF

    chmod +x "$INSTALL_DIR/manage-platform.sh"
    ln -sf "$INSTALL_DIR/manage-platform.sh" /usr/local/bin/ai-platform

    log_info "Management script created: ai-platform {start|stop|restart|status}"
}

# Display installation summary
display_summary() {
    log_info "================================================"
    log_info "AI Platform Installation Complete!"
    log_info "================================================"
    log_info ""
    log_info "Installed Components:"

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_OLLAMA" = true ]; then
        log_info "  ✓ Ollama - http://localhost:11434"
    fi

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_N8N" = true ]; then
        log_info "  ✓ n8n - http://localhost:5678 (admin/admin123)"
    fi

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_SUPABASE" = true ]; then
        log_info "  ✓ Supabase - http://localhost:3000"
    fi

    if [ "$INSTALL_ALL" = true ] || [ "$INSTALL_MONITORING" = true ]; then
        log_info "  ✓ Grafana - http://localhost:3001 (admin/admin123)"
        log_info "  ✓ Prometheus - http://localhost:9090"
    fi

    log_info ""
    log_info "Management:"
    log_info "  ai-platform start    - Start all services"
    log_info "  ai-platform stop     - Stop all services"
    log_info "  ai-platform restart  - Restart all services"
    log_info "  ai-platform status   - Check service status"
    log_info ""
    log_info "Installation directory: $INSTALL_DIR"
    log_info "Data directory: $DATA_DIR"
}

# Main execution
main() {
    log_info "AI Platform Installation Script"
    log_info "================================================"

    check_root
    parse_args "$@"

    create_directories

    if [ "$INSTALL_ALL" = true ]; then
        install_ollama
        install_n8n
        install_supabase
        install_monitoring
    else
        [ "$INSTALL_OLLAMA" = true ] && install_ollama
        [ "$INSTALL_N8N" = true ] && install_n8n
        [ "$INSTALL_SUPABASE" = true ] && install_supabase
        [ "$INSTALL_MONITORING" = true ] && install_monitoring
    fi

    create_management_script
    display_summary
}

main "$@"
