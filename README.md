# WayMint 🐝

> On-chain provenance certificates for AI agents — trust rails for the agent ecosystem.

**Built at [The Synthesis Hackathon](https://synthesis.md) by [Maksika](https://x.com/Maksikabee) 🐝**

Think: SSL certificates for websites, but for AI agents.

When an AI agent contacts your API, places an order, or negotiates on your behalf — there's no standard way to verify who built or operates it. WayMint solves this with on-chain, permissionless, composable provenance.

---

## Local Setup

### Prerequisites

- Node.js 18+
- Git

### 1. Clone the repo

```bash
git clone https://github.com/maksika/waymint.git
cd waymint
```

### 2. Run the frontend

```bash
cd frontend
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

### 3. Run the contracts (optional)

Requires [Foundry](https://book.getfoundry.sh/getting-started/installation).

```bash
cd contracts
forge install
forge build
forge test
```

To deploy to Status Network Sepolia (gasless):

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url https://public.sepolia.rpc.status.network \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --legacy \
  --gas-price 0
```

> **Note:** Status Network doesn't support the PUSH0 opcode (EIP-3855). The `foundry.toml` is already set to `evm_version = "paris"` to handle this.

---

## How It Works

1. **Connect your wallet** — the wallet that controls your AI agent
2. **Choose a verification tier:**
   - 🔑 **WalletOnly** — basic ownership cert, no identity required
   - 🪪 **SelfLinked** — requires prior Self Protocol registration (passport-backed)
   - ✅ **SelfVerified** — requires an active, non-expired ZK proof from Self Protocol
3. **Mint the certificate** — stored on-chain, readable by anyone
4. **Share the certificate URL** — anyone can verify your agent's authenticity via `/verify`

---

## Deployed Contracts

| Network | Address | Explorer |
|---|---|---|
| Status Network Sepolia | `0xEC2d7dbB5D05a523E04e036405Cbe2c990B5bE74` | [sepoliascan.status.network](https://sepoliascan.status.network/address/0xEC2d7dbB5D05a523E04e036405Cbe2c990B5bE74) |

---

## Architecture

```
waymint/
├── contracts/          # Solidity — Foundry project
│   └── src/
│       ├── ClaimMinter.sol         # Core certificate minter
│       └── ISelfAgentRegistry.sol  # Self Protocol interface
├── frontend/           # Next.js 16 + TypeScript + Tailwind
│   └── app/
│       ├── page.tsx    # Homepage
│       ├── mint/       # Mint a certificate
│       └── verify/     # Verify an agent
└── self/               # Self Protocol registration flow
    └── register.mjs    # CLI: init registration QR + poll status
```

---

## Self Protocol Integration

WayMint uses [Self Protocol's SelfAgentRegistry](https://github.com/selfxyz/self-agent-id) for ZK-backed identity verification. This integration is **load-bearing**, not decorative:

- `mintSelfLinkedCert()` — calls `getAgentId(agentKey)` on the live registry; reverts if not registered
- `mintSelfVerifiedCert()` — calls `isVerifiedAgent(agentKey)`; reverts if proof is expired or missing

Registry addresses:
- Celo Mainnet: `0xaC3DF9ABf80d0F5c020C06B04Cced27763355944`
- Celo Sepolia: `0x043DaCac8b0771DD5b444bCC88f2f8BBDBEdd379`

---

## Bounty Targets

| Bounty | Track | Status |
|---|---|---|
| Self Protocol | $1,000 — ZK identity integration | 🟡 In progress |
| Status Network | ~$50 — gasless deploy + AI agent | ✅ Qualified |
| Synthesis Open Track | $7,661 | 🟡 In progress |

---

## Stack

- **Contracts:** Foundry, Solidity 0.8.x
- **Identity:** Self Protocol (ZK passport proofs)
- **Standard:** ERC-8004 (trustless agent identity)
- **Frontend:** Next.js 16, TypeScript, Tailwind, viem
- **Chains:** Status Network Sepolia (gasless), Celo (Self Protocol)

---

## Links

- Site: https://mint.way.je *(coming soon)*
- X: [@Maksikabee](https://x.com/Maksikabee)
- GitHub: [maksika/waymint](https://github.com/maksika/waymint)
