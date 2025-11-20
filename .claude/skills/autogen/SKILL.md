# AutoGen Multi-Agent Skill

## Description
Implements multi-agent systems using Microsoft AutoGen framework with local Ollama LLMs.

## Auto-Activation Triggers
- User mentions: "autogen", "multi-agent", "agent collaboration", "agentic"
- Files matching: `src/agents/**/*`, `autogen/**/*`
- Commands: `/autogen`, `/agents`, `/collaborate`

## Capabilities
- Multi-agent orchestration
- Agent conversation patterns
- Tool integration for agents
- Local LLM integration (Ollama)
- Distributed problem solving
- Code execution agents
- Research and analysis agents

## AutoGen Architecture

```
┌─────────────────────────────────────────────────┐
│ User Proxy Agent (Human in the loop)           │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────┐
│ Planning Agent                                  │
│ - Breaks down task                              │
│ - Creates execution plan                        │
└─────────────────┬───────────────────────────────┘
                  │
                  ├──────────────────┬──────────────────┬────────────────┐
                  ▼                  ▼                  ▼                ▼
┌─────────────────────┐  ┌─────────────────┐  ┌─────────────┐  ┌──────────────┐
│ Coder Agent         │  │ Researcher      │  │ Critic      │  │ Executor     │
│ - Writes code       │  │ - Gathers info  │  │ - Reviews   │  │ - Runs code  │
│ - Fixes bugs        │  │ - Web search    │  │ - Validates │  │ - Tests      │
└─────────────────────┘  └─────────────────┘  └─────────────┘  └──────────────┘
```

## Implementation

### 1. Setup Script

**scripts/setup-autogen.sh**:
```bash
#!/bin/bash

echo "🔧 Setting up AutoGen environment..."

# Install dependencies
pip install pyautogen litellm chainlit

# Pull Ollama models
ollama pull llama3:8b
ollama pull qwen2.5-coder:7b
ollama pull deepseek-r1:7b

echo "✅ AutoGen environment setup complete"
```

### 2. Ollama Configuration

**src/agents/config.py**:
```python
import autogen

# Ollama LLM configuration
llm_config = {
    "config_list": [
        {
            "model": "ollama/llama3:8b",
            "base_url": "http://localhost:11434",
            "api_key": "ollama",  # Dummy key for Ollama
            "stream": False
        }
    ],
    "timeout": 600,
    "temperature": 0.7,
    "cache_seed": None  # Disable caching for dynamic responses
}

# Coding-specific LLM config
coding_llm_config = {
    "config_list": [
        {
            "model": "ollama/qwen2.5-coder:7b",
            "base_url": "http://localhost:11434",
            "api_key": "ollama",
        }
    ],
    "timeout": 600,
    "temperature": 0.3,  # Lower temperature for more precise code
}

# Reasoning LLM config
reasoning_llm_config = {
    "config_list": [
        {
            "model": "ollama/deepseek-r1:7b",
            "base_url": "http://localhost:11434",
            "api_key": "ollama",
        }
    ],
    "timeout": 600,
    "temperature": 0.5,
}
```

### 3. Basic Agent Setup

