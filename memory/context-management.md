# Context Management Strategies

## Purpose

This document outlines best practices for managing context, memory, and conversation history when working with Claude Code on projects of varying size and complexity. Effective context management ensures Claude maintains relevant knowledge while avoiding token limits and confusion.

---

## I. Context Hierarchy

### 1.1 Four Tiers of Context

```
┌─────────────────────────────────────────────────────┐
│ 1. ACTIVE CONTEXT (Current Conversation)           │
│    - Last ~50 messages                              │
│    - Current task and immediate history             │
│    - Token limit: ~100K (Claude Sonnet 4.5)         │
└─────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────┐
│ 2. SESSION CONTEXT (Files & Skills)                │
│    - CLAUDE.md (project conventions)                │
│    - Active skills (auto-loaded)                    │
│    - Recently read files                            │
└─────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────┐
│ 3. PROJECT MEMORY (memory/ folder)                 │
│    - constitution.md (architectural rules)          │
│    - project-checklist.md (tool configuration)      │
│    - coding-standards.md (language conventions)     │
│    - context-management.md (this document)          │
└─────────────────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────┐
│ 4. ARCHIVAL CONTEXT (memory/archive/)              │
│    - Completed feature discussions                  │
│    - Old design decisions                           │
│    - Historical architecture debates                │
│    - Indexed, retrievable, not auto-loaded          │
└─────────────────────────────────────────────────────┘
```

### 1.2 Context Flow Principle

- **Active → Session**: Summarize key decisions into CLAUDE.md or skills
- **Session → Project Memory**: Extract architectural principles to memory/
- **Project Memory → Archive**: Move outdated content monthly
- **Archive → Active**: Retrieve specific historical context only when needed

---

## II. Short-Term Context Management

### 2.1 Active Conversation (Current Session)

**Best Practices**:
- Keep conversations focused on **single feature or task**
- Break large refactors into multiple sessions
- Use clear task boundaries ("Let's finish authentication before starting payments")

**When to Start New Conversation**:
- [ ] Current task completed
- [ ] Switching to unrelated feature
- [ ] Conversation > 50 messages
- [ ] Claude seems confused or repeats itself
- [ ] Context feels "polluted" with old information

**Conversation Transition Strategy**:
```
OLD SESSION:
You: "Authentication is complete. Let's commit this."
Claude: [commits authentication feature]

NEW SESSION:
You: "Now let's implement the payment system.
      Context: We're using Stripe API, user auth is complete."
Claude: [starts fresh with clear context]
```

### 2.2 File Context Management

**Selective File Reading**:
- Read **only files relevant to current task**
- Avoid reading entire codebase upfront
- Use `grep` to find specific patterns before reading files

**Example - Inefficient**:
```
You: "Read all files in src/ and refactor the API"
[Claude reads 100+ files, hits token limits]
```

**Example - Efficient**:
```
You: "Find all API route handlers"
Claude: [uses grep to locate routes/]
You: "Read the authentication routes"
Claude: [reads only src/routes/auth.ts]
```

### 2.3 Context Pruning

**Explicit Summarization**:
When conversation gets long, request summarization:

```
You: "Summarize what we've accomplished in this session so far"
Claude: [provides bullet-point summary]
You: "Great, let's continue with the next task: [X]"
```

**Forget Irrelevant Details**:
```
You: "We don't need to remember the discussion about database schema
      from earlier. Focus on the current API endpoint implementation."
```

---

## III. Medium-Term Context (CLAUDE.md & Skills)

### 3.1 CLAUDE.md Structure

This file should contain **session-persistent** context:

```markdown
# CLAUDE.md - Project Context for AI Agents

## Project Overview
- **Name**: MyApp
- **Type**: Full-stack SaaS application
- **Tech Stack**: React, Node.js, PostgreSQL, Redis
- **Architecture**: Microservices with API gateway

## Current Phase
**Phase 3**: Implementing payment system
- Stripe integration in progress
- User billing dashboard next
- Subscription management planned

## Code Conventions
- API routes: Express.js with async/await
- Frontend: React Hooks (no class components)
- Styling: Tailwind CSS with custom design system
- Database: Prisma ORM with migrations

## Active Decisions
1. Using JWT for authentication (expires 1h, refresh tokens 7d)
2. Redis for session storage and caching
3. PostgreSQL with read replicas for scaling
4. Monorepo structure with pnpm workspaces

## Current Gotchas
- Remember to run `pnpm db:migrate` after schema changes
- Redis connection must be closed in tests
- API rate limiting: 100 req/min per user

## Next Steps
- [ ] Complete Stripe webhook handling
- [ ] Add payment method update UI
- [ ] Implement subscription cancellation flow
```

