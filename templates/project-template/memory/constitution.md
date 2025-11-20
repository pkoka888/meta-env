# Project Constitution

## Non-Negotiable Architectural Rules

These are the fundamental principles that govern this project. They should not be changed without team consensus.

## 1. Version Management

- **Python**: Managed via pyenv, version pinned in `.python-version`
- **Node.js**: Managed via nvm, version pinned in `.nvmrc`
- **Dependencies**: Locked versions in `requirements.txt` and `package-lock.json`

## 2. Environment Isolation

- Each project has its own Python virtual environment
- No global package installations (except pyenv, nvm, Docker)
- All services run in Docker containers for consistency

## 3. Configuration Management

- **No secrets in code**: All sensitive data in `.env` (gitignored)
- **Environment-specific configs**: Use `.env.dev`, `.env.prod`
- **Twelve-Factor App**: Follow twelve-factor principles

## 4. Code Quality Standards

- **Python**: Black formatter, flake8 linting, type hints required
- **JavaScript**: Prettier formatter, ESLint
- **Tests**: Minimum 80% code coverage
- **Documentation**: All public APIs must be documented

## 5. Git Workflow

- **Branch naming**: `feature/`, `bugfix/`, `hotfix/` prefixes
- **Commits**: Conventional commits format
- **Pull requests**: Required for all changes, must pass CI
- **No force push**: To main/master branches

## 6. Database Migrations

- All schema changes via migrations (Alembic for Python, Knex for Node)
- Never modify production database directly
- Migrations must be reversible

## 7. API Design

- **RESTful**: Follow REST principles
- **Versioning**: API versions in URL path (`/api/v1/`)
- **Error handling**: Consistent error response format
- **Rate limiting**: Applied to all public endpoints

## 8. Security

- **Authentication**: JWT tokens, secure storage
- **Authorization**: Role-based access control (RBAC)
- **Input validation**: All user inputs validated and sanitized
- **HTTPS only**: In production

## 9. Monitoring and Logging

- **Structured logging**: JSON format
- **Log levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Metrics**: Prometheus for all services
- **Alerting**: Critical errors trigger alerts

## 10. AI/LLM Integration

- **Fallback providers**: Always have fallback if primary LLM fails
- **Cost tracking**: Monitor API usage and costs
- **Rate limiting**: Implement client-side rate limiting
- **Privacy**: Never send sensitive data to external LLMs

## 11. Docker and Containerization

- **Multi-stage builds**: For smaller images
- **Non-root user**: Containers run as non-root
- **Health checks**: All services have health endpoints
- **Resource limits**: CPU and memory limits defined

## 12. Development Workflow

- **Local development**: Must work without internet (except LLM APIs)
- **Hot reload**: Enabled for development
- **Consistent setup**: `./setup.sh` creates working environment
- **Documentation**: README must be always up to date

## Decision Log

Major architectural decisions should be documented here:

### [YYYY-MM-DD] Decision Title
- **Context**: Why the decision was needed
- **Decision**: What was decided
- **Consequences**: Impact on the project
- **Alternatives**: What other options were considered