**src/agents/basic_agents.py**:
```python
import autogen
from .config import llm_config, coding_llm_config

def create_user_proxy():
    """Create user proxy agent (human in the loop)."""
    return autogen.UserProxyAgent(
        name="User_Proxy",
        human_input_mode="NEVER",  # Set to "ALWAYS" for interactive mode
        max_consecutive_auto_reply=10,
        is_termination_msg=lambda x: x.get("content", "").rstrip().endswith("TERMINATE"),
        code_execution_config={
            "work_dir": "coding",
            "use_docker": False,  # Set to True for sandboxed execution
        },
        system_message="""You are a helpful assistant. Execute code and provide feedback.
Reply TERMINATE when the task is complete."""
    )

def create_assistant():
    """Create general assistant agent."""
    return autogen.AssistantAgent(
        name="Assistant",
        llm_config=llm_config,
        system_message="""You are a helpful AI assistant.
Solve tasks using your coding and language skills.
When you're done, reply TERMINATE."""
    )

def create_coder():
    """Create specialized coding agent."""
    return autogen.AssistantAgent(
        name="Coder",
        llm_config=coding_llm_config,
        system_message="""You are an expert programmer.
Write clean, efficient, well-documented code.
Follow best practices and include error handling.
Reply TERMINATE when the code is complete and tested."""
    )

def create_critic():
    """Create code review agent."""
    return autogen.AssistantAgent(
        name="Critic",
        llm_config=llm_config,
        system_message="""You are a code review expert.
Review code for:
- Correctness and logic errors
- Security vulnerabilities
- Performance issues
- Best practices violations
- Code quality and maintainability
Provide specific, actionable feedback."""
    )
```

### 4. Multi-Agent Collaboration

**src/agents/collaboration.py**:
```python
import autogen
from .basic_agents import (
    create_user_proxy,
    create_assistant,
    create_coder,
    create_critic
)

class MultiAgentSystem:
    """Orchestrate multiple agents for complex tasks."""

    def __init__(self):
        self.user_proxy = create_user_proxy()
        self.assistant = create_assistant()
        self.coder = create_coder()
        self.critic = create_critic()

    def simple_chat(self, task: str):
        """Simple two-agent conversation."""
        self.user_proxy.initiate_chat(
            self.assistant,
            message=task
        )

    def code_review_workflow(self, task: str):
        """Multi-agent code review workflow."""
        # 1. Coder writes code
        print("🔨 Phase 1: Writing code...")
        self.user_proxy.initiate_chat(
            self.coder,
            message=task
        )

        # 2. Critic reviews code
        print("\n🔍 Phase 2: Code review...")
        self.user_proxy.initiate_chat(
            self.critic,
            message="Review the code written by the Coder agent. Identify any issues."
        )

        # 3. Coder fixes issues
        print("\n🔧 Phase 3: Fixing issues...")
        self.user_proxy.initiate_chat(
            self.coder,
            message="Fix the issues identified by the Critic agent."
        )

    def group_chat(self, task: str):
        """Group chat with all agents."""
        # Create group chat
        groupchat = autogen.GroupChat(
            agents=[self.user_proxy, self.assistant, self.coder, self.critic],
            messages=[],
            max_round=12,
            speaker_selection_method="round_robin"  # or "auto"
        )

        # Create manager
        manager = autogen.GroupChatManager(
            groupchat=groupchat,
            llm_config={"config_list": llm_config["config_list"]}
        )

        # Initiate group chat
        self.user_proxy.initiate_chat(
            manager,
            message=task
        )
```

### 5. Advanced Patterns

