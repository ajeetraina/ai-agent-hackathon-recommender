#!/bin/bash

# 🚀 Next.js AI Agents Hackathon Project Recommender Setup
# Modern React/TypeScript stack like agno example

set -e

echo "🚀 Setting up Next.js Hackathon Project Recommender..."
echo "=================================================="

# Create the agent-ui directory structure
echo "📁 Creating Next.js project structure..."
mkdir -p agent-ui/src/{app,components,lib,types}
mkdir -p agent-ui/public

# Create package.json for Next.js
echo "📦 Creating package.json..."
cat > agent-ui/package.json << 'EOF'
{
  "name": "hackathon-recommender-ui",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev -p 3000",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "format": "prettier --check \"**/*.{ts,tsx,mdx}\" --cache",
    "format:fix": "prettier --write \"**/*.{ts,tsx,mdx}\" --cache",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "@radix-ui/react-dialog": "^1.1.5",
    "@radix-ui/react-icons": "^1.3.2",
    "@radix-ui/react-slot": "^1.1.1",
    "@radix-ui/react-tooltip": "^1.1.7",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "framer-motion": "^12.4.1",
    "lucide-react": "^0.474.0",
    "next": "15.2.3",
    "next-themes": "^0.4.4",
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "react-markdown": "^9.0.3",
    "tailwind-merge": "^3.0.1",
    "tailwindcss-animate": "^1.0.7",
    "zustand": "^5.0.3"
  },
  "devDependencies": {
    "@types/node": "^20",
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "eslint": "^9",
    "eslint-config-next": "15.2.3",
    "postcss": "^8",
    "prettier": "3.4.2",
    "tailwindcss": "^3.4.1",
    "typescript": "^5"
  }
}
EOF

# Create TypeScript configuration
echo "📝 Creating tsconfig.json..."
cat > agent-ui/tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
EOF

# Create Next.js configuration
echo "⚙️ Creating next.config.ts..."
cat > agent-ui/next.config.ts << 'EOF'
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
};

export default nextConfig;
EOF

# Create Tailwind configuration
echo "🎨 Creating tailwind.config.ts..."
cat > agent-ui/tailwind.config.ts << 'EOF'
import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: ["class"],
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))"
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))"
        },
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))"
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))"
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))"
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))"
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))"
        },
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        chart: {
          "1": "hsl(var(--chart-1))",
          "2": "hsl(var(--chart-2))",
          "3": "hsl(var(--chart-3))",
          "4": "hsl(var(--chart-4))",
          "5": "hsl(var(--chart-5))"
        }
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)"
      }
    }
  },
  plugins: [require("tailwindcss-animate")],
} satisfies Config;

export default config;
EOF

# Create PostCSS configuration
echo "📦 Creating postcss.config.mjs..."
cat > agent-ui/postcss.config.mjs << 'EOF'
/** @type {import('postcss-load-config').Config} */
const config = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};

export default config;
EOF

# Create global CSS
echo "🎨 Creating global styles..."
cat > agent-ui/src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 240 10% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 240 10% 3.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 240 10% 3.9%;
    --primary: 240 9% 89%;
    --primary-foreground: 240 5.9% 10%;
    --secondary: 240 4.8% 95.9%;
    --secondary-foreground: 240 5.9% 10%;
    --muted: 240 4.8% 95.9%;
    --muted-foreground: 240 3.8% 46.1%;
    --accent: 240 4.8% 95.9%;
    --accent-foreground: 240 5.9% 10%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 5.9% 90%;
    --input: 240 5.9% 90%;
    --ring: 240 10% 3.9%;
    --chart-1: 12 76% 61%;
    --chart-2: 173 58% 39%;
    --chart-3: 197 37% 24%;
    --chart-4: 43 74% 66%;
    --chart-5: 27 87% 67%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 240 10% 3.9%;
    --foreground: 0 0% 98%;
    --card: 240 10% 3.9%;
    --card-foreground: 0 0% 98%;
    --popover: 240 10% 3.9%;
    --popover-foreground: 0 0% 98%;
    --primary: 0 0% 98%;
    --primary-foreground: 240 5.9% 10%;
    --secondary: 240 3.7% 15.9%;
    --secondary-foreground: 0 0% 98%;
    --muted: 240 3.7% 15.9%;
    --muted-foreground: 240 5% 64.9%;
    --accent: 240 3.7% 15.9%;
    --accent-foreground: 0 0% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;
    --border: 240 3.7% 15.9%;
    --input: 240 3.7% 15.9%;
    --ring: 240 4.9% 83.9%;
    --chart-1: 220 70% 50%;
    --chart-2: 160 60% 45%;
    --chart-3: 30 80% 55%;
    --chart-4: 280 65% 60%;
    --chart-5: 340 75% 55%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
EOF

# Create root layout
echo "📄 Creating layout.tsx..."
cat > agent-ui/src/app/layout.tsx << 'EOF'
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "🏆 AI Agents Hackathon Project Recommender",
  description: "Discover your perfect hackathon project! Analyzes GitHub profiles to recommend personalized projects.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900">
        {children}
      </body>
    </html>
  );
}
EOF

