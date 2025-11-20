# Project Checklist - Adaptive Agent Configuration

## Purpose

This document provides a **smart decision tree** for Claude Code to automatically determine which agents, skills, MCP servers, and tools to activate based on project type, structure, and requirements. This ensures optimal resource usage and context efficiency.

---

## I. Project Type Detection

Claude Code should analyze the project structure and activate appropriate configurations:

### 1.1 Web Frontend Project
**Detection Signals**:
- [ ] `package.json` with React/Vue/Angular/Svelte dependencies
- [ ] `src/components/` or `src/pages/` directories
- [ ] Tailwind/SCSS/CSS configuration files
- [ ] `public/` or `static/` directories

**Auto-Activate**:
- **Skills**: `react-best-practices`, `tailwind-skill`, `component-design`
- **MCP Servers**: `filesystem`, `github`
- **Tools**: ESLint, Prettier, Vite/Webpack
- **Agents**: `accessibility-auditor`, `performance-optimizer`

### 1.2 Backend API Project
**Detection Signals**:
- [ ] `app.py`, `main.py`, `server.js`, `index.ts` with API frameworks
- [ ] `routes/` or `api/` directories
- [ ] Database configuration files
- [ ] API documentation (OpenAPI/Swagger)

**Auto-Activate**:
- **Skills**: `api-design-skill`, `database-skill`, `security-audit`
- **MCP Servers**: `filesystem`, `database`, `github`
- **Tools**: API testing tools (Postman collections), DB migration tools
- **Agents**: `security-auditor`, `api-documentation-writer`

### 1.3 Full-Stack Application
**Detection Signals**:
- [ ] Both frontend and backend structure
- [ ] `client/` and `server/` or `frontend/` and `backend/` directories
- [ ] Monorepo structure (lerna, nx, turborepo)

**Auto-Activate**:
- **Skills**: All frontend + backend skills
- **MCP Servers**: `filesystem`, `database`, `github`
- **Tools**: Full stack testing framework
- **Agents**: `full-stack-coordinator`, `integration-tester`

### 1.4 AI/ML Project
**Detection Signals**:
- [ ] `requirements.txt` with ML libraries (tensorflow, pytorch, sklearn)
- [ ] `notebooks/` directory with Jupyter notebooks
- [ ] `models/` directory for trained models
- [ ] `data/` directory for datasets

**Auto-Activate**:
- **Skills**: `ollama-integration`, `model-training`, `data-pipeline`
- **MCP Servers**: `filesystem`, `prometheus`, `ollama`
- **Tools**: MLflow, Weights & Biases integrations
- **Agents**: `model-optimizer`, `data-scientist`
- **Monitoring**: GPU metrics, model performance tracking

### 1.5 DevOps/Infrastructure Project
**Detection Signals**:
- [ ] `docker-compose.yml`, `Dockerfile`
- [ ] Kubernetes manifests (`k8s/`, `*.yaml` with deployments)
- [ ] Terraform/Ansible/CloudFormation files
- [ ] CI/CD configuration (`.github/workflows/`, `.gitlab-ci.yml`)

**Auto-Activate**:
- **Skills**: `deployment-skill`, `monitoring-skill`, `container-optimization`
- **MCP Servers**: `filesystem`, `github`, `prometheus`
- **Tools**: Docker, kubectl, terraform
- **Agents**: `infrastructure-auditor`, `security-scanner`

### 1.6 Data Engineering Project
**Detection Signals**:
- [ ] ETL/ELT pipeline code
- [ ] `dbt/` directory for data transformations
- [ ] Apache Airflow/Prefect DAGs
- [ ] Data warehouse configurations

**Auto-Activate**:
- **Skills**: `data-pipeline-skill`, `database-optimization`
- **MCP Servers**: `filesystem`, `database`, `prometheus`
- **Tools**: dbt, data quality validators
- **Agents**: `data-quality-auditor`, `pipeline-optimizer`

---

## II. Required MCP Servers by Context

