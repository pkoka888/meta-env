# Deployment Guide

## Prerequisites

- Docker and Docker Compose installed
- Access to target server (VPS or physical)
- Domain name (for production)
- SSL certificate (for production)

## Development Deployment

### Local Development

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## Staging Deployment

### Using Docker Compose

1. **Set up environment**:
```bash
# Copy environment template
cp .env.example .env.staging

# Edit staging variables
nano .env.staging
```

2. **Deploy**:
```bash
# Build and deploy
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Run migrations
docker-compose exec backend python manage.py migrate

# Create superuser
docker-compose exec backend python manage.py createsuperuser
```

## Production Deployment

### Using CapRover

1. **Install CapRover**:
```bash
# On server
docker run -p 80:80 -p 443:443 -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock -v /captain:/captain caprover/caprover
```

2. **Deploy app**:
```bash
# Login
caprover login

# Deploy
caprover deploy
```

### Using Dokku

1. **Set up Dokku**:
```bash
# On server
wget https://raw.githubusercontent.com/dokku/dokku/master/bootstrap.sh
sudo DOKKU_TAG=v0.30.0 bash bootstrap.sh

# Create app
dokku apps:create myapp
```

2. **Deploy**:
```bash
# Add remote
git remote add dokku dokku@your-server:myapp

# Push to deploy
git push dokku main
```

### Manual Deployment

1. **Server setup**:
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

2. **Deploy application**:
```bash
# Clone repository
git clone <repo-url> /var/www/myapp
cd /var/www/myapp

# Set up environment
cp .env.example .env.prod
nano .env.prod

# Build and start
docker-compose -f docker-compose.prod.yml up -d
```

3. **Set up Nginx reverse proxy**:
```nginx
# /etc/nginx/sites-available/myapp
server {
    listen 80;
    server_name example.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

4. **SSL with Let's Encrypt**:
```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d example.com
```

## Database Management

### Backups

```bash
# Automated backup script
#!/bin/bash
BACKUP_DIR="/backups/postgres"
DATE=$(date +%Y%m%d_%H%M%S)

docker-compose exec -T postgres pg_dump -U postgres mydb > $BACKUP_DIR/backup_$DATE.sql

# Keep only last 7 days
find $BACKUP_DIR -type f -mtime +7 -delete
```

### Migrations

```bash
# Run migrations
docker-compose exec backend python manage.py migrate

# Rollback migration
docker-compose exec backend python manage.py migrate app_name migration_name
```

## Monitoring

### Health Checks

```bash
# Check service health
docker-compose ps

# Check application health
curl http://localhost:8000/health
```

### Log Management

```bash
# View logs
docker-compose logs -f backend

# Log rotation
# Add to docker-compose.yml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## Scaling

### Horizontal Scaling

```bash
# Scale workers
docker-compose up -d --scale worker=4

# Scale API
docker-compose up -d --scale api=3
```

### Load Balancing

Use Nginx or HAProxy for load balancing:

```nginx
upstream backend {
    server backend1:8000;
    server backend2:8000;
    server backend3:8000;
}
```

## Rollback

```bash
# Rollback to previous version
git checkout <previous-commit>
docker-compose up -d --build

# Or use specific image tag
docker-compose pull myapp:v1.2.3
docker-compose up -d
```

## Troubleshooting

### Common Issues

1. **Container won't start**:
```bash
docker-compose logs <service-name>
docker inspect <container-name>
```

2. **Database connection issues**:
```bash
docker-compose exec backend env | grep DATABASE
docker-compose exec postgres psql -U postgres -c "\l"
```

3. **Port conflicts**:
```bash
netstat -tulpn | grep <port>
# Change port in .env
```

## Security Checklist

- [ ] Change default passwords
- [ ] Enable HTTPS
- [ ] Set up firewall (ufw)
- [ ] Configure CORS properly
- [ ] Enable rate limiting
- [ ] Set up monitoring alerts
- [ ] Regular security updates
- [ ] Backup encryption
- [ ] Environment variables secured
- [ ] API keys rotated

## Post-Deployment

1. **Verify deployment**:
```bash
# Check all services running
docker-compose ps

# Test API endpoints
curl http://your-domain/api/health

# Check logs for errors
docker-compose logs --tail=100
```

2. **Monitor metrics**:
- Check Prometheus metrics
- Verify Grafana dashboards
- Review error logs

3. **Set up alerts**:
- Configure AlertManager
- Set up email/Slack notifications
- Define alert thresholds
