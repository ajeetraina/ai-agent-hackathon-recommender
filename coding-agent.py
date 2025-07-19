#!/usr/bin/env python3
"""
Minimal Node.js Agentic Compose Demo
An AI agent that solves coding problems using Node.js sandbox MCP server.
Supports Docker Model Runner (local models), OpenAI, and Docker Offload.
Updated to use official Agentic Compose patterns.
"""

import os
import json
import subprocess
import requests
import time
from datetime import datetime

def wait_for_model_service():
    """Wait for the model service to be ready"""
    model_provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner').lower()
    
    if model_provider in ['docker-model-runner', 'local']:
        # With Agentic Compose, Docker automatically manages model lifecycle
        print("🔄 Waiting for Docker Model Runner to initialize...")
        time.sleep(5)  # Give Docker Model Runner time to start
        print("✅ Docker Model Runner should be ready")
        return True
    
    return True

def create_ai_client():
    """Create appropriate AI client based on MODEL_PROVIDER"""
    provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner').lower()
    
    if provider == 'openai':
        from openai import OpenAI
        return OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    
    elif provider in ['docker-model-runner', 'local']:
        from openai import OpenAI
        
        # NEW: Use Agentic Compose environment variables
        # Docker Compose automatically injects these based on service-level model config
        base_url = os.getenv('OPENAI_BASE_URL')
        model_name = os.getenv('OPENAI_MODEL') 
        api_key = os.getenv('OPENAI_API_KEY', 'irrelevant')
        
        if not base_url:
            print("⚠️ OPENAI_BASE_URL not set - Docker Compose should inject this automatically")
            base_url = 'http://host.docker.internal/engines/llama.cpp/'
        
        print(f"🔗 Connecting to Docker Model Runner at: {base_url}")
        print(f"🤖 Model from environment: {model_name}")
        
        return OpenAI(
            base_url=base_url,
            api_key=api_key
        )
    
    else:
        raise ValueError(f"Unsupported MODEL_PROVIDER: {provider}")

def generate_code_solution(problem):
    """Generate JavaScript code to solve the given problem"""
    client = create_ai_client()
    provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner').lower()
    
    # Use appropriate model name based on provider
    if provider == 'openai':
        model_name = os.getenv('OPENAI_MODEL', 'gpt-3.5-turbo')
    else:
        # For Docker Model Runner with Agentic Compose, use injected model name
        model_name = os.getenv('OPENAI_MODEL', 'ai/qwen3:8B-Q4_0')
    
    print(f"🤖 Using model: {model_name}")
    
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

def execute_code_via_mcp_gateway(code):
    """Execute JavaScript code using MCP Gateway with node-code-sandbox server"""
    try:
        mcp_gateway_url = os.getenv('MCPGATEWAY_URL', 'http://mcp-gateway:8811')
        
        # NEW: Use SSE transport as per Agentic Compose pattern
        # Create MCP request for node-code-sandbox server
        mcp_request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
                "name": "run_js",
                "arguments": {
                    "code": code
                }
            }
        }
        
        # Send request to MCP Gateway with SSE endpoint
        response = requests.post(
            f"{mcp_gateway_url}/mcp",
            json=mcp_request,
            timeout=60,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code == 200:
            result = response.json()
            if "result" in result:
                return {
                    'success': True,
                    'output': result["result"].get('content', ''),
                    'error': '',
                    'execution_time': 0
                }
            else:
                return {
                    'success': False,
                    'error': f"MCP Error: {result.get('error', 'Unknown error')}",
                    'output': ''
                }
        else:
            return {
                'success': False,
                'error': f"HTTP {response.status_code}: {response.text}",
                'output': ''
            }
            
    except requests.exceptions.Timeout:
        return {
            'success': False,
            'error': "Execution timed out (60s limit)",
            'output': ''
        }
    except Exception as e:
        return {
            'success': False,
            'error': f"Failed to execute code via MCP Gateway: {e}",
            'output': ''
        }

def execute_code_direct_docker(code):
    """Fallback: Execute JavaScript code directly using Docker node-code-sandbox"""
    try:
        # Run the node-code-sandbox MCP server via Docker with the code
        docker_cmd = [
            "docker", "run", "--rm", "-i",
            "-v", "/var/run/docker.sock:/var/run/docker.sock",
            "-v", f"{os.getcwd()}/sandbox-output:/root",
            "-e", "FILES_DIR=/root",
            "mcp/node-code-sandbox"
        ]
        
        # Create MCP request for execution
        mcp_request = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
                "name": "run_js",
                "arguments": {
                    "code": code
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

def execute_code_in_sandbox(code):
    """Execute JavaScript code using MCP Gateway or fallback to direct Docker"""
    # Try MCP Gateway first
    result = execute_code_via_mcp_gateway(code)
    
    # If MCP Gateway fails, fallback to direct Docker execution
    if not result['success'] and ('MCP Gateway' in result['error'] or 'HTTP' in result['error']):
        print("⚠️ MCP Gateway failed, falling back to direct Docker execution...")
        result = execute_code_direct_docker(code)
    
    return result

def analyze_results(problem, code, execution_result):
    """Analyze the code execution results"""
    client = create_ai_client()
    provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner').lower()
    
    # Use appropriate model name based on provider
    if provider == 'openai':
        model_name = os.getenv('OPENAI_MODEL', 'gpt-3.5-turbo')
    else:
        model_name = os.getenv('OPENAI_MODEL', 'ai/qwen3:8B-Q4_0')
    
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
    provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner')
    model_name = os.getenv('OPENAI_MODEL', 'ai/qwen3:8B-Q4_0')
    
    print(f"🤖 Coding Agent Starting...")
    print(f"📝 Problem: {problem}")
    print(f"🔧 Model Provider: {provider}")
    print(f"🧠 Model: {model_name}")
    print(f"🔧 Using Node.js Sandbox via MCP Gateway (node-code-sandbox)")
    print(f"🚀 Using Agentic Compose patterns")
    
    # Create output directories
    os.makedirs('/app/output', exist_ok=True)
    os.makedirs('/app/sandbox-output', exist_ok=True)
    
    # Wait for model service
    wait_for_model_service()
    
    # Generate code solution
    print("🧠 Generating JavaScript solution...")
    code = generate_code_solution(problem)
    
    if code.startswith("// Error"):
        print("❌ Failed to generate code")
        print(f"Error: {code}")
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
        f.write(f"// Agentic Compose: Enabled\n")
        f.write(f"// MCP Server: node-code-sandbox via MCP Gateway\n\n")
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
        'agentic_compose': True,
        'mcp_server': 'node-code-sandbox via MCP Gateway'
    }
    
    with open('/app/output/result.json', 'w') as f:
        json.dump(result_data, f, indent=2)
    
    # Save human-readable report
    with open('/app/output/result.txt', 'w') as f:
        f.write(f"Coding Problem: {problem}\n")
        f.write(f"Timestamp: {result_data['timestamp']}\n")
        f.write(f"Model Provider: {provider}\n")
        f.write(f"Model: {model_name}\n")
        f.write(f"Agentic Compose: Enabled\n")
        f.write(f"MCP Server: node-code-sandbox via MCP Gateway\n")
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
            if execution_result['output']:
                f.write(f"Partial Output: {execution_result['output']}\n")
        
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
        output_preview = execution_result['output'].strip()
        if len(output_preview) > 100:
            output_preview = output_preview[:100] + "..."
        print(f"🔢 Output: {output_preview}")
    else:
        print(f"❌ Execution failed: {execution_result['error']}")

if __name__ == "__main__":
    main()
