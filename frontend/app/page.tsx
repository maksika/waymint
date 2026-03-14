import Link from "next/link";

export default function Home() {
  return (
    <main className="min-h-screen bg-black text-white flex flex-col">
      {/* Hero */}
      <section className="flex flex-col items-center justify-center flex-1 px-6 py-24 text-center">
        <div className="text-6xl mb-6">🐝</div>
        <h1 className="text-5xl md:text-7xl font-bold tracking-tight mb-6">
          WayMint
        </h1>
        <p className="text-xl md:text-2xl text-zinc-400 max-w-2xl mb-4">
          On-chain provenance certificates for AI agents.
        </p>
        <p className="text-base text-zinc-500 max-w-xl mb-12">
          Think SSL certificates for websites — but for AI agents.
          Verifiable, privacy-preserving, backed by Self Protocol ZK proofs.
        </p>
        <div className="flex gap-4 flex-wrap justify-center">
          <Link
            href="/mint"
            className="px-8 py-4 bg-white text-black font-semibold rounded-lg hover:bg-zinc-200 transition"
          >
            Mint a Certificate
          </Link>
          <Link
            href="/verify"
            className="px-8 py-4 border border-zinc-700 text-white font-semibold rounded-lg hover:border-zinc-400 transition"
          >
            Verify an Agent
          </Link>
        </div>
      </section>

      {/* Trust tiers */}
      <section className="px-6 py-20 max-w-5xl mx-auto w-full">
        <h2 className="text-2xl font-semibold mb-10 text-center text-zinc-300">
          Three tiers of trust
        </h2>
        <div className="grid md:grid-cols-3 gap-6">
          {[
            {
              tier: "WalletOnly",
              icon: "🔑",
              color: "border-zinc-600",
              desc: "Basic ownership proof. Links an AI agent to a wallet address. No identity verification required.",
            },
            {
              tier: "SelfLinked",
              icon: "🪪",
              color: "border-blue-700",
              desc: "Registered in Self Protocol. Agent is backed by a passport/ID ZK proof — human behind the agent is real.",
            },
            {
              tier: "SelfVerified",
              icon: "✅",
              color: "border-green-600",
              desc: "Active, non-expired ZK proof. The strongest guarantee — live verification against Self Protocol's registry.",
            },
          ].map(({ tier, icon, color, desc }) => (
            <div
              key={tier}
              className={`border ${color} rounded-xl p-6 bg-zinc-950`}
            >
              <div className="text-3xl mb-3">{icon}</div>
              <h3 className="text-lg font-semibold mb-2">{tier}</h3>
              <p className="text-sm text-zinc-400">{desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* How it works */}
      <section className="px-6 py-16 border-t border-zinc-900 max-w-3xl mx-auto w-full">
        <h2 className="text-2xl font-semibold mb-8 text-center text-zinc-300">How it works</h2>
        <ol className="space-y-4 text-zinc-400">
          {[
            "Connect the wallet that controls your AI agent",
            "Choose a verification tier (WalletOnly → SelfVerified)",
            "Mint your provenance certificate on-chain",
            "Share the certificate URL — anyone can verify your agent's authenticity",
          ].map((step, i) => (
            <li key={i} className="flex gap-4">
              <span className="text-white font-bold">{i + 1}.</span>
              <span>{step}</span>
            </li>
          ))}
        </ol>
      </section>

      {/* Footer */}
      <footer className="text-center text-zinc-600 text-sm py-8 border-t border-zinc-900">
        Built at The Synthesis Hackathon 2026 by{" "}
        <a href="https://x.com/Maksikabee" className="hover:text-zinc-400 underline">
          Maksika 🐝
        </a>
        {" · "}
        <a href="https://github.com/maksika/waymint" className="hover:text-zinc-400 underline">
          GitHub
        </a>
      </footer>
    </main>
  );
}
