export const CLAIM_MINTER_ABI = [
  {
    "inputs": [{"name": "_selfRegistry", "type": "address"}],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "name": "mintWalletCert",
    "inputs": [
      {"name": "agentURI", "type": "string"},
      {"name": "agentProvider", "type": "string"}
    ],
    "outputs": [{"name": "certId", "type": "uint256"}],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "name": "mintSelfLinkedCert",
    "inputs": [
      {"name": "agentURI", "type": "string"},
      {"name": "agentProvider", "type": "string"}
    ],
    "outputs": [{"name": "certId", "type": "uint256"}],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "name": "mintSelfVerifiedCert",
    "inputs": [
      {"name": "agentURI", "type": "string"},
      {"name": "agentProvider", "type": "string"}
    ],
    "outputs": [{"name": "certId", "type": "uint256"}],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "name": "getCertForAgent",
    "inputs": [{"name": "agentKey", "type": "bytes32"}],
    "outputs": [{
      "components": [
        {"name": "certId", "type": "uint256"},
        {"name": "owner", "type": "address"},
        {"name": "agentKey", "type": "bytes32"},
        {"name": "level", "type": "uint8"},
        {"name": "selfAgentId", "type": "uint256"},
        {"name": "humanNullifier", "type": "uint256"},
        {"name": "agentURI", "type": "string"},
        {"name": "agentProvider", "type": "string"},
        {"name": "issuedAt", "type": "uint64"},
        {"name": "active", "type": "bool"}
      ],
      "name": "",
      "type": "tuple"
    }],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "name": "walletAgentKey",
    "inputs": [{"name": "wallet", "type": "address"}],
    "outputs": [{"name": "", "type": "bytes32"}],
    "stateMutability": "pure",
    "type": "function"
  },
  {
    "name": "CertificateMinted",
    "inputs": [
      {"indexed": true, "name": "certId", "type": "uint256"},
      {"indexed": true, "name": "owner", "type": "address"},
      {"indexed": true, "name": "agentKey", "type": "bytes32"},
      {"indexed": false, "name": "level", "type": "uint8"},
      {"indexed": false, "name": "selfAgentId", "type": "uint256"},
      {"indexed": false, "name": "humanNullifier", "type": "uint256"}
    ],
    "type": "event"
  }
] as const;

export const CONTRACTS = {
  statusSepolia: {
    chainId: 1660990954,
    name: "Status Network Sepolia",
    address: "0xEC2d7dbB5D05a523E04e036405Cbe2c990B5bE74" as `0x${string}`,
    rpc: "https://public.sepolia.rpc.status.network",
    explorer: "https://sepoliascan.status.network",
    gasless: true,
  },
  // celoSepolia will be added after deploy
} as const;

export const VERIFICATION_LEVELS = ["WalletOnly", "SelfLinked", "SelfVerified"] as const;
export type VerificationLevel = typeof VERIFICATION_LEVELS[number];
