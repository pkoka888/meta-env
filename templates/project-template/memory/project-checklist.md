# Project Checklist - Adaptive Agent Configuration

## Project Type Detection

Based on the files in `src/`, determine the project type:

- [ ] **Web App (Frontend)** → Activate: `react-skill`, `tailwind-skill`, `ui-testing-skill`
- [ ] **Backend API** → Activate: `api-design-skill`, `database-skill`, `security-skill`
- [ ] **AI/ML Project** → Activate: `ollama-integration`, `rag-skill`, `model-evaluation-skill`
- [ ] **DevOps/Infrastructure** → Activate: `deployment-skill`, `monitoring-skill`, `docker-skill`
- [ ] **Full Stack** → Activate: Combination of above

## Required MCP Servers

Auto-activate based on project structure:

- [x] **filesystem** - Always active (src/, tests/, docs/)
- [ ] **github** - If `.git` directory exists
- [ ] **database** - If `database/` or `migrations/` folder exists
- [ ] **prometheus** - If `monitoring/` folder exists
- [ ] **slack** - If team collaboration is configured

## Active Skills

Skills to load based on detected files:

### Frontend Development
- React components (*.jsx, *.tsx) → Load `react-best-practices`
- Tailwind classes → Load `tailwind-optimization`
- UI tests → Load `component-testing`

### Backend Development
- API routes → Load `api-security-checklist`
- Database models → Load `database-optimization`
- Background jobs → Load `async-task-management`

### DevOps
- Dockerfile → Load `container-optimization`
- docker-compose.yml → Load `service-orchestration`
- CI/CD configs → Load `deployment-automation`

### AI/ML
- Ollama usage → Load `local-llm-best-practices`
- RAG implementation → Load `rag-optimization`
- AutoGen agents → Load `multi-agent-coordination`

## Sub-Agents to Spawn

Spawn specialized agents based on context:

### Always Active
- [x] **Documentation Writer** - Keeps docs up to date

### Conditional
- [ ] **Security Auditor** - If production deployment or security-sensitive code
- [ ] **Performance Optimizer** - If >1000 lines of code or performance issues detected
- [ ] **Test Generator** - If test coverage < 80%
- [ ] **Database Expert** - If complex queries or schema changes
- [ ] **API Designer** - If new endpoints being created

## Context Management Strategy

### Project Size
- **Small (<500 LOC)**: Single conversation thread
- **Medium (500-2000 LOC)**: Feature-based threads
- **Large (>2000 LOC)**: Module-based threads + architecture overview

### Memory Management
- Keep active conversation < 50 messages
- Archive completed features to `memory/archive/`
- Maintain `memory/constitution.md` for long-term decisions
- Update this checklist as project evolves

## Monitoring and Observability

Check if monitoring is needed:

- [ ] **Prometheus** - For metrics collection
- [ ] **Grafana** - For visualization
- [ ] **Logging** - Structured JSON logs
- [ ] **Alerting** - Critical error notifications

## Development Workflow

### Pre-Commit Checks
- [ ] Tests pass (`pytest` or `npm test`)
- [ ] Linting passes (flake8, eslint)
- [ ] Formatting applied (black, prettier)
- [ ] Type checking (mypy, tsc)

### Before Deployment
- [ ] All tests pass
- [ ] Security audit completed
- [ ] Performance benchmarks acceptable
- [ ] Documentation updated
- [ ] Environment variables configured

## LLM Configuration

Choose appropriate models based on task:

### Code Generation
- **Primary**: Claude Sonnet 4 (via Anthropic or OpenRouter)
- **Autocomplete**: Qwen 2.5 Coder 7B (local Ollama)
- **Embeddings**: nomic-embed-text (local Ollama)

### Task-Specific
- **Research**: Claude Sonnet 4 (needs web access)
- **Quick edits**: DeepSeek R1 7B (local, fast)
- **Testing**: Claude Sonnet 4 (comprehensive test cases)
- **Documentation**: Local Ollama (cost-effective)

## Project-Specific Notes

Add project-specific guidelines here:

### Example:
- Always use TypeScript for new frontend code
- Database migrations must be reviewed by DBA
- API changes require version bump
- Security changes need two-person review

---

**Last Updated**: [Date]
**Next Review**: [Date + 1 month]
