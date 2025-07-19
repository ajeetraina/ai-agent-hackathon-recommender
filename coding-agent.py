#!/usr/bin/env python3
"""
Minimal Node.js Agentic Compose Demo
An AI agent that solves coding problems using Node.js sandbox execution.
Supports Docker Model Runner (local models), OpenAI, and Docker Offload.
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
        # Docker Model Runner uses a different endpoint structure
        model_url = os.getenv('MODEL_RUNNER_URL', 'http://localhost:8000')
        print("🔄 Waiting for Docker Model Runner to be ready...")
        
        for i in range(60):  # Wait up to 60 seconds for model to be ready
            try:
                # Docker Model Runner health check endpoint
                response = requests.get(f"{model_url}/health", timeout=5)
                if response.status_code == 200:
                    print("✅ Docker Model Runner is ready")
                    return True
            except:
                pass
            time.sleep(1)
        
        print("⚠️ Docker Model Runner not ready, continuing anyway...")
        return False
    
    return True

def create_ai_client():
    """Create appropriate AI client based on MODEL_PROVIDER"""
    provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner').lower()
    
    if provider == 'openai':
        from openai import OpenAI
        return OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    
    elif provider in ['docker-model-runner', 'local']:
        from openai import OpenAI
        # Docker Model Runner provides OpenAI-compatible API
        model_url = os.getenv('MODEL_RUNNER_URL', 'http://localhost:8000')
        return OpenAI(
            base_url=f"{model_url}/v1",
            api_key="dummy-key"  # Docker Model Runner doesn't need real API key
        )
    
    else:
        raise ValueError(f"Unsupported MODEL_PROVIDER: {provider}")

def generate_code_solution(problem):
    """Generate JavaScript code to solve the given problem"""
    client = create_ai_client()
    model_name = os.getenv('MODEL_RUNNER_MODEL', 'qwen3-small')
    
    # For OpenAI, use OpenAI model names
    provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner').lower()
    if provider == 'openai':
        model_name = os.getenv('MODEL_NAME', 'gpt-3.5-turbo')
    
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

def execute_code_in_nodejs_container(code):
    """Execute JavaScript code directly in a Node.js container"""
    try:
        # Create a temporary directory for output
        os.makedirs('/app/sandbox-output', exist_ok=True)
        
        # Run code in a Node.js container with volume mounts
        docker_cmd = [
            "docker", "run", "--rm", "-i",
            "-v", f"{os.getcwd()}/sandbox-output:/output",
            "-w", "/output",
            "node:lts-alpine",
            "node", "-e", code
        ]
        
        # Execute the JavaScript code
        process = subprocess.run(
            docker_cmd,
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if process.returncode == 0:
            return {
                'success': True,
                'output': process.stdout,
                'error': process.stderr if process.stderr else '',
                'execution_time': 0
            }
        else:
            return {
                'success': False,
                'error': f"Execution failed: {process.stderr}",
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
    model_name = os.getenv('MODEL_RUNNER_MODEL', 'qwen3-small')
    
    # For OpenAI, use OpenAI model names
    provider = os.getenv('MODEL_PROVIDER', 'docker-model-runner').lower()
    if provider == 'openai':
        model_name = os.getenv('MODEL_NAME', 'gpt-3.5-turbo')
    
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
    model_name = os.getenv('MODEL_RUNNER_MODEL', 'qwen3-small')
    
    print(f"🤖 Coding Agent Starting...")
    print(f"📝 Problem: {problem}")
    print(f"🔧 Model Provider: {provider}")
    print(f"🧠 Model: {model_name}")
    print(f"🔧 Using Direct Node.js Container Execution")
    
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
    
    # Execute code in Node.js container
    print("🏃 Executing code in Node.js container...")
    execution_result = execute_code_in_nodejs_container(code)
    
    # Analyze results
    print("🔍 Analyzing results...")
    analysis = analyze_results(problem, code, execution_result)
    
    # Save the generated code
    with open('/app/output/solution.js', 'w') as f:
        f.write(f"// Problem: {problem}\n")
        f.write(f"// Generated: {datetime.now().isoformat()}\n")
        f.write(f"// Model Provider: {provider}\n")
        f.write(f"// Model: {model_name}\n")
        f.write(f"// Execution: Direct Node.js Container\n\n")
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
        'execution_method': 'Direct Node.js Container'
    }
    
    with open('/app/output/result.json', 'w') as f:
        json.dump(result_data, f, indent=2)
    
    # Save human-readable report
    with open('/app/output/result.txt', 'w') as f:
        f.write(f"Coding Problem: {problem}\n")
        f.write(f"Timestamp: {result_data['timestamp']}\n")
        f.write(f"Model Provider: {provider}\n")
        f.write(f"Model: {model_name}\n")
        f.write(f"Execution Method: Direct Node.js Container\n")
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
