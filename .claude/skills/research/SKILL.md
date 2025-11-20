# Research & Analysis Skill

## Description
Conducts technical research, compares solutions, evaluates technologies, and generates comprehensive reports.

## Auto-Activation Triggers
- User mentions: "research", "compare", "evaluate", "analyze", "investigate"
- Files matching: `docs/research-templates/*.md`
- Commands: `/research`, `/compare`, `/evaluate`

## Capabilities
- Web search for latest information
- GitHub repository analysis
- Technology comparison tables
- Competitive analysis
- Feature feasibility studies
- Trend analysis and recommendations

## Workflow

### 1. Research Planning
When user requests research:
1. Clarify research scope and objectives
2. Identify key questions to answer
3. Determine sources (web, GitHub, documentation)
4. Create research outline

### 2. Information Gathering
1. **Web Search**: Latest articles, documentation, best practices
2. **GitHub Analysis**: Repository stars, activity, issues, community health
3. **Documentation Review**: Official docs, tutorials, guides
4. **Community Feedback**: Reddit, HN, Stack Overflow, Discord

### 3. Analysis & Comparison
1. Create comparison matrices
2. Evaluate pros/cons for each option
3. Score based on criteria (performance, community, documentation, cost)
4. Identify best fit for use case

### 4. Report Generation
Generate markdown report in `docs/research/` with:
```markdown
# [Research Topic]

## Executive Summary
[1-2 paragraph summary of findings]

## Research Questions
1. Question 1
2. Question 2
3. Question 3

## Options Evaluated

### Option 1: [Name]
**Overview**: [Description]

**Pros**:
- Pro 1
- Pro 2

**Cons**:
- Con 1
- Con 2

**Use Cases**: [When to use]

### Option 2: [Name]
[Same structure]

## Comparison Matrix

| Criteria | Option 1 | Option 2 | Option 3 |
|----------|----------|----------|----------|
| Performance | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Community | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Documentation | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Cost | Free | Paid | Free |

## Recommendations

### Best Overall: [Option Name]
**Reasoning**: [Why this is the best choice]

### Best for Specific Use Cases:
- **High Performance**: Option 1
- **Large Community**: Option 2
- **Best Documentation**: Option 3

## Implementation Resources
- GitHub: [links]
- Documentation: [links]
- Tutorials: [links]
- Community: [links]

## Next Steps
1. Step 1
2. Step 2
3. Step 3
```

### 5. Update Project Documentation
- Update `roadmap.md` with findings
- Add to `memory/decisions.md` for future reference
- Create actionable tasks based on research

## Tools Available
- Web search
- GitHub API
- Markdown generation
- File system access

## Example Usage

**User**: "Research the best options for implementing RAG with local LLMs"

**Skill Actions**:
1. Search for RAG implementations with Ollama, LangChain, LlamaIndex
2. Analyze GitHub repositories:
   - karthik-codex/Autogen_GraphRAG_Ollama
   - run-llama/llama_index
   - langchain-ai/langchain
3. Compare features, performance, ease of use
4. Generate report at `docs/research/rag-local-llm-comparison.md`
5. Update `roadmap.md` with recommended approach

## Best Practices
- Always cite sources
- Include dates (information freshness)
- Be objective in comparisons
- Consider project-specific context
- Include both quantitative and qualitative analysis
- Provide actionable recommendations