### 2.1 Always Active
- **filesystem**: Core functionality for reading/writing project files
- **github**: If `.git/` directory detected

### 2.2 Conditional Activation

#### Database Server
**Activate When**:
- [ ] `database/` folder exists
- [ ] Database config files detected (`knexfile.js`, `alembic.ini`)
- [ ] ORM configuration (SQLAlchemy, Prisma, TypeORM)

**Configuration**:
```json
{
  "database": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-database"],
    "env": { "DATABASE_URL": "${DATABASE_URL}" }
  }
}
```

#### Prometheus Server
**Activate When**:
- [ ] `monitoring/` folder exists
- [ ] `prometheus.yml` file detected
- [ ] AI/ML project with model monitoring needs

**Configuration**:
```json
{
  "prometheus": {
    "command": "node",
    "args": ["./mcp-servers/prometheus-server.js"]
  }
}
```

#### Custom API Server
**Activate When**:
- [ ] External API integration required
- [ ] `mcp-servers/custom-api-server.json` exists

---

## III. Skills Activation Logic

### 3.1 File Pattern Based Activation

**React Components Detected** (`src/**/*.tsx`, `src/**/*.jsx`):
- Load: `react-best-practices`
- Load: `component-architecture`
- Load: `react-testing-library`

**API Routes Detected** (`routes/`, `api/`, `controllers/`):
- Load: `api-security-checklist`
- Load: `rest-best-practices`
- Load: `api-testing`

**Dockerfile Detected**:
- Load: `container-optimization`
- Load: `docker-security`
- Load: `multi-stage-builds`

**Test Files Detected** (`tests/`, `__tests__/`, `*.test.*`):
- Load: `test-best-practices`
- Load: `coverage-improvement`

**Database Migrations** (`migrations/`, `alembic/`):
- Load: `database-migration-safety`
- Load: `backward-compatibility`

### 3.2 Complexity Based Activation

**Lines of Code Thresholds**:
- **< 500 LOC**: Minimal tooling, single-agent mode
- **500-2000 LOC**: Activate documentation writer, basic linting
- **2000-10000 LOC**: Activate performance optimizer, security auditor
- **> 10000 LOC**: Full multi-agent coordination, advanced monitoring

**File Count Thresholds**:
- **< 20 files**: Single agent, basic skills
- **20-100 files**: Multi-agent for parallel review
- **> 100 files**: Dedicated agents per module/domain

---

## IV. Subagent Spawning Strategy

### 4.1 Always Spawn (for production projects)
- **Documentation Writer**: Maintains README, API docs, CHANGELOG
- **Test Coverage Guardian**: Ensures 80%+ coverage, writes missing tests

### 4.2 Conditional Spawning

#### Security Auditor
**Spawn When**:
- [ ] Production deployment detected
- [ ] Environment has `PRODUCTION` or `PROD` variables
- [ ] User authentication/authorization code present
- [ ] Payment processing detected

**Responsibilities**:
- Scan for SQL injection, XSS, CSRF vulnerabilities
- Review dependency security (npm audit, pip-audit)
- Validate secret management
- Check for hardcoded credentials

#### Performance Optimizer
**Spawn When**:
- [ ] Project > 1000 LOC
- [ ] `monitoring/` folder exists
- [ ] User reports performance issues
- [ ] Prometheus metrics show degradation

**Responsibilities**:
- Profile hot paths
- Optimize database queries
- Implement caching strategies
- Review bundle sizes (frontend)

#### Infrastructure Specialist
**Spawn When**:
- [ ] `docker-compose.yml` or Kubernetes manifests exist
- [ ] CI/CD configuration present
- [ ] Multi-environment setup (dev/staging/prod)

**Responsibilities**:
- Optimize container images
- Review deployment strategies
- Ensure environment parity
- Setup monitoring and alerting

#### Accessibility Auditor
**Spawn When**:
- [ ] Frontend project detected
- [ ] Public-facing web application
- [ ] ARIA attributes or accessibility imports found

