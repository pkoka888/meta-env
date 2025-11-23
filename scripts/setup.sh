#!/bin/bash
###############################################################################
# setup.sh - Bootstrap script for new meta-env installation
#
# This script sets up the complete meta-env development environment including:
# - System dependencies (pyenv, nvm, direnv, docker)
# - Directory structure (/opt/ai-platform, /var/www/universal-env)
# - Basic configurations
#
# Usage: sudo ./setup.sh
###############################################################################

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Error handler
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

# Detect actual user (when run with sudo)
get_actual_user() {
    if [ -n "${SUDO_USER:-}" ]; then
        echo "$SUDO_USER"
    else
        echo "$USER"
    fi
}

# Install system dependencies
install_system_deps() {
    log_info "Installing system dependencies..."

    apt-get update || error_exit "Failed to update package lists"

    apt-get install -y \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        wget \
        curl \
        llvm \
        libncurses5-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libffi-dev \
        liblzma-dev \
        git \
        direnv \
        docker.io \
        docker-compose \
        redis-tools \
        postgresql-client \
        || error_exit "Failed to install system dependencies"

    log_info "System dependencies installed successfully"
}

# Install pyenv for Python version management
install_pyenv() {
    local actual_user=$(get_actual_user)
    local user_home=$(eval echo "~$actual_user")

    log_info "Installing pyenv for user: $actual_user"

    if [ -d "$user_home/.pyenv" ]; then
        log_warn "pyenv already installed, skipping..."
        return 0
    fi

    # Install pyenv as the actual user
    sudo -u "$actual_user" bash -c "curl https://pyenv.run | bash" || error_exit "Failed to install pyenv"

    # Add pyenv to shell configuration
    local shell_rc="$user_home/.bashrc"
    if ! grep -q "pyenv init" "$shell_rc"; then
        cat >> "$shell_rc" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF
        log_info "Added pyenv configuration to $shell_rc"
    fi

    log_info "pyenv installed successfully"
}

# Install nvm for Node.js version management
install_nvm() {
    local actual_user=$(get_actual_user)
    local user_home=$(eval echo "~$actual_user")

    log_info "Installing nvm for user: $actual_user"

    if [ -d "$user_home/.nvm" ]; then
        log_warn "nvm already installed, skipping..."
        return 0
    fi

    # Install nvm as the actual user
    sudo -u "$actual_user" bash -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash" \
        || error_exit "Failed to install nvm"

    log_info "nvm installed successfully"
}

# Setup direnv hook
setup_direnv() {
    local actual_user=$(get_actual_user)
    local user_home=$(eval echo "~$actual_user")
    local shell_rc="$user_home/.bashrc"

    log_info "Configuring direnv..."

    if ! grep -q "direnv hook" "$shell_rc"; then
        echo 'eval "$(direnv hook bash)"' >> "$shell_rc"
        log_info "Added direnv hook to $shell_rc"
    else
        log_warn "direnv hook already configured"
    fi
}

# Create directory structure
create_directory_structure() {
    local actual_user=$(get_actual_user)

    log_info "Creating directory structure..."

    # Create /opt/ai-platform/
    mkdir -p /opt/ai-platform/{ollama,n8n,supabase,monitoring}
    chown -R root:root /opt/ai-platform
    chmod 755 /opt/ai-platform

    # Create /var/www/universal-env/
    mkdir -p /var/www/universal-env/{python-versions,node-versions,mcp-servers,redis-configs,docker-compose-templates}
    chown -R "$actual_user":www-data /var/www/universal-env
    chmod 2775 /var/www/universal-env

    # Create /var/www/projects/
    mkdir -p /var/www/projects
    chown -R "$actual_user":www-data /var/www/projects
    chmod 2775 /var/www/projects

    log_info "Directory structure created successfully"
}

# Setup Docker
setup_docker() {
    local actual_user=$(get_actual_user)

    log_info "Configuring Docker..."

    # Add user to docker group
    usermod -aG docker "$actual_user" || log_warn "Failed to add user to docker group"

    # Start and enable Docker
    systemctl start docker || log_warn "Failed to start Docker"
    systemctl enable docker || log_warn "Failed to enable Docker"

    log_info "Docker configured successfully"
}

# Copy meta-env scripts and templates
setup_meta_env() {
    local actual_user=$(get_actual_user)

    log_info "Setting up meta-env in /var/www/universal-env/..."

    # Copy templates and configs
    if [ -d "/home/$actual_user/meta-env/templates" ]; then
        cp -r "/home/$actual_user/meta-env/templates" /var/www/universal-env/
        log_info "Copied templates"
    fi

    if [ -d "/home/$actual_user/meta-env/configs" ]; then
        cp -r "/home/$actual_user/meta-env/configs" /var/www/universal-env/
        log_info "Copied configs"
    fi

    # Make scripts available globally
    if [ -d "/home/$actual_user/meta-env/scripts" ]; then
        ln -sf "/home/$actual_user/meta-env/scripts" /var/www/universal-env/scripts
        log_info "Created symlink to scripts"
    fi

    # Fix permissions
    chown -R "$actual_user":www-data /var/www/universal-env

    log_info "meta-env setup completed"
}

# Create Redis template configuration
create_redis_template() {
    log_info "Creating Redis template configuration..."

    cat > /var/www/universal-env/redis-configs/redis-template.conf << 'EOF'
# Redis template configuration for meta-env projects
bind 127.0.0.1
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300

# Persistence
databases 16
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb

# Logging
loglevel notice
logfile ""

# Memory
maxmemory-policy noeviction
EOF

    log_info "Redis template created"
}

# Main execution
main() {
    log_info "Starting meta-env bootstrap setup..."
    log_info "================================================"

    check_root

    local actual_user=$(get_actual_user)
    log_info "Installing for user: $actual_user"

    install_system_deps
    install_pyenv
    install_nvm
    setup_direnv
    create_directory_structure
    setup_docker
    setup_meta_env
    create_redis_template

    log_info "================================================"
    log_info "meta-env bootstrap completed successfully!"
    log_info ""
    log_info "Next steps:"
    log_info "  1. Logout and login again (or run: source ~/.bashrc)"
    log_info "  2. Install AI platform: sudo ./install-ai-platform.sh"
    log_info "  3. Create your first project: ./create-project.sh my-project"
    log_info ""
    log_info "Directory structure created:"
    log_info "  /opt/ai-platform/           - System-wide AI tools"
    log_info "  /var/www/universal-env/     - Shared configs and templates"
    log_info "  /var/www/projects/          - Your projects"
}

main "$@"
