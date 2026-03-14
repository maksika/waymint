"use client";

import { useState } from "react";
import { createPublicClient, http, isAddress, pad } from "viem";
import { CLAIM_MINTER_ABI, CONTRACTS, VERIFICATION_LEVELS } from "@/lib/contracts";

const LEVEL_COLORS = ["text-zinc-400", "text-blue-400", "text-green-400"];
const LEVEL_ICONS = ["🔑", "🪪", "✅"];

export default function VerifyPage() {
  const [address, setAddress] = useState("");
  const [loading, setLoading] = useState(false);
  const [cert, setCert] = useState<null | {
    certId: bigint;
    owner: string;
    level: number;
    agentProvider: string;
    agentURI: string;
    issuedAt: bigint;
    active: boolean;
  }>(null);
  const [error, setError] = useState("");

  async function lookup() {
    setError("");
    setCert(null);
    if (!isAddress(address)) {
      setError("Please enter a valid Ethereum address");
      return;
    }
    setLoading(true);
    try {
      const client = createPublicClient({
        transport: http(CONTRACTS.statusSepolia.rpc),
      });

      const agentKey = pad(address as `0x${string}`, { size: 32 });

      const result = await client.readContract({
        address: CONTRACTS.statusSepolia.address,
        abi: CLAIM_MINTER_ABI,
        functionName: "getCertForAgent",
        args: [agentKey],
      });

      if (!result.active && result.certId === 0n) {
        setError("No certificate found for this address");
      } else {
        setCert({
          certId: result.certId,
          owner: result.owner,
          level: result.level,
          agentProvider: result.agentProvider,
          agentURI: result.agentURI,
          issuedAt: result.issuedAt,
          active: result.active,
        });
      }
    } catch (e) {
      setError("Lookup failed: " + String(e));
    }
    setLoading(false);
  }

  return (
    <main className="min-h-screen bg-black text-white flex flex-col items-center px-6 py-16">
      <div className="text-4xl mb-4">🔍</div>
      <h1 className="text-3xl font-bold mb-2">Verify an Agent</h1>
      <p className="text-zinc-400 mb-10 text-center max-w-md">
        Look up a WayMint provenance certificate by wallet address.
      </p>

      <div className="w-full max-w-xl flex gap-3 mb-8">
        <input
          type="text"
          placeholder="0x... agent wallet address"
          value={address}
          onChange={(e) => setAddress(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && lookup()}
          className="flex-1 bg-zinc-900 border border-zinc-700 rounded-lg px-4 py-3 text-white placeholder-zinc-500 focus:outline-none focus:border-zinc-400"
        />
        <button
          onClick={lookup}
          disabled={loading}
          className="px-6 py-3 bg-white text-black font-semibold rounded-lg hover:bg-zinc-200 transition disabled:opacity-50"
        >
          {loading ? "..." : "Verify"}
        </button>
      </div>

      {error && (
        <p className="text-red-400 mb-6">{error}</p>
      )}

      {cert && (
        <div className="w-full max-w-xl bg-zinc-950 border border-zinc-800 rounded-xl p-6 space-y-4">
          <div className="flex items-center gap-3">
            <span className="text-3xl">{LEVEL_ICONS[cert.level]}</span>
            <div>
              <div className={`text-lg font-semibold ${LEVEL_COLORS[cert.level]}`}>
                {VERIFICATION_LEVELS[cert.level]}
              </div>
              <div className="text-sm text-zinc-500">Certificate #{cert.certId.toString()}</div>
            </div>
            {cert.active ? (
              <span className="ml-auto text-green-500 text-sm font-medium">Active</span>
            ) : (
              <span className="ml-auto text-red-500 text-sm font-medium">Suspended</span>
            )}
          </div>

          <div className="border-t border-zinc-800 pt-4 space-y-2 text-sm">
            <Row label="Owner" value={cert.owner} mono />
            <Row label="Provider" value={cert.agentProvider || "—"} />
            <Row label="Metadata URI" value={cert.agentURI || "—"} />
            <Row label="Issued" value={new Date(Number(cert.issuedAt) * 1000).toLocaleString()} />
          </div>

          <a
            href={`${CONTRACTS.statusSepolia.explorer}/address/${CONTRACTS.statusSepolia.address}`}
            target="_blank"
            rel="noopener noreferrer"
            className="block text-center text-xs text-zinc-500 hover:text-zinc-300 mt-2"
          >
            View on explorer ↗
          </a>
        </div>
      )}
    </main>
  );
}

function Row({ label, value, mono }: { label: string; value: string; mono?: boolean }) {
  return (
    <div className="flex justify-between gap-4">
      <span className="text-zinc-500">{label}</span>
      <span className={`text-zinc-200 text-right break-all ${mono ? "font-mono text-xs" : ""}`}>
        {value}
      </span>
    </div>
  );
}
