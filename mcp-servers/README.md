# MCP Servers Configuration

Model Context Protocol (MCP) server configurations for Claude Code integration in the meta-env project.

## Overview

MCP servers provide specialized capabilities to AI assistants like Claude Code, enabling seamless integration with filesystems, databases, GitHub, monitoring tools, and more.

## Available Servers

### 1. Filesystem Server (`filesystem-server.json`)
**Purpose**: Safe, sandboxed access to project files

**Capabilities**:
- Read/write files
- Directory management
- File search and pattern matching
- Metadata inspection
- Respects .gitignore

**Configuration**:
```json
{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/user/meta-env"]
}
```

**Allowed Directories**:
- `/home/user/meta-env`
- `/var/www/projects`
- `/var/www/universal-env`

### 2. GitHub Server (`github-server.json`)
**Purpose**: GitHub repository and workflow management

**Capabilities**:
- Repository operations (create, fork, search)
- File operations (read, write, commit, push)
- Issue and PR management
- Code search across repositories
- Branch and commit management

**Setup**:
```bash
# Generate GitHub token
# Go to: Settings -> Developer settings -> Personal access tokens

# Set environment variable
export GITHUB_TOKEN="ghp_your_token_here"

# Or add to .env file
echo "GITHUB_TOKEN=ghp_your_token_here" >> .env
```

**Required Permissions**:
- `repo` - Full repository access
- `workflow` - Workflow management
- `write:packages` - Package publishing
- `read:org` - Organization read access

### 3. Database Server (`database-server.json`)
**Purpose**: Database operations and schema management

**Supported Databases**:
- PostgreSQL (primary)
- MySQL
- SQLite
- Supabase

**Capabilities**:
- Query execution
- Schema inspection
- Migrations
- Backups
- Data analysis

**Setup**:
```bash
# PostgreSQL
export DATABASE_URL="postgresql://user:password@localhost:5432/dbname"

# Or individual settings
export DB_HOST="localhost"
export DB_PORT="5432"
export DB_NAME="mydb"
export DB_USER="postgres"
export DB_PASSWORD="secretpass"

# Supabase
export DATABASE_URL="postgresql://postgres:password@db.project.supabase.co:5432/postgres"
```

### 4. Prometheus Server (`prometheus-server.js`)
**Purpose**: Custom monitoring and observability integration

**Capabilities**:
- PromQL query execution
- Metrics exploration
- Target monitoring
- Alert management
- Grafana dashboard integration
- Performance analysis

**Setup**:
```bash
# Install dependencies
cd /home/user/meta-env/mcp-servers
npm install

# Set environment variables
export PROMETHEUS_URL="http://localhost:9090"
export GRAFANA_URL="http://localhost:3000"
export GRAFANA_API_KEY="your_grafana_api_key"

# Run the server
npm run start:prometheus

# Or in development mode
npm run dev:prometheus
```

**Available Tools**:
- `query_metrics` - Execute instant PromQL queries
- `query_range` - Time-range queries
- `list_metrics` - List all available metrics
- `get_targets` - Monitor target status
- `get_alerts` - View active alerts
- `create_grafana_dashboard` - Create dashboards programmatically
- `get_grafana_dashboards` - List existing dashboards
- `analyze_performance` - AI-powered performance insights

## Integration with Claude Code

### .claude/config.json
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

### .cline/config.json
```json
{
  "mcpServers": [
    {
      "name": "filesystem",
      "config": "/home/user/meta-env/mcp-servers/filesystem-server.json"
    },
    {
      "name": "github",
      "config": "/home/user/meta-env/mcp-servers/github-server.json"
    }
  ]
}
```

### .continue/config.json
```json
{
  "experimental": {
    "modelContextProtocol": true
  },
  "mcpServers": {
    "filesystem": "/home/user/meta-env/mcp-servers/filesystem-server.json",
    "github": "/home/user/meta-env/mcp-servers/github-server.json",
    "database": "/home/user/meta-env/mcp-servers/database-server.json",
    "prometheus": "/home/user/meta-env/mcp-servers/prometheus-server.js"
  }
}
```

## Use Cases

### Filesystem Server
```
Claude: "Search for all TypeScript files in src/ that import React"
Claude: "Read the contents of package.json and analyze dependencies"
Claude: "Create a new component file in src/components/"
```

