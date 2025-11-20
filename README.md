# Meta-Env: Elite AI-Boosted Development Environment

> A production-grade, multi-project AI development platform template for Debian-based systems with intelligent orchestration, version management, and monitoring.

## Overview

Meta-Env is a comprehensive, batteries-included project template that combines AI-powered development tools, infrastructure monitoring, and best practices for building scalable applications. It provides a standardized environment for multi-agent AI workflows, RAG systems, and production deployments.

### Key Features

- **AI-First Development**: Pre-configured Claude Code, Cline, Continue.dev, and Ollama integration
- **Version Management**: pyenv, nvm, and direnv for isolated project environments
- **Multi-Agent Support**: AutoGen, RAG, and LangChain ready-to-use configurations
- **Production Monitoring**: Grafana, Prometheus, and comprehensive observability
- **Workflow Automation**: n8n integration for complex automation pipelines
- **Container Orchestration**: Docker Compose with Redis, PostgreSQL, and all essential services
- **Intelligent Decision Making**: Project checklist system that activates relevant tools automatically
- **Security First**: UFW firewall configs, OpenVPN support, and secure defaults

## Quick Start

### Prerequisites

- Debian 12+ or Ubuntu 22.04+
- Docker and Docker Compose
- Git
- Python 3.11+
- Node.js 20+

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/your-org/meta-env.git my-project
cd my-project

# 2. Run setup script
chmod +x scripts/setup.sh
./scripts/setup.sh

# 3. Copy environment variables
cp .env.example .env
# Edit .env with your credentials

# 4. Start services
docker-compose up -d

# 5. Open in VS Code
code .
```

### First Project

```bash
# Create a new project from template
./scripts/create-project.sh my-ai-app "AI-powered web application"

cd my-ai-app

# Services auto-start via docker-compose
# Claude Code reads project-checklist.md and activates relevant skills
```

## Directory Structure

```
meta-env/
├── .claude/                      # Claude Code configuration
│   ├── config.json              # MCP servers, API keys, model configs
│   ├── skills/                  # Pre-built skills for auto-activation
│   │   ├── research/           # Research & documentation
│   │   ├── testing/            # Test generation & validation
│   │   └── deployment/         # Deploy, monitor, rollback
│   ├── agents/                  # Specialized subagents
│   └── commands/                # Custom slash commands
│
├── .cline/                      # Cline-specific settings
│   └── config.json
│
├── .continue/                   # Continue.dev configuration
│   └── config.json              # Models, providers, autocomplete
│
├── .vscode/                     # VS Code workspace settings
│   ├── settings.json           # Must-have, recommended extensions
│   ├── extensions.json         # Required extensions list
│   └── launch.json             # Debug configurations
│
├── memory/                      # Project memory & rules
│   ├── constitution.md         # Non-negotiable architectural rules
│   ├── project-checklist.md    # What agents/tools to activate
│   ├── context-management.md   # How to handle long contexts
│   └── coding-standards.md     # Style guides, conventions
│
├── docs/                        # Documentation
│   ├── roadmap.md              # Development milestones
│   ├── CLAUDE.md               # How to work with Claude
│   ├── parallel-plans.md       # Multi-agent coordination
│   └── research-templates/     # Pre-built research workflows
│
├── monitoring/                  # Observability configs
│   ├── prometheus/             # Metrics collection
│   ├── grafana/                # Dashboards and visualizations
│   │   └── dashboards/
│   └── wazuh/                  # Security monitoring
│
├── redis/                       # Universal Redis configs
│   ├── redis.conf              # Base configuration
│   ├── redis-dev.conf          # Development overrides
│   └── redis-prod.conf         # Production settings
│
├── mcp-servers/                 # Model Context Protocol servers
│   ├── filesystem-server.json
│   ├── github-server.json
│   ├── database-server.json
│   └── custom-api-server.json
│
├── configs/                     # Shared configuration templates
│   ├── nginx/
│   ├── apache/
│   └── docker/
│
├── templates/                   # Project templates
│   ├── nextjs/                 # Next.js starter
│   ├── fastapi/                # FastAPI backend
│   ├── react-native/           # Mobile app
│   └── autogen/                # Multi-agent systems
│
├── scripts/                     # Automation scripts
│   ├── setup.sh                # Initial setup
│   ├── create-project.sh       # Scaffold new project
│   ├── deploy.sh               # Deployment automation
│   └── backup.sh               # Backup databases and configs
│
├── src/                         # Application source code
├── tests/                       # Test suite
│
├── docker-compose.yml           # Service orchestration
├── Dockerfile                   # Multi-stage build
├── .env.example                 # Environment variables template
├── .gitignore                   # Git ignore rules
├── README.md                    # This file
└── project-checklist.md         # Decision tree for Claude

