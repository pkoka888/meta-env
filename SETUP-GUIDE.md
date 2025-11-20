# Meta-Env Setup Guide

Quick setup guide for Redis and MCP servers in the meta-env project.

## Created Configurations

### Redis Configurations (`/home/user/meta-env/redis/`)
- `redis.conf` - Base configuration (119 lines)
- `redis-dev.conf` - Development overrides (69 lines)
- `redis-prod.conf` - Production settings (137 lines)
- `README.md` - Complete documentation

### MCP Server Configurations (`/home/user/meta-env/mcp-servers/`)
- `filesystem-server.json` - File system operations (88 lines)
- `github-server.json` - GitHub integration (149 lines)
- `database-server.json` - Database operations (191 lines)
- `prometheus-server.js` - Custom Prometheus server (461 lines)
- `package.json` - Dependencies for custom servers
- `README.md` - Complete documentation

**Total: 1,202 lines of production-ready configuration**

## Quick Start

### 1. Install MCP Server Dependencies
```bash
cd /home/user/meta-env/mcp-servers
npm install
```

### 2. Set Environment Variables
```bash
# Create .env file
cat > /home/user/meta-env/.env << 'EOF'
# GitHub Integration
GITHUB_TOKEN=ghp_your_token_here

# Database Connection
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# Monitoring Stack
PROMETHEUS_URL=http://localhost:9090
GRAFANA_URL=http://localhost:3000
GRAFANA_API_KEY=your_grafana_api_key

# Redis
REDIS_PASSWORD=your_secure_redis_password
EOF

# Load environment variables
source /home/user/meta-env/.env
```

### 3. Start Redis (Development)
```bash
# Option A: Direct
redis-server /home/user/meta-env/redis/redis.conf \
  --include /home/user/meta-env/redis/redis-dev.conf

# Option B: Docker
docker run -d \
  --name redis-dev \
  -v /home/user/meta-env/redis:/usr/local/etc/redis:ro \
  -p 6379:6379 \
  redis:7-alpine \
  redis-server /usr/local/etc/redis/redis.conf \
  --include /usr/local/etc/redis/redis-dev.conf
```

### 4. Start Redis (Production)
```bash
# Update password first!
sed -i 's/CHANGE_THIS_IN_PRODUCTION_USE_ENV_VAR/${REDIS_PASSWORD}/' \
  /home/user/meta-env/redis/redis-prod.conf

# Start with systemd
sudo systemctl start redis@production

# Or with Docker
docker run -d \
  --name redis-prod \
  -v /home/user/meta-env/redis:/usr/local/etc/redis:ro \
  -v redis-data:/var/lib/redis \
  -p 6379:6379 \
  redis:7-alpine \
  redis-server /usr/local/etc/redis/redis.conf \
  --include /usr/local/etc/redis/redis-prod.conf
```

### 5. Test MCP Servers

#### Filesystem Server
```bash
# Test with npx
npx -y @modelcontextprotocol/server-filesystem /home/user/meta-env
```

#### GitHub Server
```bash
# Verify GitHub token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Test server
npx -y @modelcontextprotocol/server-github
```

#### Database Server
```bash
# Test database connection
psql $DATABASE_URL -c "SELECT version();"

# Test server
npx -y @modelcontextprotocol/server-postgres
```

#### Prometheus Server
```bash
# Install dependencies first
cd /home/user/meta-env/mcp-servers
npm install

# Test Prometheus connection
curl http://localhost:9090/api/v1/status/config

# Start server
node prometheus-server.js
```

### 6. Configure Claude Code

Add to `/home/user/meta-env/.claude/config.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/meta-env"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    },
    "prometheus": {
      "command": "node",
      "args": ["/home/user/meta-env/mcp-servers/prometheus-server.js"],
      "env": {
        "PROMETHEUS_URL": "${PROMETHEUS_URL}",
        "GRAFANA_URL": "${GRAFANA_URL}",
        "GRAFANA_API_KEY": "${GRAFANA_API_KEY}"
      }
    }
  }
}
```

### 7. Configure VS Code (Cline/Continue)

For Cline (`.cline/config.json`):
```json
{
  "mcpServers": [
    {
      "name": "filesystem",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/meta-env"]
    },
    {
      "name": "github",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  ]
}
```

For Continue (`.continue/config.json`):
```json
{
  "experimental": {
    "modelContextProtocol": true
  },
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/meta-env"]
    }
  }
}
```

## Verification Checklist

- [ ] Redis starts without errors
- [ ] Can connect to Redis: `redis-cli ping` returns `PONG`
- [ ] GitHub token is valid and has required permissions
- [ ] Database connection successful
- [ ] Prometheus and Grafana are accessible
- [ ] MCP servers load without errors in Claude Code
- [ ] All environment variables are set in `.env`
- [ ] `.env` file is added to `.gitignore`

## Security Checklist

- [ ] Change Redis password in production config
- [ ] Secure GitHub token (never commit to git)
- [ ] Encrypt database credentials
- [ ] Enable Redis SSL/TLS for production
- [ ] Configure firewall rules for Redis
- [ ] Set up Redis authentication
- [ ] Restrict database user permissions
- [ ] Rotate API keys regularly

## Monitoring Setup

### Prometheus Configuration
Add Redis exporter to `/home/user/meta-env/monitoring/prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['localhost:9121']
        labels:
          instance: 'redis-main'
```

### Start Redis Exporter
```bash
docker run -d \
  --name redis-exporter \
  -p 9121:9121 \
  oliver006/redis_exporter \
  --redis.addr=redis://localhost:6379
```

## Troubleshooting

### Redis won't start
```bash
# Check logs
tail -f /var/log/redis/redis-dev.log

# Test configuration
redis-server --test-memory 1024

# Check port availability
netstat -tuln | grep 6379
```

### MCP Server Connection Failed
```bash
# Test MCP server manually
DEBUG=mcp:* npx -y @modelcontextprotocol/server-filesystem /home/user/meta-env

# Check Node.js version (requires >= 18)
node --version
```

### GitHub Authentication Failed
```bash
# Verify token
echo $GITHUB_TOKEN

# Test API access
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Check rate limit
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit
```

## Next Steps

1. Review Redis configurations in `/home/user/meta-env/redis/README.md`
2. Review MCP server documentation in `/home/user/meta-env/mcp-servers/README.md`
3. Set up monitoring dashboards in Grafana
4. Create backup scripts for Redis data
5. Configure project-specific database isolation
6. Test MCP integrations with Claude Code

## References

- Redis Configuration: `/home/user/meta-env/redis/README.md`
- MCP Servers: `/home/user/meta-env/mcp-servers/README.md`
- Project Documentation: `/home/user/meta-env/0-init-prompt.md`
- Deep Dive Guide: `/home/user/meta-env/3-deep-dive.md`

## Support

For issues or questions:
1. Check the README files in each directory
2. Review logs for error messages
3. Verify environment variables are set correctly
4. Ensure all dependencies are installed
5. Test each component individually before integration
