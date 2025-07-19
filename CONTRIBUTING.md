# Contributing to Minimal Agentic Compose

Thank you for your interest in contributing to this project! We welcome contributions from the community.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/minimal-agentic-compose.git
   cd minimal-agentic-compose
   ```
3. **Create a branch** for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Setting Up Development Environment

1. **Install Docker Desktop** or Docker Engine
2. **Set up OpenAI API key**:
   ```bash
   cp .env.example .env
   # Edit .env and add your OpenAI API key
   ```
3. **Test the demo**:
   ```bash
   docker-compose up --build
   ```

## Types of Contributions

We welcome several types of contributions:

### 🐛 Bug Reports
- Use GitHub Issues with the "bug" label
- Include steps to reproduce the issue
- Provide Docker and environment details
- Include error logs if applicable

### ✨ Feature Requests
- Use GitHub Issues with the "enhancement" label
- Describe the use case and expected behavior
- Consider backward compatibility

### 🔧 Code Contributions

#### Areas Where We Need Help:
- **Additional MCP Servers**: Integration with other MCP servers from the catalog
- **Language Support**: Support for Python, Go, Rust code execution
- **Error Handling**: Better error messages and recovery
- **Performance**: Optimization of container startup and execution
- **Documentation**: More examples and use cases
- **Testing**: Unit tests and integration tests

## Development Guidelines

### Code Style
- **Python**: Follow PEP 8 standards
- **Docker**: Use multi-stage builds where appropriate
- **Documentation**: Use clear, concise comments

### Pull Request Process

1. **Ensure your code follows the project style**
2. **Test your changes thoroughly**:
   ```bash
   # Test basic functionality
   PROBLEM="Test my changes" docker-compose up --build
   
   # Test edge cases
   PROBLEM="Invalid code test" docker-compose up
   ```
3. **Update documentation** if needed
4. **Write clear commit messages**:
   ```
   Add support for Python code execution
   
   - Integrate python-sandbox MCP server
   - Update docker-compose.yml with python service
   - Add Python-specific code generation prompts
   ```
5. **Submit your PR** with:
   - Clear description of changes
   - Link to related issues
   - Screenshots/logs if applicable

### Testing

Since this is a minimal demo, testing should focus on:

- **Functional testing**: Does the agent generate and execute code?
- **Integration testing**: Does the MCP server communicate properly?
- **Error handling**: Does it fail gracefully?
- **Edge cases**: Empty problems, invalid code, timeout scenarios

Example test commands:
```bash
# Test successful execution
PROBLEM="Calculate 2+2" docker-compose up

# Test error handling  
PROBLEM="Intentionally broken code with syntax errors" docker-compose up

# Test timeout
PROBLEM="Create an infinite loop" docker-compose up
```

## Project Structure

```
minimal-agentic-compose/
├── docker-compose.yml       # Main orchestration
├── coding-agent.py          # Core agent logic
├── Dockerfile              # Agent container
├── requirements.txt         # Python dependencies
├── .env.example            # Environment template
└── README.md               # Project documentation
```

### Key Components:

- **`coding-agent.py`**: Main agent with OpenAI integration
- **`docker-compose.yml`**: Orchestrates agent + MCP server
- **MCP Integration**: Uses Alfonso Graziano's node-code-sandbox

## Adding New Features

### Adding a New MCP Server

1. **Update `docker-compose.yml`**:
   ```yaml
   new-mcp-server:
     image: new-mcp-server:latest
     # server configuration
   ```

2. **Update `coding-agent.py`**:
   - Add new execution function
   - Update main() to choose appropriate executor
   - Handle new response formats

3. **Test integration**:
   ```bash
   PROBLEM="Test new MCP server" docker-compose up
   ```

### Adding Language Support

1. **Extend code generation prompts** in `generate_code_solution()`
2. **Add language-specific execution** in new function
3. **Update file extensions** and output formatting
4. **Test with language-specific problems**

## Documentation

When contributing:

- **Update README.md** for new features
- **Add inline comments** for complex logic
- **Include example usage** in commit messages
- **Document environment variables** and configuration

## Security Considerations

- **Never commit API keys** or secrets
- **Test with malicious code** to ensure sandboxing works
- **Validate user inputs** before processing
- **Use minimal Docker images** to reduce attack surface

## Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Discord/Docker Community**: For general Docker questions

## Recognition

Contributors will be recognized in:
- GitHub contributors list
- Release notes for significant contributions
- README acknowledgments

## License

By contributing, you agree that your contributions will be licensed under the same dual license as the project (MIT OR Apache-2.0).

---

Thank you for contributing to Minimal Agentic Compose! 🚀
