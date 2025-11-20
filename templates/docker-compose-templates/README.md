# Docker Compose Templates

This directory contains reusable Docker Compose templates for different application stacks.

## Available Stacks

### 1. Web App Stack (`web-app-stack.yml`)

Complete web application stack with frontend, backend, database, and reverse proxy.

**Services**:
- **Frontend**: Node.js application (React/Vue/etc.)
- **Backend**: Python API (FastAPI/Flask)
- **PostgreSQL**: Primary database
- **Redis**: Caching layer
- **Nginx**: Reverse proxy
- **pgAdmin**: Database management (dev profile)

**Quick Start**:
```bash
# Copy the template
cp templates/docker-compose-templates/web-app-stack.yml ./docker-compose.yml

# Create .env file
cat > .env << EOF
PROJECT_NAME=mywebapp
FRONTEND_PORT=3000
BACKEND_PORT=8000
DB_USER=postgres
DB_PASSWORD=secure_password
EOF

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Start with dev tools
docker-compose --profile dev up -d
```

**Access Points**:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- pgAdmin: http://localhost:5050 (dev profile)

### 2. API Stack (`api-stack.yml`)

Production-ready API stack with gateway, workers, and message queues.

**Services**:
- **Kong API Gateway**: Route management and authentication
- **API Service**: Main API application
- **Worker**: Celery workers for background jobs
- **Scheduler**: Celery beat for scheduled tasks
- **PostgreSQL**: Database
- **Redis**: Cache and message broker
- **MinIO**: S3-compatible object storage
- **Elasticsearch**: Search and analytics
- **RabbitMQ**: Message queue (messaging profile)

**Quick Start**:
```bash
cp templates/docker-compose-templates/api-stack.yml ./docker-compose.yml

# Start core services
docker-compose up -d

# Start with messaging profile
docker-compose --profile messaging up -d

# Scale workers
docker-compose up -d --scale worker=4
```

**Access Points**:
- API Gateway: http://localhost:8000
- Kong Admin: http://localhost:8001
- MinIO Console: http://localhost:9001
- Elasticsearch: http://localhost:9200
- RabbitMQ Management: http://localhost:15672

### 3. Monitoring Stack (`monitoring-stack.yml`)

Comprehensive monitoring, logging, and alerting infrastructure.

**Services**:
- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Node Exporter**: Host metrics
- **cAdvisor**: Container metrics
- **Loki**: Log aggregation
- **Promtail**: Log collector
- **AlertManager**: Alert management
- **Jaeger**: Distributed tracing (tracing profile)
- **Redis Exporter**: Redis metrics (exporters profile)
- **PostgreSQL Exporter**: Database metrics (exporters profile)
- **Blackbox Exporter**: Endpoint monitoring (exporters profile)

**Quick Start**:
```bash
cp templates/docker-compose-templates/monitoring-stack.yml ./docker-compose.yml

# Create config directories
mkdir -p prometheus grafana loki promtail alertmanager blackbox

# Create basic Prometheus config
cat > prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
EOF

# Start monitoring stack
docker-compose up -d

# Start with all exporters
docker-compose --profile exporters up -d
```

**Access Points**:
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000 (admin/admin)
- AlertManager: http://localhost:9093
- Jaeger UI: http://localhost:16686

### 4. AI Stack (`ai-stack.yml`)

AI/ML development stack with LLMs, vector databases, and workflow automation.

**Services**:
- **Ollama**: Local LLM inference (GPU support)
- **ChromaDB**: Vector database
- **n8n**: Workflow automation
- **Qdrant**: Alternative vector DB (alternative profile)
- **Weaviate**: Alternative vector DB (alternative profile)
- **LiteLLM Proxy**: Unified LLM API (proxy profile)
- **Flowise**: Low-code LLM apps (lowcode profile)
- **PostgreSQL**: Database for proxy/lowcode
- **Redis**: Caching
- **Chainlit**: Chat UI (ui profile)
- **Open WebUI**: Ollama UI (ui profile)

**Quick Start**:
```bash
cp templates/docker-compose-templates/ai-stack.yml ./docker-compose.yml

# Start core AI services
docker-compose up -d

# Pull Ollama models
docker exec -it <project>_ollama ollama pull llama3:8b
docker exec -it <project>_ollama ollama pull nomic-embed-text

# Start with UI
docker-compose --profile ui up -d

# Start with proxy
docker-compose --profile proxy up -d
```

