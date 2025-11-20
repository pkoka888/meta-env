# Project Name

## Overview
Brief description of the project

## Tech Stack
- **Backend**: [e.g., Python 3.11, Node.js 20.10]
- **Frontend**: [e.g., React, Vue]
- **Database**: [e.g., PostgreSQL, MongoDB]
- **Cache**: Redis
- **AI/ML**: [e.g., Ollama, AutoGen]

## Setup

### Prerequisites
- pyenv (Python version management)
- nvm (Node.js version management)
- Docker & Docker Compose
- direnv (optional but recommended)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd <project-name>
   ```

2. **Set up Python environment**
   ```bash
   pyenv local 3.11.5
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Set up Node.js environment**
   ```bash
   nvm use
   npm install
   ```

4. **Configure environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configurations
   ```

5. **Start services**
   ```bash
   docker-compose up -d
   ```

## Project Structure

```
.
├── .claude/              # Claude Code configuration
├── .vscode/              # VS Code settings
├── .cline/               # Cline configuration
├── .continue/            # Continue.dev configuration
├── src/                  # Source code
├── tests/                # Test files
├── docs/                 # Documentation
├── memory/               # Project memory and rules
├── monitoring/           # Observability configs
└── docker-compose.yml    # Services orchestration
```

## Development Workflow

1. Read `docs/CLAUDE.md` for AI assistant guidance
2. Check `memory/project-checklist.md` for project-specific workflows
3. Follow coding standards in `memory/coding-standards.md`
4. Run tests before committing: `npm test` or `pytest`

## Deployment

See `docs/DEPLOYMENT.md` for detailed deployment instructions.

## Monitoring

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000

## Contributing

See `docs/CONTRIBUTING.md`

## License

[Your License]
