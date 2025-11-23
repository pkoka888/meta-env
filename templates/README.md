# Meta-Env Project Templates

Comprehensive project templates for AI-boosted development environments on Debian 13.

## Overview

This templates directory contains battle-tested configurations, structures, and examples for building production-grade projects with integrated AI assistance (Claude Code, Cline, Continue.dev), multi-agent systems (AutoGen), RAG capabilities, and comprehensive monitoring.

## Directory Structure

```
templates/
├── project-template/          # Complete project structure
├── autogen-configs/           # Multi-agent system configurations
├── rag-configs/               # RAG system configurations
└── docker-compose-templates/  # Service orchestration templates
```

## Quick Start

### Create New Project from Template

```bash
# Navigate to your projects directory
cd /var/www/projects

# Copy template
cp -r /home/user/meta-env/templates/project-template ./my-new-project
cd my-new-project

# Set up environment
cp .env.example .env
nano .env

# Initialize git
git init
git add .
git commit -m "Initial commit from meta-env template"

# Set up Python environment
pyenv local 3.11.5
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Set up Node.js environment
nvm use
npm install

# Start services
docker-compose up -d

# Open in VS Code
code .
```

## Available Templates

### 1. Project Template (`project-template/`)

**What's Included**:
- ✅ Complete folder structure (src/, tests/, docs/, memory/)
- ✅ AI assistant configurations (.claude/, .cline/, .continue/)
- ✅ VS Code settings with recommended extensions
- ✅ Python and Node.js setup files
- ✅ Git configuration (.gitignore)
- ✅ Environment templates (.env.example)
- ✅ Documentation templates
- ✅ Memory management system
- ✅ Project constitution and coding standards

**Key Features**:
- **AI-First Design**: Pre-configured for Claude Code, Cline, and Continue.dev
- **Context Optimized**: Smart memory management and project checklist
- **Best Practices**: Industry-standard folder structure and conventions
- **Developer Experience**: Comprehensive VS Code settings and extensions

**Use Cases**:
- Web applications (frontend + backend)
- API services
- AI/ML projects
- Full-stack applications

### 2. AutoGen Configurations (`autogen-configs/`)

**What's Included**:
- ✅ Research Team (4 agents)
- ✅ Code Team (5 agents)
- ✅ Analysis Team (5 agents)
- ✅ Complete workflow configurations
- ✅ Ollama integration setup

**Agent Teams**:

**Research Team**:
- Researcher: Gathers information
- Analyst: Analyzes and structures data
- Critic: Validates findings
- Writer: Creates documentation

**Code Team**:
- Architect: System design
- Developer: Implementation
- Tester: Quality assurance
- Reviewer: Code review
- Security Expert: Security audits

**Analysis Team**:
- Data Engineer: Data preparation
- Statistician: Statistical analysis
- ML Engineer: Model building
- Visualizer: Data visualization
- Interpreter: Business insights

**Use Cases**:
- Complex research projects
- Collaborative software development
- Data analysis and insights generation
- Multi-perspective problem solving

### 3. RAG Configurations (`rag-configs/`)

**What's Included**:
- ✅ LangChain configuration
- ✅ ChromaDB setup
- ✅ Embedding model configuration
- ✅ Document processing pipelines
- ✅ Monitoring and caching setup

**Features**:
- **Multiple Vector Stores**: ChromaDB, Qdrant, Weaviate support
- **Local-First**: Ollama embeddings with cloud fallbacks
- **Production Ready**: Caching, monitoring, rate limiting
- **Flexible Processing**: Multiple document loaders and chunking strategies

**Use Cases**:
- Document Q&A systems
- Knowledge base applications
- Semantic search
- AI-powered documentation

### 4. Docker Compose Templates (`docker-compose-templates/`)

**What's Included**:
- ✅ Web App Stack (6 services)
- ✅ API Stack (9 services)
- ✅ Monitoring Stack (11 services)
- ✅ AI Stack (10+ services)

**Stacks**:

**Web App Stack**:
- Frontend (Node.js)
- Backend (Python)
- PostgreSQL
- Redis
- Nginx
- pgAdmin

**API Stack**:
- Kong API Gateway
- API Service
- Worker (Celery)
- Scheduler
- PostgreSQL
- Redis
- MinIO
- Elasticsearch
- RabbitMQ

**Monitoring Stack**:
- Prometheus
- Grafana
- Loki
- Promtail
- AlertManager
- Node Exporter
- cAdvisor
- Jaeger
- Multiple exporters

**AI Stack**:
- Ollama (GPU support)
- ChromaDB
- n8n
- Qdrant/Weaviate
- LiteLLM Proxy
- Flowise
- Open WebUI
- Chainlit

