# Minimal Agentic Compose

A minimal Docker Compose setup for building AI agents with Node.js code execution capabilities using Docker Model Runner, MCP Gateway, and Node.js Sandbox.

## Features

- **Coding Agent**: AI agent that solves coding problems using JavaScript/Node.js
- **Docker Model Runner**: Local LLM execution with GPU acceleration (no API keys needed)
- **MCP Gateway**: Secure gateway for Model Context Protocol servers
- **Node.js Sandbox**: Safe code execution environment via MCP
- **Multiple Deployment Options**: Local models, OpenAI, and Docker Offload

## Quick Start

### Prerequisites

- [Docker Desktop 4.43.0+](https://www.docker.com/products/docker-desktop/) or [Docker Engine](https://docs.docker.com/engine/) with Docker Compose 2.38.1+
- For local models: GPU recommended (MacBook M-series, NVIDIA GPU, etc.)
- For Docker Offload: Enable in Docker Desktop Settings > Beta Features

### 1. Default Setup (Docker Model Runner - Local Models)

```bash
# Clone the repository
git clone https://github.com/ajeetraina/minimal-agentic-compose.git
cd minimal-agentic-compose

# Run with local models (no API key needed!)
PROBLEM="Create a function to find prime numbers under 100" docker compose up --build
```

### 2. OpenAI Setup

```bash
# Set your OpenAI API key
export OPENAI_API_KEY=your_openai_api_key_here

# Run with OpenAI models
PROBLEM="Implement binary search algorithm" OPENAI_API_KEY=$OPENAI_API_KEY docker compose -f compose.yaml -f compose.openai.yaml up --build
```

### 3. Docker Offload Setup (Cloud GPU)

```bash
# Enable Docker Offload in Docker Desktop Settings > Beta Features
# Or via CLI: docker offload start

# Run with Docker Offload (larger models on cloud GPU)
PROBLEM="Generate a sorting algorithm comparison" docker compose -f compose.yaml -f compose.offload.yaml up --build
```

## Architecture

```
🤖 Coding Agent → 🧠 Docker Model Runner (Local LLM) → 📝 Generate Code
       ↓
🔒 MCP Gateway → 🏃 Node.js Sandbox → ⚡ Execute Code → 📊 Return Results  
       ↓
🔍 AI Analysis → 💾 Save Files (./output/)
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| **coding-agent** | - | Main AI agent that generates and executes code |
| **mcp-gateway** | 8811 | Secure gateway managing node-sandbox MCP server |

## Models

| Model | Size | VRAM | Use Case |
|-------|------|------|----------|
| **qwen3-small** | 4.44 GB | 7 GB | Development, fast inference |
| **qwen3-medium** | 11.28 GB | 15 GB | Better quality, more complex problems |
| **qwen3-large** | 17.28 GB | 20 GB | Best quality, Docker Offload recommended |

## Example Problems

```bash
# Algorithm challenges
PROBLEM="Implement quicksort algorithm" docker compose up --build

# Data processing
PROBLEM="Parse CSV and calculate averages" docker compose up --build

# Math problems  
PROBLEM="Calculate compound interest with monthly contributions" docker compose up --build

# File generation
PROBLEM="Generate JSON file with sample user data" docker compose up --build

# Web utilities
PROBLEM="Create a URL validator function" docker compose up --build
```

## Output Files

The agent creates several output files in the `./output/` directory:

- **`solution.js`** - The generated JavaScript code
- **`result.txt`** - Human-readable execution results and AI analysis  
- **`result.json`** - Structured data for programmatic use

Any files created by the executed code are saved in `./sandbox-output/`.

## Configuration Options

### Model Providers

| Provider | Command | Requirements |
|----------|---------|--------------|
| **Docker Model Runner** (Default) | `docker compose up` | Local GPU recommended |
| **OpenAI** | `docker compose -f compose.yaml -f compose.openai.yaml up` | OpenAI API key |
| **Docker Offload** | `docker compose -f compose.yaml -f compose.offload.yaml up` | Docker Desktop 4.43.0+, Beta Features enabled |

### Environment Variables

```bash
# Problem to solve
PROBLEM="Your coding challenge here"

# OpenAI API key (for OpenAI provider)
OPENAI_API_KEY=your_api_key_here

# Model selection (for OpenAI)
MODEL_NAME=gpt-3.5-turbo  # or gpt-4
```

## Docker Offload

Docker Offload is a built-in feature of Docker Desktop 4.43.0+ that automatically provisions cloud GPU infrastructure when your local machine needs more resources.

**Setup:**
1. **Docker Desktop**: Go to Settings > Beta Features > Enable "Docker Offload"
2. **CLI**: Run `docker offload start` and select your account
3. **GPU Support**: Choose "Enable GPU" for AI workloads

**Benefits:**
- **No tokens or authentication needed** - uses your Docker account
- **Automatic provisioning** - cloud GPU instances when needed  
- **Same commands** - `docker compose up` works the same way
- **NVIDIA L4 GPUs** - 23GB memory for large models

**Verification:**
```bash
# Check Docker Offload status
docker offload status

# Verify you're using cloud instance
docker info | grep "Operating System"
# Should show: Operating System: Ubuntu 22.04.5 LTS (cloud)

# Check GPU availability
docker run --rm --gpus all nvidia/cuda:12.4.0-runtime-ubuntu22.04 nvidia-smi
```

## How It Works

1. **Problem Input**: You provide a coding problem via the `PROBLEM` environment variable
2. **Code Generation**: The AI agent generates JavaScript code using your chosen model
3. **Safe Execution**: Code runs in an isolated Node.js container via MCP Gateway
4. **Analysis**: The AI analyzes results and provides insights
5. **Output**: Generated code, execution results, and analysis are saved locally

## Technical Details

### MCP Integration

- **MCP Gateway**: Securely manages the node-sandbox MCP server
- **Node.js Sandbox**: Provides isolated JavaScript execution environment
- **Docker API Socket**: Allows MCP Gateway to manage sandbox containers

### Model Integration

- **Docker Model Runner**: Provides OpenAI-compatible API for local models
- **Environment Variables**: Automatically injected for model endpoints
- **GPU Acceleration**: Automatic GPU detection and utilization

## File Structure

```
minimal-agentic-compose/
├── compose.yaml             # Main compose file (Docker Model Runner)
├── compose.openai.yaml      # OpenAI override
├── compose.offload.yaml     # Docker Offload override
├── coding-agent.py          # Multi-provider AI agent
├── Dockerfile              # Agent container definition
├── requirements.txt         # Python dependencies
├── agents.yaml             # Agent configuration
├── .mcp.env               # MCP environment (no secrets needed)
├── output/                 # Generated results directory
└── sandbox-output/         # Files created by executed code
```

## Troubleshooting

### Common Issues

**Docker Model Runner not starting:**
- Ensure Docker has GPU access enabled
- Try smaller model: Use `qwen3-small` instead of `qwen3-medium`
- Check available VRAM: `nvidia-smi` (NVIDIA) or Activity Monitor (macOS)

**MCP Gateway connection failed:**
- Verify Docker socket access: `docker ps` should work
- Check MCP Gateway logs: `docker compose logs mcp-gateway`

**Code execution fails:**
- Check sandbox container logs: `docker compose logs coding-agent`
- Verify Docker socket permissions

**OpenAI authentication:**
- Verify API key: `echo $OPENAI_API_KEY`
- Check API key permissions and credits

**Docker Offload issues:**
- Enable in Docker Desktop: Settings > Beta Features > Docker Offload
- Start session: `docker offload start`
- Check status: `docker offload status`

### Performance Tips

- **Local Models**: Use GPU-enabled Docker for faster inference
- **OpenAI**: Use `gpt-3.5-turbo` for faster responses
- **Docker Offload**: Automatically provisions optimal hardware

## Example Output

**Input:** `PROBLEM="Calculate the first 10 Fibonacci numbers"`

**Generated Code:**
```javascript
// Problem: Calculate the first 10 Fibonacci numbers
// Generated: 2025-07-19T10:30:45Z
// Model Provider: docker-model-runner
// Model: qwen3-small

function fibonacci(n) {
    const sequence = [0, 1];
    for (let i = 2; i < n; i++) {
        sequence[i] = sequence[i-1] + sequence[i-2];
    }
    return sequence;
}

const result = fibonacci(10);
console.log("First 10 Fibonacci numbers:", result);
```

**Execution Result:** ✅ SUCCESS  
**Output:** `First 10 Fibonacci numbers: [0,1,1,2,3,5,8,13,21,34]`  
**AI Analysis:** "The solution correctly implements the Fibonacci sequence using an iterative approach. Clean, efficient code with proper output."

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is dual-licensed under the [MIT License](LICENSE-MIT) or [Apache License 2.0](LICENSE-APACHE), at your option.

## Related Projects

- [Docker Compose for Agents](https://github.com/docker/compose-for-agents) - Official collection of AI agent demos
- [Docker Model Runner](https://docs.docker.com/ai/model-runner/) - Local model execution documentation
- [Model Context Protocol](https://modelcontextprotocol.io/) - Protocol for AI-tool integration
- [Alfonso Graziano's Node.js Sandbox MCP](https://github.com/alfonsograziano/node-code-sandbox-mcp) - The MCP server used for code execution

---

**Perfect for learning agentic patterns with real Docker Model Runner integration!** 🚀