**Update Frequency**: After completing each major feature or when decisions change

### 3.2 Skills as Context

**When to Create a Skill**:
- [ ] Repeated patterns across project (e.g., "always use this auth pattern")
- [ ] Domain-specific conventions (e.g., "healthcare data handling")
- [ ] Complex workflows that need documentation (e.g., "deployment process")

**Skill Size Limit**: Keep under 500 lines
- If larger, split into multiple files
- Reference external docs instead of duplicating

**Example Skill Structure**:
```markdown
# Payment Processing Skill

When working with payments in this project:

1. **Always** validate webhook signatures (see lib/stripe.ts)
2. **Never** store raw card data (use Stripe tokens)
3. **Idempotency keys** required for all charge operations
4. **Test mode**: Use test_* API keys in development

## Common Patterns

### Create Subscription
```typescript
const subscription = await stripe.subscriptions.create({
  customer: user.stripeCustomerId,
  items: [{ price: priceId }],
  payment_behavior: 'default_incomplete',
  expand: ['latest_invoice.payment_intent'],
});
```

[Additional patterns...]
```

---

## IV. Long-Term Context (memory/ Folder)

### 4.1 Constitution.md

**Purpose**: Non-negotiable architectural principles
**Update Trigger**: Only when core architectural decisions change
**Review Cycle**: Quarterly or after major incidents

**Content**:
- Security principles (never commit secrets, always validate input)
- Performance standards (< 200ms API responses)
- Testing requirements (80% coverage minimum)
- Deployment policies (blue-green deployments)

### 4.2 Project-Checklist.md

**Purpose**: Auto-activate correct tools and agents
**Update Trigger**: When project structure changes significantly
**Review Cycle**: Monthly

**Content**:
- Project type detection logic
- MCP server activation rules
- Skill loading conditions
- Agent spawning strategy

### 4.3 Coding-Standards.md

**Purpose**: Language-specific coding conventions
**Update Trigger**: When adopting new language or framework
**Review Cycle**: Quarterly

**Content**:
- Naming conventions per language
- File organization patterns
- Documentation requirements
- Language-specific best practices

### 4.4 Custom Memory Documents

Create additional documents as needed:

```
memory/
├─ architecture-decisions.md    # ADR (Architecture Decision Records)
├─ domain-model.md              # DDD domain boundaries
├─ api-contracts.md             # API design patterns
├─ security-policies.md         # Security-specific rules
└─ performance-budgets.md       # Performance targets per route
```

---

## V. Archival Strategy

### 5.1 When to Archive

**Archive Completed Work**:
- [ ] Feature fully implemented and merged
- [ ] Bug investigation concluded
- [ ] Experiment completed (success or failure)
- [ ] Refactoring finished and tested

**Archive Schedule**:
- **Weekly**: Review completed features
- **Monthly**: Bulk archive old conversations
- **Quarterly**: Clean up and re-organize archive

### 5.2 Archive Organization

```
memory/archive/
├─ 2025-01/                    # Monthly folders
│   ├─ feature-authentication.md
│   ├─ bug-payment-timeout.md
│   └─ refactor-api-layer.md
├─ 2025-02/
│   ├─ feature-notifications.md
│   └─ performance-optimization.md
└─ index.md                    # Searchable index
```

### 5.3 Archive Format

Each archived conversation should include:

```markdown
# Feature: User Authentication (Completed 2025-01-15)

## Summary
Implemented JWT-based authentication with refresh tokens.

## Key Decisions
- JWT expires in 1 hour, refresh token in 7 days
- Redis used for token blacklisting on logout
- bcrypt for password hashing (12 rounds)

## Files Changed
- src/auth/jwt.ts (new)
- src/middleware/authenticate.ts (new)
- src/routes/auth.ts (new)
- tests/auth.test.ts (new)

## Lessons Learned
- Remember to handle token expiry edge cases
- Refresh token rotation prevents theft issues

## References
- Commit: abc123f
- PR: #42
- Related Issues: #38, #39
```

### 5.4 Retrieving Archived Context

**When You Need Old Context**:
1. Check `memory/archive/index.md` for topic
2. Read specific archived document
3. Summarize relevant parts into current conversation
4. Avoid loading entire archive into active context

**Example Retrieval**:
```
You: "How did we implement authentication? Check memory/archive/2025-01/feature-authentication.md"
Claude: [reads archived doc]
Claude: "We used JWT with 1-hour expiry and refresh tokens. Key files: src/auth/jwt.ts..."
You: "Thanks. Now let's apply similar pattern to API key authentication."
```

---

## VI. Git Worktree Strategy

### 6.1 When to Use Worktrees

