# Redis Configuration Templates

Universal Redis configurations for the meta-env project, supporting development and production environments.

## Files

### redis.conf
Base Redis configuration with sensible defaults for all environments. Contains:
- Network settings (bind, port, timeout)
- Database configuration (16 databases for project isolation)
- Persistence settings (RDB snapshots)
- Memory management
- Security settings
- Performance tuning

### redis-dev.conf
Development-specific overrides:
- More verbose logging (debug level)
- Disabled persistence for faster development
- Memory limit (256MB)
- Keyspace notifications enabled for debugging
- Lower client limits
- Protected mode disabled for local development

### redis-prod.conf
Production-grade configuration:
- Enhanced security (password protection, command renaming)
- Full persistence (RDB + AOF)
- Memory limits (2GB default)
- Replication support
- Systemd integration
- Comprehensive logging

## Usage

### Development
```bash
# Start with development config
redis-server /home/user/meta-env/redis/redis.conf --include /home/user/meta-env/redis/redis-dev.conf

# Or use docker-compose
docker run -d \
  -v /home/user/meta-env/redis:/usr/local/etc/redis \
  -p 6379:6379 \
  redis:7-alpine \
  redis-server /usr/local/etc/redis/redis.conf --include /usr/local/etc/redis/redis-dev.conf
```

### Production
```bash
# Start with production config
redis-server /home/user/meta-env/redis/redis.conf --include /home/user/meta-env/redis/redis-prod.conf

# With systemd
sudo systemctl start redis@production
```

## Database Isolation Strategy

The base configuration provides 16 databases (0-15) for project isolation:

**Development (redis-dev.conf):**
- DB 0: Main development
- DB 1: Testing/Experimental
- DB 2: Cache testing
- DB 3-15: Feature branches

**Production (redis-prod.conf):**
- DB 0-3: Main application
- DB 4-7: Cache layer
- DB 8-11: Session management
- DB 12-15: Background jobs

## Multi-Project Setup

### Option A: Separate Redis Instances (Recommended)
```bash
# Project 1 - Port 6379
redis-server --port 6379 --dbfilename project1.rdb

# Project 2 - Port 6380
redis-server --port 6380 --dbfilename project2.rdb

# Project 3 - Port 6381
redis-server --port 6381 --dbfilename project3.rdb
```

### Option B: Shared Redis with Database Numbers
Use different database numbers (0-15) for each project on a single Redis instance.

## Security Notes

### Production Checklist:
1. **Change the password**: Edit `requirepass` in `redis-prod.conf`
2. **Use environment variables**: Set password via `REDIS_PASSWORD` env var
3. **Enable SSL/TLS**: Uncomment TLS configuration in production config
4. **Restrict network access**: Use firewall rules to limit access
5. **Monitor access logs**: Review logs regularly for suspicious activity

### Dangerous Commands (Renamed in Production):
- `FLUSHDB` - Disabled
- `FLUSHALL` - Disabled
- `KEYS` - Disabled (use SCAN instead)
- `CONFIG` - Renamed to prevent unauthorized changes
- `DEBUG` - Disabled

## Performance Tuning

### Linux Kernel Settings:
```bash
# Add to /etc/sysctl.conf
vm.overcommit_memory = 1
net.core.somaxconn = 65535

# Disable Transparent Huge Pages
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```

### File Descriptors:
```bash
# Add to /etc/security/limits.conf
redis soft nofile 65535
redis hard nofile 65535
```

## Monitoring

### With Prometheus
Use `redis_exporter` for Prometheus integration:
```bash
docker run -d \
  -p 9121:9121 \
  oliver006/redis_exporter \
  --redis.addr=redis://localhost:6379
```

### CLI Monitoring
```bash
# Real-time monitoring
redis-cli MONITOR

# Statistics
redis-cli --stat

# Latency testing
redis-cli --latency

# Memory analysis
redis-cli --bigkeys
```

## Backup Strategy

### RDB (Point-in-time Snapshots)
- Automatic: Configured via `save` directives
- Manual: `redis-cli BGSAVE`
- Location: Specified by `dir` and `dbfilename`

### AOF (Append-Only File)
- Continuous append of all write operations
- Safer than RDB but larger files
- Auto-rewrite configured via `auto-aof-rewrite-percentage`

### Recommended Backup Script:
```bash
#!/bin/bash
# /home/user/meta-env/scripts/backup-redis.sh
BACKUP_DIR="/var/lib/redis/backups"
DATE=$(date +%Y%m%d-%H%M%S)

# Trigger background save
redis-cli BGSAVE

# Wait for save to complete
while [ $(redis-cli LASTSAVE) -eq $LASTSAVE ]; do
  sleep 1
done

# Copy RDB file
cp /var/lib/redis/dump-production.rdb "$BACKUP_DIR/dump-$DATE.rdb"

# Compress old backups
find "$BACKUP_DIR" -name "*.rdb" -mtime +7 -exec gzip {} \;

# Delete backups older than 30 days
find "$BACKUP_DIR" -name "*.rdb.gz" -mtime +30 -delete
```

## Troubleshooting

### High Memory Usage
```bash
# Check memory stats
redis-cli INFO memory

# Find large keys
redis-cli --bigkeys

# Set maxmemory and eviction policy
redis-cli CONFIG SET maxmemory 2gb
redis-cli CONFIG SET maxmemory-policy allkeys-lru
```

### Slow Queries
```bash
# Check slow log
redis-cli SLOWLOG GET 10

# Adjust threshold
redis-cli CONFIG SET slowlog-log-slower-than 5000
```

### Connection Issues
```bash
# Check connections
redis-cli CLIENT LIST

# Max clients
redis-cli CONFIG GET maxclients

# Increase if needed
redis-cli CONFIG SET maxclients 20000
```

## References

- Based on recommendations from `0-init-prompt.md` and `3-deep-dive.md`
- Redis Official Documentation: https://redis.io/docs/
- Redis Best Practices: https://redis.io/docs/management/optimization/
- Redis Security: https://redis.io/docs/management/security/
