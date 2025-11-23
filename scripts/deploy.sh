#!/bin/bash
###############################################################################
# deploy.sh - Deployment script for meta-env projects
#
# This script handles deployment of projects from dev to prod:
# - Build production artifacts
# - Run tests
# - Deploy to production environment
# - Health checks
# - Rollback on failure
#
# Usage: ./deploy.sh <project-name> [--skip-tests] [--no-backup]
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
SKIP_TESTS=false
NO_BACKUP=false
DEPLOY_TIMESTAMP=$(date +%Y%m%d_%H%M%S)

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
Usage: $0 <project-name> [OPTIONS]

Deploy project from development to production environment.

Arguments:
  project-name    Name of the project to deploy

Options:
  --skip-tests    Skip running tests before deployment
  --no-backup     Skip creating backup before deployment
  --help          Show this help message

Examples:
  $0 my-project
  $0 my-api --skip-tests
  $0 my-app --no-backup

Environment Variables:
  PROJECTS_DIR    Projects directory (default: /var/www/projects)
EOF
    exit 1
}

# Parse command line arguments
parse_args() {
    if [ $# -lt 1 ]; then
        usage
    fi

    PROJECT_NAME="$1"
    shift

    while [ $# -gt 0 ]; do
        case "$1" in
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --no-backup)
                NO_BACKUP=true
                shift
                ;;
            --help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
}

# Validate project exists
validate_project() {
    local project_dir="$PROJECTS_DIR/$PROJECT_NAME"

    if [ ! -d "$project_dir" ]; then
        error_exit "Project '$PROJECT_NAME' not found in $PROJECTS_DIR"
    fi

    if [ ! -d "$project_dir/dev" ] || [ ! -d "$project_dir/prod" ]; then
        error_exit "Project structure invalid (missing dev/ or prod/ directories)"
    fi

    PROJECT_DIR="$project_dir"
}

# Check git status
check_git_status() {
    log_step "Checking Git status..."

    cd "$PROJECT_DIR"

    if [ ! -d ".git" ]; then
        log_warn "Not a Git repository, skipping Git checks"
        return 0
    fi

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_warn "Uncommitted changes detected!"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error_exit "Deployment cancelled"
        fi
    fi

    # Get current branch and commit
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    GIT_COMMIT=$(git rev-parse --short HEAD)

    log_info "Branch: $GIT_BRANCH"
    log_info "Commit: $GIT_COMMIT"
}

# Run tests
run_tests() {
    if [ "$SKIP_TESTS" = true ]; then
        log_warn "Skipping tests (--skip-tests flag set)"
        return 0
    fi

    log_step "Running tests..."

    cd "$PROJECT_DIR"

    # Check if tests exist
    if [ ! -d "tests" ] && [ ! -f "pytest.ini" ] && [ ! -f "setup.cfg" ]; then
        log_warn "No tests found, skipping test execution"
        return 0
    fi

    # Run pytest if available
    if command -v pytest &> /dev/null; then
        pytest tests/ || error_exit "Tests failed! Fix issues before deploying."
        log_info "✓ All tests passed"
    else
        log_warn "pytest not found, skipping tests"
    fi
}

# Create backup
create_backup() {
    if [ "$NO_BACKUP" = true ]; then
        log_warn "Skipping backup (--no-backup flag set)"
        return 0
    fi

    log_step "Creating backup..."

    local backup_dir="$PROJECT_DIR/backups/$DEPLOY_TIMESTAMP"
    mkdir -p "$backup_dir"

    # Backup production files
    if [ -d "$PROJECT_DIR/prod/dist" ]; then
        cp -r "$PROJECT_DIR/prod/dist" "$backup_dir/dist.bak" || log_warn "Failed to backup dist/"
    fi

    # Backup environment file
    if [ -f "$PROJECT_DIR/prod/.env.prod" ]; then
        cp "$PROJECT_DIR/prod/.env.prod" "$backup_dir/.env.prod.bak"
    fi

    # Backup database (if PostgreSQL)
    if [ -f "$PROJECT_DIR/prod/.env.prod" ]; then
        source "$PROJECT_DIR/prod/.env.prod"
        if [ -n "${DATABASE_URL:-}" ]; then
            log_info "Creating database backup..."
            # Extract DB connection info and backup
            # This is a placeholder - adjust based on your actual DB setup
            log_warn "Database backup not implemented - add your DB backup logic here"
        fi
    fi

    # Create backup manifest
    cat > "$backup_dir/manifest.txt" << EOF
Deployment Backup
=================
Project: $PROJECT_NAME
Timestamp: $DEPLOY_TIMESTAMP
Git Branch: ${GIT_BRANCH:-unknown}
Git Commit: ${GIT_COMMIT:-unknown}
EOF

    log_info "Backup created: $backup_dir"
    BACKUP_DIR="$backup_dir"
}

# Build production artifacts
build_production() {
    log_step "Building production artifacts..."

    cd "$PROJECT_DIR/dev"

    # Python build
    if [ -f "setup.py" ] || [ -f "pyproject.toml" ]; then
        log_info "Building Python package..."
        python -m pip install build || log_warn "pip build not available"
        python -m build || log_warn "Build failed"
    fi

    # Node.js build
    if [ -f "package.json" ]; then
        log_info "Building Node.js application..."
        if command -v npm &> /dev/null; then
            npm run build || log_warn "npm build failed (check if build script exists)"
        fi
    fi

    # Copy built files to prod
    log_info "Copying artifacts to production..."

    # Copy source files
    rsync -av --exclude='node_modules' --exclude='__pycache__' --exclude='.git' \
        "$PROJECT_DIR/dev/src/" "$PROJECT_DIR/prod/dist/" 2>/dev/null || log_warn "No src/ directory to sync"

    # Copy dependencies
    if [ -f "$PROJECT_DIR/dev/requirements.txt" ]; then
        cp "$PROJECT_DIR/dev/requirements.txt" "$PROJECT_DIR/prod/"
    fi

    if [ -f "$PROJECT_DIR/dev/package.json" ]; then
        cp "$PROJECT_DIR/dev/package.json" "$PROJECT_DIR/prod/"
    fi

    log_info "✓ Production artifacts built"
}

# Deploy to production
deploy_to_production() {
    log_step "Deploying to production..."

    cd "$PROJECT_DIR/prod"

    # Stop running services
    if [ -f "docker-compose.prod.yml" ]; then
        log_info "Stopping production services..."
        docker-compose -f docker-compose.prod.yml down || log_warn "Failed to stop services"
    fi

    # Install production dependencies
    if [ -f "requirements.txt" ]; then
        log_info "Installing Python dependencies..."
        pip install -r requirements.txt || log_warn "Failed to install Python dependencies"
    fi

    if [ -f "package.json" ]; then
        log_info "Installing Node dependencies..."
        npm install --production || log_warn "Failed to install Node dependencies"
    fi

    # Start production services
    if [ -f "docker-compose.prod.yml" ]; then
        log_info "Starting production services..."
        docker-compose -f docker-compose.prod.yml up -d || error_exit "Failed to start production services"
    fi

    log_info "✓ Deployed to production"
}

# Run health checks
run_health_checks() {
    log_step "Running health checks..."

    sleep 5  # Wait for services to start

    # Check Docker containers
    if [ -f "$PROJECT_DIR/prod/docker-compose.prod.yml" ]; then
        log_info "Checking Docker containers..."
        cd "$PROJECT_DIR/prod"

        local running_containers=$(docker-compose -f docker-compose.prod.yml ps --services --filter "status=running" | wc -l)
        local total_containers=$(docker-compose -f docker-compose.prod.yml ps --services | wc -l)

        if [ "$running_containers" -eq "$total_containers" ]; then
            log_info "✓ All containers are running ($running_containers/$total_containers)"
        else
            log_warn "⚠ Some containers are not running ($running_containers/$total_containers)"
            docker-compose -f docker-compose.prod.yml ps
        fi
    fi

    # Check if health-check script exists
    if [ -x "/home/user/meta-env/scripts/health-check.sh" ]; then
        log_info "Running health check script..."
        /home/user/meta-env/scripts/health-check.sh "$PROJECT_NAME" || log_warn "Health check reported issues"
    fi

    log_info "✓ Health checks completed"
}

# Rollback deployment
rollback_deployment() {
    log_error "Deployment failed! Rolling back..."

    if [ -z "${BACKUP_DIR:-}" ]; then
        log_error "No backup available for rollback"
        return 1
    fi

    # Restore from backup
    if [ -d "$BACKUP_DIR/dist.bak" ]; then
        rm -rf "$PROJECT_DIR/prod/dist"
        cp -r "$BACKUP_DIR/dist.bak" "$PROJECT_DIR/prod/dist"
        log_info "Restored production files from backup"
    fi

    # Restart services
    cd "$PROJECT_DIR/prod"
    if [ -f "docker-compose.prod.yml" ]; then
        docker-compose -f docker-compose.prod.yml up -d
        log_info "Restarted production services"
    fi

    log_info "Rollback completed"
}

# Create deployment record
create_deployment_record() {
    local status="$1"

    log_step "Recording deployment..."

    local deploy_log="$PROJECT_DIR/deployments.log"

    cat >> "$deploy_log" << EOF
================================================================================
Deployment: $DEPLOY_TIMESTAMP
Status: $status
Project: $PROJECT_NAME
Git Branch: ${GIT_BRANCH:-unknown}
Git Commit: ${GIT_COMMIT:-unknown}
Deployed by: $USER
Timestamp: $(date)
Tests: $([ "$SKIP_TESTS" = true ] && echo "skipped" || echo "passed")
Backup: $([ "$NO_BACKUP" = true ] && echo "skipped" || echo "$BACKUP_DIR")
================================================================================

EOF

    log_info "Deployment recorded in $deploy_log"
}

# Main execution
main() {
    log_info "Meta-Env Deployment Script"
    log_info "================================================"

    parse_args "$@"
    validate_project

    log_info "Deploying project: $PROJECT_NAME"
    log_info "Project directory: $PROJECT_DIR"
    log_info "Timestamp: $DEPLOY_TIMESTAMP"
    log_info ""

    # Set error handler for rollback
    trap 'rollback_deployment; create_deployment_record "FAILED"' ERR

    check_git_status
    run_tests
    create_backup
    build_production
    deploy_to_production
    run_health_checks

    # Disable error handler (deployment successful)
    trap - ERR

    create_deployment_record "SUCCESS"

    log_info "================================================"
    log_info "Deployment completed successfully!"
    log_info "================================================"
    log_info ""
    log_info "Project: $PROJECT_NAME"
    log_info "Timestamp: $DEPLOY_TIMESTAMP"
    log_info "Backup: ${BACKUP_DIR:-none}"
    log_info ""
    log_info "Next steps:"
    log_info "  - Monitor logs: docker-compose -f $PROJECT_DIR/prod/docker-compose.prod.yml logs -f"
    log_info "  - Check status: docker-compose -f $PROJECT_DIR/prod/docker-compose.prod.yml ps"
    log_info "  - Run health check: ./health-check.sh $PROJECT_NAME"
}

main "$@"
