#!/bin/bash
###############################################################################
# health-check.sh - Health check script for meta-env projects
#
# This script performs comprehensive health checks on:
# - Docker containers
# - Database connectivity (PostgreSQL, Redis)
# - Ollama service
# - n8n service
# - Disk space
# - Memory usage
# - Service endpoints
#
# Usage: ./health-check.sh [project-name|all] [--verbose] [--json]
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
AI_PLATFORM_DIR="/opt/ai-platform"
VERBOSE=false
JSON_OUTPUT=false

# Health check results
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# Logging functions
log_info() {
    if [ "$JSON_OUTPUT" = false ]; then
        echo -e "${GREEN}[INFO]${NC} $1"
    fi
}

log_warn() {
    if [ "$JSON_OUTPUT" = false ]; then
        echo -e "${YELLOW}[WARN]${NC} $1"
    fi
    ((CHECKS_WARNED++))
}

log_error() {
    if [ "$JSON_OUTPUT" = false ]; then
        echo -e "${RED}[ERROR]${NC} $1"
    fi
    ((CHECKS_FAILED++))
}

log_success() {
    if [ "$JSON_OUTPUT" = false ]; then
        echo -e "${GREEN}[PASS]${NC} $1"
    fi
    ((CHECKS_PASSED++))
}

log_step() {
    if [ "$JSON_OUTPUT" = false ] && [ "$VERBOSE" = true ]; then
        echo -e "${BLUE}[CHECK]${NC} $1"
    fi
}

# Usage information
usage() {
    cat << EOF
Usage: $0 [project-name|all|platform] [OPTIONS]

Perform health checks on meta-env projects and services.

Arguments:
  project-name    Check specific project (default: all)
  all             Check all projects
  platform        Check only AI platform services

Options:
  --verbose       Show detailed check information
  --json          Output results in JSON format
  --help          Show this help message

Examples:
  $0
  $0 my-project
  $0 all --verbose
  $0 platform --json

Environment Variables:
  PROJECTS_DIR    Projects directory (default: /var/www/projects)
EOF
    exit 1
}

# Parse command line arguments
parse_args() {
    TARGET="${1:-all}"
    shift || true

    while [ $# -gt 0 ]; do
        case "$1" in
            --verbose)
                VERBOSE=true
                shift
                ;;
            --json)
                JSON_OUTPUT=true
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

# Check Docker is running
check_docker() {
    log_step "Checking Docker service..."

    if systemctl is-active --quiet docker; then
        log_success "Docker service is running"
        return 0
    else
        log_error "Docker service is not running"
        return 1
    fi
}

# Check disk space
check_disk_space() {
    log_step "Checking disk space..."

    local usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

    if [ "$usage" -lt 80 ]; then
        log_success "Disk space OK (${usage}% used)"
    elif [ "$usage" -lt 90 ]; then
        log_warn "Disk space getting low (${usage}% used)"
    else
        log_error "Disk space critical (${usage}% used)"
    fi
}

# Check memory usage
check_memory() {
    log_step "Checking memory usage..."

    local total=$(free -m | awk 'NR==2 {print $2}')
    local used=$(free -m | awk 'NR==2 {print $3}')
    local percent=$((used * 100 / total))

    if [ "$percent" -lt 80 ]; then
        log_success "Memory usage OK (${percent}%)"
    elif [ "$percent" -lt 90 ]; then
        log_warn "Memory usage high (${percent}%)"
    else
        log_error "Memory usage critical (${percent}%)"
    fi
}

# Check Ollama service
check_ollama() {
    log_step "Checking Ollama service..."

    # Check if Ollama is running
    if systemctl is-active --quiet ollama 2>/dev/null; then
        log_success "Ollama service is running"
    else
        log_warn "Ollama service is not running (may be using remote instance)"
        return 0
    fi

    # Check if Ollama API is responding
    local ollama_host="${OLLAMA_HOST:-http://localhost:11434}"

    if curl -f -s -m 5 "$ollama_host/api/tags" > /dev/null 2>&1; then
        log_success "Ollama API is responding ($ollama_host)"

        if [ "$VERBOSE" = true ]; then
            local models=$(curl -s "$ollama_host/api/tags" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | wc -l)
            log_info "  Available models: $models"
        fi
    else
        log_error "Ollama API is not responding ($ollama_host)"
    fi
}

