#!/bin/bash
###############################################################################
# backup.sh - Backup script for meta-env projects
#
# This script creates comprehensive backups of:
# - Project files (dev/, prod/, configs/)
# - Databases (PostgreSQL, Redis)
# - Docker volumes
# - Environment configurations
# - Git repositories
#
# Usage: ./backup.sh <project-name|all> [--destination=/path/to/backup]
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
DEFAULT_BACKUP_DIR="/var/backups/meta-env"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

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
Usage: $0 <project-name|all> [OPTIONS]

Create backup of project(s) and databases.

Arguments:
  project-name    Name of the project to backup (or 'all' for all projects)

Options:
  --destination=PATH    Backup destination directory (default: $DEFAULT_BACKUP_DIR)
  --compress            Compress backup with gzip
  --databases-only      Backup only databases
  --files-only          Backup only files (skip databases)
  --retention=DAYS      Delete backups older than DAYS (default: $RETENTION_DAYS)
  --help                Show this help message

Examples:
  $0 my-project
  $0 all
  $0 my-project --destination=/mnt/backup --compress
  $0 all --databases-only

Environment Variables:
  PROJECTS_DIR        Projects directory (default: /var/www/projects)
  BACKUP_DIR          Backup destination (default: $DEFAULT_BACKUP_DIR)
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

    BACKUP_DESTINATION="$DEFAULT_BACKUP_DIR"
    COMPRESS=false
    DATABASES_ONLY=false
    FILES_ONLY=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --destination=*)
                BACKUP_DESTINATION="${1#*=}"
                shift
                ;;
            --compress)
                COMPRESS=true
                shift
                ;;
            --databases-only)
                DATABASES_ONLY=true
                shift
                ;;
            --files-only)
                FILES_ONLY=true
                shift
                ;;
            --retention=*)
                RETENTION_DAYS="${1#*=}"
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
    local project="$1"

    if [ "$project" = "all" ]; then
        return 0
    fi

    if [ ! -d "$PROJECTS_DIR/$project" ]; then
        error_exit "Project '$project' not found in $PROJECTS_DIR"
    fi
}

# Create backup directory
create_backup_directory() {
    local project="$1"
    local backup_path="$BACKUP_DESTINATION/$project/$BACKUP_TIMESTAMP"

    mkdir -p "$backup_path"
    CURRENT_BACKUP_DIR="$backup_path"

    log_info "Backup directory: $backup_path"
}

# Backup project files
backup_project_files() {
    local project_dir="$1"
    local backup_dir="$2"

    if [ "$DATABASES_ONLY" = true ]; then
        log_warn "Skipping file backup (--databases-only flag set)"
        return 0
    fi

    log_step "Backing up project files..."

    # Create files backup directory
    local files_backup="$backup_dir/files"
    mkdir -p "$files_backup"

    # Backup dev/
    if [ -d "$project_dir/dev" ]; then
        log_info "Backing up dev/..."
        rsync -av --exclude='node_modules' --exclude='__pycache__' --exclude='*.pyc' \
              --exclude='venv' --exclude='.venv' \
              "$project_dir/dev/" "$files_backup/dev/" || log_warn "Failed to backup dev/"
    fi

    # Backup prod/
    if [ -d "$project_dir/prod" ]; then
        log_info "Backing up prod/..."
        rsync -av --exclude='node_modules' --exclude='__pycache__' --exclude='*.pyc' \
              --exclude='venv' --exclude='.venv' \
              "$project_dir/prod/" "$files_backup/prod/" || log_warn "Failed to backup prod/"
    fi

    # Backup shared/
    if [ -d "$project_dir/shared" ]; then
        log_info "Backing up shared/..."
        cp -r "$project_dir/shared" "$files_backup/" || log_warn "Failed to backup shared/"
    fi

    # Backup docs/
    if [ -d "$project_dir/docs" ]; then
        cp -r "$project_dir/docs" "$files_backup/" || log_warn "Failed to backup docs/"
    fi

    # Backup configuration files
    log_info "Backing up configuration files..."
    for file in .python-version .nvmrc .envrc .gitignore README.md; do
        if [ -f "$project_dir/$file" ]; then
            cp "$project_dir/$file" "$files_backup/"
        fi
    done

    # Backup environment files (with caution)
    if [ -f "$project_dir/dev/.env.dev" ]; then
        cp "$project_dir/dev/.env.dev" "$files_backup/.env.dev.bak"
    fi

    if [ -f "$project_dir/prod/.env.prod" ]; then
        cp "$project_dir/prod/.env.prod" "$files_backup/.env.prod.bak"
    fi

    log_info "✓ Project files backed up"
}

