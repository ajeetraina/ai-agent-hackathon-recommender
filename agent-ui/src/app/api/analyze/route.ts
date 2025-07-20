import { NextRequest, NextResponse } from "next/server";

const MCP_GATEWAY_URL = process.env.MCPGATEWAY_ENDPOINT || "http://mcp-gateway:8811";

async function callMcpTool(toolName: string, arguments: any) {
  try {
    const response = await fetch(`${MCP_GATEWAY_URL}/mcp`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        jsonrpc: "2.0",
        id: 1,
        method: "tools/call",
        params: {
          name: toolName,
          arguments: arguments,
        },
      }),
    });

    if (response.ok) {
      const result = await response.json();
      if ("result" in result) {
        return { success: true, data: result.result };
      } else {
        return { success: false, error: result.error || "Unknown error" };
      }
    } else {
      return { success: false, error: `HTTP ${response.status}` };
    }
  } catch (error) {
    return { success: false, error: String(error) };
  }
}

export async function POST(request: NextRequest) {
  try {
    const { username } = await request.json();

    if (!username?.trim()) {
      return NextResponse.json(
        { success: false, error: "Username is required" },
        { status: 400 }
      );
    }

    // Try to get user info using get_me first
    let userResult = await callMcpTool("get_me", {});
    let userInfo;

    if (userResult.success) {
      userInfo = userResult.data;
    } else {
      // Fallback to search_users
      userResult = await callMcpTool("search_users", {
        query: username,
        per_page: 1,
      });

      if (!userResult.success) {
        return NextResponse.json({
          success: false,
          error: `Failed to find user: ${userResult.error}`,
        });
      }

      const usersData = userResult.data;
      if (!usersData?.items?.length) {
        return NextResponse.json({
          success: false,
          error: `User '${username}' not found on GitHub`,
        });
      }

      userInfo = usersData.items[0];
    }

    // Get repositories
    let reposResult = await callMcpTool("list_repositories", {
      owner: username,
      per_page: 20,
      sort: "updated",
    });

    let repositories = [];
    if (!reposResult.success) {
      // Fallback to search
      reposResult = await callMcpTool("search_repositories", {
        query: `user:${username}`,
        sort: "updated",
        per_page: 20,
      });

      if (reposResult.success) {
        const reposData = reposResult.data;
        repositories = reposData.items || [];
      }
    } else {
      repositories = reposResult.data || [];
    }

    // Extract skills
    const languages: Record<string, number> = {};
    const topics = new Set<string>();
    const frameworks = new Set<string>();

    const techKeywords = [
      "react", "vue", "angular", "node", "express", "django", "flask",
      "docker", "kubernetes", "aws", "azure", "gcp", "tensorflow", "pytorch",
      "machine-learning", "ai", "blockchain", "web3", "api", "microservices",
      "database", "sql", "nosql", "mongodb", "postgres", "redis", "firebase"
    ];

    for (const repo of repositories) {
      if (repo.language) {
        languages[repo.language] = (languages[repo.language] || 0) + 1;
      }

      if (repo.topics) {
        repo.topics.forEach((topic: string) => topics.add(topic));
      }

      const repoText = `${repo.name || ""} ${repo.description || ""}`.toLowerCase();
      for (const tech of techKeywords) {
        if (repoText.includes(tech)) {
          frameworks.add(tech);
        }
      }
    }

    // Generate simple recommendations (you can integrate with AI model here)
    const topLanguages = Object.keys(languages).slice(0, 5);
    const topTopics = Array.from(topics).slice(0, 10);
    const topFrameworks = Array.from(frameworks).slice(0, 8);

    const recommendations = `**🚀 Project 1: Smart Developer Portfolio**

**Category**: Developer Tools

**Description**: Create an AI-powered portfolio website that automatically updates with your latest GitHub projects, analyzes your coding patterns, and suggests skill improvements. Perfect for showcasing your work to hackathon judges and potential employers.

**Tech Stack**: ${topLanguages.join(", ") || "JavaScript, React, Node.js"}

**Key Features**:
• Automatic GitHub integration and project showcase
• AI-powered code quality analysis and recommendations  
• Interactive skill visualization and progress tracking
• Resume optimization based on trending technologies

**Difficulty**: Intermediate

**Why Perfect for You**: Matches your ${languages[topLanguages[0]] || 0}+ ${topLanguages[0] || "programming"} repositories and showcases your diverse technical skills across ${Object.keys(languages).length} programming languages.

**Potential Impact**: Helps developers present their skills more effectively and discover growth opportunities.

---

**🚀 Project 2: Open Source Contribution Finder**

**Category**: AI Agents

**Description**: Build an intelligent system that analyzes a developer's GitHub profile and recommends the most suitable open source projects to contribute to, based on their skills, interests, and experience level.

**Tech Stack**: ${topLanguages.slice(0, 3).join(", ") || "Python, JavaScript, React"}

**Key Features**:
• GitHub profile analysis and skill matching
• Open source project recommendation engine
• Contribution difficulty assessment
• Community impact scoring

**Difficulty**: ${repositories.length > 10 ? "Advanced" : "Intermediate"}

**Why Perfect for You**: Leverages your experience with ${topTopics.join(", ") || "various technologies"} and your ${userInfo.public_repos || 0} public repositories demonstrate strong open source engagement.

**Potential Impact**: Helps developers find meaningful open source contributions and strengthens the developer community.

---

**🚀 Project 3: Hackathon Team Builder**

**Category**: Web3 & Community

**Description**: Create a platform that uses AI to match developers with complementary skills for hackathon teams, analyzing GitHub profiles to ensure balanced team composition and project success potential.

**Tech Stack**: ${topFrameworks.length > 0 ? Array.from(frameworks).slice(0, 3).join(", ") : "React, Node.js, MongoDB"}

**Key Features**:
• Skill-based team matching algorithm
• Real-time hackathon event integration
• Team communication and project planning tools
• Success prediction based on team composition

**Difficulty**: Advanced

**Why Perfect for You**: Your ${repositories.length} repositories show collaboration skills, and your diverse technology experience (${topFrameworks.length} different frameworks) makes you ideal for building team coordination tools.

**Potential Impact**: Improves hackathon outcomes by creating more balanced and effective teams.

---

**💡 Pro Tips for Success**:
• Start with the core functionality first
• Focus on user experience and clear value proposition
• Prepare a compelling demo that shows real-world usage
• Consider open-sourcing for community impact`;

    return NextResponse.json({
      success: true,
      recommendations,
      profile: {
        username: userInfo.login,
        repos: userInfo.public_repos || 0,
        languages: topLanguages,
        topics: topTopics.slice(0, 5),
        frameworks: topFrameworks.slice(0, 5),
      },
    });
  } catch (error) {
    return NextResponse.json(
      { success: false, error: `Analysis failed: ${String(error)}` },
      { status: 500 }
    );
  }
}
