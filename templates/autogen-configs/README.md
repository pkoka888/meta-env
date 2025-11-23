# AutoGen Agent Configurations

This directory contains pre-configured AutoGen multi-agent teams for different tasks.

## Available Teams

### 1. Research Team (`research-team.json`)
**Purpose**: Comprehensive research and analysis tasks

**Agents**:
- **Researcher**: Gathers information from multiple sources
- **Analyst**: Analyzes data and identifies patterns
- **Critic**: Provides critical review and validation
- **Writer**: Creates professional documentation

**Use Cases**:
- Competitive analysis
- Technology evaluation
- Market research
- Literature review

### 2. Code Team (`code-team.json`)
**Purpose**: Software development and code quality

**Agents**:
- **Architect**: Designs system architecture
- **Developer**: Implements features
- **Tester**: Writes and runs tests
- **Reviewer**: Reviews code quality
- **Security Expert**: Performs security audits

**Use Cases**:
- Feature development
- Code refactoring
- Security audits
- Technical debt reduction

### 3. Analysis Team (`analysis-team.json`)
**Purpose**: Data analysis and insights generation

**Agents**:
- **Data Engineer**: Prepares and cleans data
- **Statistician**: Performs statistical analysis
- **ML Engineer**: Builds predictive models
- **Visualizer**: Creates visualizations
- **Interpreter**: Translates to business insights

**Use Cases**:
- Data analysis projects
- Predictive modeling
- Business intelligence
- Statistical reports

## Usage

### Python Example

```python
import autogen
import json

# Load team configuration
with open('templates/autogen-configs/research-team.json', 'r') as f:
    config = json.load(f)

# Initialize agents
agents = []
for agent_config in config['agents']:
    if agent_config['name'] == 'user_proxy':
        agent = autogen.UserProxyAgent(
            name=agent_config['name'],
            human_input_mode=agent_config['human_input_mode'],
            max_consecutive_auto_reply=agent_config['max_consecutive_auto_reply'],
            code_execution_config=agent_config.get('code_execution_config')
        )
    else:
        agent = autogen.AssistantAgent(
            name=agent_config['name'],
            system_message=agent_config['system_message'],
            llm_config=agent_config['llm_config']
        )
    agents.append(agent)

# Create group chat
groupchat = autogen.GroupChat(
    agents=agents,
    messages=[],
    max_round=config['termination']['max_rounds']
)

manager = autogen.GroupChatManager(groupchat=groupchat)

# Start task
user_proxy = agents[-1]  # Last agent is user_proxy
user_proxy.initiate_chat(
    manager,
    message="Research the latest trends in AI-powered development tools"
)
```

## Configuration Options

### Agent Settings

- **name**: Unique identifier for the agent
- **role**: Human-readable role description
- **system_message**: Instructions for the agent's behavior
- **llm_config**: LLM configuration (model, temperature, timeout)
- **human_input_mode**: "NEVER", "TERMINATE", or "ALWAYS"
- **max_consecutive_auto_reply**: Maximum automatic responses
- **code_execution_config**: Configuration for code execution

### LLM Configuration

```json
{
  "config_list": [
    {
      "model": "ollama/llama3:8b",
      "base_url": "http://localhost:11434",
      "api_key": "ollama"
    }
  ],
  "temperature": 0.7,
  "timeout": 120
}
```

### Workflow Types

- **sequential**: Agents work in order
- **round_robin**: Agents take turns
- **dynamic**: Manager decides who speaks next

## Customization

### Adding Custom Agents

```json
{
  "name": "custom_agent",
  "role": "Custom Role",
  "system_message": "Your custom instructions here",
  "llm_config": {
    "config_list": [
      {
        "model": "ollama/llama3:8b",
        "base_url": "http://localhost:11434",
        "api_key": "ollama"
      }
    ],
    "temperature": 0.5
  },
  "human_input_mode": "NEVER",
  "max_consecutive_auto_reply": 5
}
```

### Modifying Workflow

Edit the `workflow` section to change agent execution order:

```json
{
  "workflow": {
    "type": "sequential",
    "steps": [
      {"agent": "agent1", "description": "First step"},
      {"agent": "agent2", "description": "Second step"}
    ]
  }
}
```

## Best Practices

1. **Choose the right team**: Match the team to your task type
2. **Adjust temperature**: Lower for deterministic tasks, higher for creative
3. **Set appropriate timeouts**: Complex tasks may need longer timeouts
4. **Monitor token usage**: Track costs if using paid APIs
5. **Review output**: Always validate agent-generated results
6. **Iterate configurations**: Fine-tune based on results

## Troubleshooting

### Ollama Connection Issues

```python
# Test Ollama connection
import requests
response = requests.get('http://localhost:11434/api/tags')
print(response.json())
```

### Agent Not Responding

- Check system_message clarity
- Verify llm_config is correct
- Increase max_consecutive_auto_reply
- Check Ollama logs

### Infinite Loops

- Set reasonable max_rounds
- Use clear termination messages
- Review agent system messages for conflicts

## Resources

- [AutoGen Documentation](https://microsoft.github.io/autogen/)
- [Ollama Models](https://ollama.com/library)
- [LiteLLM Proxy](https://docs.litellm.ai/)