# Check n8n service
check_n8n() {
    log_step "Checking n8n service..."

    if docker ps --format '{{.Names}}' | grep -q "^n8n$"; then
        log_success "n8n container is running"

        # Check if n8n is responding
        if curl -f -s -m 5 http://localhost:5678 > /dev/null 2>&1; then
            log_success "n8n is responding (http://localhost:5678)"
        else
            log_warn "n8n container is running but not responding"
        fi
    else
        log_warn "n8n container is not running"
    fi
}

# Check Grafana/Prometheus
check_monitoring() {
    log_step "Checking monitoring services..."

    # Check Prometheus
    if docker ps --format '{{.Names}}' | grep -q "^prometheus$"; then
        log_success "Prometheus container is running"

        if curl -f -s -m 5 http://localhost:9090/-/healthy > /dev/null 2>&1; then
            log_success "Prometheus is healthy"
        else
            log_warn "Prometheus is not responding"
        fi
    else
        log_warn "Prometheus container is not running"
    fi

    # Check Grafana
    if docker ps --format '{{.Names}}' | grep -q "^grafana$"; then
        log_success "Grafana container is running"

        if curl -f -s -m 5 http://localhost:3001/api/health > /dev/null 2>&1; then
            log_success "Grafana is healthy"
        else
            log_warn "Grafana is not responding"
        fi
    else
        log_warn "Grafana container is not running"
    fi
}

# Check PostgreSQL connectivity
check_postgres() {
    local container_name="$1"

    log_step "Checking PostgreSQL ($container_name)..."

    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_warn "PostgreSQL container not found: $container_name"
        return 0
    fi

    log_success "PostgreSQL container is running: $container_name"

    # Check if PostgreSQL is accepting connections
    if docker exec "$container_name" pg_isready -U user > /dev/null 2>&1; then
        log_success "PostgreSQL is accepting connections"

        if [ "$VERBOSE" = true ]; then
            local db_size=$(docker exec "$container_name" psql -U user -t -c "SELECT pg_size_pretty(pg_database_size(current_database()));" 2>/dev/null | xargs || echo "unknown")
            log_info "  Database size: $db_size"
        fi
    else
        log_error "PostgreSQL is not accepting connections"
    fi
}

# Check Redis connectivity
check_redis() {
    local container_name="$1"

    log_step "Checking Redis ($container_name)..."

    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_warn "Redis container not found: $container_name"
        return 0
    fi

    log_success "Redis container is running: $container_name"

    # Check if Redis is responding
    if docker exec "$container_name" redis-cli ping > /dev/null 2>&1; then
        log_success "Redis is responding to PING"

        if [ "$VERBOSE" = true ]; then
            local keys=$(docker exec "$container_name" redis-cli DBSIZE 2>/dev/null | grep -o '[0-9]*' || echo "unknown")
            local memory=$(docker exec "$container_name" redis-cli INFO memory 2>/dev/null | grep "used_memory_human" | cut -d: -f2 | tr -d '\r' || echo "unknown")
            log_info "  Keys: $keys"
            log_info "  Memory: $memory"
        fi
    else
        log_error "Redis is not responding"
    fi
}

# Check Docker containers for a project
check_project_containers() {
    local project_name="$1"

    log_step "Checking Docker containers for $project_name..."

    local containers=$(docker ps --filter "name=${project_name}_" --format '{{.Names}}' || true)

    if [ -z "$containers" ]; then
        log_warn "No running containers found for $project_name"
        return 0
    fi

    local running=0
    for container in $containers; do
        local status=$(docker inspect --format='{{.State.Status}}' "$container" 2>/dev/null || echo "unknown")

        if [ "$status" = "running" ]; then
            log_success "Container running: $container"
            ((running++))
        else
            log_error "Container not running: $container (status: $status)"
        fi
    done

    if [ "$VERBOSE" = true ]; then
        log_info "  Total containers: $running"
    fi
}

