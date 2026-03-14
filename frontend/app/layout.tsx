import type { Metadata } from "next";
import { Geist } from "next/font/google";
import Link from "next/link";
import "./globals.css";

const geist = Geist({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "WayMint — AI Agent Provenance Certificates",
  description:
    "On-chain provenance certificates for AI agents. Think SSL certs for websites, but for AI agents. Built with Self Protocol ZK proofs.",
  openGraph: {
    title: "WayMint",
    description: "On-chain provenance certificates for AI agents.",
    url: "https://mint.way.je",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={`${geist.className} bg-black text-white antialiased`}>
        <nav className="flex items-center justify-between px-6 py-4 border-b border-zinc-900">
          <Link href="/" className="font-bold text-lg tracking-tight flex items-center gap-2">
            <span>🐝</span> WayMint
          </Link>
          <div className="flex gap-6 text-sm text-zinc-400">
            <Link href="/mint" className="hover:text-white transition">Mint</Link>
            <Link href="/verify" className="hover:text-white transition">Verify</Link>
            <a
              href="https://github.com/maksika/waymint"
              target="_blank"
              rel="noopener noreferrer"
              className="hover:text-white transition"
            >
              GitHub
            </a>
          </div>
        </nav>
        {children}
      </body>
    </html>
  );
}
