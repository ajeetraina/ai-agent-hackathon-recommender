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