**Use Cases**:
- Complete application deployments
- Development environments
- Production infrastructure
- AI/ML service orchestration

## Integration with Meta-Env

These templates are designed to work seamlessly with the meta-env project structure:

```
/opt/ai-platform/           # System-wide AI tools (Ollama, n8n)
/var/www/universal-env/     # Shared configs (from templates)
/var/www/projects/          # Your projects (using templates)
```

### Recommended Workflow

1. **Set up universal environment**:
```bash
# Copy shared configs
cp -r templates/rag-configs /var/www/universal-env/
cp -r templates/docker-compose-templates /var/www/universal-env/
```

2. **Create new project**:
```bash
cd /var/www/projects
cp -r /home/user/meta-env/templates/project-template ./my-project
cd my-project
```

3. **Customize for project type**:
```bash
# For web app
cp /var/www/universal-env/docker-compose-templates/web-app-stack.yml ./docker-compose.yml

# For API service
cp /var/www/universal-env/docker-compose-templates/api-stack.yml ./docker-compose.yml

# For AI project
cp /var/www/universal-env/docker-compose-templates/ai-stack.yml ./docker-compose.yml
```

4. **Configure AI agents** (if needed):
```bash
cp /var/www/universal-env/autogen-configs/* ./agents/
cp /var/www/universal-env/rag-configs/* ./rag/
```

## Customization Guide

### Adapting Templates

1. **Project Template**:
   - Edit `memory/constitution.md` for project-specific rules
   - Update `memory/project-checklist.md` for your tech stack
   - Modify `.vscode/extensions.json` for your tools
   - Customize `memory/coding-standards.md` for your style

2. **AutoGen Configs**:
   - Adjust agent system messages for your domain
   - Change temperature values for creativity/precision
   - Modify workflow steps for your process
   - Add custom tools and capabilities

3. **RAG Configs**:
   - Update chunk sizes for your document types
   - Configure different embedding models
   - Adjust retrieval parameters (k, score_threshold)
   - Enable/disable features based on needs

4. **Docker Compose**:
   - Remove unused services
   - Adjust resource limits
   - Change port mappings
   - Add custom services

## Best Practices

### Version Management
- Use `.python-version` and `.nvmrc` for consistency
- Pin dependency versions in requirements.txt and package.json
- Document major version upgrades

### Environment Configuration
- Never commit `.env` files
- Keep `.env.example` up to date
- Use different `.env` files for dev/staging/prod
- Rotate secrets regularly

### AI Assistant Usage
- Start each project by reading `docs/CLAUDE.md`
- Keep `memory/project-checklist.md` current
- Archive old conversations monthly
- Use skills for repeated patterns

### Docker Services
- Use health checks for all services
- Implement proper logging
- Set resource limits
- Use named volumes for persistence

## Troubleshooting

### Common Issues

**Port Conflicts**:
```bash
# Check port usage
netstat -tulpn | grep <port>
# Change port in .env
```

**Permission Issues**:
```bash
# Fix ownership
sudo chown -R $USER:$USER ./project
```

**Ollama Connection**:
```bash
# Test connection
curl http://localhost:11434/api/tags
# Check container logs
docker logs <project>_ollama
```

**ChromaDB Issues**:
```bash
# Recreate database
rm -rf ./data/chroma_db
# Restart service
docker-compose restart chromadb
```

## Updating Templates

### Pull Latest Updates

```bash
cd /home/user/meta-env
git pull origin main

# Update your projects selectively
# (Don't overwrite custom configurations)
```

### Contributing Improvements

If you improve a template:

1. Test thoroughly
2. Document changes
3. Update relevant READMEs
4. Commit to meta-env repository

## Resources

### Documentation
- [0-init-prompt.md](/home/user/meta-env/0-init-prompt.md) - Initial setup guide
- [3-deep-dive.md](/home/user/meta-env/3-deep-dive.md) - Deep dive into configurations

### External Resources
- [AutoGen Documentation](https://microsoft.github.io/autogen/)
- [LangChain Documentation](https://python.langchain.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Ollama Models](https://ollama.com/library)

### Community
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code)
- AutoGen Discord Community
- Ollama Discord Community

## Template Versioning

**Current Version**: 1.0.0
**Last Updated**: 2025-11-20
**Compatible With**:
- Debian 13
- Python 3.11+
- Node.js 20+
- Docker Compose 3.8+

## License

These templates are part of the meta-env project and follow the same license.

## Support

For issues, questions, or contributions:
1. Check existing documentation
2. Review troubleshooting section
3. Consult community resources
4. Create issue in meta-env repository

---

**Built with**: Claude Code, AutoGen, LangChain, Docker, and best practices from production deployments.
