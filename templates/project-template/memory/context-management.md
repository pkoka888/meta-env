# Context Management Guide

## Overview

Effective context management ensures Claude Code and other AI assistants have the right information at the right time without overwhelming the conversation.

## Context Layers

### 1. Immediate Context (Active Conversation)
**What**: Current task or feature being worked on
**Lifespan**: Single conversation (< 50 messages)
**Storage**: Active chat

**Best Practices**:
- Keep focused on one feature or bug
- Break large tasks into smaller conversations
- Archive when feature is complete

### 2. Short-term Context (Project Files)
**What**: Project-specific rules and current state
**Lifespan**: Duration of feature development (days to weeks)
**Storage**:
- `memory/project-checklist.md`
- `.claude/skills/`
- Active documentation

**Best Practices**:
- Update project-checklist.md when adding features
- Keep skills under 500 lines
- Reference files instead of duplicating content

### 3. Medium-term Context (Project Knowledge)
**What**: Architectural decisions and coding standards
**Lifespan**: Entire project (months)
**Storage**:
- `memory/constitution.md`
- `memory/coding-standards.md`
- `docs/CLAUDE.md`

**Best Practices**:
- Update constitution when making architectural changes
- Document major decisions
- Keep standards document current

### 4. Long-term Context (Archive)
**What**: Completed features, old decisions, historical context
**Lifespan**: Permanent (but accessed infrequently)
**Storage**: `memory/archive/`

**Best Practices**:
- Move completed feature discussions to archive
- Organize by date or feature
- Summarize before archiving

## Context Optimization Strategies

### 1. Conversation Size Management

```markdown
# Good: Focused conversation
User: "Add JWT authentication to the login endpoint"
Claude: [Implements focused change]

# Bad: Too broad
User: "Rebuild the entire authentication system"
Claude: [Needs too much context]
```

**Solution**: Break into smaller tasks
1. Research JWT libraries
2. Implement token generation
3. Add token validation
4. Update endpoints
5. Write tests

### 2. File Reference Strategy

```markdown
# Good: Reference existing files
"Follow the coding standards in memory/coding-standards.md"
"Update the API based on docs/api-spec.md"

# Bad: Paste entire files
[Pasting thousands of lines of code]
```

### 3. Skill-Based Context

Create skills for frequently needed context:

```markdown
# .claude/skills/api-design/SKILL.md
---
description: "API design guidelines for this project"
---

# API Design Skill

When designing new endpoints:
1. Follow REST conventions
2. Use versioned URLs (/api/v1/)
3. Return consistent error format
4. Include rate limiting

See docs/api-standards.md for full details.
```

### 4. Progressive Disclosure

Start with summary, drill down as needed:

```markdown
# 1. High-level request
"I need to optimize database queries"

# 2. Claude analyzes
# 3. Specific problem identified
"The user list query has N+1 problem"

# 4. Focused solution
[Fix specific query]
```

## Context Patterns

### Pattern 1: Feature Development

```
1. Create feature branch
2. Start new conversation
3. Reference project-checklist.md
4. Implement feature
5. Update documentation
6. Archive conversation
```

### Pattern 2: Bug Investigation

```
1. Start conversation with error description
2. Share relevant logs/stack trace
3. Review related code files
4. Identify root cause
5. Fix and test
6. Update issue tracker
```

### Pattern 3: Refactoring

```
1. Identify code smell
2. Create refactoring plan
3. Use git worktree for isolation
4. Incremental changes with tests
5. Update documentation
6. Archive old approach notes
```

## Tools for Context Management

### 1. Git Worktrees

For parallel feature development:

```bash
# Create worktree for new feature
git worktree add ../feature-x feature-x

# Work in isolation
cd ../feature-x

# Separate Claude conversation for each worktree
```

### 2. Project Checklist

Smart decision tree for Claude:

```markdown
# Trigger: User mentions "authentication"
- Activate: security-skill
- Load: docs/authentication.md
- Spawn: security-auditor subagent
```

### 3. Conversation Bookmarks

Mark important points in conversation:

```markdown
📌 **Bookmark**: Decision to use PostgreSQL over MongoDB
Reason: Need ACID compliance for transactions
Date: 2025-11-20
```

### 4. Context Summary

Periodically summarize conversation:

```markdown
## Conversation Summary (Messages 1-30)
- Decided on FastAPI for backend
- Implemented user registration
- Added input validation
- Next: Password reset flow
```

## Context Anti-Patterns

### ❌ Don't: Paste Entire Codebase

```markdown
# Bad
Here's all 50 files in my project...
[50,000 lines of code]
```

**Instead**: Use Grep/Glob tools, reference specific files

### ❌ Don't: Repeat Information

```markdown
# Bad
User: "Follow these rules: [paste coding standards]"
Claude: [Response]
User: "Remember these rules: [paste same standards]"
```

**Instead**: Store in memory/coding-standards.md, reference once

### ❌ Don't: Mix Unrelated Tasks

```markdown
# Bad
"Fix the login bug AND refactor the database AND update docs AND..."
```

**Instead**: One conversation per focused task

### ❌ Don't: Ignore Project Structure

```markdown
# Bad
[Working without checking project-checklist.md]
```

**Instead**: Always start by reading project-checklist.md

## Measuring Context Health

### Indicators of Good Context Management

- ✅ Conversations complete tasks efficiently
- ✅ Claude rarely asks for repeated information
- ✅ Skills are being auto-activated appropriately
- ✅ Documentation stays current
- ✅ Archive grows with completed work

### Indicators of Poor Context Management

- ❌ Conversations become circular
- ❌ Repeated questions about project structure
- ❌ Skills not activating when they should
- ❌ Outdated documentation
- ❌ No archived conversations

## Monthly Maintenance

### Context Cleanup Checklist

- [ ] Archive completed feature conversations
- [ ] Update project-checklist.md with new patterns
- [ ] Review and update constitution.md
- [ ] Prune outdated skills
- [ ] Update coding-standards.md
- [ ] Organize archive by date/feature
- [ ] Remove duplicate information
- [ ] Update CLAUDE.md with new insights

## Advanced Techniques

### 1. Context Inheritance

```markdown
# Base context (always loaded)
memory/constitution.md

# Project type context (conditional)
If web_app: memory/web-app-standards.md
If api: memory/api-standards.md

# Feature context (task-specific)
If auth_task: .claude/skills/auth/SKILL.md
```

### 2. Dynamic Context Loading

```markdown
# project-checklist.md
## Auto-load based on file changes
- If modified: src/api/*.py → Load api-design-skill
- If modified: tests/*.py → Load testing-skill
- If modified: docker-compose.yml → Load deployment-skill
```

### 3. Context Versioning

```markdown
# Track context evolution
memory/
├── constitution.md (v3.0)
├── archive/
│   ├── constitution-v2.0.md
│   └── constitution-v1.0.md
```

## Resources

- Keep constitution.md under 1000 lines
- Skills should be under 500 lines each
- Archive conversations > 50 messages
- Review context health monthly
- Document major context changes

---

**Remember**: Good context management makes AI assistants more effective while reducing token usage and costs.