# Check project health
check_project() {
    local project_name="$1"
    local project_dir="$PROJECTS_DIR/$project_name"

    if [ ! -d "$project_dir" ]; then
        log_error "Project directory not found: $project_dir"
        return 1
    fi

    log_info "================================================"
    log_info "Health Check: $project_name"
    log_info "================================================"

    # Check containers
    check_project_containers "$project_name"

    # Check databases
    check_postgres "${project_name}_postgres_prod"
    check_postgres "${project_name}_postgres_dev"
    check_redis "${project_name}_redis_prod"
    check_redis "${project_name}_redis_dev"

    # Check if project files exist
    if [ ! -d "$project_dir/dev" ]; then
        log_warn "Missing dev/ directory"
    fi

    if [ ! -d "$project_dir/prod" ]; then
        log_warn "Missing prod/ directory"
    fi

    log_info ""
}

# Check AI platform
check_platform() {
    log_info "================================================"
    log_info "Health Check: AI Platform"
    log_info "================================================"

    check_docker
    check_disk_space
    check_memory
    check_ollama
    check_n8n
    check_monitoring

    log_info ""
}

# Check all projects
check_all_projects() {
    if [ ! -d "$PROJECTS_DIR" ]; then
        log_error "Projects directory not found: $PROJECTS_DIR"
        return 1
    fi

    local projects=$(ls -1 "$PROJECTS_DIR" 2>/dev/null || true)

    if [ -z "$projects" ]; then
        log_warn "No projects found in $PROJECTS_DIR"
        return 0
    fi

    for project in $projects; do
        if [ -d "$PROJECTS_DIR/$project" ]; then
            check_project "$project"
        fi
    done
}

# Generate JSON report
generate_json_report() {
    cat << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "target": "$TARGET",
  "summary": {
    "passed": $CHECKS_PASSED,
    "failed": $CHECKS_FAILED,
    "warned": $CHECKS_WARNED,
    "total": $((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED)),
    "status": "$([ $CHECKS_FAILED -eq 0 ] && echo "healthy" || echo "unhealthy")"
  },
  "system": {
    "hostname": "$(hostname)",
    "disk_usage": "$(df -h / | awk 'NR==2 {print $5}')",
    "memory_usage": "$(free -m | awk 'NR==2 {printf "%.0f%%", $3/$2 * 100}')"
  }
}
EOF
}

# Display summary
display_summary() {
    if [ "$JSON_OUTPUT" = true ]; then
        generate_json_report
        return 0
    fi

    log_info "================================================"
    log_info "Health Check Summary"
    log_info "================================================"
    log_info ""
    log_info "Checks passed:  ${GREEN}$CHECKS_PASSED${NC}"
    log_info "Checks warned:  ${YELLOW}$CHECKS_WARNED${NC}"
    log_info "Checks failed:  ${RED}$CHECKS_FAILED${NC}"
    log_info "Total checks:   $((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNED))"
    log_info ""

    if [ $CHECKS_FAILED -eq 0 ]; then
        log_info "Overall status: ${GREEN}HEALTHY${NC}"
        return 0
    else
        log_info "Overall status: ${RED}UNHEALTHY${NC}"
        return 1
    fi
}

# Main execution
main() {
    parse_args "$@"

    if [ "$JSON_OUTPUT" = false ]; then
        log_info "Meta-Env Health Check"
        log_info "Target: $TARGET"
        log_info "Timestamp: $(date)"
        log_info ""
    fi

    case "$TARGET" in
        all)
            check_platform
            check_all_projects
            ;;
        platform)
            check_platform
            ;;
        *)
            check_project "$TARGET"
            ;;
    esac

    display_summary
}

main "$@"