# Create main page component
echo "📄 Creating page.tsx..."
cat > agent-ui/src/app/page.tsx << 'EOF'
"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Loader2, Github, Search, Cpu, Zap } from "lucide-react";

interface AnalysisResult {
  success: boolean;
  recommendations?: string;
  profile?: {
    username: string;
    repos: number;
    languages: string[];
  };
  error?: string;
}

export default function Home() {
  const [username, setUsername] = useState("");
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState<AnalysisResult | null>(null);

  const handleAnalyze = async () => {
    if (!username.trim()) return;

    setLoading(true);
    setResult(null);

    try {
      const response = await fetch("/api/analyze", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ username: username.trim() }),
      });

      const data: AnalysisResult = await response.json();
      setResult(data);
    } catch (error) {
      setResult({
        success: false,
        error: "Network error. Please check that the backend is running.",
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-4xl">
      {/* Header */}
      <div className="text-center mb-8">
        <div className="inline-flex items-center gap-2 bg-gradient-to-r from-yellow-500 to-orange-500 text-black px-6 py-3 rounded-full font-bold text-2xl mb-4">
          🏆 AI Agents Hackathon Project Recommender
        </div>
        <p className="text-xl text-gray-300 mb-2">
          <strong>Discover your perfect hackathon project!</strong>
        </p>
        <p className="text-gray-400 mb-4">
          Analyzes GitHub profiles to recommend personalized projects that match your skills and interests.
        </p>
        <p className="text-sm text-blue-400 italic">
          Inspired by Microsoft AI Agents for Beginners - built with MCP servers & Docker Model Runner
        </p>
      </div>

      {/* Input Form */}
      <Card className="mb-8 bg-gray-800/50 border-gray-700">
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-white">
            <Search className="w-5 h-5" />
            Enter GitHub Username
          </CardTitle>
          <CardDescription>
            Enter any GitHub username to analyze their coding style and recommend projects
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <Input
            placeholder="e.g., ajeetraina, microsoft, openai, torvalds"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && !loading && handleAnalyze()}
            className="bg-gray-900 border-gray-600 text-white placeholder-gray-400"
          />
          <Button
            onClick={handleAnalyze}
            disabled={!username.trim() || loading}
            className="w-full bg-gradient-to-r from-red-500 to-pink-500 hover:from-red-600 hover:to-pink-600"
          >
            {loading ? (
              <>
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                Analyzing GitHub profile...
              </>
            ) : (
              <>
                🚀 Generate Hackathon Recommendations
              </>
            )}
          </Button>

          {/* Powered By Badges */}
          <div className="flex flex-wrap gap-2 justify-center">
            <Badge variant="secondary" className="bg-green-600 text-white">
              <Github className="w-3 h-3 mr-1" />
              GitHub MCP Server
            </Badge>
            <Badge variant="secondary" className="bg-green-600 text-white">
              <Search className="w-3 h-3 mr-1" />
              DuckDuckGo Search
            </Badge>
            <Badge variant="secondary" className="bg-green-600 text-white">
              <Cpu className="w-3 h-3 mr-1" />
              AI Model Runner
            </Badge>
            <Badge variant="secondary" className="bg-green-600 text-white">
              <Zap className="w-3 h-3 mr-1" />
              WebSocket-Free
            </Badge>
          </div>
        </CardContent>
      </Card>

      {/* Results */}
      {loading && (
        <Card className="mb-8 bg-blue-900/20 border-blue-700">
          <CardContent className="pt-6">
            <div className="flex items-center justify-center gap-3">
              <Loader2 className="w-8 h-8 animate-spin text-blue-400" />
              <div>
                <p className="text-blue-300 font-medium">
                  🤖 Analyzing GitHub profile and generating personalized recommendations...
                </p>
                <p className="text-sm text-blue-400 mt-1">
                  This may take 30-60 seconds for AI processing
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {result && !loading && (
        <Card className={`mb-8 ${result.success ? 'bg-green-900/20 border-green-700' : 'bg-red-900/20 border-red-700'}`}>
          <CardHeader>
            <CardTitle className={result.success ? 'text-green-300' : 'text-red-300'}>
              {result.success ? '✅ Analysis Complete!' : '❌ Error'}
            </CardTitle>
            {result.success && result.profile && (
              <CardDescription className="text-green-400">
                Found {result.profile.repos} repositories • Top languages: {result.profile.languages.join(', ')}
              </CardDescription>
            )}
          </CardHeader>
          <CardContent>
            {result.success ? (
              <div className="prose prose-invert max-w-none">
                <pre className="whitespace-pre-wrap text-gray-200 leading-relaxed">
                  {result.recommendations}
                </pre>
              </div>
            ) : (
              <p className="text-red-300">{result.error}</p>
            )}
          </CardContent>
        </Card>
      )}

      {/* Footer */}
      <div className="text-center text-gray-400 text-sm">
        <p className="mb-2">
          <strong>🛠️ Built with MCP (Model Context Protocol)</strong>
        </p>
        <p>GitHub Analysis • Trend Research • AI Recommendations • Secure Infrastructure</p>
      </div>
    </div>
  );
}
EOF

# Create UI components
echo "🎨 Creating UI components..."
mkdir -p agent-ui/src/components/ui

# Button component
cat > agent-ui/src/components/ui/button.tsx << 'EOF'
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground hover:bg-primary/90",
        destructive:
          "bg-destructive text-destructive-foreground hover:bg-destructive/90",
        outline:
          "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
        secondary:
          "bg-secondary text-secondary-foreground hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
EOF

# Input component
cat > agent-ui/src/components/ui/input.tsx << 'EOF'
import * as React from "react"
import { cn } from "@/lib/utils"

export interface InputProps
  extends React.InputHTMLAttributes<HTMLInputElement> {}

const Input = React.forwardRef<HTMLInputElement, InputProps>(
  ({ className, type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Input.displayName = "Input"

export { Input }
EOF

# Card components
cat > agent-ui/src/components/ui/card.tsx << 'EOF'
import * as React from "react"
import { cn } from "@/lib/utils"

const Card = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      "rounded-lg border bg-card text-card-foreground shadow-sm",
      className
    )}
    {...props}
  />
))
Card.displayName = "Card"

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col space-y-1.5 p-6", className)}
    {...props}
  />
))
CardHeader.displayName = "CardHeader"