**Parallel Development**:
- [ ] Working on multiple features simultaneously
- [ ] Need to test different approaches
- [ ] Hotfix required while feature in progress
- [ ] Code review while continuing development

**Benefits**:
- Separate Claude Code sessions per worktree
- Independent context for each feature
- No context mixing between unrelated tasks
- Easy to switch without losing state

### 6.2 Worktree Setup

**Create Worktrees**:
```bash
# Main project
cd /var/www/projects/my-app

# Create worktree for feature
git worktree add ../my-app-feature-auth feature/auth

# Create worktree for hotfix
git worktree add ../my-app-hotfix-security hotfix/security-patch

# Create worktree for experiment
git worktree add ../my-app-experiment-redis experiment/redis-caching
```

**Directory Structure**:
```
/var/www/projects/
├─ my-app/                    # Main worktree (main branch)
├─ my-app-feature-auth/       # Feature worktree
├─ my-app-hotfix-security/    # Hotfix worktree
└─ my-app-experiment-redis/   # Experiment worktree
```

### 6.3 Worktree + VS Code Sessions

**One VS Code Window Per Worktree**:
- Open each worktree in separate VS Code window
- Each has independent Claude Code session
- Context remains isolated and focused

**Session Management**:
```
Window 1: my-app (main)
├─ Claude Session: General maintenance
└─ Context: Overall project architecture

Window 2: my-app-feature-auth
├─ Claude Session: Authentication feature
└─ Context: Auth routes, JWT, tests

Window 3: my-app-hotfix-security
├─ Claude Session: Security patch
└─ Context: Vulnerability fix, minimal scope
```

### 6.4 Worktree Cleanup

**When Feature Complete**:
```bash
# Merge feature
git checkout main
git merge feature/auth

# Remove worktree
git worktree remove ../my-app-feature-auth

# Archive conversation
# Move discussion to memory/archive/2025-11/feature-auth.md
```

---

## VII. Context Splitting Strategies

### 7.1 By Feature/Module

**Strategy**: One conversation per feature or module

**Example**:
- **Session 1**: User authentication
- **Session 2**: Payment processing
- **Session 3**: Email notifications
- **Session 4**: Admin dashboard

**Transition Between Sessions**:
```
Session 1: Complete auth, document in CLAUDE.md
Session 2: Read CLAUDE.md for auth context, implement payments
Session 3: Refer to previous sessions as needed, keep focused
```

### 7.2 By Development Phase

**Strategy**: One conversation per phase

**Example**:
- **Phase 1**: Project scaffolding and setup
- **Phase 2**: Core feature development
- **Phase 3**: Performance optimization
- **Phase 4**: Production deployment

### 7.3 By Problem-Solving Session

**Strategy**: Isolate debugging from feature development

**Example**:
- **Main Session**: Feature development
- **Debug Session**: Investigate specific bug (separate conversation)
- **Return to Main**: After fix, summarize solution

---

## VIII. Large Project Strategies

### 8.1 Monorepo Context Management

**Challenge**: Multiple packages/services in one repo

**Strategy**:
- Create separate `.claude/` configs per package
- Use package-specific skills
- Limit file reads to relevant package

**Example Structure**:
```
monorepo/
├─ packages/
│   ├─ frontend/
│   │   ├─ .claude/config.json
│   │   └─ CLAUDE.md
│   ├─ backend/
│   │   ├─ .claude/config.json
│   │   └─ CLAUDE.md
│   └─ shared/
│       └─ CLAUDE.md
└─ memory/                     # Shared architectural docs
    └─ constitution.md
```

**Context Boundaries**:
- Frontend work: Only read `packages/frontend/` and `packages/shared/`
- Backend work: Only read `packages/backend/` and `packages/shared/`
- Cross-package: Explicitly state when context needs to span packages

### 8.2 Microservices Context

**Strategy**: Treat each service as independent project

**Example**:
```
/var/www/projects/
├─ auth-service/               # Independent Claude context
├─ payment-service/            # Independent Claude context
├─ notification-service/       # Independent Claude context
└─ api-gateway/                # Independent Claude context
```

**Shared Context**:
- Create `shared-docs/` repo with common patterns
- Reference in each service's CLAUDE.md
- API contracts documented centrally

---

## IX. Context Refresh Strategies

### 9.1 Periodic Refresh

**Weekly Refresh**:
- Review CLAUDE.md, update current phase
- Archive completed features
- Update project-checklist.md if tools changed

**Monthly Refresh**:
- Review memory/ documents for accuracy
- Archive old conversations
- Update skills based on new patterns

**Quarterly Refresh**:
- Full architecture review
- Update constitution.md with new principles
- Incorporate latest Claude Code best practices

