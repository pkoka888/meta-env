<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# and how to create new projects with preprepared structure by best good practices - while i am mostly using claude code cli for those projects - just i would like to have as best as possible core principles, files folders structure, core definition of files about the project like constitution.md for rules, roadmap.md, etc? What and how would you recommend it? And would you recommend to use tools like dokku or?......

For quickly creating new AI-oriented projects using Claude Code CLI, the best practice is to use a clear, documented folder structure and provide foundational files like constitution.md, roadmap.md, and CLAUDE.md to anchor project rules, style, and goals. Automation tools (like Claude CLI templates, git worktrees, or simple scripts) reinforce conventions, improve onboarding, and prevent future technical debt. Here are recommended structures, file definitions, and deployment/orchestration tips, with community sources and GitHub links.[^1][^2][^3]

### Recommended Project Structure

```
project-root/
│
├─ src/                   # Application source code
│   └─ ...
├─ tests/                 # Test scripts and sample data
│   └─ ...
├─ .claude/               # Claude CLI scripts, config.json, workflow templates
│   └─ ...
├─ docs/                  # Extended technical docs
│   └─ ...
├─ memory/                # Architecture, principles, DDD domains
│   └─ constitution.md
├─ roadmap.md             # Development milestones, open issues [web:61]
├─ CLAUDE.md              # How to prompt/plan with Claude [web:58][web:60]
├─ README.md              # Quick project summary, setup instructions
├─ CHANGELOG.md           # Release notes
├─ LICENSE
└─ docker-compose.yml     # Container orchestration (if needed)
```


### Core File Definitions

- **constitution.md**: Outlines your project's architectural principles, APIs, coding standards, and non-negotiable rules; ideal for AI-code agents and new contributors.[^4][^5]
- **roadmap.md**: Lists milestones, current tasks, and where the project is heading (use short/medium/long-term sections, link issues).[^6]
- **CLAUDE.md**: Stores conventions for prompt engineering, codegen, and task management in Claude (context for agents/subagents).[^2][^1]
- **README.md**: Quick start, installation/test instructions, summary of mission (can be adapted for roadmap/constitution cross-links).[^2][^6]


### Workflow Automation With Claude Code

- Use `.claude` folder for templates, scripts, and config to automate feature scaffolding and consistent codegen (e.g. `claude run create-feature –featureName=UserProfile`).[^7]
- Store coding conventions and rules in `CLAUDE.md` so agents adapt to your team’s style.[^7]
- Spawn sub-agents for parallel tasks—code review, tests, doc updates—using Claude CLI’s built-in task delegation.[^1]


### Git Worktree + Multi-Session Best Practices

- Use git worktree and separate terminal tabs/IDE windows for independent parallel agentic workstreams (feature A, bugfix B, etc.).[^3]
- Maintain strict naming conventions per worktree and project artifact.


### Deployment/Orchestration: Dokku \& Alternatives

- **Dokku**: Great for simple Heroku-style git push deployments, isolated app containers—manual scaling and configuration suits well-documented monoprojects.[^8][^9][^10]
- **CapRover/Coolify/Dokploy/Easypanel**: Modern alternatives supporting out-of-the-box CI/CD, multi-service orchestration, worker management, role-based access (recommended for multi-project SaaS or teams).[^9][^10][^8]
- **Kuberns/Northflank**: For larger teams or when you want zero DevOps and full stack automation, these platforms abstract away most infrastructure details and add smart scaling, preview deployments, and service graphs.[^10][^9]

| Tool/Platform | Use Case | Comments |
| :-- | :-- | :-- |
| Dokku | Single apps, simple deployment | Manual, but portable[^8] |
| CapRover | Multi-app SaaS, easy scaling | Built-in dashboard, Nginx[^8] |
| Coolify | Teams, Docker-compose support | Modern UI, easy multi-project[^8] |
| Dokploy | Advanced routing, multi-worker | Role management, auto-deploy[^8][^9] |

### Community Repos (Scaffolding/Conventions)

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code): Structured workflows, planning docs, scaffold scripts for Claude-driven projects.[^11]
- [Set Up New Project Structure](https://desktopcommander.app/library/prompts/set-up-new-project-structure/): Prompts/templates for codebase bootstrapping.[^12]
- [Spec Kit](https://github.com/github/spec-kit): Open source toolkit for spec-driven repo scaffolding.[^13]


### Tips

- Document coding style, API boundaries, deploy steps, and release criteria in each repo early.[^5][^4]
- Link roadmap milestones to issues/pull requests for actionable planning.[^6]
- When scaling up: migrate to orchestration tools that support CI/CD, multi-team workflows, and RBAC.[^8][^9][^10]

A strong foundational structure helps agents, contributors, and orchestration platforms focus on delivering features instead of wrestling messy process, scaling smoothly from hobby projects to multi-server apps.[^11][^3][^1][^7]
<span style="display:none">[^14][^15][^16][^17][^18][^19][^20]</span>

<div align="center">⁂</div>

[^1]: https://blog.sshh.io/p/how-i-use-every-claude-code-feature

[^2]: https://www.reddit.com/r/ClaudeAI/comments/1ljv2kz/tips_for_developing_large_projects_with_claude/

[^3]: https://www.anthropic.com/engineering/claude-code-best-practices

[^4]: https://developer.microsoft.com/blog/spec-driven-development-spec-kit

[^5]: https://dev.to/danielsogl/spec-driven-development-sdd-a-initial-review-2llp

[^6]: https://mozillascience.github.io/working-open-workshop/roadmapping/

[^7]: https://www.sidetool.co/post/how-to-automate-tasks-with-claude-code-workflow-for-developers/

[^8]: https://www.edopedia.com/blog/dokku-alternatives/

[^9]: https://kuberns.com/blogs/post/dokku-alternatives-that-simplify-cloud-deployment/

[^10]: https://northflank.com/blog/6-best-dokku-alternatives

[^11]: https://github.com/hesreallyhim/awesome-claude-code

[^12]: https://desktopcommander.app/library/prompts/set-up-new-project-structure/

[^13]: https://ainativedev.io/news/a-look-at-spec-kit-githubs-spec-driven-software-development-toolkit

[^14]: https://dev.to/ujjavala/a-week-with-claude-code-lessons-surprises-and-smarter-workflows-23ip

[^15]: https://code.claude.com/docs/en/common-workflows

[^16]: https://uxdesign.cc/designing-with-claude-code-and-codex-cli-building-ai-driven-workflows-powered-by-code-connect-ui-f10c136ec11f

[^17]: https://openalternative.co/alternatives/dokku

[^18]: https://dius.com.au/insights/week-with-claude-code/

[^19]: https://governance.md

[^20]: https://www.reddit.com/r/selfhosted/comments/qttuvw/paas_like_dokku_or_some_other_solution_for/