const CardTitle = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn(
      "text-2xl font-semibold leading-none tracking-tight",
      className
    )}
    {...props}
  />
))
CardTitle.displayName = "CardTitle"

const CardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn("text-sm text-muted-foreground", className)}
    {...props}
  />
))
CardDescription.displayName = "CardDescription"

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
))
CardContent.displayName = "CardContent"

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex items-center p-6 pt-0", className)}
    {...props}
  />
))
CardFooter.displayName = "CardFooter"

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent }
EOF

# Badge component
cat > agent-ui/src/components/ui/badge.tsx << 'EOF'
import * as React from "react"
import { cva, type VariantProps } from "class-variance-authority"
import { cn } from "@/lib/utils"

const badgeVariants = cva(
  "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
  {
    variants: {
      variant: {
        default:
          "border-transparent bg-primary text-primary-foreground hover:bg-primary/80",
        secondary:
          "border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80",
        destructive:
          "border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80",
        outline: "text-foreground",
      },
    },
    defaultVariants: {
      variant: "default",
    },
  }
)

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant }), className)} {...props} />
  )
}

export { Badge, badgeVariants }
EOF

# Create utility functions
echo "🔧 Creating lib/utils.ts..."
cat > agent-ui/src/lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF

# Create API route
echo "🔌 Creating API route..."
mkdir -p agent-ui/src/app/api/analyze
cat > agent-ui/src/app/api/analyze/route.ts << 'EOF'
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
EOF

# Create Dockerfile for agent-ui
echo "🐳 Creating Dockerfile for Next.js..."
cat > agent-ui/Dockerfile << 'EOF'
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json package-lock.json* ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Build the application
RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Automatically leverage output traces to reduce image size
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]
EOF

# Update compose.yaml to include Next.js UI
echo "🔧 Updating compose.yaml..."
cat > compose.yaml << 'EOF'
services:
  agents-ui:
    build:
      context: agent-ui
    ports:
      - "3000:3000"
    environment:
      - MCPGATEWAY_ENDPOINT=http://mcp-gateway:8811/sse
    depends_on:
      - mcp-gateway

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

echo ""
echo "✅ Next.js Hackathon Project Recommender setup complete!"
echo "=================================================="
echo ""
echo "📁 Files created:"
echo "   • agent-ui/                 - Complete Next.js application"
echo "   • agent-ui/src/app/         - Next.js app router pages"
echo "   • agent-ui/src/components/  - Reusable UI components"
echo "   • agent-ui/src/app/api/     - API routes for MCP integration"
echo "   • compose.yaml              - Updated for Next.js"
echo ""
echo "🔧 Next steps:"
echo "   1. Ensure .mcp.env exists with your GitHub token:"
echo "      cp .mcp.env.example .mcp.env"
echo "      # Then edit .mcp.env with your real token"
echo ""
echo "   2. Install dependencies and start:"
echo "      cd agent-ui && npm install"
echo "      cd .. && docker compose up --build"
echo ""
echo "   3. Open in browser:"
echo "      http://localhost:3000"
echo ""
echo "🎯 Benefits of Next.js version:"
echo "   ✅ Modern React/TypeScript stack"
echo "   ✅ Beautiful Tailwind CSS UI"
echo "   ✅ Component-based architecture"
echo "   ✅ Type safety with TypeScript"
echo "   ✅ Same MCP functionality"
echo "   ✅ Follows agno example pattern"
echo ""
echo "🚀 Your modern Next.js AI Agents Hackathon Project Recommender is ready!"
