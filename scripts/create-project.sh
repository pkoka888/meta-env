#!/bin/bash
###############################################################################
# create-project.sh - Scaffold new project from template
#
# This script creates a new project with the complete meta-env structure:
# - Project directory structure (dev/, prod/, shared/)
# - Version pinning (.python-version, .nvmrc, .envrc)
# - Docker compose configuration
# - AI tool configurations (.claude, .continue, .cline)
# - Git initialization
#
# Usage: ./create-project.sh <project-name> [description]
###############################################################################

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECTS_DIR="${PROJECTS_DIR:-/var/www/projects}"
TEMPLATE_DIR="${TEMPLATE_DIR:-/var/www/universal-env/templates}"
DEFAULT_PYTHON_VERSION="3.11.5"
DEFAULT_NODE_VERSION="20.10.0"

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

# Usage information
usage() {
    cat << EOF
Usage: $0 <project-name> [description]

Arguments:
  project-name    Name of the project (required)
  description     Project description (optional)

Examples:
  $0 my-api "REST API with FastAPI"
  $0 ai-agent "Multi-agent RAG system"

Environment Variables:
  PROJECTS_DIR    Project directory (default: /var/www/projects)
  TEMPLATE_DIR    Template directory (default: /var/www/universal-env/templates)
EOF
    exit 1
}

# Validate project name
validate_project_name() {
    local name="$1"

    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        error_exit "Invalid project name. Use only letters, numbers, hyphens, and underscores."
    fi

    if [ -d "$PROJECTS_DIR/$name" ]; then
        error_exit "Project '$name' already exists in $PROJECTS_DIR"
    fi
}

# Create project directory structure
create_directory_structure() {
    local project_name="$1"
    local project_dir="$PROJECTS_DIR/$project_name"

    log_step "Creating directory structure..."

    mkdir -p "$project_dir"/{dev,prod,shared,docs,tests}
    mkdir -p "$project_dir"/dev/{src,data,logs}
    mkdir -p "$project_dir"/prod/{dist,logs}
    mkdir -p "$project_dir"/shared/{nginx,redis,docker}
    mkdir -p "$project_dir"/.claude
    mkdir -p "$project_dir"/.continue
    mkdir -p "$project_dir"/.cline
    mkdir -p "$project_dir"/memory

    log_info "Directory structure created"
}

# Create version files
create_version_files() {
    local project_dir="$1"

    log_step "Creating version configuration files..."

    # .python-version
    echo "$DEFAULT_PYTHON_VERSION" > "$project_dir/.python-version"
    log_info "Created .python-version (Python $DEFAULT_PYTHON_VERSION)"

    # .nvmrc
    echo "$DEFAULT_NODE_VERSION" > "$project_dir/.nvmrc"
    log_info "Created .nvmrc (Node $DEFAULT_NODE_VERSION)"

    # .envrc
    cat > "$project_dir/.envrc" << 'EOF'
# Auto-activate Python virtual environment
layout python

# Load environment-specific variables
if [ -f .env ]; then
    source_env .env
fi

# Load development environment
if [ -f dev/.env.dev ]; then
    source_env dev/.env.dev
fi
EOF

    log_info "Created .envrc for direnv"
}

# Create environment files
create_env_files() {
    local project_dir="$1"
    local project_name="$2"

    log_step "Creating environment configuration files..."

    # Development environment
    cat > "$project_dir/dev/.env.dev" << EOF
# Development Environment
PROJECT_NAME=$project_name
ENVIRONMENT=development
DEBUG=true

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/${project_name}_dev
REDIS_URL=redis://localhost:6379/0

# AI Platform
OLLAMA_HOST=http://localhost:11434
N8N_HOST=http://localhost:5678

# Monitoring
LOG_LEVEL=debug
EOF

    # Production environment
    cat > "$project_dir/prod/.env.prod" << EOF
# Production Environment
PROJECT_NAME=$project_name
ENVIRONMENT=production
DEBUG=false

# Database (configure with actual credentials)
DATABASE_URL=postgresql://user:password@localhost:5432/${project_name}_prod
REDIS_URL=redis://localhost:6380/0

# AI Platform
OLLAMA_HOST=http://localhost:11434

# Monitoring
LOG_LEVEL=info
EOF

    log_info "Created environment files"
}

# Create Docker Compose files
create_docker_files() {
    local project_dir="$1"
    local project_name="$2"

    log_step "Creating Docker Compose configurations..."

    # Development docker-compose
    cat > "$project_dir/dev/docker-compose.dev.yml" << EOF
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: ${project_name}_redis_dev
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

  postgres:
    image: postgres:15-alpine
    container_name: ${project_name}_postgres_dev
    environment:
      POSTGRES_DB: ${project_name}_dev
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  redis_data:
  postgres_data:
EOF

    # Production docker-compose
    cat > "$project_dir/prod/docker-compose.prod.yml" << EOF
version: '3.8'

services:
  redis:
    image: redis:7-alpine
    container_name: ${project_name}_redis_prod
    ports:
      - "6380:6379"
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    container_name: ${project_name}_postgres_prod
    environment:
      POSTGRES_DB: ${project_name}_prod
      POSTGRES_USER: user
      POSTGRES_PASSWORD: \${POSTGRES_PASSWORD}
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  redis_data:
  postgres_data:
EOF

    log_info "Created Docker Compose files"
}

