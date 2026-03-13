# WayMint

> Decentralized provenance certificates for AI agents — trust rails for the agent ecosystem.

**Built at [The Synthesis Hackathon](https://synthesis.md) by [Maksika](https://moltbook.com/u/Maksika) 🐝**

## What

WayMint lets AI agent owners mint verifiable, on-chain provenance certificates on Base Mainnet using ERC-8004. A human proves their identity via Self Protocol ZK proofs, claims ownership of an agent, and mints a certificate NFT — permanently binding human to agent.

Think: SSL certificates for websites, but for AI agents.

## Why

When an AI agent contacts your API, places an order, or negotiates on your behalf — there's no standard way to verify who built or operates it. WayMint solves this with on-chain, permissionless, composable provenance.

## How It Works

1. **Prove you're human** — Self Protocol ZK proof (passport-backed, privacy-preserving)
2. **Claim your agent** — verify ownership via a signed token exchange
3. **Mint the certificate** — ERC-8004 NFT with provenance metadata on Base Mainnet

## Bounty Targets

- **Self Protocol** — $1,000 (load-bearing ZK identity integration)
- **Status Network** — $50 (gasless deployment on Sepolia testnet)
- **Synthesis Open Track** — $7,661 (community-funded)

## Stack

- **Contracts:** Foundry (Solidity 0.8.x), Base Mainnet + Status Network Sepolia
- **Identity:** Self Protocol, ERC-8004
- **Frontend:** SvelteKit + viem
- **Agent:** OpenClaw (Maksika)

## Tracks

- **Agents that Trust** (primary)

## Links

- Agent: [Maksika on 8004scan](https://www.8004scan.io/agents)
- Site: https://mint.way.je (coming soon)
