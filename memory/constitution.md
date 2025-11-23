# Meta-Env Constitution

## Purpose

This document outlines the **non-negotiable architectural principles, coding standards, security rules, and foundational conventions** for all projects created using the meta-env template. These rules ensure consistency, maintainability, security, and scalability across all AI-boosted development projects.

---

## I. Architectural Principles

### 1.1 Separation of Concerns
- **Strict layering**: Separate presentation, business logic, and data access layers
- **Modularity**: Each component should have a single, well-defined responsibility
- **Dependencies**: Always point inward (outer layers depend on inner layers, never vice versa)

### 1.2 Configuration Management
- **Environment Variables**: All environment-specific configurations MUST use environment variables
- **No Hardcoded Secrets**: Never commit API keys, passwords, database credentials, or tokens to version control
- **Configuration Files**: Use `.env` files for local development, secret managers for production
- **Version Pinning**: Pin all dependencies (Python packages, npm modules, Docker images) to specific versions

### 1.3 Project Structure Standards
```
project-root/
├─ src/                   # Application source code only
├─ tests/                 # Test scripts and fixtures
├─ .claude/               # Claude Code configuration
├─ .vscode/               # VS Code workspace settings
├─ memory/                # Project architecture, principles, DDD domains
├─ docs/                  # Extended technical documentation
├─ monitoring/            # Observability configs (Prometheus, Grafana)
├─ scripts/               # Automation and deployment scripts
├─ configs/               # Configuration templates
├─ docker-compose.yml     # Container orchestration
├─ .python-version        # pyenv Python version
├─ .nvmrc                 # nvm Node.js version
├─ .envrc                 # direnv auto-activation
├─ README.md              # Project overview and quick start
└─ CHANGELOG.md           # Release notes and version history
```

### 1.4 Version Management
- **Python**: Use `pyenv` for version management, commit `.python-version`
- **Node.js**: Use `nvm` for version management, commit `.nvmrc`
- **Dependencies**: Lock files (requirements.txt, poetry.lock, package-lock.json) MUST be committed
- **System Services**: Containerize with Docker for reproducibility

---

## II. Coding Standards

