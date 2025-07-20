def analyze_github_user(username):
    """Analyze GitHub user profile and repositories using correct MCP tool names"""
    with st.spinner(f"🔍 Analyzing GitHub profile: @{username}"):
        
        # Search for the user using search_users tool
        user_result = call_mcp_tool("search_users", {
            "query": f"user:{username}",
            "per_page": 1
        })
        
        if not user_result["success"]:
            st.error(f"❌ Failed to search for user: {user_result.get('error', 'Unknown error')}")
            return None
        
        users_data = user_result.get("data", {})
        if not users_data.get("items") or len(users_data["items"]) == 0:
            st.error(f"❌ User '{username}' not found")
            return None
        
        user_info = users_data["items"][0]  # Get first user from search results
        
        # Search for user's repositories using search_repositories tool
        repos_result = call_mcp_tool("search_repositories", {
            "query": f"user:{username}",
            "sort": "updated",
            "per_page": 20
        })
        
        if not repos_result["success"]:
            st.error(f"❌ Failed to search repositories: {repos_result.get('error', 'Unknown error')}")
            return None
        
        repos_data = repos_result.get("data", {})
        repositories = repos_data.get("items", [])
        
        return {
            "user": user_info,
            "repositories": repositories
        }

def search_hackathon_inspiration():
    """Search for current hackathon themes using DuckDuckGo search tool"""
    with st.spinner("🔍 Searching for hackathon inspiration..."):
        
        search_queries = [
            "AI hackathon 2025 trending projects",
            "developer tools hackathon ideas", 
            "open source hackathon themes"
        ]
        
        all_results = []
        for query in search_queries[:2]:  # Limit to 2 searches
            result = call_mcp_tool("search", {
                "query": query,
                "max_results": 3
            })
            
            if result["success"] and result.get("data"):
                # Handle different response formats
                data = result["data"]
                if isinstance(data, list):
                    all_results.extend(data)
                elif isinstance(data, dict) and "results" in data:
                    all_results.extend(data["results"])
                elif isinstance(data, dict) and "items" in data:
                    all_results.extend(data["items"])
        
        return all_results