### GitHub Server
```
Claude: "Create a new issue titled 'Bug: Login not working' with detailed description"
Claude: "Search for repositories related to 'redis caching'"
Claude: "Create a PR from feature-branch to main with summary"
```

### Database Server
```
Claude: "List all tables in the database and their row counts"
Claude: "Generate a migration to add 'email_verified' column to users table"
Claude: "Analyze slow queries and suggest indexes"
```

### Prometheus Server
```
Claude: "Query CPU usage for service 'api-server' over the last hour"
Claude: "Show me all active alerts"
Claude: "Analyze performance metrics for 'web-app' and identify bottlenecks"
Claude: "Create a Grafana dashboard for monitoring Redis metrics"
```

## Security Best Practices

### 1. Environment Variables
Store sensitive credentials in environment variables, never in config files:
```bash
# Create .env file (add to .gitignore!)
cat > /home/user/meta-env/.env << EOF
GITHUB_TOKEN=ghp_xxxxxxxxxxxxx
DATABASE_URL=postgresql://user:pass@localhost/db
GRAFANA_API_KEY=eyJrIjoixxxxx
EOF

# Load in shell
source /home/user/meta-env/.env
```

### 2. Restricted Paths
Filesystem server excludes sensitive directories:
- `.git/` directories
- `node_modules/`
- `.env` files
- `credentials.json`

### 3. Database Safety
Production database server restricts dangerous operations:
- `DROP DATABASE` - Blocked
- `TRUNCATE TABLE` - Blocked in production
- All queries use parameterization to prevent SQL injection

### 4. GitHub Rate Limits
Monitor GitHub API usage to avoid rate limiting:
- Primary API: 5000 requests/hour
- Search API: 30 requests/minute
- Use conditional requests when possible

## Monitoring and Debugging

### Filesystem Server
```bash
# Enable debug logging
DEBUG=mcp:* npx -y @modelcontextprotocol/server-filesystem /home/user/meta-env
```

### GitHub Server
```bash
# Test GitHub connection
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# Check rate limit
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/rate_limit
```

### Database Server
```bash
# Test database connection
psql $DATABASE_URL -c "SELECT version();"

# Check active connections
psql $DATABASE_URL -c "SELECT count(*) FROM pg_stat_activity;"
```

### Prometheus Server
```bash
# Test Prometheus connection
curl http://localhost:9090/api/v1/status/config

# Test Grafana connection
curl -H "Authorization: Bearer $GRAFANA_API_KEY" http://localhost:3000/api/health
```

## Custom MCP Server Development

The `prometheus-server.js` is a custom MCP server. You can create similar servers for other integrations:

### Template Structure
```javascript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

class CustomServer {
  constructor() {
    this.server = new Server({
      name: 'custom-server',
      version: '1.0.0',
    }, {
      capabilities: {
        resources: {},
        tools: {},
      },
    });

    this.setupHandlers();
  }

  setupHandlers() {
    // Define tools, resources, and handlers
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new CustomServer();
server.run().catch(console.error);
```

## Troubleshooting

### MCP Server Not Found
```bash
# Ensure npx can find the package
npx -y @modelcontextprotocol/server-filesystem --version

# Or install globally
npm install -g @modelcontextprotocol/server-filesystem
```

### Permission Denied
```bash
# Make custom servers executable
chmod +x /home/user/meta-env/mcp-servers/prometheus-server.js

# Fix ownership
sudo chown -R $USER:$USER /home/user/meta-env/mcp-servers
```

### Environment Variables Not Loaded
```bash
# Verify environment variables are set
env | grep -E "GITHUB_TOKEN|DATABASE_URL|PROMETHEUS_URL"

# Load from .env file
export $(cat /home/user/meta-env/.env | xargs)
```

## References

- MCP Specification: https://spec.modelcontextprotocol.io/
- MCP SDK: https://github.com/modelcontextprotocol/sdk
- Claude Code Documentation: https://docs.anthropic.com/claude/docs
- Based on: `0-init-prompt.md` and `3-deep-dive.md`

## Next Steps

1. Install dependencies: `cd /home/user/meta-env/mcp-servers && npm install`
2. Set environment variables in `/home/user/meta-env/.env`
3. Configure Claude Code to use these servers in `.claude/config.json`
4. Test each server individually before integration
5. Monitor server logs for errors and performance issues
