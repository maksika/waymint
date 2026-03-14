"use client";

import { useState } from "react";

const TIERS = [
  {
    id: "wallet",
    name: "WalletOnly",
    icon: "🔑",
    desc: "Basic ownership cert. No identity required.",
    color: "border-zinc-600 hover:border-zinc-400",
  },
  {
    id: "linked",
    name: "SelfLinked",
    icon: "🪪",
    desc: "Requires prior Self Protocol registration on Celo.",
    color: "border-blue-700 hover:border-blue-500",
  },
  {
    id: "verified",
    name: "SelfVerified",
    icon: "✅",
    desc: "Requires active, non-expired Self ZK proof.",
    color: "border-green-700 hover:border-green-500",
  },
];

export default function MintPage() {
  const [tier, setTier] = useState<string | null>(null);
  const [agentProvider, setAgentProvider] = useState("");
  const [agentURI, setAgentURI] = useState("");

  return (
    <main className="min-h-screen bg-black text-white flex flex-col items-center px-6 py-16">
      <div className="text-4xl mb-4">🪙</div>
      <h1 className="text-3xl font-bold mb-2">Mint a Certificate</h1>
      <p className="text-zinc-400 mb-10 text-center max-w-md">
        Issue an on-chain provenance certificate for your AI agent.
      </p>

      {/* Tier selection */}
      <div className="w-full max-w-xl mb-8">
        <h2 className="text-sm font-medium text-zinc-400 mb-3 uppercase tracking-wider">
          1. Choose verification tier
        </h2>
        <div className="grid gap-3">
          {TIERS.map((t) => (
            <button
              key={t.id}
              onClick={() => setTier(t.id)}
              className={`text-left border rounded-xl p-4 transition ${t.color} ${
                tier === t.id ? "bg-zinc-900" : "bg-black"
              }`}
            >
              <div className="flex items-center gap-3">
                <span className="text-2xl">{t.icon}</span>
                <div>
                  <div className="font-semibold">{t.name}</div>
                  <div className="text-sm text-zinc-400">{t.desc}</div>
                </div>
                {tier === t.id && (
                  <span className="ml-auto text-white">●</span>
                )}
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Metadata */}
      <div className="w-full max-w-xl mb-8 space-y-4">
        <h2 className="text-sm font-medium text-zinc-400 uppercase tracking-wider">
          2. Agent details
        </h2>
        <input
          type="text"
          placeholder="Agent provider (e.g. anthropic/claude-sonnet-4-6)"
          value={agentProvider}
          onChange={(e) => setAgentProvider(e.target.value)}
          className="w-full bg-zinc-900 border border-zinc-700 rounded-lg px-4 py-3 text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-400"
        />
        <input
          type="text"
          placeholder="Metadata URI (optional, e.g. ipfs://...)"
          value={agentURI}
          onChange={(e) => setAgentURI(e.target.value)}
          className="w-full bg-zinc-900 border border-zinc-700 rounded-lg px-4 py-3 text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-400"
        />
      </div>

      {/* Connect + mint */}
      <div className="w-full max-w-xl">
        <h2 className="text-sm font-medium text-zinc-400 uppercase tracking-wider mb-3">
          3. Connect wallet & mint
        </h2>
        <div className="bg-zinc-950 border border-zinc-800 rounded-xl p-6 text-center">
          <p className="text-zinc-400 text-sm mb-4">
            Wallet connection coming soon. For now, mint directly via{" "}
            <a
              href="https://sepoliascan.status.network/address/0xEC2d7dbB5D05a523E04e036405Cbe2c990B5bE74#writeContract"
              target="_blank"
              rel="noopener noreferrer"
              className="text-white underline hover:text-zinc-300"
            >
              the contract on Status Network explorer ↗
            </a>
          </p>
          <code className="block text-xs text-zinc-500 bg-black rounded p-3 text-left break-all">
            Contract: 0xEC2d7dbB5D05a523E04e036405Cbe2c990B5bE74
            <br />
            Chain: Status Network Sepolia (1660990954)
            <br />
            Gas price: 0 (free)
          </code>
        </div>
      </div>
    </main>
  );
}