```

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# API Keys
ANTHROPIC_API_KEY=sk-ant-xxx
OPENAI_API_KEY=sk-xxx
OPENROUTER_API_KEY=sk-or-xxx

# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DB=meta_env
REDIS_PASSWORD=your_redis_password

# Services
GRAFANA_ADMIN_PASSWORD=admin
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=password

# Ollama (local or remote)
OLLAMA_HOST=http://localhost:11434
# For remote GPU: http://192.168.1.100:11434
```

### VS Code Setup

Required extensions are automatically suggested. Install all "required" extensions:

- **Continue.dev** - AI autocomplete and chat
- **Cline** (claude-dev) - Agentic coding assistant
- **GitHub Copilot** - Backup AI pair programmer
- **Prettier** - Code formatting
- **ESLint** - Linting

Recommended extensions will be suggested based on your project type.

### Version Management

Each project uses `.python-version` and `.nvmrc` for automatic version switching:

```bash
# Set Python version
pyenv local 3.11.5
echo "3.11.5" > .python-version

# Set Node version
nvm use 20.10.0
echo "20.10.0" > .nvmrc

# direnv automatically loads environment
direnv allow
```

## Usage

### Daily Workflow

1. **Start with CLAUDE.md**: Review project-specific prompting guide
2. **Check roadmap.md**: See what's next on the development schedule
3. **Use skills**: Claude auto-activates based on task type
4. **Parallel work**: Spawn subagents for security audits, tests, documentation
5. **Monitor**: Grafana dashboard shows app and AI metrics in real-time

### AI-Powered Development

**Claude Code Integration**:
```bash
# Claude reads project-checklist.md automatically
# Activates relevant skills based on project structure

# For web apps: react-skill, tailwind-skill
# For APIs: api-design-skill, database-skill
# For AI/ML: ollama-integration, prometheus-monitoring
```

**Multi-Agent Orchestration**:
```bash
# Research new feature
claude research "Compare authentication solutions"

# Implement with parallel agents
claude feature "Add OAuth authentication"
# - Security auditor validates implementation
# - Test generator creates comprehensive tests
# - Documentation writer updates README
```

### Working with Services

**Start/Stop Services**:
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Restart specific service
docker-compose restart redis
```

**Access Services**:
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- n8n: http://localhost:5678
- PostgreSQL: localhost:5432
- Redis: localhost:6379

### Database Operations

**PostgreSQL**:
```bash
# Connect via psql
docker-compose exec postgres psql -U postgres -d meta_env

# Backup
./scripts/backup.sh postgres

# Restore
docker-compose exec -T postgres psql -U postgres -d meta_env < backup.sql
```

**Redis**:
```bash
# Connect via redis-cli
docker-compose exec redis redis-cli

# Monitor commands
docker-compose exec redis redis-cli MONITOR
```

### Monitoring Stack

**Prometheus Metrics**:
- Application metrics: http://localhost:9090
- Query editor for custom metrics
- Alerting rules configured in `monitoring/prometheus/alerts.yml`

**Grafana Dashboards**:
- System metrics (CPU, RAM, Disk)
- Application performance (requests, latency, errors)
- AI metrics (model usage, token counts, response times)
- Custom dashboards in `monitoring/grafana/dashboards/`

### Multi-Project Redis Strategy

**Option A: Separate instances** (Recommended):
```bash
redis-server --port 6379 --dbfilename project1.rdb
redis-server --port 6380 --dbfilename project2.rdb
```

**Option B: Shared Redis with database isolation**:
```python
# Project 1 uses DB 0-3
redis_client = Redis(host='localhost', port=6379, db=0)

# Project 2 uses DB 4-7
redis_client = Redis(host='localhost', port=6379, db=4)
```

## Best Practices

### Version Management

- **Always** use `.python-version` and `.nvmrc` for version pinning
- Install direnv for automatic environment activation
- Keep dependencies in `requirements.txt` (Python) and `package.json` (Node)
- Use virtual environments: `python -m venv venv`

### Context Management

- Keep skills under 500 lines for optimal context usage
- Reference external files instead of duplicating content
- Use git worktrees for parallel feature development
- Archive completed discussions to `memory/archive/` monthly

### Security

- **Never commit** `.env` files (use `.env.example` as template)
- Store secrets in environment variables, not code
- Use SSH keys, not passwords for server access
- Regular security audits with the security-auditor agent
- Keep OpenVPN for secure access to monitoring tools

### Docker Best Practices

- Use multi-stage builds to reduce image size
- Pin specific versions in `docker-compose.yml`
- Use `.dockerignore` to exclude unnecessary files
- Regular cleanup: `docker system prune -a`

### Development vs Production

```
project/
├── dev/                    # Development workspace
│   ├── src/
│   ├── .env.dev
│   └── docker-compose.dev.yml
├── prod/                   # Production builds
│   ├── dist/
│   ├── .env.prod
│   └── docker-compose.prod.yml
└── shared/                 # Common configs
    ├── nginx.conf
    └── redis.conf
