# Minimal Agentic Compose

A truly minimal agentic system that **solves coding problems** using AI + Node.js code execution. This demonstrates real agentic behavior where the AI writes, tests, and analyzes code using Docker Compose orchestration.

[![License: MIT OR Apache-2.0](https://img.shields.io/badge/License-MIT%20OR%20Apache--2.0-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Required-blue.svg)](https://www.docker.com/)
[![OpenAI](https://img.shields.io/badge/OpenAI-API-green.svg)](https://openai.com/)

## What It Does

This demo showcases a complete agentic workflow:

1. 🧠 **Takes a coding problem** (e.g., "Sort array by date")
2. 💡 **AI generates JavaScript solution** using OpenAI GPT
3. 🏃 **Executes code safely** in Node.js sandbox container  
4. 📊 **Analyzes results** and provides intelligent feedback
5. 💾 **Saves code + results** for review

## Architecture

```
🤖 Coding Agent → 🧠 OpenAI → 📝 Generate Code
       ↓
🏃 Node.js Sandbox → ⚡ Execute → 📊 Return Results  
       ↓
🔍 AI Analysis → 💾 Save Files
```

**MCP Server Used:** [Alfonso Graziano's node-code-sandbox-mcp](https://github.com/alfonsograziano/node-code-sandbox-mcp)

## Quick Start

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) 4.43.0+ or [Docker Engine](https://docs.docker.com/engine/)
- OpenAI API key ([Get one here](https://platform.openai.com/api-keys))

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ajeetraina/minimal-agentic-compose.git
   cd minimal-agentic-compose
   ```

2. **Set your OpenAI API key:**
   ```bash
   export OPENAI_API_KEY=your_openai_api_key_here
   ```
   
   Or create a `.env` file:
   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```

3. **Run the demo:**
   ```bash
   PROBLEM="Create a function to find prime numbers under 100" docker-compose up --build
   ```

4. **Check the results:**
   ```bash
   cat output/solution.js    # Generated code
   cat output/result.txt     # Execution results + AI analysis
   ls sandbox-output/        # Any files created by the code
   ```

## Example Problems

```bash
# Algorithm challenges
PROBLEM="Implement binary search algorithm" docker-compose up

# Data manipulation
PROBLEM="Parse CSV data and calculate averages" docker-compose up

# Math problems  
PROBLEM="Calculate compound interest with monthly contributions" docker-compose up

# Utility functions
PROBLEM="Create a URL validator function" docker-compose up

# File generation
PROBLEM="Generate a JSON file with sample user data" docker-compose up
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

## Advanced Usage

### Using OpenAI Models Instead of Local Models

The demo uses OpenAI by default, but you can customize the model:

```python
# Edit coding-agent.py, line 37
model="gpt-4"  # or "gpt-3.5-turbo"
```

### Customization Options

- **Change execution timeout:** Modify `timeout=60` in `execute_code_in_sandbox()`
- **Add more dependencies:** Update the code generation prompt to include npm packages
- **Different analysis:** Customize the analysis prompt in `analyze_results()`
- **Output format:** Modify file writing in `main()`

### Development Mode

For development and testing:

```bash
# Build and run with verbose output
docker-compose up --build --verbose

# Run without rebuilding
docker-compose up

# Clean up containers
docker-compose down
```

## File Structure

```
minimal-agentic-compose/
├── docker-compose.yml       # Orchestration configuration
├── coding-agent.py          # Main AI agent application
├── Dockerfile              # Agent container definition
├── requirements.txt         # Python dependencies
├── .env.example            # Environment variables template
├── .dockerignore           # Docker ignore rules
├── .gitignore             # Git ignore rules
├── LICENSE-MIT            # MIT License
├── LICENSE-APACHE         # Apache 2.0 License
├── CONTRIBUTING.md        # Contribution guidelines
├── README.md              # This file
└── output/                # Generated results directory
    ├── solution.js        # Generated JavaScript code
    ├── result.txt         # Human-readable results
    └── result.json        # Structured results data
```

## Why This Demo is Powerful

Unlike complex multi-agent orchestrations, this minimal demo:

- ✅ **Real agentic behavior** - AI writes AND tests code
- ✅ **Safe execution** - Sandboxed Node.js containers  
- ✅ **Immediate feedback** - See if the solution actually works
- ✅ **Educational** - Learn from generated code and analysis
- ✅ **Production patterns** - Shows real AI-code integration
- ✅ **Minimal complexity** - Single agent, clear purpose
- ✅ **Zero configuration** - Just set API key and run

## Technical Details

### MCP Server Integration

This demo uses [Alfonso Graziano's node-code-sandbox-mcp](https://github.com/alfonsograziano/node-code-sandbox-mcp) server, which provides:

- Ephemeral Docker containers for code execution
- npm dependency installation support  
- File system operations and file return capabilities
- Resource limits for security (CPU/memory controls)
- Clean container teardown after execution

### Security Considerations

- Code executes in isolated Docker containers
- Containers have resource limits (CPU/memory)
- No persistent state between executions
- Docker socket access limited to sandbox operations
- Generated files are returned safely

## Troubleshooting

### Common Issues

**"Failed to connect to sandbox"**
- Ensure Docker is running
- Check that Docker socket is accessible: `docker ps`

**"Error generating code"**  
- Verify OpenAI API key is set correctly
- Check API key has sufficient credits

**"Permission denied"**
- Ensure Docker socket permissions: `sudo chmod 666 /var/run/docker.sock` (Linux)

**Empty output files**
- Check Docker logs: `docker-compose logs coding-agent`
- Verify the problem statement is clear

### Getting Help

1. Check the [Issues](https://github.com/ajeetraina/minimal-agentic-compose/issues) page
2. Review Docker and OpenAI documentation
3. Join the [Docker Community](https://www.docker.com/community/)

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is dual-licensed under the [MIT License](LICENSE-MIT) or [Apache License 2.0](LICENSE-APACHE), at your option.

## Related Projects

- [Docker Compose for Agents](https://github.com/docker/compose-for-agents) - Collection of AI agent demos
- [Alfonso Graziano's Node.js Sandbox MCP](https://github.com/alfonsograziano/node-code-sandbox-mcp) - The MCP server used in this demo
- [Model Context Protocol](https://modelcontextprotocol.io/) - The protocol standard

---

**Perfect for learning agentic patterns without complexity!** 🚀