**Responsibilities**:
- Validate WCAG compliance
- Check keyboard navigation
- Review screen reader compatibility
- Test color contrast ratios

---

## V. Context Management Strategy

### 5.1 Git Worktree Usage

**Use Worktrees When**:
- [ ] Parallel feature development (2+ features simultaneously)
- [ ] Hotfix needed while feature branch in progress
- [ ] Testing multiple approaches to same problem
- [ ] Long-running refactoring alongside bug fixes

**Naming Convention**:
```
/var/www/projects/my-project/
├─ main/                 # Main worktree
├─ feature-auth/         # Feature: authentication
├─ feature-payments/     # Feature: payments
├─ hotfix-security/      # Hotfix: security patch
└─ refactor-api/         # Refactor: API redesign
```

### 5.2 Context Splitting

**Split Context When**:
- [ ] Conversation > 50 messages
- [ ] Working on unrelated feature
- [ ] Claude seems to forget earlier context
- [ ] Need to archive completed work

**Archive Strategy**:
- Create `memory/archive/YYYY-MM/` directories
- Move completed feature discussions
- Summarize key decisions in main memory docs

### 5.3 Skill Granularity

**Keep Skills Under 500 Lines**:
- If skill grows too large, split into sub-skills
- Reference external files instead of embedding
- Use includes/imports where supported

**Example**:
```markdown
# Python Best Practices Skill

See detailed guides:
- [Python Testing](./python-testing.md)
- [Python Performance](./python-performance.md)
- [Python Security](./python-security.md)
```

---

## VI. Tool Selection Matrix

### 6.1 Language-Specific Tools

**Python Projects**:
- **Linting**: ruff (fast), pylint (comprehensive)
- **Formatting**: black, isort
- **Type Checking**: mypy, pyright
- **Testing**: pytest, hypothesis
- **Dependency Management**: poetry, pip-tools

**JavaScript/TypeScript Projects**:
- **Linting**: ESLint with recommended configs
- **Formatting**: Prettier
- **Type Checking**: TypeScript strict mode
- **Testing**: Vitest (modern), Jest (legacy)
- **Build**: Vite (SPA), Next.js (SSR)

**Rust Projects**:
- **Linting**: clippy
- **Formatting**: rustfmt
- **Testing**: cargo test
- **Documentation**: cargo doc

### 6.2 Deployment Tools

**Choose Based On**:

| Tool | Project Size | Team Size | Complexity | Best For |
|------|--------------|-----------|------------|----------|
| **Dokku** | Small | 1-3 | Low | Simple apps, single server |
| **CapRover** | Medium | 3-10 | Medium | Multi-app, easy scaling |
| **Coolify** | Medium-Large | 5-20 | Medium | Docker-compose projects |
| **Dokploy** | Large | 10+ | High | Advanced routing, RBAC |
| **Kubernetes** | Enterprise | 20+ | Very High | Microservices, high availability |

---

## VII. Monitoring Activation

### 7.1 Prometheus Metrics

**Always Collect**:
- HTTP request rate, latency, error rate
- Process CPU/memory usage
- Database connection pool status

**Conditionally Collect**:
- **AI/ML Projects**: Model inference time, GPU utilization, batch processing throughput
- **API Projects**: Endpoint-specific latency, rate limiting metrics
- **Queue Workers**: Queue depth, job processing time, failure rate

### 7.2 Grafana Dashboards

**Auto-Generate Dashboards For**:
- [ ] Service overview (golden signals: latency, traffic, errors, saturation)
- [ ] Database performance (query time, connection pool, slow queries)
- [ ] AI/ML models (inference time, accuracy, drift detection)
- [ ] Infrastructure (CPU, memory, disk, network)

### 7.3 Alerting Rules

**Critical Alerts** (immediate action):
- Error rate > 5% for 5 minutes
- P99 latency > 1s for 10 minutes
- Database connection pool > 90% for 5 minutes
- Disk usage > 90%

