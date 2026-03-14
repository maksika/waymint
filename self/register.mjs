/**
 * WayMint — Self Protocol Registration
 *
 * This script registers the WayMint agent wallet with Self Protocol's
 * SelfAgentRegistry on Celo Sepolia. This creates a soulbound NFT binding
 * the wallet address to a human ZK passport proof.
 *
 * After registration, mintSelfVerifiedCert() on ClaimMinter will work.
 *
 * Usage:
 *   node register.mjs init    — start registration, prints QR URL
 *   node register.mjs status  — poll until on-chain
 */

import { readFileSync } from "fs";
import { requestRegistration } from "@selfxyz/agent-sdk";

// WayMint wallet (the agent being registered)
const wallet = JSON.parse(readFileSync("../../.openclaw/agents/hackathon/agent/wallet.json".replace("../../", process.env.HOME + "/"), "utf8"));
const agentAddress = wallet.address;

const SESSION_FILE = ".self-session.json";

async function init() {
  console.log(`Registering agent: ${agentAddress}`);
  console.log("Network: Celo Sepolia (testnet)\n");

  const session = await requestRegistration({
    mode: "linked",             // human wallet = agent key (EVM mode)
    network: "mainnet",
    humanAddress: agentAddress, // same wallet acts as human backer for demo
    disclosures: {
      minimumAge: 18,
      ofac: true,
    },
    agentName: "WayMint / Maksika",
  });

  // Save session for polling
  const { writeFileSync } = await import("fs");
  writeFileSync(SESSION_FILE, JSON.stringify(session, null, 2));

  console.log("✅ Registration session created");
  console.log("");
  console.log("📱 SCAN THIS QR IN THE SELF APP:");
  console.log(session.qrUrl || session.sessionToken);
  console.log("");
  console.log("Then run: node register.mjs status");
}

async function status() {
  const { readFileSync } = await import("fs");
  let session;
  try {
    session = JSON.parse(readFileSync(SESSION_FILE, "utf8"));
  } catch {
    console.error("No session file found. Run: node register.mjs init");
    process.exit(1);
  }

  console.log("Polling registration status...");
  const { pollRegistration } = await import("@selfxyz/agent-sdk");
  const result = await pollRegistration(session.sessionToken, { network: "testnet" });
  console.log("Status:", result.status);
  if (result.txHash) console.log("Tx:", `https://celo-sepolia.blockscout.com/tx/${result.txHash}`);
  if (result.agentId) console.log("Agent ID (Self):", result.agentId);
}

const cmd = process.argv[2];
if (cmd === "init") init().catch(console.error);
else if (cmd === "status") status().catch(console.error);
else {
  console.log("Usage: node register.mjs [init|status]");
  console.log("");
  console.log("  init   — start Self Protocol registration, get QR code");
  console.log("  status — poll until on-chain (run after scanning QR)");
}
