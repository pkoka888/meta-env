# Deployment & DevOps Skill

## Description
Handles deployment automation, monitoring setup, rollback procedures, and infrastructure management.

## Auto-Activation Triggers
- User mentions: "deploy", "deployment", "production", "rollback", "infrastructure"
- Files matching: `docker-compose.yml`, `Dockerfile`, `deployment/**/*`
- Commands: `/deploy`, `/rollback`, `/monitor`

## Capabilities
- Docker containerization
- Docker Compose orchestration
- Deployment scripts creation
- Monitoring setup (Prometheus, Grafana)
- CI/CD pipeline configuration
- Rollback procedures
- Health check implementation
- Zero-downtime deployments

## Workflow

### 1. Pre-Deployment Checklist
Before any deployment:
- [ ] All tests passing (unit, integration, e2e)
- [ ] Code reviewed and approved
- [ ] Documentation updated
- [ ] Database migrations ready
- [ ] Environment variables configured
- [ ] Backup created
- [ ] Rollback plan documented
- [ ] Monitoring alerts configured

### 2. Containerization

**Dockerfile (Python/FastAPI)**:
```dockerfile
# Multi-stage build for optimization
FROM python:3.11-slim as builder

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Final stage
FROM python:3.11-slim

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /root/.local /root/.local
ENV PATH=/root/.local/bin:$PATH

# Copy application
COPY src/ ./src/
COPY .env.production .env

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run application
EXPOSE 8000
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

**Dockerfile (Node.js)**:
```dockerfile
FROM node:20-alpine as builder

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy application
COPY . .

# Build
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node healthcheck.js

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### 3. Docker Compose Orchestration

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: ${PROJECT_NAME}_app
    restart: unless-stopped
    ports:
      - "${APP_PORT}:8000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - redis
      - postgres
    networks:
      - app_network
    volumes:
      - ./logs:/app/logs
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s

  redis:
    image: redis:7-alpine
    container_name: ${PROJECT_NAME}_redis
    restart: unless-stopped
    ports:
      - "${REDIS_PORT}:6379"
    volumes:
      - redis_data:/data
    networks:
      - app_network
    command: redis-server --appendonly yes

  postgres:
    image: postgres:15-alpine
    container_name: ${PROJECT_NAME}_postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
      - POSTGRES_DB=${DB_NAME}
    ports:
      - "${DB_PORT}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app_network

  prometheus:
    image: prom/prometheus:latest
    container_name: ${PROJECT_NAME}_prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    networks:
      - app_network
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'

  grafana:
    image: grafana/grafana:latest
    container_name: ${PROJECT_NAME}_grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
    networks:
      - app_network
    depends_on:
      - prometheus

volumes:
  redis_data:
  postgres_data:
  prometheus_data:
  grafana_data:

networks:
  app_network:
    driver: bridge
```

### 4. Deployment Script

**scripts/deploy.sh**:
```bash
#!/bin/bash
set -e  # Exit on error

PROJECT_NAME="my-project"
ENVIRONMENT=${1:-production}

echo "🚀 Starting deployment to $ENVIRONMENT..."

# 1. Pre-deployment checks
echo "📋 Running pre-deployment checks..."
npm run test || { echo "❌ Tests failed"; exit 1; }
echo "✅ Tests passed"

# 2. Backup current state
echo "💾 Creating backup..."
./scripts/backup.sh

# 3. Build new images
echo "🏗️ Building Docker images..."
docker-compose build

# 4. Stop old containers
echo "🛑 Stopping old containers..."
docker-compose down

# 5. Run database migrations
echo "🔄 Running database migrations..."
docker-compose run --rm app npm run migrate

# 6. Start new containers
echo "▶️ Starting new containers..."
docker-compose up -d

# 7. Health check
echo "🏥 Running health checks..."
sleep 10
./scripts/health-check.sh || { echo "❌ Health check failed"; ./scripts/rollback.sh; exit 1; }

# 8. Smoke tests
echo "🧪 Running smoke tests..."
npm run test:smoke || { echo "⚠️ Smoke tests failed"; }

# 9. Update monitoring
echo "📊 Updating monitoring dashboards..."
./scripts/update-monitoring.sh

echo "✅ Deployment successful!"
echo "📱 Application available at: https://$PROJECT_NAME.example.com"
```

### 5. Rollback Script

**scripts/rollback.sh**:
```bash
#!/bin/bash
set -e

echo "⏪ Starting rollback..."

# 1. Stop current containers
echo "🛑 Stopping current containers..."
docker-compose down

# 2. Restore from backup
echo "💾 Restoring from backup..."
./scripts/restore-backup.sh

# 3. Start previous version
echo "▶️ Starting previous version..."
docker-compose up -d

# 4. Health check
echo "🏥 Running health checks..."
sleep 10
./scripts/health-check.sh

echo "✅ Rollback complete"
```

### 6. Health Check Script

**scripts/health-check.sh**:
```bash
#!/bin/bash

APP_URL=${1:-http://localhost:8000}
MAX_RETRIES=30
RETRY_INTERVAL=2

echo "🏥 Checking application health at $APP_URL/health"

for i in $(seq 1 $MAX_RETRIES); do
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL/health)

  if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Health check passed (attempt $i/$MAX_RETRIES)"
    exit 0
  fi

  echo "⏳ Health check failed (attempt $i/$MAX_RETRIES), retrying in ${RETRY_INTERVAL}s..."
  sleep $RETRY_INTERVAL
done

echo "❌ Health check failed after $MAX_RETRIES attempts"
exit 1
```

### 7. Monitoring Setup

**monitoring/prometheus/prometheus.yml**:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['app:8000']
        labels:
          environment: 'production'

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
```

### 8. CI/CD Pipeline (GitHub Actions)

**.github/workflows/deploy.yml**:
```yaml
name: Deploy to Production

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run tests
        run: |
          npm install
          npm run test

      - name: Run linting
        run: npm run lint

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v3

      - name: Deploy to server
        env:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          SERVER_HOST: ${{ secrets.SERVER_HOST }}
        run: |
          echo "$SSH_PRIVATE_KEY" > private_key
          chmod 600 private_key

          ssh -i private_key -o StrictHostKeyChecking=no user@$SERVER_HOST '
            cd /var/www/my-project &&
            git pull &&
            ./scripts/deploy.sh production
          '
```

## Deployment Strategies

### 1. Blue-Green Deployment
- Two identical environments (blue and green)
- Deploy to inactive environment
- Switch traffic after validation
- Instant rollback by switching back

### 2. Rolling Deployment
- Gradually replace old instances
- Maintains availability during deployment
- Slower but safer

### 3. Canary Deployment
- Deploy to small subset of users first
- Monitor metrics
- Gradually increase traffic if successful

## Best Practices
- Always have rollback plan
- Use health checks
- Implement graceful shutdown
- Log everything
- Monitor key metrics
- Test in staging first
- Use environment variables
- Never deploy on Fridays 😉
- Automate everything
- Document procedures
