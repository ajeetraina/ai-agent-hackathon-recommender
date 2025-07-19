# Minimal Agentic Compose

A truly minimal agentic system that **solves coding problems** using AI + Node.js code execution. This demonstrates real agentic behavior where the AI writes, tests, and analyzes code using Docker Compose orchestration.

[![License: MIT OR Apache-2.0](https://img.shields.io/badge/License-MIT%20OR%20Apache--2.0-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)

## What It Does

This demo showcases a complete agentic workflow:

1. 🧠 **Takes a coding problem** (e.g., "Sort array by date")
2. 💡 **AI generates JavaScript solution** using local LLM (Docker Model Runner) or OpenAI
3. 🏃 **Executes code safely** in Node.js sandbox container  
4. 📊 **Analyzes results** and provides intelligent feedback
5. 💾 **Saves code + results** for review

## Architecture

```
🤖 Coding Agent → 🧠 LLM (DMR/OpenAI/Offload) → 📝 Generate Code
       ↓
🏃 Node.js Sandbox → ⚡ Execute → 📊 Return Results  
       ↓
🔍 AI Analysis → 💾 Save Files
```

**MCP Server Used:** [Alfonso Graziano's node-code-sandbox-mcp](https://github.com/alfonsograziano/node-code-sandbox-mcp)

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) 4.43.0+ or [Docker Engine](https://docs.docker.com/engine/)
- A laptop or workstation with a GPU (e.g., a MacBook) for running open models locally
- If you don't have a GPU, you can use [Docker Offload](https://www.docker.com/products/docker-offload) or OpenAI
- If using Docker Engine on Linux, ensure [Docker Model Runner requirements](https://docs.docker.com/ai/model-runner/) are met

## Quick Start

### Method 1: Local Models (Default - Docker Model Runner)

```bash
# Clone and setup
git clone https://github.com/ajeetraina/minimal-agentic-compose.git
cd minimal-agentic-compose

# Run with local models (no API key needed!)
PROBLEM="Create a function to find prime numbers under 100" docker compose up --build
```

### Method 2: OpenAI Models

```bash
# Set your OpenAI API key
echo "sk-your_openai_api_key_here" > secret.openai-api-key

# Or set environment variable
export OPENAI_API_KEY=your_openai_api_key_here

# Run with OpenAI
PROBLEM="Implement binary search" docker compose -f compose.yaml -f compose.openai.yaml up --build
```

### Method 3: Docker Offload

```bash
# Set your Docker Offload token
export DOCKER_OFFLOAD_TOKEN=your_token_here

# Run with Docker Offload
PROBLEM="Generate JSON data" docker compose -f compose.yaml -f compose.offload.yaml up --build
```

## Configuration Options

The demo supports multiple configuration methods:

### Environment Variables
```bash
# Create .mcp.env from template
cp .mcp.env.example .mcp.env
# Edit .mcp.env with your settings

# Or set variables directly
PROBLEM="Your coding problem" docker compose up
```

### Model Providers

| Provider | Compose Command | Requirements |
|----------|----------------|--------------|
| **Docker Model Runner** (Default) | `docker compose up` | Local GPU recommended |
| **OpenAI** | `docker compose -f compose.yaml -f compose.openai.yaml up` | OpenAI API key |
| **Docker Offload** | `docker compose -f compose.yaml -f compose.offload.yaml up` | Docker Offload token |

## Example Problems

```bash
# Algorithm challenges
PROBLEM="Implement quicksort algorithm" docker compose up

# Data manipulation
PROBLEM="Parse CSV data and calculate averages" docker compose up

# Math problems  
PROBLEM="Calculate compound interest with monthly contributions" docker compose up

# File generation
PROBLEM="Generate a JSON file with sample user data" docker compose up

# Web utilities
PROBLEM="Create a URL validator function" docker compose up
```

## Output Files

The demo creates several output files:

- **`output/solution.js`** - The generated JavaScript code
- **`output/result.txt`** - Human-readable execution results + AI analysis  
- **`output/result.json`** - Structured data for programmatic use
- **`sandbox-output/`** - Any files created by the executed code

## Example Output

**Input:** `PROBLEM="Calculate the first 10 Fibonacci numbers"`

**Generated Code:**
```javascript
// Problem: Calculate the first 10 Fibonacci numbers
// Generated: 2024-07-19T10:30:45
// Model Provider: docker-model-runner
// Model: llama3.2:3b
// MCP Server: Alfonso Graziano's node-code-sandbox

function fibonacci(n) {
    const sequence = [0, 1];
    
    for (let i = 2; i < n; i++) {
        sequence[i] = sequence[i-1] + sequence[i-2];
    }
    
    return sequence;
}

const result = fibonacci(10);
console.log("First 10 Fibonacci numbers:", result);
console.log("Sum:", result.reduce((a, b) => a + b, 0));
```

**Execution Result:** ✅ SUCCESS  
**Output:** `First 10 Fibonacci numbers: [0,1,1,2,3,5,8,13,21,34]`  
**AI Analysis:** "The solution correctly implements the Fibonacci sequence using an iterative approach. The code is clean, efficient, and includes helpful output for verification."

## File Structure

```
minimal-agentic-compose/
├── compose.yaml             # Main compose file (Docker Model Runner)
├── compose.openai.yaml      # OpenAI override
├── compose.offload.yaml     # Docker Offload override
├── coding-agent.py          # Multi-provider AI agent
├── Dockerfile              # Agent container definition
├── requirements.txt         # Python dependencies
├── .mcp.env.example        # MCP environment template
├── .env.example            # General environment template
├── examples/               # Sample outputs and examples
├── .github/workflows/      # CI/CD pipeline
└── output/                 # Generated results directory
```

## Advanced Usage

### Custom Models

Edit the compose files to use different models:

```yaml
# In compose.yaml for Docker Model Runner
environment:
  - MODEL_NAME=llama3.2:1b  # Smaller, faster model

# In compose.openai.yaml for OpenAI
environment:
  - MODEL_NAME=gpt-4        # More powerful model
```

### Development Mode

```bash
# Build and run with verbose output
docker compose up --build --verbose

# Run without rebuilding
docker compose up

# Clean up everything
docker compose down -v
```

### Custom Problems via File

```bash
# Create a problem file
echo "Build a web scraper for parsing HTML" > my-problem.txt

# Pass it to the agent
PROBLEM="$(cat my-problem.txt)" docker compose up
```

## Why This Demo is Powerful

Unlike complex multi-agent orchestrations, this minimal demo:

- ✅ **Multiple Model Options** - Local LLMs, OpenAI, or Docker Offload
- ✅ **Real Agentic Behavior** - AI writes AND tests code
- ✅ **Safe Execution** - Sandboxed Node.js containers  
- ✅ **No API Required** - Default uses local models via Docker Model Runner
- ✅ **Production Patterns** - Shows real AI-code integration
- ✅ **Minimal Complexity** - Single agent, clear purpose
- ✅ **Compose Best Practices** - Multiple compose files for different scenarios

## Technical Details

### Model Providers

1. **Docker Model Runner** (Default)
   - Runs models locally using Docker
   - No internet connection required
   - GPU acceleration supported
   - Models: llama3.2:3b, llama3.2:1b, etc.

2. **OpenAI**
   - Uses OpenAI's API
   - Requires API key and internet
   - Models: gpt-3.5-turbo, gpt-4, etc.

3. **Docker Offload**
   - Uses Docker's cloud model service
   - Requires Docker Offload token
   - Models: Various cloud-hosted options

### MCP Server Integration

Uses [Alfonso Graziano's node-code-sandbox-mcp](https://github.com/alfonsograziano/node-code-sandbox-mcp):

- Ephemeral Docker containers for code execution
- npm dependency installation support  
- File system operations and file return capabilities
- Resource limits for security (CPU/memory controls)
- Clean container teardown after execution

## Troubleshooting

### Common Issues

**"model-runner service not starting"**
- Ensure Docker has GPU access enabled
- Try with a smaller model: `MODEL_NAME=llama3.2:1b`
- Use OpenAI instead: `docker compose -f compose.yaml -f compose.openai.yaml up`

**"Failed to connect to sandbox"**
- Ensure Docker is running: `docker ps`
- Check Docker socket permissions

**"Error generating code"**  
- For OpenAI: Verify API key and credits
- For Docker Model Runner: Check model download progress
- For Docker Offload: Verify token validity

**Empty output files**
- Check logs: `docker compose logs coding-agent`
- Verify the problem statement is clear

### Performance Tips

- **Local Models**: Use GPU-enabled Docker for faster inference
- **OpenAI**: Use gpt-3.5-turbo for faster responses
- **Docker Offload**: Choose appropriate model size for your needs

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is dual-licensed under the [MIT License](LICENSE-MIT) or [Apache License 2.0](LICENSE-APACHE), at your option.

## Related Projects

- [Docker Compose for Agents](https://github.com/docker/compose-for-agents) - Collection of AI agent demos
- [Alfonso Graziano's Node.js Sandbox MCP](https://github.com/alfonsograziano/node-code-sandbox-mcp) - The MCP server used in this demo
- [Model Context Protocol](https://modelcontextprotocol.io/) - The protocol standard
- [Docker Model Runner](https://docs.docker.com/ai/model-runner/) - Local model execution

---

**Perfect for learning agentic patterns with real model flexibility!** 🚀
