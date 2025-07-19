#!/usr/bin/env python3
"""
Minimal Node.js Agentic Compose Demo
An AI agent that solves coding problems using Alfonso Graziano's Node.js sandbox.
Supports local models via Ollama, OpenAI, and Docker Offload.
"""

import os
import json
import subprocess
import requests
import time
from datetime import datetime

def wait_for_model_service():
    """Wait for the model service to be ready"""
    model_provider = os.getenv('MODEL_PROVIDER', 'local').lower()
    
    if model_provider in ['local', 'docker-model-runner']:
        model_url = "http://model:11434"
        print("🔄 Waiting for local model service to be ready...")
        
        for i in range(30):  # Wait up to 30 seconds
            try:
                response = requests.get(f"{model_url}/api/tags", timeout=5)
                if response.status_code == 200:
                    print("✅ Model service is ready")
                    return True
            except:
                pass
            time.sleep(1)
        
        print("⚠️ Model service not ready, continuing anyway...")
        return False
    
    return True

def ensure_model_pulled():
    """Ensure the required model is pulled"""
    model_provider = os.getenv('MODEL_PROVIDER', 'local').lower()
    
    if model_provider in ['local', 'docker-model-runner']:
        model_name = os.getenv('MODEL_NAME', 'llama3.2:3b')
        model_url = "http://model:11434"
        
        print(f"🔍 Checking if model {model_name} is available...")
        
        try:
            # Check if model exists
            response = requests.get(f"{model_url}/api/tags", timeout=10)
            if response.status_code == 200:
                models = response.json().get('models', [])
                model_names = [m.get('name', '') for m in models]
                
                if model_name in model_names:
                    print(f"✅ Model {model_name} is already available")
                    return True
                
                print(f"📥 Pulling model {model_name}...")
                pull_response = requests.post(
                    f"{model_url}/api/pull",
                    json={"name": model_name},
                    timeout=300  # 5 minutes timeout for pulling
                )
                
                if pull_response.status_code == 200:
                    print(f"✅ Model {model_name} pulled successfully")
                    return True
                else:
                    print(f"⚠️ Failed to pull model {model_name}")
                    return False
        except Exception as e:
            print(f"⚠️ Could not ensure model is pulled: {e}")
            return False
    
    return True

def create_ai_client():
    """Create appropriate AI client based on MODEL_PROVIDER"""
    provider = os.getenv('MODEL_PROVIDER', 'local').lower()
    
    if provider == 'openai':
        from openai import OpenAI
        return OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    
    elif provider in ['local', 'docker-model-runner']:
        from openai import OpenAI
        model_url = "http://model:11434/v1"
        return OpenAI(
            base_url=model_url,
            api_key="dummy-key"  # Ollama doesn't need real API key
        )
    
    elif provider == 'docker-offload':
        from openai import OpenAI
        model_url = os.getenv('MODEL_URL', 'https://docker.com/api/v1/models')
        token = os.getenv('DOCKER_OFFLOAD_TOKEN')
        if not token:
            raise ValueError("DOCKER_OFFLOAD_TOKEN is required for Docker Offload")
        return OpenAI(
            base_url=model_url,
            api_key=token
        )
    
    else:
        raise ValueError(f"Unsupported MODEL_PROVIDER: {provider}")

def generate_code_solution(problem):
    """Generate JavaScript code to solve the given problem"""
    client = create_ai_client()
    model_name = os.getenv('MODEL_NAME', 'llama3.2:3b')
    
    # For local models, use the model name as-is
    # For OpenAI, use the OpenAI model name
    provider = os.getenv('MODEL_PROVIDER', 'local').lower()
    if provider == 'openai' and model_name.startswith('llama'):
        model_name = 'gpt-3.5-turbo'
    
    prompt = f"""
    Write JavaScript code to solve this problem: {problem}

    Requirements:
    - Write clean, well-commented JavaScript code
    - Include console.log statements to show the results
    - Make it runnable in a Node.js environment
    - Don't use any external dependencies unless absolutely necessary
    - If you need to save files, use fs/promises module
    - Provide a complete working solution

    Return only the JavaScript code, no explanations or markdown formatting.
    """
    
    try:
        response = client.chat.completions.create(
            model=model_name,
            messages=[{"role": "user", "content": prompt}],
            max_tokens=800,
            temperature=0.3
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        return f"// Error generating code: {e}"

def execute_code_in_sandbox(code):
    """Execute JavaScript code using Alfonso Graziano's MCP server via Docker"""
    try:
        # Run the MCP server via Docker with the code
        docker_cmd = [
            "docker", "run", "--rm", "-i",
            "-v", "/var/run/docker.sock:/var/run/docker.sock",
            "-v", f"{os.getcwd()}/sandbox-output:/root",
            "-e", "FILES_DIR=/root",
            "alfonsograziano/node-code-sandbox-mcp"
        ]
        
        # Create MCP request for ephemeral execution
        mcp_request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
                "name": "run_js_ephemeral",
                "arguments": {
                    "code": code,
                    "image": "node:lts-slim"
                }
            }
        }
        
        # Execute the request
        process = subprocess.run(
            docker_cmd,
            input=json.dumps(mcp_request),
            text=True,
            capture_output=True,
            timeout=60
        )
        
        if process.returncode == 0:
            try:
                response = json.loads(process.stdout)
                if "result" in response:
                    result = response["result"]
                    return {
                        'success': True,
                        'output': result.get('content', [{}])[0].get('text', ''),
                        'error': '',
                        'execution_time': 0
                    }
                else:
                    return {
                        'success': False,
                        'error': f"MCP Error: {response.get('error', 'Unknown error')}",
                        'output': ''
                    }
            except json.JSONDecodeError:
                return {
                    'success': True,
                    'output': process.stdout,
                    'error': process.stderr,
                    'execution_time': 0
                }
        else:
            return {
                'success': False,
                'error': f"Docker process failed: {process.stderr}",
                'output': process.stdout
            }
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'error': "Execution timed out (60s limit)",
            'output': ''
        }
    except Exception as e:
        return {
            'success': False,
            'error': f"Failed to execute code: {e}",
            'output': ''
        }

