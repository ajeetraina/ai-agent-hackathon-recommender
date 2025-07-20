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