### 2.1 General Principles
- **DRY (Don't Repeat Yourself)**: Abstract common patterns into reusable functions/modules
- **KISS (Keep It Simple, Stupid)**: Prefer simple, readable solutions over clever code
- **YAGNI (You Aren't Gonna Need It)**: Don't implement features until they're required
- **Code Reviews**: All production code requires review (human or AI agent)

### 2.2 Naming Conventions
- **Files**: `snake_case` for Python, `kebab-case` for configs, `PascalCase` for TypeScript components
- **Functions/Methods**: `snake_case` for Python, `camelCase` for JavaScript/TypeScript
- **Classes**: `PascalCase` for all languages
- **Constants**: `UPPER_SNAKE_CASE` for all languages
- **Private Members**: Prefix with `_` (Python) or `#` (JavaScript)

### 2.3 Documentation Requirements
- **Functions**: Document purpose, parameters, return values, and exceptions
- **Classes**: Document responsibility, public interface, and usage examples
- **Modules**: Include module-level docstring explaining purpose
- **APIs**: Maintain OpenAPI/Swagger specifications for all REST APIs
- **Architecture**: Keep `memory/` folder updated with major architectural decisions

### 2.4 Error Handling
- **Fail Fast**: Validate inputs early, raise exceptions immediately on invalid state
- **Specific Exceptions**: Use specific exception types, never bare `except:` clauses
- **Logging**: Log all exceptions with context (user ID, request ID, timestamp)
- **User-Facing Errors**: Never expose stack traces or internal details to end users

---

## III. Security Principles

### 3.1 Authentication & Authorization
- **Authentication Required**: All API endpoints MUST require authentication unless explicitly public
- **Least Privilege**: Users and services receive minimum permissions necessary
- **Token Security**: Use short-lived JWT tokens, refresh tokens stored securely
- **Session Management**: Implement timeout, secure cookie flags (HttpOnly, Secure, SameSite)

### 3.2 Data Protection
- **Encryption in Transit**: TLS 1.3+ for all network communication
- **Encryption at Rest**: Sensitive data encrypted in databases and file storage
- **PII Handling**: Personal Identifiable Information follows GDPR/privacy regulations
- **Data Retention**: Implement clear retention policies, automatic purging of old data

### 3.3 Input Validation
- **Validate All Inputs**: Never trust user input, validate on server side
- **Sanitization**: Sanitize inputs before storage or display
- **SQL Injection Prevention**: Use parameterized queries or ORMs exclusively
- **XSS Prevention**: Escape all user-generated content in HTML contexts
- **CSRF Protection**: Implement CSRF tokens for state-changing operations

### 3.4 Dependency Security
- **Audit Regularly**: Run `npm audit`, `pip-audit`, or equivalents weekly
- **Update Promptly**: Security patches applied within 48 hours of disclosure
- **Minimal Dependencies**: Only include necessary dependencies, review licenses
- **Lock Files**: Commit lock files to prevent supply chain attacks

### 3.5 Secrets Management
- **Never Commit**: `.env` files, API keys, credentials NEVER committed to git
- **Git History**: If secrets leaked, rotate immediately and clean git history
- **Secret Rotation**: Implement automated secret rotation for production systems
- **Access Control**: Secrets accessible only to authorized services/personnel

---

## IV. Testing Standards

### 4.1 Test Coverage
- **Minimum Coverage**: 80% code coverage for production code
- **Critical Paths**: 100% coverage for authentication, payment, data modification
- **Test Types**: Unit tests, integration tests, end-to-end tests as appropriate

### 4.2 Test Organization
- **Mirror Source Structure**: Test directory structure mirrors `src/` structure
- **Naming**: Test files named `test_<module>.py` or `<module>.test.ts`
- **Test Data**: Use fixtures and factories, never production data

### 4.3 Continuous Integration
- **Pre-Commit Hooks**: Run linters and formatters on commit
- **CI Pipeline**: Tests run on every pull request
- **Deployment Gates**: All tests must pass before deployment

---

## V. Performance Standards

### 5.1 Response Times
- **API Endpoints**: < 200ms for p95, < 500ms for p99
- **Database Queries**: < 100ms for simple queries, indexed appropriately
- **Frontend**: First Contentful Paint < 1.5s, Time to Interactive < 3.5s

### 5.2 Resource Usage
- **Memory**: Monitor and prevent memory leaks
- **CPU**: Profile and optimize hot paths
- **Database Connections**: Use connection pooling, close connections properly
- **File Handles**: Always close files, use context managers

### 5.3 Scalability
- **Stateless Services**: Design services to be horizontally scalable
- **Caching**: Implement caching for expensive operations (Redis, CDN)
- **Async Processing**: Use message queues for long-running tasks
- **Database Design**: Proper indexing, query optimization, read replicas

---

## VI. Monitoring & Observability

### 6.1 Logging
- **Structured Logging**: JSON format with consistent fields (timestamp, level, service, message)
- **Log Levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL used appropriately
- **Sensitive Data**: Never log passwords, tokens, or PII
- **Retention**: Logs retained for minimum 30 days

### 6.2 Metrics
- **Business Metrics**: Track key business KPIs (signups, conversions, revenue)
- **Technical Metrics**: Track errors, latency, throughput, resource usage
- **Prometheus**: All services expose Prometheus metrics endpoints
- **Grafana Dashboards**: Maintain dashboards for each service

### 6.3 Alerting
- **Alert on Symptoms**: Alert on user-facing issues, not just internal metrics
- **Actionable Alerts**: Every alert must have a runbook or clear action
- **Alert Fatigue**: Tune alerts to prevent noise, remove non-actionable alerts

### 6.4 Tracing
- **Distributed Tracing**: Implement request tracing across services
- **Correlation IDs**: Pass correlation IDs through entire request chain
- **Performance Profiling**: Regular profiling to identify bottlenecks

---

## VII. Deployment & DevOps

### 7.1 Version Control
- **Git Flow**: Use feature branches, pull requests, protected main branch
- **Commit Messages**: Conventional Commits format (feat:, fix:, docs:, etc.)
- **Atomic Commits**: Each commit should be a single logical change
- **Code Review**: All changes reviewed before merge

### 7.2 Deployment Strategy
- **Automated Deployments**: Use CI/CD for all deployments
- **Blue-Green/Canary**: Zero-downtime deployments for production
- **Rollback Plan**: Every deployment must have documented rollback procedure
- **Database Migrations**: Backward-compatible migrations, separate deploy step

### 7.3 Environment Parity
- **Dev/Staging/Prod**: Maintain environment parity to prevent "works on my machine"
- **Infrastructure as Code**: Use Terraform, Ansible, or Docker Compose
- **Configuration Drift**: Prevent drift through automation and auditing

### 7.4 Backup & Recovery
- **Automated Backups**: Daily backups for databases and critical data
- **Backup Testing**: Quarterly restore tests to verify backup integrity
- **Disaster Recovery**: Documented DR plan, tested annually
- **Data Retention**: Clear policies for backup retention (7 daily, 4 weekly, 12 monthly)

---

## VIII. AI & LLM Integration

### 8.1 Model Selection
- **Right Tool for Job**: Choose models based on task (local Ollama for speed, Claude for reasoning)
- **Cost Optimization**: Use smaller models where possible, cache results
- **Fallback Strategy**: Implement fallbacks when primary model unavailable

### 8.2 Context Management
- **Token Limits**: Respect model context limits, implement chunking strategies
- **Context Relevance**: Include only relevant context, prune unnecessary information
- **Memory Systems**: Use `memory/` folder for long-term project knowledge

### 8.3 MCP Servers
- **Standardized Integration**: Use Model Context Protocol for tool integration
- **Error Handling**: Graceful degradation when MCP servers unavailable
- **Security**: Validate and sanitize all MCP server inputs/outputs

---

## IX. Documentation Requirements

### 9.1 Project Documentation
- **README.md**: Quick start, installation, basic usage
- **CLAUDE.md**: How to work with Claude on this specific project
- **roadmap.md**: Current status, planned features, known issues
- **CHANGELOG.md**: Version history, breaking changes, migration guides

### 9.2 Architecture Documentation
- **memory/constitution.md**: This document - architectural principles
- **memory/project-checklist.md**: Project-specific tool and agent configuration
- **memory/context-management.md**: Context handling strategies
- **memory/coding-standards.md**: Language-specific coding standards

### 9.3 API Documentation
- **OpenAPI Specs**: Maintain OpenAPI 3.0+ specifications
- **Examples**: Provide example requests and responses
- **Authentication**: Document authentication requirements clearly
- **Versioning**: API version strategy documented

---

## X. Non-Negotiable Rules

### 10.1 Absolute Requirements
1. **No Secrets in Git**: Automatic failure if secrets detected in commits
2. **Tests Must Pass**: Cannot merge or deploy if tests fail
3. **Security Audits**: Monthly dependency security audits required
4. **Code Review**: No direct commits to main/master branch
5. **Backup Verification**: Quarterly backup restore tests mandatory

### 10.2 Breaking the Rules
- **Exception Process**: Architectural exceptions require documented approval
- **Technical Debt**: Temporary violations must have tickets for remediation
- **Post-Mortem**: Security or availability incidents require post-mortem

---

## XI. Continuous Improvement

### 11.1 Constitution Updates
- **Living Document**: Constitution updated quarterly or after major learnings
- **Community Input**: Team/community proposals for improvements welcome
- **Version Control**: Constitution changes follow same git workflow as code

### 11.2 Learning from Incidents
- **Blameless Post-Mortems**: Focus on systems, not individuals
- **Action Items**: Every incident generates improvement tasks
- **Pattern Recognition**: Update constitution when patterns emerge

### 11.3 Tool and Practice Evolution
- **Stay Current**: Review and adopt best practices from Claude docs, LLM news
- **Experiment Safely**: Test new tools in non-production environments first
- **Share Knowledge**: Document learnings in `memory/` and `docs/`

---

## Appendix: Enforcement

This constitution is enforced through:
- **Pre-commit hooks**: Automated linting, formatting, secret detection
- **CI/CD pipelines**: Tests, security scans, coverage checks
- **Code review**: Human and AI agent review processes
- **Monitoring**: Automated alerts for security and performance violations
- **Quarterly audits**: Manual review of compliance with principles

**Version**: 1.0
**Last Updated**: 2025-11-20
**Maintainer**: Meta-Env Project
**Review Cycle**: Quarterly or after major incidents
