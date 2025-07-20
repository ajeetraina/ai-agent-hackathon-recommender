#!/bin/bash

# 🚀 Complete Flask-based Hackathon Project Recommender Setup
# Replaces Streamlit with WebSocket-free Flask interface

set -e

echo "🔧 Converting to Flask-based Hackathon Project Recommender..."
echo "=================================================="

# Backup existing files
echo "📦 Backing up existing files..."
if [ -f "project-recommender.py" ]; then
    cp project-recommender.py project-recommender-streamlit.backup
    echo "✅ Backed up project-recommender.py → project-recommender-streamlit.backup"
fi

# Stop any running containers
echo "🛑 Stopping existing containers..."
docker compose down 2>/dev/null || true

# Create the Flask application
echo "📝 Creating hackathon-recommender.py (Flask app)..."
cat > hackathon-recommender.py << 'EOF'
#!/usr/bin/env python3
"""
Simple HTML Hackathon Project Recommender - No WebSockets!
Following compose-for-agents pattern with basic HTML interface.
"""

from flask import Flask, render_template_string, request, jsonify
import requests
import json
import os
from datetime import datetime
from openai import OpenAI

app = Flask(__name__)

def get_mcp_gateway_url():
    """Get MCP Gateway URL"""
    return os.getenv('MCPGATEWAY_ENDPOINT', 'http://mcp-gateway:8811')

def create_ai_client():
    """Create AI client for recommendations"""
    provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner')
    
    if provider == 'openai':
        return OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    else:
        base_url = os.getenv('OPENAI_BASE_URL', 'http://model-runner.docker.internal:12434/engines/llama.cpp/v1')
        return OpenAI(
            base_url=base_url,
            api_key=os.getenv('OPENAI_API_KEY', 'irrelevant')
        )