**Warning Alerts** (investigate):
- Error rate > 1% for 15 minutes
- Memory usage > 80% for 30 minutes
- Test coverage drops below 80%

---

## VIII. Decision Tree Example

```
START: New project detected in /var/www/projects/my-app/

1. Scan directory structure
   ├─ Found: package.json with "react"
   ├─ Found: src/components/
   ├─ Found: .github/workflows/
   └─ Found: docker-compose.yml

2. Classify: Full-Stack Web App + DevOps

3. Activate MCP Servers:
   ├─ ✓ filesystem (always)
   ├─ ✓ github (git detected)
   └─ ✓ database (docker-compose has postgres service)

4. Load Skills:
   ├─ ✓ react-best-practices (React components found)
   ├─ ✓ api-security-checklist (API routes detected)
   ├─ ✓ docker-optimization (Dockerfile found)
   └─ ✓ ci-cd-best-practices (GitHub Actions found)

5. Count files: 243 files, ~8,500 LOC

6. Spawn Subagents:
   ├─ ✓ Documentation Writer (always for production)
   ├─ ✓ Security Auditor (production project)
   ├─ ✓ Performance Optimizer (> 1000 LOC)
   └─ ✓ Accessibility Auditor (frontend project)

7. Setup Monitoring:
   ├─ ✓ Prometheus metrics (monitoring/ folder exists)
   ├─ ✓ Grafana dashboard template
   └─ ✓ Alert rules (production project)

8. Context Strategy:
   ├─ ✓ Medium project size → standard context
   ├─ ✓ Enable worktrees (multiple features expected)
   └─ ✓ Weekly archive to memory/archive/

READY: Configuration complete, begin development
```

---

## IX. Manual Overrides

### 9.1 Override File

Create `.claude/project-config.json` to override auto-detection:

```json
{
  "projectType": "ai-ml",
  "forceActivate": {
    "mcpServers": ["prometheus", "custom-ml-server"],
    "skills": ["model-training", "data-pipeline"],
    "agents": ["model-optimizer", "data-quality-auditor"]
  },
  "forceDeactivate": {
    "agents": ["accessibility-auditor"]
  },
  "monitoring": {
    "prometheus": true,
    "grafana": true,
    "customDashboards": ["gpu-metrics", "model-performance"]
  }
}
```

### 9.2 Temporary Overrides

Use `.envrc` for session-specific overrides:

```bash
# .envrc
export CLAUDE_FORCE_SKILL="debugging-mode"
export CLAUDE_DISABLE_AGENTS="performance-optimizer"
```

---

## X. Checklist Maintenance

### 10.1 Regular Updates

- **Weekly**: Review if auto-activation matches project needs
- **Monthly**: Update based on new Claude Code features
- **Quarterly**: Align with latest LLM best practices

### 10.2 Feedback Loop

When Claude makes suboptimal choices:
1. Document the scenario
2. Update detection signals
3. Test on similar projects
4. Commit updated checklist

---

## Appendix: Quick Reference

### Project Type → Configuration Mapping

| Project Type | MCP Servers | Key Skills | Primary Agents |
|--------------|-------------|------------|----------------|
| **Frontend** | filesystem, github | react-best-practices, tailwind | accessibility, performance |
| **Backend API** | filesystem, database, github | api-design, security-audit | security, documentation |
| **Full-Stack** | filesystem, database, github | All frontend + backend | full-stack-coordinator, integration-tester |
| **AI/ML** | filesystem, prometheus, ollama | ollama-integration, model-training | model-optimizer, data-scientist |
| **DevOps** | filesystem, github, prometheus | deployment, monitoring | infrastructure-auditor, security-scanner |
| **Data Engineering** | filesystem, database, prometheus | data-pipeline, dbt | data-quality-auditor, pipeline-optimizer |

---

**Version**: 1.0
**Last Updated**: 2025-11-20
**Review Cycle**: Monthly
**Auto-Update**: Pulls latest recommendations from Claude docs quarterly
