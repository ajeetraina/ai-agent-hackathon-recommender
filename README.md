# Minimal Agentic Compose

A minimal Docker Compose setup for building AI agents with Node.js code execution capabilities using **official Agentic Compose patterns** and Docker Model Runner.

> ⚡ **Now using Official Agentic Compose!** This project follows the latest Docker Compose for AI specifications released July 2025.

## Features

- **Coding Agent**: AI agent that solves coding problems using JavaScript/Node.js
- **Docker Model Runner**: Local LLM execution with GPU acceleration (no API keys needed)
- **Official Agentic Compose**: Uses the new Docker Compose AI patterns 
- **MCP Gateway Integration**: Standardized tool integration via Model Context Protocol
- **Multiple Deployment Options**: Local models, OpenAI, and Docker Offload

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop 4.43.0+** with [Docker Model Runner](https://docs.docker.com/ai/model-runner/) support
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
PROBLEM="Implement binary search algorithm" \
docker compose -f compose.yaml -f compose.openai.yaml up --build
```

### 3. Docker Offload Setup (Cloud GPU)

```bash
# Enable Docker Offload in Docker Desktop Settings > Beta Features
# Or via CLI: docker offload start

# Run with Docker Offload (larger models on cloud GPU)
PROBLEM="Generate a sorting algorithm comparison" \
docker compose -f compose.yaml -f compose.offload.yaml up --build
```

## 🏗️ Agentic Compose Architecture

This project uses the **official Agentic Compose patterns** from Docker's AI framework:

```
🤖 Agent App → 📡 MCP Gateway → 🔧 Tools (Node.js Sandbox)
     ↓              ↓              ↓
🧠 Model Layer  →  📊 SSE Transport → ⚡ Code Execution
     ↓              ↓              ↓  
💾 Results     →  🔍 Analysis     → 📁 Output Files
```

### Key Components

| Layer | Component | Description |
|-------|-----------|-------------|
| **App** | `coding-agent` | Python application using OpenAI client |
| **Gateway** | `mcp-gateway` | MCP protocol gateway with SSE transport |
| **Tools** | `node-code-sandbox` | Containerized JavaScript execution |
| **Models** | `qwen3` | Local LLM via Docker Model Runner |

## 📋 Agentic Compose Configuration

The project follows Docker's new AI-first compose syntax:

```yaml
# compose.yaml
services:
  coding-agent:
    models:
      qwen3:
        endpoint_var: OPENAI_BASE_URL    # Auto-injected by Docker
        model_var: OPENAI_MODEL          # Auto-injected by Docker
    depends_on:
      - mcp-gateway

  mcp-gateway:
    image: docker/mcp-gateway:latest
    command:
      - --transport=sse                  # Server-Sent Events
      - --servers=node-code-sandbox
      - --tools=run_js

# Top-level models section (new in Agentic Compose)
models:
  qwen3:
    model: ai/qwen3:8B-Q4_0
    context_size: 8096
```

### How It Works

1. **Automatic Environment Injection**: Docker Compose automatically injects `OPENAI_BASE_URL` and `OPENAI_MODEL` based on service-level model configuration
2. **Model Lifecycle Management**: Docker handles model pulling, starting, and endpoint configuration
3. **Standardized Communication**: MCP Gateway uses SSE transport for reliable tool communication
4. **GPU Acceleration**: Automatic GPU detection and utilization through Docker Model Runner

## 🔧 Deployment Options

| Mode | Command | Requirements | Use Case |
|------|---------|--------------|----------|
| **Local** | `docker compose up` | Docker Desktop 4.43.0+, 7GB VRAM | Development |
| **OpenAI** | `docker compose -f compose.yaml -f compose.openai.yaml up` | OpenAI API key | Testing/Fallback |
| **Offload** | `docker compose -f compose.yaml -f compose.offload.yaml up` | Docker Offload enabled | Production/Large models |

## 📊 Model Options

| Model | Size | VRAM | Deployment |
|-------|------|------|------------|
| **qwen3:8B-Q4_0** | 4.44 GB | 7 GB | Local (default) |
| **qwen3:14B-Q6_K** | 11.28 GB | 15 GB | Docker Offload |
| **qwen3:30B** | 17.28 GB | 20+ GB | Docker Offload only |

## 🧪 Example Problems

```bash
# Algorithm challenges
PROBLEM="Implement quicksort algorithm" docker compose up --build

# Data processing
PROBLEM="Parse CSV and calculate averages" docker compose up --build

# Math problems  
PROBLEM="Calculate compound interest with monthly contributions" docker compose up --build

# File generation
PROBLEM="Generate JSON file with sample user data" docker compose up --build
```

## 📁 Output Files

Generated in `./output/` directory:
- **`solution.js`** - Generated JavaScript code
- **`result.txt`** - Human-readable execution results and AI analysis  
- **`result.json`** - Structured data for programmatic use

Files created by executed code saved in `./sandbox-output/`.

## 🐛 Troubleshooting

### ✅ Fixed: "backend not found" Error

**Previous Issue**: Coding agent couldn't connect to Docker Model Runner.

**Solution Applied**: Updated to official Agentic Compose patterns:
- ✅ Service-level model configuration with `endpoint_var` and `model_var`
- ✅ Automatic environment variable injection by Docker Compose
- ✅ SSE transport for MCP Gateway
- ✅ Proper model lifecycle management

### Common Issues

**Docker Model Runner not starting:**
- Ensure Docker Desktop 4.43.0+ with AI features enabled
- Check GPU availability: `docker run --rm --gpus all nvidia/cuda:12.0-base nvidia-smi`
- Try smaller model: Use default `qwen3:8B-Q4_0`

**Environment variables not injected:**
- Verify service-level `models:` configuration exists
- Check Docker Compose version: `docker compose version` (needs 2.38.1+)
- Confirm top-level `models:` section is present

**OpenAI fallback:**
```bash
export OPENAI_API_KEY=your_key_here
PROBLEM="Create a function to find prime numbers under 100" \
docker compose -f compose.yaml -f compose.openai.yaml up --build
```

### Docker Model Runner Diagnostics

```bash
# Check Docker version
docker --version  # Should be 4.43.0+

# Test Model Runner availability  
docker model --help

# List available models
docker model ls

# Manual model pull
docker model pull ai/qwen3:8B-Q4_0
```

## 📚 File Structure

```
minimal-agentic-compose/
├── compose.yaml              # Main Agentic Compose configuration
├── compose.openai.yaml       # OpenAI override
├── compose.offload.yaml      # Docker Offload override
├── coding-agent.py           # Multi-provider AI agent
├── Dockerfile               # Agent container definition
├── requirements.txt          # Python dependencies
├── output/                  # Generated results directory
└── sandbox-output/          # Files created by executed code
```

## 🎯 What's New

This version includes:

- ✅ **Official Agentic Compose patterns** from Docker's July 2025 release
- ✅ **Service-level model configuration** with automatic environment injection
- ✅ **SSE transport** for MCP Gateway communication
- ✅ **Enhanced Docker Model Runner integration** 
- ✅ **Improved error handling** and debugging
- ✅ **Cloud GPU support** via Docker Offload

## 📖 References

- [Docker Compose for Agents](https://github.com/docker/compose-for-agents) - Official Docker AI agent examples
- [Docker Model Runner](https://docs.docker.com/ai/model-runner/) - Local model execution docs
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification
- [Agentic Compose Guide](https://docs.docker.com) - Official Docker AI documentation

## 🤝 Contributing

We welcome contributions! This project demonstrates cutting-edge Docker AI capabilities.

## 📄 License

Dual-licensed under [MIT License](LICENSE-MIT) or [Apache License 2.0](LICENSE-APACHE).

---

**🚀 Perfect for learning the latest Docker AI patterns with official Agentic Compose!**