**src/agents/advanced_patterns.py**:
```python
import autogen
from typing import List, Dict

class ResearchTeam:
    """Multi-agent research team."""

    def __init__(self):
        # Planner agent
        self.planner = autogen.AssistantAgent(
            name="Planner",
            llm_config=llm_config,
            system_message="""You are a research planner.
Break down research tasks into subtasks.
Assign subtasks to specialist agents.
Synthesize findings into final report."""
        )

        # Research agents
        self.web_researcher = autogen.AssistantAgent(
            name="Web_Researcher",
            llm_config=llm_config,
            system_message="You search the web for information and summarize findings."
        )

        self.paper_analyst = autogen.AssistantAgent(
            name="Paper_Analyst",
            llm_config=llm_config,
            system_message="You analyze academic papers and extract key insights."
        )

        self.data_analyst = autogen.AssistantAgent(
            name="Data_Analyst",
            llm_config=llm_config,
            system_message="You analyze data, create visualizations, and find patterns."
        )

        self.writer = autogen.AssistantAgent(
            name="Writer",
            llm_config=llm_config,
            system_message="""You write comprehensive research reports.
Synthesize information from multiple sources.
Create clear, well-structured documents."""
        )

        self.user_proxy = create_user_proxy()

    def research_workflow(self, topic: str):
        """Execute research workflow."""
        # Create sequential workflow
        workflow = [
            (self.planner, "Create research plan for: " + topic),
            (self.web_researcher, "Search web for latest information"),
            (self.paper_analyst, "Analyze relevant papers"),
            (self.data_analyst, "Analyze any relevant data"),
            (self.writer, "Write comprehensive report")
        ]

        for agent, task in workflow:
            self.user_proxy.initiate_chat(agent, message=task)

class CodeTeam:
    """Multi-agent software development team."""

    def __init__(self):
        self.architect = autogen.AssistantAgent(
            name="Architect",
            llm_config=llm_config,
            system_message="You design software architecture and create technical specs."
        )

        self.backend_dev = autogen.AssistantAgent(
            name="Backend_Developer",
            llm_config=coding_llm_config,
            system_message="You implement backend APIs, databases, and business logic."
        )

        self.frontend_dev = autogen.AssistantAgent(
            name="Frontend_Developer",
            llm_config=coding_llm_config,
            system_message="You implement user interfaces and client-side logic."
        )

        self.tester = autogen.AssistantAgent(
            name="Tester",
            llm_config=llm_config,
            system_message="You write comprehensive tests and identify bugs."
        )

        self.devops = autogen.AssistantAgent(
            name="DevOps",
            llm_config=llm_config,
            system_message="You handle deployment, monitoring, and infrastructure."
        )

        self.user_proxy = create_user_proxy()

    def development_workflow(self, feature: str):
        """Execute full development workflow."""
        # Group chat with all team members
        groupchat = autogen.GroupChat(
            agents=[
                self.user_proxy,
                self.architect,
                self.backend_dev,
                self.frontend_dev,
                self.tester,
                self.devops
            ],
            messages=[],
            max_round=20,
            speaker_selection_method="auto"
        )

        manager = autogen.GroupChatManager(
            groupchat=groupchat,
            llm_config=llm_config
        )

        self.user_proxy.initiate_chat(
            manager,
            message=f"Implement this feature: {feature}"
        )
```

### 6. Usage Example

**examples/autogen_demo.py**:
```python
from src.agents.collaboration import MultiAgentSystem
from src.agents.advanced_patterns import ResearchTeam, CodeTeam

# Simple two-agent conversation
system = MultiAgentSystem()
system.simple_chat("Write a Python function to calculate Fibonacci numbers")

# Code review workflow
system.code_review_workflow("Create a REST API for user authentication")

# Group chat
system.group_chat("Design and implement a caching system")

# Research team
research_team = ResearchTeam()
research_team.research_workflow("Compare RAG implementations with Ollama")

# Development team
code_team = CodeTeam()
code_team.development_workflow("Add real-time notifications to the application")
```

## Agent Patterns

### 1. Sequential Workflow
Agents work in sequence (pipeline)

### 2. Parallel Execution
Multiple agents work simultaneously

### 3. Hierarchical
Manager agent delegates to specialist agents

### 4. Swarm
Agents collaborate dynamically based on task requirements

### 5. Debate
Agents discuss and critique each other's solutions

## Best Practices
- **Clear System Messages**: Define agent roles precisely
- **Termination Conditions**: Always include termination logic
- **Context Management**: Keep conversation history manageable
- **Tool Integration**: Give agents access to tools (code execution, web search)
- **Human in the Loop**: Use for critical decisions
- **Logging**: Track agent conversations for debugging
- **Cost Management**: Monitor token usage with local LLMs
- **Failure Handling**: Implement retry logic and fallbacks

## Monitoring
- Track conversation rounds
- Monitor task completion rate
- Measure collaboration effectiveness
- Log agent decision-making
- Analyze failure patterns