# Backup PostgreSQL database
backup_postgres() {
    local project_name="$1"
    local backup_dir="$2"

    if [ "$FILES_ONLY" = true ]; then
        return 0
    fi

    log_step "Backing up PostgreSQL database..."

    # Create database backup directory
    local db_backup="$backup_dir/databases"
    mkdir -p "$db_backup"

    # Try to find database container
    local db_container="${project_name}_postgres_prod"
    if ! docker ps --format '{{.Names}}' | grep -q "^${db_container}$"; then
        db_container="${project_name}_postgres_dev"
    fi

    if docker ps --format '{{.Names}}' | grep -q "^${db_container}$"; then
        log_info "Backing up PostgreSQL from container: $db_container"

        # Dump database
        docker exec "$db_container" pg_dumpall -U user > "$db_backup/postgres_dump.sql" || log_warn "Failed to dump PostgreSQL"

        log_info "✓ PostgreSQL database backed up"
    else
        log_warn "No PostgreSQL container found for $project_name"
    fi
}

# Backup Redis data
backup_redis() {
    local project_name="$1"
    local backup_dir="$2"

    if [ "$FILES_ONLY" = true ]; then
        return 0
    fi

    log_step "Backing up Redis data..."

    local db_backup="$backup_dir/databases"
    mkdir -p "$db_backup"

    # Try to find Redis container
    local redis_container="${project_name}_redis_prod"
    if ! docker ps --format '{{.Names}}' | grep -q "^${redis_container}$"; then
        redis_container="${project_name}_redis_dev"
    fi

    if docker ps --format '{{.Names}}' | grep -q "^${redis_container}$"; then
        log_info "Backing up Redis from container: $redis_container"

        # Trigger Redis save
        docker exec "$redis_container" redis-cli SAVE || log_warn "Failed to trigger Redis SAVE"

        # Copy dump.rdb
        docker cp "$redis_container:/data/dump.rdb" "$db_backup/redis_dump.rdb" || log_warn "Failed to copy Redis dump"

        log_info "✓ Redis data backed up"
    else
        log_warn "No Redis container found for $project_name"
    fi
}

# Backup Docker volumes
backup_docker_volumes() {
    local project_name="$1"
    local backup_dir="$2"

    if [ "$FILES_ONLY" = true ]; then
        return 0
    fi

    log_step "Backing up Docker volumes..."

    local volumes_backup="$backup_dir/volumes"
    mkdir -p "$volumes_backup"

    # List volumes for this project
    local volumes=$(docker volume ls --format '{{.Name}}' | grep "^${project_name}_" || true)

    if [ -z "$volumes" ]; then
        log_warn "No Docker volumes found for $project_name"
        return 0
    fi

    for volume in $volumes; do
        log_info "Backing up volume: $volume"

        # Create temporary container to access volume
        docker run --rm -v "$volume:/data" -v "$volumes_backup:/backup" \
            alpine tar czf "/backup/${volume}.tar.gz" -C /data . || log_warn "Failed to backup volume $volume"
    done

    log_info "✓ Docker volumes backed up"
}

# Backup Git repository
backup_git_repo() {
    local project_dir="$1"
    local backup_dir="$2"

    if [ "$DATABASES_ONLY" = true ]; then
        return 0
    fi

    log_step "Backing up Git repository..."

    if [ ! -d "$project_dir/.git" ]; then
        log_warn "Not a Git repository, skipping Git backup"
        return 0
    fi

    cd "$project_dir"

    # Create git bundle (complete backup)
    git bundle create "$backup_dir/git_repository.bundle" --all || log_warn "Failed to create Git bundle"

    # Save git log
    git log --all --oneline > "$backup_dir/git_log.txt" || log_warn "Failed to save Git log"

    # Save current status
    git status > "$backup_dir/git_status.txt" 2>&1 || log_warn "Failed to save Git status"

    log_info "✓ Git repository backed up"
}

# Create backup manifest
create_backup_manifest() {
    local project_name="$1"
    local backup_dir="$2"

    log_step "Creating backup manifest..."

    cat > "$backup_dir/manifest.txt" << EOF
Meta-Env Backup Manifest
========================
Project: $project_name
Backup Date: $(date)
Timestamp: $BACKUP_TIMESTAMP
Backup Directory: $backup_dir

Options:
  Compress: $COMPRESS
  Databases Only: $DATABASES_ONLY
  Files Only: $FILES_ONLY

Contents:
$(ls -lh "$backup_dir")

System Information:
  Hostname: $(hostname)
  User: $USER
  OS: $(uname -a)

Disk Usage:
$(du -sh "$backup_dir")
EOF

    log_info "✓ Backup manifest created"
}

