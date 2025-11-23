# Working with Claude Code on This Project

## Project Context

This project uses an AI-boosted development environment with Claude Code, Cline, and Continue.dev.

## Getting Started

1. **Read the Constitution**: Start with `memory/constitution.md` for non-negotiable architectural rules
2. **Check the Checklist**: Review `memory/project-checklist.md` to understand active skills and agents
3. **Follow Standards**: Adhere to `memory/coding-standards.md` for code style

## Active MCP Servers

- **filesystem**: Access to src/, tests/, and docs/
- **github**: GitHub API integration
- Add more as needed in `.claude/config.json`

## Skills

Skills are auto-activated based on the task:

- **Research**: When analyzing or comparing solutions
- **Testing**: When writing or fixing tests
- **Deployment**: When deploying or configuring infrastructure

See `.claude/skills/` for available skills.

## Best Practices

### Context Management

- Keep conversations focused on specific features or bugs
- Use git worktrees for parallel feature development
- Archive completed discussions to `memory/archive/`

### File Organization

- Source code: `src/`
- Tests: `tests/`
- Documentation: `docs/`
- Configuration: root and config directories

### Prompting Guidelines

1. **Be Specific**: Mention file paths, function names, or specific requirements
2. **Provide Context**: Reference related files or previous decisions
3. **Set Constraints**: Specify performance requirements, compatibility needs, etc.

## Multi-Agent Coordination

For complex tasks, Claude can:

1. Spawn specialized sub-agents (security, performance, documentation)
2. Coordinate parallel work streams
3. Aggregate results and maintain consistency

See `docs/parallel-plans.md` for coordination strategies.

## Memory Management

- **Short-term**: Current conversation
- **Medium-term**: Skills and command files
- **Long-term**: Constitution, standards, architecture docs
- **Archive**: Completed features, old decisions

## Monitoring

Claude can read metrics from:

- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

Use these to identify performance issues or system health.

## Deployment

For deployment tasks:

1. Review `docs/DEPLOYMENT.md`
2. Ensure tests pass
3. Check environment variables
4. Verify monitoring is working

## Tips

- Use `/skills` to see available skills
- Reference `project-checklist.md` regularly
- Keep context documents up to date
- Archive old conversations monthly