def analyze_results(problem, code, execution_result):
    """Analyze the code execution results"""
    client = create_ai_client()
    model_name = os.getenv('MODEL_NAME', 'llama3.2:3b')
    
    # For OpenAI, ensure we use the right model name
    provider = os.getenv('MODEL_PROVIDER', 'local').lower()
    if provider == 'openai' and model_name.startswith('llama'):
        model_name = 'gpt-3.5-turbo'
    
    if execution_result['success']:
        status = "✅ Success"
        details = f"Output: {execution_result['output']}"
        if execution_result['error']:
            details += f"\nWarnings: {execution_result['error']}"
    else:
        status = "❌ Failed"
        details = f"Error: {execution_result['error']}"
    
    analysis_prompt = f"""
    Analyze this coding solution:
    
    Problem: {problem}
    Code: {code}
    Execution Status: {status}
    Details: {details}
    
    Provide a brief analysis of:
    1. Whether the solution correctly addresses the problem
    2. Code quality and approach
    3. Any improvements or issues
    
    Keep it concise (2-3 sentences).
    """
    
    try:
        response = client.chat.completions.create(
            model=model_name,
            messages=[{"role": "user", "content": analysis_prompt}],
            max_tokens=200,
            temperature=0.3
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        return f"Could not analyze results: {e}"

def main():
    problem = os.getenv('PROBLEM', 'Calculate the first 10 Fibonacci numbers')
    provider = os.getenv('MODEL_PROVIDER', 'local')
    model_name = os.getenv('MODEL_NAME', 'llama3.2:3b')
    
    print(f"🤖 Coding Agent Starting...")
    print(f"📝 Problem: {problem}")
    print(f"🔧 Model Provider: {provider}")
    print(f"🧠 Model: {model_name}")
    print(f"🔧 Using Alfonso Graziano's Node.js Sandbox MCP Server")
    
    # Create output directories
    os.makedirs('/app/output', exist_ok=True)
    os.makedirs('/app/sandbox-output', exist_ok=True)
    
    # Wait for model service and ensure model is available
    wait_for_model_service()
    ensure_model_pulled()
    
    # Generate code solution
    print("🧠 Generating JavaScript solution...")
    code = generate_code_solution(problem)
    
    if code.startswith("// Error"):
        print("❌ Failed to generate code")
        return
    
    print("✅ Code generated successfully")
    
    # Execute code in sandbox
    print("🏃 Executing code in Node.js sandbox...")
    execution_result = execute_code_in_sandbox(code)
    
    # Analyze results
    print("🔍 Analyzing results...")
    analysis = analyze_results(problem, code, execution_result)
    
    # Save the generated code
    with open('/app/output/solution.js', 'w') as f:
        f.write(f"// Problem: {problem}\n")
        f.write(f"// Generated: {datetime.now().isoformat()}\n")
        f.write(f"// Model Provider: {provider}\n")
        f.write(f"// Model: {model_name}\n")
        f.write(f"// MCP Server: Alfonso Graziano's node-code-sandbox\n\n")
        f.write(code)
    
    # Save execution results and analysis
    result_data = {
        'timestamp': datetime.now().isoformat(),
        'problem': problem,
        'model_provider': provider,
        'model_name': model_name,
        'code': code,
        'execution': execution_result,
        'analysis': analysis,
        'mcp_server': 'alfonsograziano/node-code-sandbox-mcp'
    }
    
    with open('/app/output/result.json', 'w') as f:
        json.dump(result_data, f, indent=2)
    
    # Save human-readable report
    with open('/app/output/result.txt', 'w') as f:
        f.write(f"Coding Problem: {problem}\n")
        f.write(f"Timestamp: {result_data['timestamp']}\n")
        f.write(f"Model Provider: {provider}\n")
        f.write(f"Model: {model_name}\n")
        f.write(f"MCP Server: Alfonso Graziano's node-code-sandbox\n")
        f.write("=" * 60 + "\n\n")
        
        f.write("Generated Code:\n")
        f.write("-" * 20 + "\n")
        f.write(code + "\n\n")
        
        f.write("Execution Results:\n")
        f.write("-" * 20 + "\n")
        if execution_result['success']:
            f.write("✅ Execution: SUCCESS\n")
            f.write(f"Output:\n{execution_result['output']}\n")
            if execution_result['error']:
                f.write(f"Warnings: {execution_result['error']}\n")
        else:
            f.write("❌ Execution: FAILED\n")
            f.write(f"Error: {execution_result['error']}\n")
        
        f.write(f"\nAnalysis:\n")
        f.write("-" * 20 + "\n")
        f.write(analysis + "\n")
    
    print(f"💾 Results saved to ./output/")
    print(f"📄 Code saved to: ./output/solution.js")
    print(f"📊 Full results: ./output/result.txt")
    print(f"📁 Generated files in: ./sandbox-output/")
    
    # Print summary
    if execution_result['success']:
        print(f"✅ Problem solved successfully!")
        print(f"🔢 Output: {execution_result['output'][:100]}...")
    else:
        print(f"❌ Execution failed: {execution_result['error']}")

if __name__ == "__main__":
    main()