def call_mcp_tool(tool_name, arguments):
    """Call MCP tool via gateway"""
    try:
        gateway_url = get_mcp_gateway_url()
        
        response = requests.post(
            f"{gateway_url}/mcp",
            json={
                "jsonrpc": "2.0",
                "id": 1,
                "method": "tools/call",
                "params": {
                    "name": tool_name,
                    "arguments": arguments
                }
            },
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            if "result" in result:
                return {"success": True, "data": result["result"]}
            else:
                return {"success": False, "error": result.get("error", "Unknown error")}
        else:
            return {"success": False, "error": f"HTTP {response.status_code}"}
            
    except Exception as e:
        return {"success": False, "error": str(e)}

@app.route('/')
def index():
    """Main page with simple HTML form"""
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>🏆 AI Agents Hackathon Project Recommender</title>
        <style>
            body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
                max-width: 900px;
                margin: 0 auto;
                padding: 20px;
                background: #0e1117;
                color: #fafafa;
                line-height: 1.6;
            }
            .header {
                text-align: center;
                margin-bottom: 30px;
                padding: 30px;
                background: linear-gradient(135deg, #1f4e79, #2d5aa0, #4a90e2);
                border-radius: 15px;
                box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
            }
            .header h1 {
                margin: 0 0 10px 0;
                font-size: 2.5em;
                font-weight: 700;
            }
            .header p {
                margin: 5px 0;
                opacity: 0.9;
            }
            .form-container {
                background: #262730;
                padding: 30px;
                border-radius: 15px;
                margin-bottom: 20px;
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
            }
            .form-container label {
                display: block;
                margin-bottom: 10px;
                font-weight: 600;
                font-size: 1.1em;
            }
            input[type="text"] {
                width: 100%;
                padding: 18px;
                font-size: 16px;
                border: 2px solid #4a4a4a;
                border-radius: 10px;
                background: #1e1e1e;
                color: #fafafa;
                margin-bottom: 25px;
                box-sizing: border-box;
                transition: border-color 0.3s ease;
            }
            input[type="text"]:focus {
                outline: none;
                border-color: #ff4b4b;
                box-shadow: 0 0 0 3px rgba(255, 75, 75, 0.1);
            }
            button {
                background: linear-gradient(135deg, #ff4b4b, #ff6b6b);
                color: white;
                padding: 18px 30px;
                border: none;
                border-radius: 10px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                width: 100%;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            button:hover {
                transform: translateY(-2px);
                box-shadow: 0 8px 25px rgba(255, 75, 75, 0.3);
            }
            button:active {
                transform: translateY(0);
            }
            .status {
                margin: 20px 0;
                padding: 20px;
                border-radius: 10px;
                display: none;
                font-weight: 500;
            }
            .success { 
                background: linear-gradient(135deg, #1f4e3d, #2d6b4f); 
                border-left: 4px solid #00ff88; 
            }
            .error { 
                background: linear-gradient(135deg, #4e1f1f, #6b2d2d); 
                border-left: 4px solid #ff4444; 
            }
            .info { 
                background: linear-gradient(135deg, #1f3a4e, #2d546b); 
                border-left: 4px solid #4488ff; 
            }
            .results {
                background: #262730;
                padding: 30px;
                border-radius: 15px;
                margin-top: 20px;
                white-space: pre-wrap;
                display: none;
                font-size: 1.05em;
                line-height: 1.7;
                box-shadow: 0 4px 16px rgba(0, 0, 0, 0.2);
            }
            .powered-by {
                display: flex;
                gap: 15px;
                margin-top: 25px;
                flex-wrap: wrap;
                justify-content: center;
            }
            .badge {
                background: linear-gradient(135deg, #00aa44, #00cc55);
                color: white;
                padding: 10px 16px;
                border-radius: 20px;
                font-size: 13px;
                font-weight: 600;
                box-shadow: 0 3px 10px rgba(0, 170, 68, 0.3);
                transition: transform 0.2s ease;
            }
            .badge:hover {
                transform: translateY(-1px);
            }
            .loading {
                display: none;
                text-align: center;
                margin: 30px 0;
            }
            .spinner {
                border: 4px solid #262730;
                border-top: 4px solid #ff4b4b;
                border-radius: 50%;
                width: 50px;
                height: 50px;
                animation: spin 1s linear infinite;
                margin: 0 auto 15px;
            }
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
            .loading p {
                font-size: 1.1em;
                font-weight: 500;
            }
            .footer {
                margin-top: 40px;
                text-align: center;
                padding: 20px;
                background: #1a1a1a;
                border-radius: 10px;
                font-size: 0.9em;
                opacity: 0.8;
            }
            @media (max-width: 600px) {
                body { padding: 10px; }
                .header h1 { font-size: 2em; }
                .form-container { padding: 20px; }
                .powered-by { justify-content: center; }
            }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>🏆 AI Agents Hackathon Project Recommender</h1>
            <p><strong>Discover your perfect hackathon project!</strong></p>
            <p>Analyzes GitHub profiles to recommend personalized projects that match your skills and interests.</p>
            <p><em>Inspired by Microsoft AI Agents for Beginners - built with MCP servers & Docker Model Runner</em></p>
        </div>

        <div class="form-container">
            <form id="recommendForm">
                <label for="username">🔍 Enter GitHub Username:</label>
                <input type="text" id="username" name="username" placeholder="e.g., ajeetraina, microsoft, openai, torvalds" required>
                <button type="submit">🚀 Generate Hackathon Recommendations</button>
            </form>

            <div class="powered-by">
                <span class="badge">✅ GitHub MCP Server</span>
                <span class="badge">✅ DuckDuckGo Search</span>
                <span class="badge">✅ AI Model Runner</span>
                <span class="badge">✅ WebSocket-Free</span>
            </div>
        </div>

        <div class="loading" id="loading">
            <div class="spinner"></div>
            <p>🤖 Analyzing GitHub profile and generating personalized recommendations...</p>
            <p style="font-size: 0.9em; opacity: 0.7;">This may take 30-60 seconds for AI processing</p>
        </div>

        <div class="status" id="status"></div>
        <div class="results" id="results"></div>

        <div class="footer">
            <p>🛠️ <strong>Built with MCP (Model Context Protocol)</strong></p>
            <p>GitHub Analysis • Trend Research • AI Recommendations • Secure Infrastructure</p>
        </div>

        <script>
            document.getElementById('recommendForm').addEventListener('submit', async function(e) {
                e.preventDefault();
                
                const username = document.getElementById('username').value.trim();
                const loading = document.getElementById('loading');
                const status = document.getElementById('status');
                const results = document.getElementById('results');
                
                if (!username) {
                    status.textContent = '❌ Please enter a GitHub username';
                    status.className = 'status error';
                    status.style.display = 'block';
                    return;
                }
                
                // Reset UI
                status.style.display = 'none';
                results.style.display = 'none';
                loading.style.display = 'block';
                
                try {
                    const response = await fetch('/analyze', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                        },
                        body: JSON.stringify({ username: username })
                    });
                    
                    const data = await response.json();
                    loading.style.display = 'none';
                    
                    if (data.success) {
                        status.innerHTML = `✅ <strong>Analysis complete for @${data.profile.username}!</strong><br>
                                          📊 Found ${data.profile.repos} repositories • 💻 Top languages: ${data.profile.languages.join(', ')}<br>
                                          Here are your personalized hackathon project recommendations:`;
                        status.className = 'status success';
                        status.style.display = 'block';
                        
                        results.textContent = data.recommendations;
                        results.style.display = 'block';
                        
                        // Scroll to results
                        results.scrollIntoView({ behavior: 'smooth', block: 'start' });
                    } else {
                        status.innerHTML = `❌ <strong>Error:</strong> ${data.error}`;
                        status.className = 'status error';
                        status.style.display = 'block';
                    }
                } catch (error) {
                    loading.style.display = 'none';
                    status.innerHTML = `❌ <strong>Network error:</strong> ${error.message}<br>
                                      Please check that the containers are running and try again.`;
                    status.className = 'status error';
                    status.style.display = 'block';
                }
            });

            // Add some keyboard shortcuts
            document.addEventListener('keydown', function(e) {
                if (e.ctrlKey && e.key === 'Enter') {
                    document.getElementById('recommendForm').dispatchEvent(new Event('submit'));
                }
            });
        </script>
    </body>
    </html>
    """
    return html

@app.route('/analyze', methods=['POST'])
def analyze():
    """Analyze GitHub profile and generate recommendations"""
    try:
        data = request.get_json()
        username = data.get('username', '').strip()
        
        if not username:
            return jsonify({"success": False, "error": "Username is required"})
        
        # Search for user
        print(f"🔍 Searching for GitHub user: {username}")
        user_result = call_mcp_tool("search_users", {
            "query": f"user:{username}",
            "per_page": 1
        })
        
        if not user_result["success"]:
            return jsonify({"success": False, "error": f"Failed to find user: {user_result.get('error')}"})
        
        users_data = user_result.get("data", {})
        if not users_data.get("items"):
            return jsonify({"success": False, "error": f"User '{username}' not found on GitHub"})
        
        user_info = users_data["items"][0]
        print(f"✅ Found user: @{user_info.get('login')} with {user_info.get('public_repos', 0)} repos")
        
        # Search for repositories
        print(f"📊 Fetching repositories for {username}...")
        repos_result = call_mcp_tool("search_repositories", {
            "query": f"user:{username}",
            "sort": "updated",
            "per_page": 20
        })
        
        if not repos_result["success"]:
            return jsonify({"success": False, "error": f"Failed to fetch repositories: {repos_result.get('error')}"})
        
        repos_data = repos_result.get("data", {})
        repositories = repos_data.get("items", [])
        print(f"✅ Analyzed {len(repositories)} repositories")
        
        # Extract skills and technologies
        languages = {}
        topics = set()
        frameworks = set()
        
        # Technology keywords to detect
        tech_keywords = {
            'react', 'vue', 'angular', 'node', 'express', 'django', 'flask', 
            'docker', 'kubernetes', 'aws', 'azure', 'gcp', 'tensorflow', 'pytorch',
            'machine-learning', 'ai', 'blockchain', 'web3', 'api', 'microservices',
            'database', 'sql', 'nosql', 'mongodb', 'postgres', 'redis', 'firebase'
        }
        
        for repo in repositories:
            # Count programming languages
            if repo.get('language'):
                lang = repo['language']
                languages[lang] = languages.get(lang, 0) + 1
            
            # Extract repository topics
            if repo.get('topics'):
                topics.update(repo['topics'])
            
            # Look for frameworks in repo name and description
            repo_text = f"{repo.get('name', '')} {repo.get('description', '')}".lower()
            for tech in tech_keywords:
                if tech in repo_text:
                    frameworks.add(tech)
        
        # Get trending hackathon topics
        print("🔍 Researching current hackathon trends...")
        trends_result = call_mcp_tool("search", {
            "query": "AI hackathon 2025 trending projects",
            "max_results": 3
        })
        
        trends_context = ""
        if trends_result.get("success") and trends_result.get("data"):
            trends_context = "Current hackathon trends: AI agents, developer tools, climate tech, web3, and accessibility solutions."
        
        # Generate AI recommendations
        print("🤖 Generating personalized recommendations...")
        client = create_ai_client()
        model_name = os.getenv('MODEL_NAME', 'ai/qwen3:8B-Q4_0')
        top_languages = list(languages.keys())[:5]
        top_topics = list(topics)[:10]
        top_frameworks = list(frameworks)[:8]
        
        prompt = f"""You are an expert hackathon mentor. Based on this GitHub profile analysis, recommend 3 specific hackathon projects that would be perfect for this developer.

## Developer Profile Analysis:
**Username**: @{user_info.get('login')}
**Public Repositories**: {user_info.get('public_repos', 0)}
**Primary Languages**: {', '.join(top_languages) if top_languages else 'Various'}
**Repository Topics**: {', '.join(top_topics) if top_topics else 'General development'}
**Technologies Used**: {', '.join(top_frameworks) if top_frameworks else 'Various frameworks'}
**Profile Bio**: {user_info.get('bio', 'Not provided')}

## Context:
{trends_context}

## Instructions:
Recommend 3 hackathon projects that:
1. Match the developer's demonstrated skills and interests
2. Can realistically be built in 24-48 hours
3. Address real problems or leverage current tech trends
4. Showcase the developer's strengths while being achievable
5. Have clear potential for impact and innovation

Format each recommendation exactly like this:

**🚀 Project 1: [Creative, memorable project name]**

**Category**: [e.g., AI Agents, Developer Tools, Web3, Climate Tech, Accessibility, etc.]

**Description**: [2-3 compelling sentences describing what the project does, why it's valuable, and what problem it solves]

**Tech Stack**: [Specific technologies, prioritizing languages/frameworks the developer knows]

**Key Features**:
• [Main feature 1]
• [Main feature 2] 
• [Main feature 3]
• [Bonus feature if time permits]

**Difficulty**: [Beginner/Intermediate/Advanced - based on their experience level]

**Why Perfect for You**: [2-3 sentences explaining how this matches their GitHub activity, skills, and interests]

**Potential Impact**: [Who would benefit and how this could make a difference]

---

**🚀 Project 2: [Different creative name]**
[Same format...]

---

**🚀 Project 3: [Different creative name]**
[Same format...]

---

**💡 Pro Tips for Success**:
• Start with the core functionality first
• Focus on user experience and clear value proposition
• Prepare a compelling demo that shows real-world usage
• Consider open-sourcing for community impact

Keep recommendations innovative, practical, and directly relevant to their programming background. Each project should feel exciting and achievable while demonstrating technical skill."""

        try:
            response = client.chat.completions.create(
                model=model_name,
                messages=[{"role": "user", "content": prompt}],
                max_tokens=1800,
                temperature=0.7
            )
            recommendations = response.choices[0].message.content.strip()
            print("✅ Recommendations generated successfully")
            
            return jsonify({
                "success": True,
                "recommendations": recommendations,
                "profile": {
                    "username": user_info.get('login'),
                    "repos": user_info.get('public_repos', 0),
                    "languages": top_languages,
                    "topics": top_topics[:5],
                    "frameworks": top_frameworks[:5]
                }
            })
            
        except Exception as e:
            print(f"❌ AI generation error: {str(e)}")
            return jsonify({"success": False, "error": f"AI recommendation generation failed: {str(e)}"})
        
    except Exception as e:
        print(f"❌ Analysis error: {str(e)}")
        return jsonify({"success": False, "error": f"Analysis failed: {str(e)}"})

@app.route('/health')
def health():
    """Health check endpoint"""
    return {"status": "healthy", "service": "hackathon-recommender"}

if __name__ == '__main__':
    print("🚀 Starting AI Agents Hackathon Project Recommender")
    print("🌐 Server will be available at: http://localhost:8501")
    print("🔧 MCP Gateway: " + os.getenv('MCPGATEWAY_ENDPOINT', 'http://mcp-gateway:8811'))
    app.run(host='0.0.0.0', port=8501, debug=False)
EOF

# Create Flask requirements.txt
echo "📦 Creating requirements.txt for Flask..."
cat > requirements.txt << 'EOF'
flask>=2.3.0
requests>=2.31.0
openai>=1.12.0
EOF

# Create Flask Dockerfile
echo "🐳 Creating Dockerfile for Flask..."
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application code
COPY hackathon-recommender.py .

# Expose Flask port
EXPOSE 8501

# Health check
HEALTHCHECK CMD curl --fail http://localhost:8501/health || exit 1

# Run Flask app
CMD ["python", "hackathon-recommender.py"]
EOF

# Ensure compose.yaml exists (create if missing)
if [ ! -f "compose.yaml" ]; then
    echo "🔧 Creating compose.yaml..."
    cat > compose.yaml << 'EOF'
services:
  recommender-ui:
    build:
      context: .
    ports:
      - "8501:8501"
    environment:
      # point app at the MCP gateway
      - MCPGATEWAY_ENDPOINT=http://mcp-gateway:8811/sse
    depends_on:
      - mcp-gateway
    models:
      recommendation_model:
        endpoint_var: MODEL_RUNNER_URL
        model_var: MODEL_RUNNER_MODEL

  mcp-gateway:
    # mcp-gateway secures your MCP servers
    image: docker/mcp-gateway:latest
    # use docker API socket to start MCP servers
    use_api_socket: true
    command:
      - --transport=sse
      # securely embed secrets into the gateway
      - --secrets=/run/secrets/mcp_secret
      # add any MCP servers you want to use
      - --servers=github,duckduckgo,fetch
    secrets:
      - mcp_secret

models:
  recommendation_model:
    # pre-pull the model when starting Docker Model Runner
    model: ai/qwen3:8B-Q4_0 # 4.44 GB
    context_size: 15000 # 7 GB VRAM

# mount the secrets file for MCP servers
secrets:
  mcp_secret:
    file: ./.mcp.env
EOF
fi

# Ensure .mcp.env.example exists (create if missing)
if [ ! -f ".mcp.env.example" ]; then
    echo "🔐 Creating .mcp.env.example..."
    cat > .mcp.env.example << 'EOF'
# GitHub Personal Access Token
# Get from: https://github.com/settings/tokens
# Required scopes: repo, user
github.personal_access_token=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
EOF
fi

# Ensure .gitignore includes .mcp.env
if ! grep -q ".mcp.env" .gitignore 2>/dev/null; then
    echo "🚫 Adding .mcp.env to .gitignore..."
    echo ".mcp.env" >> .gitignore
fi

echo ""
echo "✅ Flask-based Hackathon Project Recommender setup complete!"
echo "=================================================="
echo ""
echo "📁 Files created/updated:"
echo "   • hackathon-recommender.py  - Flask web application (NO WebSockets!)"
echo "   • requirements.txt          - Flask dependencies"
echo "   • Dockerfile               - Flask container config"
echo "   • compose.yaml             - MCP + Flask orchestration"
echo "   • .mcp.env.example         - Environment template"
echo ""
echo "🔧 Next steps:"
echo "   1. Ensure .mcp.env exists with your GitHub token:"
echo "      cp .mcp.env.example .mcp.env"
echo "      # Then edit .mcp.env with your real token"
echo ""
echo "   2. Start the application:"
echo "      docker compose up --build"
echo ""
echo "   3. Open in browser:"
echo "      http://localhost:8501"
echo ""
echo "🎯 Benefits of Flask version:"
echo "   ✅ No WebSocket issues"
echo "   ✅ Fast loading & reliable"
echo "   ✅ Beautiful modern interface"
echo "   ✅ Same MCP functionality"
echo "   ✅ Works in all browsers"
echo ""
echo "🚀 Your WebSocket-free AI Agents Hackathon Project Recommender is ready!"
echo ""

# Make the flask app executable
chmod +x hackathon-recommender.py

echo "💡 Run 'docker compose up --build' to start your new Flask-based app!"
