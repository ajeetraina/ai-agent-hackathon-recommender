#!/usr/bin/env python3
"""
Minimal Node.js Agentic Compose Demo
An AI agent that solves coding problems using Alfonso Graziano's Node.js sandbox.
"""

import os
import json
import subprocess
from openai import OpenAI
from datetime import datetime

def generate_code_solution(problem):
    """Generate JavaScript code to solve the given problem"""
    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    
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
            model="gpt-3.5-turbo",
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
    client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
    
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
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": analysis_prompt}],
            max_tokens=200,
            temperature=0.3
        )
        return response.choices[0].message.content.strip()
    except Exception as e:
        return f"Could not analyze results: {e}"

def main():
    problem = os.getenv('PROBLEM', 'Calculate the first 10 Fibonacci numbers')
    
    print(f"🤖 Coding Agent Starting...")
    print(f"📝 Problem: {problem}")
    print(f"🔧 Using Alfonso Graziano's Node.js Sandbox MCP Server")
    
    # Create output directories
    os.makedirs('/app/output', exist_ok=True)
    os.makedirs('/app/sandbox-output', exist_ok=True)
    
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
        f.write(f"// MCP Server: Alfonso Graziano's node-code-sandbox\n\n")
        f.write(code)
    
    # Save execution results and analysis
    result_data = {
        'timestamp': datetime.now().isoformat(),
        'problem': problem,
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