**Access Points**:
- Ollama API: http://localhost:11434
- ChromaDB: http://localhost:8000
- n8n: http://localhost:5678
- Open WebUI: http://localhost:8080
- Flowise: http://localhost:3001

## Common Operations

### Environment Variables

Create a `.env` file for each stack:

```bash
# Project Configuration
PROJECT_NAME=myproject
NODE_ENV=development

# Port Configuration
FRONTEND_PORT=3000
BACKEND_PORT=8000
API_PORT=8080

# Database
DB_USER=postgres
DB_PASSWORD=secure_password
DB_NAME=mydb
DB_PORT=5432

# Redis
REDIS_PORT=6379
REDIS_PASSWORD=

# Authentication
JWT_SECRET=your-secret-key
SESSION_SECRET=your-session-secret

# AI Services
OLLAMA_PORT=11434
CHROMA_PORT=8000
N8N_PORT=5678
```

### Docker Compose Profiles

Profiles allow selective service activation:

```bash
# List all services including profiles
docker-compose config --services

# Start specific profile
docker-compose --profile dev up -d
docker-compose --profile exporters up -d

# Start multiple profiles
docker-compose --profile dev --profile tracing up -d
```

### Scaling Services

```bash
# Scale workers
docker-compose up -d --scale worker=4

# Check running instances
docker-compose ps

# Scale down
docker-compose up -d --scale worker=2
```

### Health Checks

All services include health checks. View status:

```bash
# Check health status
docker-compose ps

# Watch service health
watch docker-compose ps

# Check specific service
docker inspect --format='{{json .State.Health}}' <container_name>
```

### Logs and Debugging

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend

# View logs from last 10 minutes
docker-compose logs --since 10m

# Follow logs from multiple services
docker-compose logs -f backend worker redis
```

### Backups

```bash
# Backup PostgreSQL
docker-compose exec postgres pg_dump -U postgres mydb > backup.sql

# Backup volumes
docker run --rm -v myproject_postgres_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/postgres_backup.tar.gz /data

# Restore volume
docker run --rm -v myproject_postgres_data:/data -v $(pwd):/backup \
  alpine tar xzf /backup/postgres_backup.tar.gz -C /
```

### Resource Management

```bash
# View resource usage
docker stats

# Set resource limits in docker-compose.yml
services:
  api-service:
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

## Combining Stacks

You can combine multiple stacks:

```bash
# Merge stacks
docker-compose \
  -f docker-compose.web.yml \
  -f docker-compose.monitoring.yml \
  up -d

# Or use extends
# docker-compose.yml
version: '3.8'
services:
  frontend:
    extends:
      file: templates/docker-compose-templates/web-app-stack.yml
      service: frontend
```

## Production Considerations

### Security

1. **Use secrets management**:
```yaml
services:
  backend:
    secrets:
      - db_password

secrets:
  db_password:
    file: ./secrets/db_password.txt
```

2. **Non-root users**:
```dockerfile
USER node:node  # or appropriate user
```

3. **Network isolation**:
```yaml
networks:
  frontend:
  backend:
    internal: true  # No external access
```

### Performance

1. **Enable logging limits**:
```yaml
services:
  api:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

2. **Use build caching**:
```yaml
services:
  api:
    build:
      cache_from:
        - myregistry/api:latest
```

### High Availability

1. **Restart policies**:
```yaml
services:
  api:
    restart: always
    deploy:
      replicas: 3
```

2. **Health checks**:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

## Troubleshooting

### Common Issues

1. **Port conflicts**:
```bash
# Check port usage
netstat -tulpn | grep <port>

# Change port in .env
BACKEND_PORT=8001
```

2. **Permission issues**:
```bash
# Fix volume permissions
sudo chown -R $USER:$USER ./data
```

3. **Network issues**:
```bash
# Recreate network
docker-compose down
docker network prune
docker-compose up -d
```

4. **Volume issues**:
```bash
# Remove and recreate volumes
docker-compose down -v
docker-compose up -d
```

## Best Practices

1. **Use .dockerignore**: Exclude unnecessary files
2. **Multi-stage builds**: Reduce image size
3. **Version pinning**: Use specific image tags
4. **Health checks**: Always include health checks
5. **Resource limits**: Set CPU and memory limits
6. **Named volumes**: Use named volumes for persistence
7. **Environment files**: Never commit .env files
8. **Documentation**: Document custom configurations

## Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
