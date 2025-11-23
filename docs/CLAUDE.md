# Working with Claude on Meta-Env

Prompting conventions, best practices, and workflow guidelines for AI-assisted development on the meta-env project.

---

## Table of Contents

1. [Core Principles](#core-principles)
2. [Prompting Conventions](#prompting-conventions)
3. [Context Management](#context-management)
4. [Skill System](#skill-system)
5. [Subagent Coordination](#subagent-coordination)
6. [Common Workflows](#common-workflows)
7. [Best Practices](#best-practices)

---

## Core Principles

### 1. Explicit is Better Than Implicit
Always provide clear, specific instructions. Claude performs best when given:
- Exact file paths (prefer absolute over relative)
- Specific goals and success criteria
- Context about project architecture
- Constraints and requirements

**Good:**
```
Review the authentication logic in /home/user/meta-env/src/auth/middleware.py
and check for security vulnerabilities. Focus on JWT validation and CORS configuration.
```

**Bad:**
```
Check the auth stuff for issues.
```

### 2. Reference Project Memory
Before starting complex tasks, remind Claude to check:
- `/home/user/meta-env/memory/constitution.md` - Architectural rules
- `/home/user/meta-env/docs/roadmap.md` - Current priorities
- `/home/user/meta-env/project-checklist.md` - Active skills and agents

### 3. Use Skills for Repeated Tasks
Don't repeat the same instructions multiple times. Create or reference skills:
- Research tasks → Use `research` skill
- Testing → Use `testing` skill
- Deployment → Use `deployment` skill

---

## Prompting Conventions

### Starting a New Session

**Template:**
```
I'm working on [feature/bug/task] for the meta-env project.

Context:
- Goal: [specific objective]
- Relevant files: [list files]
- Constraints: [any limitations]
- Success criteria: [how to know it's done]

Please review memory/constitution.md and project-checklist.md to understand
the project context, then [specific first step].
```

### Requesting Research

**Template:**
```
Research [topic] for the meta-env project.

Requirements:
- Compare [option A] vs [option B] vs [option C]
- Consider: performance, cost, developer experience, community support
- Output: markdown report in docs/research-templates/[topic-name].md

Use the competitive-analysis.md template structure.
```

### Code Review Requests

**Template:**
```
Review [file/feature] for:
- Security vulnerabilities
- Performance issues
- Code style compliance (check memory/coding-standards.md)
- Test coverage

Spawn security-auditor subagent if needed.
```

---

## Context Management

### Keeping Context Fresh

**Daily Workflow:**
1. Start session with: "Review today's priority from roadmap.md"
2. Keep conversations focused on single features/bugs
3. Archive completed feature discussions to `memory/archive/[YYYY-MM]/`
4. Use git worktrees for parallel work to isolate contexts

### Context Size Optimization

**When context gets large (>100K tokens):**
- Split work into subtasks
- Create new terminal/worktree for each task
- Extract reusable patterns into skills
- Reference files instead of pasting code

**Good:**
```
Review the authentication implementation in src/auth/ and suggest improvements
based on the security best practices in memory/constitution.md.
```

**Bad:**
```
[Paste entire 5000-line auth.py file]
```

### Using Git Worktrees

```bash
# Create worktree for parallel feature
git worktree add ../meta-env-feature-auth feature/auth-improvements

# Open in new Claude session
code ../meta-env-feature-auth

# Each worktree has isolated context
```

---

## Skill System

### Auto-Activation

Claude will automatically activate skills based on `project-checklist.md`:

| Trigger | Skill Activated |
|---------|----------------|
| "research X" | `research` skill |
| "create API for X" | `api-design` skill |
| "deploy to staging" | `deployment` skill |
| "write tests for X" | `testing` skill |
| "optimize performance" | `performance-optimizer` subagent |

### Manual Skill Invocation

```
Activate [skill-name] skill and [specific task].
```

Example:
```
Activate research skill and compare Redis vs Dragonfly for our caching layer.
Output to docs/research-templates/cache-comparison.md.
```

### Creating New Skills

Skills should be:
- **Focused**: One clear purpose
- **Reusable**: Work across multiple projects
- **Documented**: Clear activation criteria
- **Concise**: <500 lines of instructions

**Skill Template:**
```markdown
---
description: "Brief description of what this skill does"
triggers: ["keyword1", "keyword2"]
---

# Skill Name

## When to Activate
[Conditions for activation]

## Prerequisites
[Required files, tools, or context]

## Workflow
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Output Format
[Expected deliverables]

## Tools Used
- [Tool 1]
- [Tool 2]
```

---

## Subagent Coordination

### Available Subagents

| Agent | Purpose | When to Spawn |
|-------|---------|---------------|
| `security-auditor` | Code security review | Production deployments, auth changes |
| `performance-optimizer` | Performance analysis | >1000 LOC, API endpoints |
| `documentation-writer` | Technical documentation | New features, API changes |
| `test-generator` | Test creation | New features, bug fixes |

### Spawning Subagents

**Template:**
```
Spawn [agent-name] subagent to [specific task] while I continue with [main task].

Subagent context:
- Files to review: [list]
- Output: [deliverable]
- Report back when: [completion criteria]
```

**Example:**
```
Spawn security-auditor subagent to review src/auth/ for vulnerabilities
while I continue implementing the API endpoints.

Security focus:
- JWT validation
- CORS configuration
- SQL injection prevention

Report findings in docs/security-audit-[date].md.
```

### Parallel Work with Multiple Agents

See [parallel-plans.md](./parallel-plans.md) for detailed strategies on multi-agent coordination.

---

## Common Workflows

### 1. Adding a New Feature

```
Feature Request: [feature name]

Steps:
1. Review roadmap.md to ensure alignment with project goals
2. Research alternatives (if applicable) using research skill
3. Create feature implementation plan
4. Implement with TDD approach (tests first)
5. Spawn documentation-writer subagent for docs
6. Spawn security-auditor for review
7. Update roadmap.md with completion status
```

### 2. Debugging Production Issue

```
Production Issue: [brief description]

Context:
- Environment: [prod/staging/dev]
- Error logs: [paste relevant logs]
- Monitoring data: [Grafana/Prometheus metrics]

Steps:
1. Analyze logs and metrics
2. Reproduce in local environment
3. Identify root cause
4. Implement fix with tests
5. Deploy to staging for verification
6. Update monitoring/alerting if needed
```

### 3. Research and Decision Making

```
Research Topic: [technology/approach to evaluate]

Use research skill to:
1. Compare alternatives using tech-stack-evaluation.md template
2. Consider: performance, cost, learning curve, community support
3. Provide recommendation with pros/cons
4. Update roadmap.md if decision impacts timeline
```

### 4. Code Refactoring

```
Refactor Target: [file/module to refactor]

Requirements:
- Maintain backward compatibility
- Improve performance by [metric]
- Follow coding-standards.md
- 100% test coverage maintained

Steps:
1. Add tests for current behavior
2. Refactor incrementally
3. Run tests after each change
4. Spawn performance-optimizer to validate improvements
5. Update documentation
```

---

## Best Practices

### Do's ✅

- **Read project memory first**: Check constitution.md and roadmap.md before major changes
- **Use git worktrees**: For parallel feature development
- **Spawn subagents**: For review, testing, documentation tasks
- **Archive old context**: Move completed conversations to memory/archive/
- **Update roadmap**: Mark items complete and add new discoveries
- **Create skills**: For tasks you'll repeat across projects
- **Reference files**: Use file paths instead of copying large code blocks
- **Be specific**: Provide exact requirements and success criteria

### Don'ts ❌

- **Don't skip project-checklist.md**: It configures active skills and agents
- **Don't mix unrelated tasks**: Keep conversations focused
- **Don't paste entire files**: Reference them by path
- **Don't ignore constitution.md**: Architectural rules are non-negotiable
- **Don't create duplicate skills**: Check existing skills first
- **Don't let context grow unbounded**: Archive and split regularly
- **Don't skip tests**: TDD approach required for production code
- **Don't deploy without security review**: Always spawn security-auditor for prod changes

---

## Model Configuration

### Primary Model
- **Claude Sonnet 4**: Main development assistance
- **Use for**: Complex reasoning, architecture decisions, code review

### Autocomplete
- **Ollama (qwen2.5-coder:7b)**: Fast local inference
- **Use for**: Code completion, quick refactoring

### Fallback
- **OpenRouter**: When Anthropic API is unavailable
- **Models**: claude-sonnet-4, gpt-4-turbo

---

## MCP Server Usage

### Active MCP Servers

1. **Filesystem**: Always active for file operations
2. **GitHub**: For repository management, PR creation
3. **Database**: When working with data models
4. **Prometheus**: For monitoring metrics queries

### Custom MCP Servers

Located in `/home/user/meta-env/mcp-servers/`
- See `mcp-servers/README.md` for usage instructions

---

## Emergency Procedures

### Claude Seems Confused
1. Start fresh conversation
2. Provide clear context with file paths
3. Reference memory/constitution.md
4. Check project-checklist.md is up to date

### Context Too Large
1. Archive current conversation to memory/archive/
2. Create summary document with key decisions
3. Start new conversation with summary reference
4. Use git worktrees for parallel work

### Unexpected Behavior
1. Check .claude/config.json for correct MCP server configs
2. Verify skills in .claude/skills/ are properly formatted
3. Review recent changes to constitution.md
4. Test with minimal reproduction case

---

## Useful Prompts

### Morning Standup
```
Review roadmap.md and tell me:
1. What's the current sprint priority?
2. Any blockers or dependencies?
3. Suggested tasks for today
```

### End of Day Summary
```
Summarize today's work:
1. What was completed?
2. What's in progress?
3. Any decisions or blockers?
4. Update roadmap.md accordingly
```

### Code Review
```
Review the changes in this branch:
1. Code quality and style compliance
2. Security considerations
3. Performance implications
4. Test coverage
5. Documentation needs

Spawn relevant subagents as needed.
```

---

## Resources

- [Anthropic Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [awesome-claude-code Repository](https://github.com/hesreallyhim/awesome-claude-code)
- [Claude Skills Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [MCP Documentation](https://modelcontextprotocol.io/docs)

---

*Remember: Claude is most effective when given clear context, specific goals, and access to project memory. Treat it as a senior developer who needs onboarding to your project's conventions and architecture.*

---

*Last Updated: 2025-11-20*
