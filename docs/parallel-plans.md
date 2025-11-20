# Parallel Plans - Multi-Agent Coordination Strategies

Guidelines and patterns for coordinating multiple AI agents working simultaneously on the meta-env project.

---

## Table of Contents

1. [Overview](#overview)
2. [Coordination Patterns](#coordination-patterns)
3. [Git Worktree Strategy](#git-worktree-strategy)
4. [Agent Communication](#agent-communication)
5. [Conflict Resolution](#conflict-resolution)
6. [Common Scenarios](#common-scenarios)
7. [Best Practices](#best-practices)

---

## Overview

### When to Use Parallel Plans

Use multi-agent coordination when:
- **Independent features**: Multiple features that don't share code/files
- **Specialized tasks**: Research + implementation + documentation happening simultaneously
- **Pipeline workflows**: Testing while implementing next feature
- **Review cycles**: Security audit while performance optimization continues

### When NOT to Use Parallel Plans

Avoid parallelization when:
- **High coupling**: Changes affect same files/modules
- **Sequential dependencies**: Task B requires Task A completion
- **Shared state**: Database migrations, schema changes
- **Single developer**: You can only review one agent at a time

---

## Coordination Patterns

### Pattern 1: Feature Isolation

**Scenario**: Building multiple independent features simultaneously

**Setup:**
```bash
# Main branch: main
# Feature branches: feature/auth, feature/api, feature/monitoring

# Create git worktrees
git worktree add ../meta-env-auth feature/auth
git worktree add ../meta-env-api feature/api
git worktree add ../meta-env-monitoring feature/monitoring

# Open each in separate VS Code windows
code ../meta-env-auth      # Claude Agent 1
code ../meta-env-api       # Claude Agent 2
code ../meta-env-monitoring # Claude Agent 3
```

**Agent Instructions:**

*Agent 1 (Authentication):*
```
You are working on the authentication system in feature/auth worktree.

Scope:
- Files: src/auth/*, tests/auth/*
- No changes outside src/auth/

Tasks:
1. Implement JWT authentication
2. Add tests (100% coverage)
3. Update docs/api/auth.md
```

*Agent 2 (API Endpoints):*
```
You are working on API endpoints in feature/api worktree.

Scope:
- Files: src/api/*, tests/api/*
- No changes outside src/api/

Tasks:
1. Create RESTful endpoints
2. Add validation middleware
3. Update docs/api/endpoints.md
```

*Agent 3 (Monitoring):*
```
You are working on monitoring in feature/monitoring worktree.

Scope:
- Files: monitoring/*, configs/prometheus/*
- No changes outside monitoring/

Tasks:
1. Setup Prometheus metrics
2. Create Grafana dashboards
3. Update docs/monitoring/setup.md
```

**Merge Strategy:**
```bash
# Agents complete independently
# Review and merge sequentially
git checkout main
git merge feature/auth
git merge feature/api
git merge feature/monitoring
```

---

### Pattern 2: Specialist Subagents

**Scenario**: One main implementation, multiple review/support agents

**Setup:**
```bash
# One worktree for main work
# Subagents work in parallel on review/support tasks
```

**Main Agent:**
```
Implementing new payment processing system in src/payment/

Spawn subagents:
1. security-auditor: Review for PCI compliance
2. documentation-writer: Create API docs
3. test-generator: Create integration tests

I will continue implementation while subagents work in parallel.
```

**Subagent Instructions:**

*Security Auditor:*
```
Review src/payment/ for security vulnerabilities:
- PCI DSS compliance
- Sensitive data handling
- API key management

Output: docs/security/payment-audit-[date].md

Do NOT modify code, only create audit report.
```

*Documentation Writer:*
```
Create comprehensive documentation for payment API:
- API reference
- Integration examples
- Error handling guide

Output: docs/api/payment.md

Read src/payment/ for implementation details.
```

*Test Generator:*
```
Create integration tests for payment system:
- Happy path scenarios
- Error cases
- Edge cases

Output: tests/payment/integration_test.py

Follow testing standards in memory/coding-standards.md.
```

**Coordination:**
- Main agent continues implementation
- Subagents read code, produce artifacts
- Main agent reviews artifacts, incorporates feedback
- Iterate until all checks pass

---

### Pattern 3: Pipeline Workflow

**Scenario**: Sequential stages with parallel tasks within each stage

**Stage 1: Research & Planning (Parallel)**
```
Agent A: Research authentication libraries (30 min)
Agent B: Research database options (30 min)
Agent C: Research deployment platforms (30 min)

Sync Point: Review research outputs, make decisions
```

**Stage 2: Implementation (Parallel)**
```
Agent A: Implement auth (based on research decision)
Agent B: Implement database layer (based on research decision)
Agent C: Setup deployment configs (based on research decision)

Sync Point: Integration testing
```

**Stage 3: Review & Documentation (Parallel)**
```
Agent A: Security audit
Agent B: Performance testing
Agent C: Documentation writing

Sync Point: Final review and merge
```

**Implementation:**
```bash
# Create tracking document
cat > docs/parallel-plan-[feature-name].md << 'EOF'
# Parallel Plan: [Feature Name]

## Stage 1: Research (Due: [date])
- [ ] Agent A: Auth research
- [ ] Agent B: Database research
- [ ] Agent C: Deployment research

## Stage 2: Implementation (Due: [date])
- [ ] Agent A: Auth implementation
- [ ] Agent B: Database layer
- [ ] Agent C: Deployment configs

## Stage 3: Review (Due: [date])
- [ ] Agent A: Security audit
- [ ] Agent B: Performance test
- [ ] Agent C: Documentation
EOF
```

---

### Pattern 4: Continuous Integration Flow

**Scenario**: One agent implements, others continuously review

**Setup:**
```bash
# Main worktree for implementation
# CI agents monitor changes
```

**Main Agent (Implementation):**
```
Implementing feature X in src/feature-x/

After each commit:
1. Run tests locally
2. Commit with descriptive message
3. Trigger CI review agents
```

**CI Agent 1 (Test Coverage):**
```
Monitor: src/feature-x/
Trigger: On commit to feature/feature-x

Tasks:
1. Run pytest with coverage
2. Ensure >90% coverage
3. Comment on commit if coverage drops
```

**CI Agent 2 (Security Scan):**
```
Monitor: src/feature-x/
Trigger: On commit to feature/feature-x

Tasks:
1. Run bandit security scan
2. Check for hardcoded secrets
3. Block merge if issues found
```

**CI Agent 3 (Performance Benchmark):**
```
Monitor: src/feature-x/
Trigger: On commit to feature/feature-x

Tasks:
1. Run performance benchmarks
2. Compare against baseline
3. Alert if >10% regression
```

---

## Git Worktree Strategy

### Creating Worktrees

```bash
# From main repository
cd /home/user/meta-env

# Create worktree for feature branch
git worktree add -b feature/new-feature ../meta-env-new-feature

# Create worktree from existing branch
git worktree add ../meta-env-bug-fix bug-fix/auth-issue

# List all worktrees
git worktree list
```

### Worktree Best Practices

1. **Naming Convention**: `../meta-env-[feature-name]`
2. **One Feature Per Worktree**: Keep scope isolated
3. **Clean Up**: Remove worktrees after merge
4. **Shared .git**: All worktrees share .git directory
5. **Independent Checkouts**: Each worktree has its own working directory

### Cleaning Up Worktrees

```bash
# Remove worktree
git worktree remove ../meta-env-feature-x

# Prune stale worktrees
git worktree prune

# Delete merged branch
git branch -d feature/feature-x
```

---

## Agent Communication

### Shared State

**Use shared documents for coordination:**

```bash
# Create coordination document
cat > docs/coordination-[date].md << 'EOF'
# Agent Coordination: [Date]

## Active Agents
- Agent 1 (Alice): Working on authentication (src/auth/)
- Agent 2 (Bob): Working on API (src/api/)
- Agent 3 (Carol): Working on monitoring (monitoring/)

## Shared Dependencies
- Redis configuration: Agent 1 owns, Agent 2 depends
  - Status: Agent 1 to complete by EOD
  - Agent 2: Blocked until Redis config ready

## Decisions Needed
- [ ] Database choice: Agent 1 and 2 need decision
  - Options: PostgreSQL vs MongoDB
  - Decision by: [date]

## Integration Points
- Authentication middleware: Agent 1 provides, Agent 2 consumes
  - Interface: /src/auth/middleware.py
  - Status: Ready for integration
EOF
```

### Status Updates

**Template for agent check-ins:**

```markdown
## Agent [Name] Status Update

**Date**: [timestamp]
**Task**: [current task]
**Status**: [on-track / blocked / completed]

### Completed Today
- [x] Task 1
- [x] Task 2

### In Progress
- [ ] Task 3 (50% complete)
- [ ] Task 4 (25% complete)

### Blocked On
- [ ] Waiting for Agent X to complete Y
- [ ] Decision needed on Z

### Next Steps
1. Step 1
2. Step 2
```

---

## Conflict Resolution

### Preventing Conflicts

1. **File-Level Isolation**: Assign exclusive file ownership
2. **Module Boundaries**: Respect architectural boundaries
3. **API Contracts**: Define interfaces before implementation
4. **Regular Syncs**: Merge main into feature branches daily

### Handling Conflicts

**When conflicts occur:**

```bash
# In feature worktree
git fetch origin main
git merge origin/main

# If conflicts detected
git status  # See conflicting files

# Resolve conflicts
# Option 1: Accept their changes (main)
git checkout --theirs <file>

# Option 2: Accept our changes (feature)
git checkout --ours <file>

# Option 3: Manual merge
# Edit files, resolve conflicts
git add <file>
git commit
```

**Escalation Process:**

1. **Automated**: Simple conflicts (whitespace, imports) - auto-resolve
2. **Agent Negotiation**: Agents discuss and agree on resolution
3. **Human Decision**: Complex conflicts require human judgment
4. **Architecture Review**: If conflict reveals design issue

---

## Common Scenarios

### Scenario 1: Full-Stack Feature Development

**Agents:**
- Frontend Agent: React components
- Backend Agent: API endpoints
- Database Agent: Schema and migrations
- DevOps Agent: Deployment configuration

**Coordination Plan:**

```markdown
# Phase 1: Contracts (1 day)
- All agents: Define API contracts
- Database agent: Define schema
- Sync: Review and approve contracts

# Phase 2: Implementation (3 days)
- Backend agent: Implement API (depends on schema)
- Database agent: Create migrations (independent)
- Frontend agent: Mock API, build UI (independent)
- DevOps agent: Setup staging environment (independent)

# Phase 3: Integration (1 day)
- Frontend agent: Connect to real API
- Backend agent: Run integration tests
- DevOps agent: Deploy to staging
- All agents: Smoke test

# Phase 4: Review (1 day)
- Security agent: Audit
- Performance agent: Benchmark
- Documentation agent: Write docs
```

### Scenario 2: Emergency Bug Fix

**Agents:**
- Detective Agent: Root cause analysis
- Fixer Agent: Implement fix
- Tester Agent: Verify fix
- Deployer Agent: Hotfix deployment

**Coordination Plan:**

```markdown
# Phase 1: Diagnosis (30 min)
- Detective agent: Analyze logs, reproduce bug
- Output: Root cause document

# Phase 2: Fix (1 hour)
- Fixer agent: Implement fix
- Tester agent: Create regression test (parallel)

# Phase 3: Verification (30 min)
- Tester agent: Run full test suite
- Fixer agent: Code review

# Phase 4: Deploy (15 min)
- Deployer agent: Hotfix to production
- Detective agent: Monitor metrics
```

### Scenario 3: Performance Optimization

**Agents:**
- Profiler Agent: Identify bottlenecks
- Optimizer Agent: Implement optimizations
- Benchmarker Agent: Measure improvements
- Reviewer Agent: Ensure correctness

**Coordination Plan:**

```markdown
# Phase 1: Baseline (1 day)
- Profiler agent: Profile application, identify top 10 bottlenecks
- Benchmarker agent: Establish performance baseline

# Phase 2: Optimization (5 days, iterative)
Repeat for each bottleneck:
  - Optimizer agent: Implement optimization
  - Benchmarker agent: Measure improvement
  - Reviewer agent: Verify correctness
  - If improvement >10%: Keep
  - Else: Revert

# Phase 3: Validation (1 day)
- Benchmarker agent: Full benchmark suite
- Reviewer agent: Final code review
- Profiler agent: Confirm bottlenecks resolved
```

---

## Best Practices

### Do's ✅

- **Clear Ownership**: Assign explicit file/module ownership
- **Regular Syncs**: Daily integration of main branch
- **Coordination Documents**: Maintain shared state documents
- **Status Updates**: Agents report progress regularly
- **API Contracts**: Define interfaces before parallel implementation
- **Independent Testing**: Each agent runs tests locally
- **Clean Worktrees**: Remove after merge

### Don'ts ❌

- **Don't Share Files**: Avoid concurrent edits to same file
- **Don't Assume**: Communicate dependencies explicitly
- **Don't Let Branches Diverge**: Sync with main daily
- **Don't Skip Integration**: Test combined changes frequently
- **Don't Ignore Conflicts**: Address immediately, don't defer
- **Don't Overload Agents**: Keep tasks focused and scoped

---

## Tools & Automation

### Coordination Scripts

```bash
# scripts/parallel-sync.sh
#!/bin/bash
# Sync all worktrees with main branch

WORKTREES=$(git worktree list | grep -v main | awk '{print $1}')

for worktree in $WORKTREES; do
  echo "Syncing $worktree"
  cd $worktree
  git fetch origin main
  git merge origin/main
done
```

### Status Dashboard

```bash
# scripts/agent-status.sh
#!/bin/bash
# Generate status report for all active agents

cat << 'EOF'
# Agent Status Dashboard

## Active Worktrees
EOF

git worktree list

cat << 'EOF'

## Recent Commits (Last 24h)
EOF

git log --all --since="24 hours ago" --oneline --graph
```

---

## Metrics & Monitoring

### Key Metrics

- **Merge Conflicts**: Track frequency and resolution time
- **Integration Test Success**: Percentage passing after merge
- **Agent Utilization**: Are agents blocked/idle?
- **Feature Velocity**: Features completed per week
- **Rework Rate**: Changes reverted or redone

### Monitoring

```bash
# Add to Grafana dashboard
# - Active worktrees count
# - Commits per agent per day
# - Merge conflict rate
# - Test coverage trend
```

---

## Emergency Procedures

### Agent Conflict Deadlock

If agents cannot resolve conflict:

1. **Stop All Agents**: Pause work on conflicting files
2. **Human Review**: Senior developer reviews conflict
3. **Architectural Decision**: Update constitution.md if needed
4. **Resume Work**: Agents continue with resolution

### Integration Failure

If merged features break:

1. **Rollback**: Revert merge
2. **Root Cause**: Identify which agent's changes broke
3. **Fix Forward**: Agent fixes issue in feature branch
4. **Retest**: Full integration test before re-merge

---

## Resources

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Microsoft AutoGen Multi-Agent Patterns](https://microsoft.github.io/autogen/)
- [Parallel Development Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

---

*Remember: Successful parallel work requires clear communication, well-defined boundaries, and regular synchronization. When in doubt, over-communicate.*

---

*Last Updated: 2025-11-20*
