// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IIdentityRegistry.sol";

/// @title ClaimMinter — WayMint provenance certificate minter
/// @notice Binds a verified human identity to an AI agent via an on-chain ERC-8004 mint.
///         Human proves identity (Self Protocol ZK proof), claims an agent, and mints
///         a permanent provenance certificate on Base Mainnet.
/// @author Maksika 🐝 (The Synthesis Hackathon 2026)
contract ClaimMinter {

    // -------------------------------------------------------------------------
    // Types
    // -------------------------------------------------------------------------

    enum VerificationLevel {
        WalletOnly,     // 0 — wallet address only
        BaseAccount,    // 1 — verified via Base Account (passkey/email)
        SelfProtocol    // 2 — ZK proof backed by passport/ID (Self Protocol)
    }

    struct Claim {
        uint256 agentId;          // ERC-8004 agent identity token ID
        address owner;            // wallet that made the claim
        VerificationLevel level;  // identity verification tier
        bytes32 proofHash;        // hash of Self Protocol proof (0x0 for lower tiers)
        uint64 timestamp;         // block timestamp of mint
        bool active;              // false if suspended
    }

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    IIdentityRegistry public immutable registry;
    address public immutable waymintAdmin;

    /// claimId => Claim
    mapping(uint256 => Claim) public claims;

    /// agentId => claimId (0 = unclaimed)
    mapping(uint256 => uint256) public agentToClaim;

    /// owner => claimIds
    mapping(address => uint256[]) public ownerClaims;

    /// verification tokens (hash => used)
    mapping(bytes32 => bool) public usedTokens;

    uint256 public nextClaimId = 1;

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    event ClaimMinted(
        uint256 indexed claimId,
        uint256 indexed agentId,
        address indexed owner,
        VerificationLevel level,
        bytes32 proofHash
    );

    event ClaimSuspended(uint256 indexed claimId);
    event ClaimReactivated(uint256 indexed claimId);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    error AlreadyClaimed(uint256 agentId);
    error TokenAlreadyUsed(bytes32 tokenHash);
    error NotClaimOwner(uint256 claimId);
    error ClaimNotActive(uint256 claimId);
    error InvalidProof();

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    constructor(address _registry) {
        registry = IIdentityRegistry(_registry);
        waymintAdmin = msg.sender;
    }

    // -------------------------------------------------------------------------
    // Core: Mint
    // -------------------------------------------------------------------------

    /// @notice Mint a WalletOnly claim (basic tier — no ZK verification)
    /// @param agentURI  Metadata URI for the ERC-8004 registration
    /// @param agentProvider  e.g. "anthropic/claude-sonnet-4-6"
    /// @param verificationToken  One-time token proving agent ownership
    function mintWalletClaim(
        string calldata agentURI,
        string calldata agentProvider,
        bytes32 verificationToken
    ) external returns (uint256 claimId) {
        bytes32 tokenHash = keccak256(abi.encodePacked(verificationToken, msg.sender));
        if (usedTokens[tokenHash]) revert TokenAlreadyUsed(tokenHash);
        usedTokens[tokenHash] = true;

        return _mintClaim(agentURI, agentProvider, VerificationLevel.WalletOnly, bytes32(0));
    }

    /// @notice Mint a Self Protocol ZK-verified claim (highest trust tier)
    /// @param agentURI          Metadata URI for the ERC-8004 registration
    /// @param agentProvider     e.g. "anthropic/claude-sonnet-4-6"
    /// @param verificationToken One-time token proving agent ownership
    /// @param selfProofHash     Hash of the Self Protocol ZK proof (stored on-chain)
    function mintSelfClaim(
        string calldata agentURI,
        string calldata agentProvider,
        bytes32 verificationToken,
        bytes32 selfProofHash
    ) external returns (uint256 claimId) {
        if (selfProofHash == bytes32(0)) revert InvalidProof();

        bytes32 tokenHash = keccak256(abi.encodePacked(verificationToken, msg.sender));
        if (usedTokens[tokenHash]) revert TokenAlreadyUsed(tokenHash);
        usedTokens[tokenHash] = true;

        return _mintClaim(agentURI, agentProvider, VerificationLevel.SelfProtocol, selfProofHash);
    }

    // -------------------------------------------------------------------------
    // Core: Lifecycle
    // -------------------------------------------------------------------------

    /// @notice Suspend a claim (owner or admin)
    function suspend(uint256 claimId) external {
        Claim storage c = claims[claimId];
        if (msg.sender != c.owner && msg.sender != waymintAdmin) revert NotClaimOwner(claimId);
        if (!c.active) revert ClaimNotActive(claimId);
        c.active = false;
        emit ClaimSuspended(claimId);
    }

    /// @notice Reactivate a suspended claim (owner only)
    function reactivate(uint256 claimId) external {
        Claim storage c = claims[claimId];
        if (msg.sender != c.owner) revert NotClaimOwner(claimId);
        c.active = true;
        emit ClaimReactivated(claimId);
    }

    // -------------------------------------------------------------------------
    // View
    // -------------------------------------------------------------------------

    /// @notice Get claim status for a given agent
    function getClaimStatus(uint256 agentId) external view returns (
        bool claimed,
        bool active,
        VerificationLevel level,
        address owner,
        uint64 timestamp
    ) {
        uint256 claimId = agentToClaim[agentId];
        if (claimId == 0) return (false, false, VerificationLevel.WalletOnly, address(0), 0);
        Claim storage c = claims[claimId];
        return (true, c.active, c.level, c.owner, c.timestamp);
    }

    /// @notice Get all claim IDs for an owner
    function getOwnerClaims(address owner) external view returns (uint256[] memory) {
        return ownerClaims[owner];
    }

    // -------------------------------------------------------------------------
    // Internal
    // -------------------------------------------------------------------------

    function _mintClaim(
        string calldata agentURI,
        string calldata agentProvider,
        VerificationLevel level,
        bytes32 proofHash
    ) internal returns (uint256 claimId) {
        // Register agent on ERC-8004
        uint256 agentId = registry.register(msg.sender, agentURI);

        if (agentToClaim[agentId] != 0) revert AlreadyClaimed(agentId);

        // Write provenance metadata
        registry.setMetadata(agentId, "waymint:provider", bytes(agentProvider));
        registry.setMetadata(agentId, "waymint:verificationLevel", abi.encode(uint8(level)));
        if (proofHash != bytes32(0)) {
            registry.setMetadata(agentId, "waymint:selfProofHash", abi.encode(proofHash));
        }
        registry.setMetadata(agentId, "waymint:claimedAt", abi.encode(uint64(block.timestamp)));

        // Store claim
        claimId = nextClaimId++;
        claims[claimId] = Claim({
            agentId: agentId,
            owner: msg.sender,
            level: level,
            proofHash: proofHash,
            timestamp: uint64(block.timestamp),
            active: true
        });

        agentToClaim[agentId] = claimId;
        ownerClaims[msg.sender].push(claimId);

        emit ClaimMinted(claimId, agentId, msg.sender, level, proofHash);
    }
}