```

Switch environments with direnv:
```bash
# Development
cd dev && direnv allow

# Production
cd prod && direnv allow
```

## Advanced Features

### AutoGen Multi-Agent Setup

Configure AutoGen with local Ollama:

```python
# autogen_config.py
import autogen

llm_config = {
    "config_list": [{
        "model": "ollama/llama3:8b",
        "base_url": "http://localhost:11434",
        "api_key": "ollama"
    }],
    "temperature": 0.7
}

assistant = autogen.AssistantAgent(
    name="assistant",
    llm_config=llm_config
)
```

### RAG System Integration

Use LangChain with local embeddings:

```python
from langchain.embeddings import OllamaEmbeddings
from langchain.vectorstores import Chroma

embeddings = OllamaEmbeddings(
    model="nomic-embed-text",
    base_url="http://localhost:11434"
)

vectorstore = Chroma(
    persist_directory="./chroma_db",
    embedding_function=embeddings
)
```

### MCP Servers

Model Context Protocol servers provide Claude with extended capabilities:

- **Filesystem**: Read/write project files
- **GitHub**: Repository management, issues, PRs
- **Database**: Query and modify databases
- **Prometheus**: Query metrics and create alerts
- **Custom**: Build your own MCP servers

Configure in `.claude/config.json`.

### Workflow Automation with n8n

Access n8n at http://localhost:5678 to create workflows:

- Automated testing on git push
- Slack notifications for deployments
- Database backups to cloud storage
- AI-powered code reviews
- Metric alerts via email/SMS

## Contributing

### Development Workflow

1. Create feature branch: `git checkout -b feature/my-feature`
2. Make changes and test locally
3. Update documentation in `docs/`
4. Run tests: `docker-compose exec app pytest`
5. Commit with descriptive message
6. Push and create Pull Request

### Code Style

- Python: PEP 8, enforced by Black and Flake8
- JavaScript: Airbnb style guide, enforced by ESLint
- TypeScript: Strict mode enabled
- Commits: Conventional Commits format

### Testing Requirements

- Unit tests for all new functions
- Integration tests for API endpoints
- E2E tests for critical user flows
- Minimum 80% code coverage

## Troubleshooting

### Common Issues

**Port conflicts**:
```bash
# Check what's using a port
sudo lsof -i :6379

# Change port in docker-compose.yml
```

**Docker permission errors**:
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

**Ollama not accessible**:
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Start Ollama
systemctl start ollama
```

**VS Code extensions not loading**:
```bash
# Reload window
Ctrl+Shift+P -> "Reload Window"

# Check extension logs
Ctrl+Shift+P -> "Developer: Show Logs"
```

## Documentation

### Core Documents

- [Constitution](memory/constitution.md) - Architectural principles and rules
- [Roadmap](docs/roadmap.md) - Development milestones and plans
- [CLAUDE.md](docs/CLAUDE.md) - AI assistant integration guide
- [Project Checklist](project-checklist.md) - Auto-configuration decision tree

### Guides

- [Setup Guide](docs/setup-guide.md) - Detailed installation instructions
- [Deployment Guide](docs/deployment-guide.md) - Production deployment
- [Monitoring Guide](docs/monitoring-guide.md) - Observability best practices
- [Security Guide](docs/security-guide.md) - Hardening and compliance

### API Documentation

- API endpoints: http://localhost:8000/docs (when app is running)
- Database schema: `docs/database-schema.md`
- MCP servers: `docs/mcp-servers.md`

## Resources

### Official Links

- [Claude Code Documentation](https://code.claude.com/docs)
- [Continue.dev Documentation](https://continue.dev/docs)
- [Ollama Documentation](https://ollama.ai/docs)
- [n8n Documentation](https://docs.n8n.io)

### Recommended Repositories

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) - Claude workflows and templates
- [Autogen GraphRAG Ollama](https://github.com/karthik-codex/Autogen_GraphRAG_Ollama) - Multi-agent RAG system
- [workshop-prometheus-grafana](https://github.com/samber/workshop-prometheus-grafana) - Monitoring setup guide
- [wazuh-prometheus-exporter](https://github.com/pyToshka/wazuh-prometheus-exporter) - Security metrics

### Community

- Claude Code Discord: [Invite Link]
- Ollama Discord: [Invite Link]
- AutoGen Community: [GitHub Discussions]

## License

MIT License - See [LICENSE](LICENSE) file for details

## Acknowledgments

Built with inspiration from:
- Anthropic's Claude Code best practices
- Microsoft's AutoGen framework
- The Ollama community
- Debian infrastructure patterns
- Production SaaS architectures

---

**Version**: 1.0.0
**Last Updated**: 2025-11-20
**Maintained By**: Your Organization

For questions or support, open an issue on GitHub or join our community Discord.