# Create README and documentation
create_documentation() {
    local project_dir="$1"
    local project_name="$2"
    local description="$3"

    log_step "Creating project documentation..."

    cat > "$project_dir/README.md" << EOF
# $project_name

$description

## Setup

\`\`\`bash
# Activate environment
cd $project_name
direnv allow

# Install Python dependencies
pip install -r requirements.txt

# Start development services
cd dev
docker-compose -f docker-compose.dev.yml up -d
\`\`\`

## Project Structure

\`\`\`
$project_name/
├── dev/                    # Development workspace
├── prod/                   # Production builds
├── shared/                 # Shared configurations
├── docs/                   # Documentation
├── tests/                  # Test files
├── memory/                 # AI context memory
├── .python-version         # Python: $DEFAULT_PYTHON_VERSION
├── .nvmrc                  # Node: $DEFAULT_NODE_VERSION
└── .envrc                  # direnv configuration
\`\`\`

## Environment

- Python: $DEFAULT_PYTHON_VERSION
- Node.js: $DEFAULT_NODE_VERSION
- Redis: 6379 (dev), 6380 (prod)
- PostgreSQL: 5432 (dev), 5433 (prod)

## AI Tools

- Claude Code: Configured in .claude/
- Continue.dev: Configured in .continue/
- Cline: Configured in .cline/

## Development

\`\`\`bash
# Development mode
cd dev
source .env.dev

# Production mode
cd prod
source .env.prod
\`\`\`
EOF

    # Create project checklist
    cat > "$project_dir/memory/project-checklist.md" << EOF
# $project_name - Project Checklist

## Project Information
- **Name**: $project_name
- **Description**: $description
- **Created**: $(date +%Y-%m-%d)
- **Environment**: meta-env

## Stack
- [ ] Python $DEFAULT_PYTHON_VERSION
- [ ] Node.js $DEFAULT_NODE_VERSION
- [ ] Redis
- [ ] PostgreSQL

## Setup Tasks
- [x] Project structure created
- [ ] Dependencies installed
- [ ] Database configured
- [ ] Tests written
- [ ] CI/CD configured

## AI Configuration
- [x] Claude Code setup
- [x] Directory structure optimized
- [ ] Context memory initialized
- [ ] RAG system configured (if needed)
- [ ] Multi-agent setup (if needed)
EOF

    log_info "Created documentation files"
}

# Initialize Git repository
init_git() {
    local project_dir="$1"
    local project_name="$2"
    local description="$3"

    log_step "Initializing Git repository..."

    cd "$project_dir"

    # Create .gitignore
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
env/
ENV/
.venv

# Node
node_modules/
npm-debug.log
yarn-error.log

# Environment
.env
.env.*
!.env.example

# IDE
.vscode/
.idea/
*.swp
*.swo

# Logs
*.log
logs/

# Data
data/
*.db
*.sqlite

# OS
.DS_Store
Thumbs.db

# Docker
docker-compose.override.yml
EOF

    # Initialize git
    git init
    git add .
    git commit -m "Initial commit: $project_name - $description" || log_warn "Failed to create initial commit"

    log_info "Git repository initialized"
}

# Create requirements.txt
create_requirements() {
    local project_dir="$1"

    log_step "Creating requirements.txt..."

    cat > "$project_dir/requirements.txt" << 'EOF'
# Core dependencies
python-dotenv>=1.0.0

# Database
psycopg2-binary>=2.9.0
redis>=5.0.0

# AI/ML (optional, uncomment as needed)
# pyautogen>=0.2.0
# langchain>=0.1.0
# chromadb>=0.4.0
# litellm>=1.0.0

# Development
pytest>=7.0.0
black>=23.0.0
ruff>=0.1.0
EOF

    log_info "Created requirements.txt"
}

# Create package.json
create_package_json() {
    local project_dir="$1"
    local project_name="$2"
    local description="$3"

    log_step "Creating package.json..."

    cat > "$project_dir/package.json" << EOF
{
  "name": "$project_name",
  "version": "0.1.0",
  "description": "$description",
  "scripts": {
    "dev": "cd dev && docker-compose -f docker-compose.dev.yml up",
    "prod": "cd prod && docker-compose -f docker-compose.prod.yml up -d",
    "test": "pytest tests/"
  },
  "keywords": ["meta-env", "ai", "automation"],
  "author": "",
  "license": "MIT"
}
EOF

    log_info "Created package.json"
}

# Main execution
main() {
    if [ $# -lt 1 ]; then
        usage
    fi

    local project_name="$1"
    local description="${2:-A meta-env project}"
    local project_dir="$PROJECTS_DIR/$project_name"

    log_info "Creating new project: $project_name"
    log_info "Description: $description"
    log_info "Location: $project_dir"
    log_info "================================================"

    validate_project_name "$project_name"
    create_directory_structure "$project_name"
    create_version_files "$project_dir"
    create_env_files "$project_dir" "$project_name"
    create_docker_files "$project_dir" "$project_name"
    create_requirements "$project_dir"
    create_package_json "$project_dir" "$project_name" "$description"
    create_documentation "$project_dir" "$project_name" "$description"
    init_git "$project_dir" "$project_name" "$description"

    log_info "================================================"
    log_info "Project '$project_name' created successfully!"
    log_info ""
    log_info "Next steps:"
    log_info "  cd $project_dir"
    log_info "  direnv allow"
    log_info "  pip install -r requirements.txt"
    log_info "  cd dev && docker-compose -f docker-compose.dev.yml up -d"
    log_info ""
    log_info "Open in VS Code: code $project_dir"
}

main "$@"