# Compress backup
compress_backup() {
    local backup_dir="$1"

    if [ "$COMPRESS" = false ]; then
        return 0
    fi

    log_step "Compressing backup..."

    local parent_dir=$(dirname "$backup_dir")
    local backup_name=$(basename "$backup_dir")

    cd "$parent_dir"
    tar czf "${backup_name}.tar.gz" "$backup_name" || error_exit "Failed to compress backup"

    rm -rf "$backup_name"

    log_info "✓ Backup compressed: ${backup_name}.tar.gz"
    CURRENT_BACKUP_DIR="${parent_dir}/${backup_name}.tar.gz"
}

# Clean old backups
cleanup_old_backups() {
    local project="$1"

    log_step "Cleaning up old backups (older than $RETENTION_DAYS days)..."

    local project_backup_dir="$BACKUP_DESTINATION/$project"

    if [ ! -d "$project_backup_dir" ]; then
        return 0
    fi

    # Find and delete old backups
    local deleted=0
    while IFS= read -r old_backup; do
        log_info "Deleting old backup: $(basename "$old_backup")"
        rm -rf "$old_backup"
        ((deleted++))
    done < <(find "$project_backup_dir" -maxdepth 1 -type d -mtime +$RETENTION_DAYS)

    if [ $deleted -gt 0 ]; then
        log_info "✓ Deleted $deleted old backup(s)"
    else
        log_info "No old backups to delete"
    fi
}

# Backup single project
backup_single_project() {
    local project_name="$1"
    local project_dir="$PROJECTS_DIR/$project_name"

    log_info "================================================"
    log_info "Backing up project: $project_name"
    log_info "================================================"

    validate_project "$project_name"
    create_backup_directory "$project_name"

    backup_project_files "$project_dir" "$CURRENT_BACKUP_DIR"
    backup_postgres "$project_name" "$CURRENT_BACKUP_DIR"
    backup_redis "$project_name" "$CURRENT_BACKUP_DIR"
    backup_docker_volumes "$project_name" "$CURRENT_BACKUP_DIR"
    backup_git_repo "$project_dir" "$CURRENT_BACKUP_DIR"
    create_backup_manifest "$project_name" "$CURRENT_BACKUP_DIR"
    compress_backup "$CURRENT_BACKUP_DIR"
    cleanup_old_backups "$project_name"

    log_info "✓ Backup completed: $CURRENT_BACKUP_DIR"
}

# Backup all projects
backup_all_projects() {
    log_info "Backing up all projects in $PROJECTS_DIR"

    if [ ! -d "$PROJECTS_DIR" ]; then
        error_exit "Projects directory not found: $PROJECTS_DIR"
    fi

    local projects=$(ls -1 "$PROJECTS_DIR" 2>/dev/null || true)

    if [ -z "$projects" ]; then
        log_warn "No projects found in $PROJECTS_DIR"
        return 0
    fi

    for project in $projects; do
        if [ -d "$PROJECTS_DIR/$project" ]; then
            backup_single_project "$project"
            echo ""
        fi
    done
}

# Calculate backup size
calculate_backup_size() {
    local backup_dir="$1"

    if [ -d "$backup_dir" ]; then
        du -sh "$backup_dir" 2>/dev/null || echo "Unknown"
    elif [ -f "$backup_dir" ]; then
        ls -lh "$backup_dir" | awk '{print $5}'
    else
        echo "Unknown"
    fi
}

# Main execution
main() {
    log_info "Meta-Env Backup Script"
    log_info "================================================"

    parse_args "$@"

    log_info "Backup configuration:"
    log_info "  Target: $PROJECT_NAME"
    log_info "  Destination: $BACKUP_DESTINATION"
    log_info "  Timestamp: $BACKUP_TIMESTAMP"
    log_info "  Compress: $COMPRESS"
    log_info "  Retention: $RETENTION_DAYS days"
    log_info ""

    # Create backup destination
    mkdir -p "$BACKUP_DESTINATION"

    # Start backup
    if [ "$PROJECT_NAME" = "all" ]; then
        backup_all_projects
    else
        backup_single_project "$PROJECT_NAME"
    fi

    log_info "================================================"
    log_info "Backup completed successfully!"
    log_info "================================================"
    log_info ""
    log_info "Backup location: $CURRENT_BACKUP_DIR"
    log_info "Backup size: $(calculate_backup_size "$CURRENT_BACKUP_DIR")"
    log_info ""
    log_info "To restore from this backup:"
    log_info "  1. Extract: tar xzf <backup-file>.tar.gz (if compressed)"
    log_info "  2. Restore files to $PROJECTS_DIR/"
    log_info "  3. Restore database: psql < databases/postgres_dump.sql"
    log_info "  4. Restore Redis: redis-cli --rdb databases/redis_dump.rdb"
}

main "$@"
