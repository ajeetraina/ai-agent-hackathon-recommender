# 🏆 AI Agents Hackathon Project Recommender

AI-powered hackathon project recommendations based on GitHub profile analysis and current tech trends.


<img width="713" height="665" alt="image" src="https://github.com/user-attachments/assets/ed8b7984-ea13-4db6-a1f2-85cf3a00b58d" />




## ✨ Features

- **🔍 GitHub Profile Analysis** - Analyzes repositories, languages, and technologies
- **💡 Trend Research** - Discovers current hackathon themes and opportunities  
- **🎯 Personalized Recommendations** - Generates 3 custom project ideas
- **📊 Skills Matching** - Matches projects to your experience level
- **📥 Downloadable Reports** - Export complete analysis as JSON

## 🚀 Quick Start

### Prerequisites
- Docker Desktop with Model Runner enabled
- GitHub Personal Access Token

### Setup

1. **Clone and configure:**
   ```bash
   git clone https://github.com/ajeetraina/project-recommender-agents.git
   cd project-recommender-agents
   
   # Copy environment template
   cp .mcp.env.example .mcp.env
   
   # Edit .mcp.env with your GitHub token
   nano .mcp.env
   ```

2. **Run the application:**
   ```bash
   docker compose up --build
   ```

3. **Access the app:**
   Open http://localhost:3003

## 🔧 How It Works

1. **Enter GitHub username** → MCP GitHub server analyzes profile
2. **Research trends** → MCP DuckDuckGo server finds current themes
3. **AI generates projects** → Docker Model Runner creates recommendations
4. **Download results** → Complete project specifications

## 🛠️ Architecture

- **🤖 AI Model**: Qwen3 8B via Docker Model Runner
- **🔧 MCP Servers**: GitHub, DuckDuckGo, Fetch
- **🖥️ Frontend**: Streamlit
- **🐳 Infrastructure**: Docker Compose + MCP Gateway

## 📋 MCP Tools Used

| Server | Tools | Purpose |
|--------|-------|---------|
| GitHub | `get_user`, `list_user_repos` | Profile & repository analysis |
| DuckDuckGo | `search` | Hackathon trend research |
| Fetch | `fetch_content` | Additional web content |

## 🏗️ Project Structure

```
project-recommender-agents/
├── project-recommender.py    # Main Streamlit application
├── compose.yaml              # Docker Compose configuration
├── Dockerfile               # Container build instructions
├── requirements.txt         # Python dependencies
├── .mcp.env.example        # Environment template
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## 🔐 Environment Variables

Create `.mcp.env` from template and add your GitHub token:

```bash
cp .mcp.env.example .mcp.env
```

Required:
- `github.personal_access_token` - GitHub Personal Access Token with `repo` and `user` scopes