### 9.2 On-Demand Refresh

**When Context Feels Stale**:
1. Start new conversation
2. Read CLAUDE.md and relevant memory/ docs
3. Summarize current project state
4. Continue with fresh context

**Context Reset Template**:
```
You: "Let's start fresh. Read CLAUDE.md and memory/constitution.md.
      Summarize the project architecture and current phase."
Claude: [reads docs and summarizes]
You: "Perfect. Now let's continue work on [current task]."
```

---

## X. Anti-Patterns to Avoid

### 10.1 Context Overload

**Problem**: Loading entire codebase into context at once

**Solution**:
- Use targeted file reads
- Grep before reading
- Read only what's needed for current task

### 10.2 Context Pollution

**Problem**: Mixing unrelated tasks in one conversation

**Solution**:
- Start new conversation for new feature
- Use worktrees for parallel work
- Clear task boundaries

### 10.3 Outdated Context

**Problem**: CLAUDE.md or memory/ docs no longer reflect reality

**Solution**:
- Update after major changes
- Regular review cycles
- Treat docs as code (review in PRs)

### 10.4 Lost Context

**Problem**: Important decisions exist only in old conversation

**Solution**:
- Extract key decisions to CLAUDE.md immediately
- Archive with searchable summaries
- Maintain decision log in memory/

### 10.5 Context Duplication

**Problem**: Same information in conversation, CLAUDE.md, skills, and memory/

**Solution**:
- **Conversation**: Current task details only
- **CLAUDE.md**: Active project state and conventions
- **Skills**: Reusable patterns and workflows
- **Memory/**: Architectural principles and standards

---

## XI. Tool-Assisted Context Management

### 11.1 MCP Servers for Context

**Use MCP to Extend Context**:
- **Database MCP**: Query schema without reading migration files
- **GitHub MCP**: Reference old PRs/issues without manual search
- **Prometheus MCP**: Get current metrics without log diving

**Example**:
```
Instead of: "Read all database migration files to understand schema"
Use: "Query database MCP for current table structure"
```

### 11.2 Skills as Context Modules

**Modular Context Loading**:
- Only activate skills relevant to current task
- Deactivate skills when switching domains
- Reference skills instead of repeating patterns

### 11.3 Search-Based Retrieval

**For Large Codebases**:
- Use `grep` to find relevant files
- Read only matches, not entire directories
- Build index of key files in CLAUDE.md

---

## XII. Context Budget Guidelines

### 12.1 Token Budget Allocation

**Recommended Distribution** (for 100K token context):
- **Active Conversation**: 40K tokens (~40%)
- **Files**: 30K tokens (~30%)
- **Skills**: 15K tokens (~15%)
- **Memory Docs**: 10K tokens (~10%)
- **Buffer**: 5K tokens (~5%)

### 12.2 Monitoring Context Usage

**Watch for Signs of Context Exhaustion**:
- Claude starts repeating information
- Seems to forget earlier conversation
- Responses become generic
- File reads fail or get truncated

**Remediation**:
1. Summarize conversation
2. Start new session
3. Reduce file reads
4. Simplify active skills

---

## XIII. Best Practices Summary

### 13.1 Do's

✅ **Do** keep conversations focused on single feature/task
✅ **Do** update CLAUDE.md after completing features
✅ **Do** archive completed work monthly
✅ **Do** use worktrees for parallel development
✅ **Do** read files selectively (grep first)
✅ **Do** extract architectural decisions to memory/
✅ **Do** use skills for reusable patterns
✅ **Do** start fresh conversation when context feels polluted

### 13.2 Don'ts

❌ **Don't** mix unrelated features in one conversation
❌ **Don't** read entire codebase upfront
❌ **Don't** let CLAUDE.md or memory/ become outdated
❌ **Don't** duplicate context across multiple files
❌ **Don't** continue conversation past 50-70 messages
❌ **Don't** forget to archive completed features
❌ **Don't** lose important decisions in conversation history

---

## XIV. Context Management Checklist

### Daily
- [ ] Focus conversation on single task
- [ ] Read only relevant files
- [ ] Start new conversation when switching features

### Weekly
- [ ] Update CLAUDE.md with current phase
- [ ] Archive completed features
- [ ] Review active skills for relevance

### Monthly
- [ ] Bulk archive old conversations
- [ ] Review memory/ documents for accuracy
- [ ] Update project-checklist.md

### Quarterly
- [ ] Full architecture review
- [ ] Update constitution.md
- [ ] Incorporate latest Claude Code best practices
- [ ] Clean and reorganize archive

---

**Version**: 1.0
**Last Updated**: 2025-11-20
**Maintainer**: Meta-Env Project
**Review Cycle**: Quarterly
