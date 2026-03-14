// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ISelfAgentRegistry.sol";

/// @title ClaimMinter — WayMint provenance certificate minter
/// @notice Issues on-chain provenance certificates for AI agents.
///         Certificates bind an agent identifier to a human owner at three trust levels:
///           0. WalletOnly  — wallet address only, no identity verification
///           1. SelfLinked  — agent is registered in Self Protocol's SelfAgentRegistry
///                            (passport/ID backed, ZK proof on Celo)
///           2. SelfVerified — registered AND currently has a valid non-expired proof
///
///         Self Protocol integration is load-bearing:
///           - SelfLinked requires getAgentId(agentKey) > 0
///           - SelfVerified requires isVerifiedAgent(agentKey) == true
///           Both check the live SelfAgentRegistry contract on Celo.
///
/// @author Maksika 🐝 (The Synthesis Hackathon 2026 — WayMint)
contract ClaimMinter {

    // -------------------------------------------------------------------------
    // Types
    // -------------------------------------------------------------------------

    enum VerificationLevel {
        WalletOnly,    // 0 — wallet address only
        SelfLinked,    // 1 — registered in Self Protocol (has ZK registration)
        SelfVerified   // 2 — registered AND proof is currently valid (non-expired)
    }

    struct Certificate {
        uint256 certId;
        address owner;
        bytes32 agentKey;         // 32-byte agent identifier (used with SelfAgentRegistry)
        VerificationLevel level;
        uint256 selfAgentId;      // Self Protocol token ID (0 if WalletOnly)
        uint256 humanNullifier;   // Sybil-resistance nullifier from Self (0 if WalletOnly)
        string  agentURI;         // metadata URI
        string  agentProvider;    // e.g. "anthropic/claude-sonnet-4-6"
        uint64  issuedAt;
        bool    active;
    }

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    ISelfAgentRegistry public immutable selfRegistry;
    address            public immutable admin;

    mapping(uint256 => Certificate)    public certs;
    mapping(bytes32 => uint256)        public agentKeyToCert;  // agentKey => certId
    mapping(address => uint256[])      public ownerCerts;

    uint256 public nextCertId = 1;

    // -------------------------------------------------------------------------
    // Events
    // -------------------------------------------------------------------------

    event CertificateMinted(
        uint256 indexed certId,
        address indexed owner,
        bytes32 indexed agentKey,
        VerificationLevel level,
        uint256 selfAgentId,
        uint256 humanNullifier
    );

    event CertificateSuspended(uint256 indexed certId);
    event CertificateReactivated(uint256 indexed certId);

    // -------------------------------------------------------------------------
    // Errors
    // -------------------------------------------------------------------------

    error AlreadyCertified(bytes32 agentKey);
    error NotCertOwner(uint256 certId);
    error CertNotActive(uint256 certId);
    error NotRegisteredInSelf();
    error ProofExpiredOrInvalid();

    // -------------------------------------------------------------------------
    // Constructor
    // -------------------------------------------------------------------------

    /// @param _selfRegistry  Address of ISelfAgentRegistry (or address(0) for mock)
    constructor(address _selfRegistry) {
        selfRegistry = ISelfAgentRegistry(_selfRegistry);
        admin = msg.sender;
    }

    // -------------------------------------------------------------------------
    // Mint — Wallet Only
    // -------------------------------------------------------------------------

    /// @notice Mint a WalletOnly certificate.
    ///         agentKey is derived from the caller's address.
    function mintWalletCert(
        string calldata agentURI,
        string calldata agentProvider
    ) external returns (uint256 certId) {
        bytes32 agentKey = _walletAgentKey(msg.sender);
        if (agentKeyToCert[agentKey] != 0) revert AlreadyCertified(agentKey);

        return _mint(msg.sender, agentKey, agentURI, agentProvider,
                     VerificationLevel.WalletOnly, 0, 0);
    }

    // -------------------------------------------------------------------------
    // Mint — Self Protocol (ZK-backed)
    // -------------------------------------------------------------------------

    /// @notice Mint a SelfLinked certificate.
    ///         selfAgentKey is the 32-byte key registered in Self Protocol's
    ///         SelfAgentRegistry (may differ from msg.sender for SDK-managed agents).
    function mintSelfLinkedCert(
        bytes32 selfAgentKey,
        string calldata agentURI,
        string calldata agentProvider
    ) external returns (uint256 certId) {
        if (agentKeyToCert[selfAgentKey] != 0) revert AlreadyCertified(selfAgentKey);

        uint256 selfAgentId = selfRegistry.getAgentId(selfAgentKey);
        if (selfAgentId == 0) revert NotRegisteredInSelf();

        uint256 nullifier = selfRegistry.getHumanNullifier(selfAgentId);

        return _mint(msg.sender, selfAgentKey, agentURI, agentProvider,
                     VerificationLevel.SelfLinked, selfAgentId, nullifier);
    }

    /// @notice Mint a SelfVerified certificate — the highest trust tier.
    ///         selfAgentKey is the 32-byte key registered in Self Protocol's
    ///         SelfAgentRegistry. The ZK proof must be current (non-expired).
    ///         This is the load-bearing Self Protocol integration:
    ///         isVerifiedAgent() is called live on SelfAgentRegistry.
    function mintSelfVerifiedCert(
        bytes32 selfAgentKey,
        string calldata agentURI,
        string calldata agentProvider
    ) external returns (uint256 certId) {
        if (agentKeyToCert[selfAgentKey] != 0) revert AlreadyCertified(selfAgentKey);

        // Load-bearing Self Protocol check — not decorative
        if (!selfRegistry.isVerifiedAgent(selfAgentKey)) revert ProofExpiredOrInvalid();

        uint256 selfAgentId = selfRegistry.getAgentId(selfAgentKey);
        uint256 nullifier   = selfRegistry.getHumanNullifier(selfAgentId);

        return _mint(msg.sender, selfAgentKey, agentURI, agentProvider,
                     VerificationLevel.SelfVerified, selfAgentId, nullifier);
    }

    // -------------------------------------------------------------------------
    // Lifecycle
    // -------------------------------------------------------------------------

    function suspend(uint256 certId) external {
        Certificate storage c = certs[certId];
        if (msg.sender != c.owner && msg.sender != admin) revert NotCertOwner(certId);
        if (!c.active) revert CertNotActive(certId);
        c.active = false;
        emit CertificateSuspended(certId);
    }

    function reactivate(uint256 certId) external {
        Certificate storage c = certs[certId];
        if (msg.sender != c.owner && msg.sender != admin) revert NotCertOwner(certId);
        c.active = true;
        emit CertificateReactivated(certId);
    }

    // -------------------------------------------------------------------------
    // View
    // -------------------------------------------------------------------------

    function getCert(uint256 certId) external view returns (Certificate memory) {
        return certs[certId];
    }

    function getCertForAgent(bytes32 agentKey) external view returns (Certificate memory) {
        return certs[agentKeyToCert[agentKey]];
    }

    function getOwnerCerts(address owner) external view returns (uint256[] memory) {
        return ownerCerts[owner];
    }

    /// @notice Compute the agentKey for a wallet address (EVM agent mode)
    function walletAgentKey(address wallet) external pure returns (bytes32) {
        return _walletAgentKey(wallet);
    }

    // -------------------------------------------------------------------------
    // Internal
    // -------------------------------------------------------------------------

    function _walletAgentKey(address wallet) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(wallet)));
    }

    function _mint(
        address owner,
        bytes32 agentKey,
        string calldata agentURI,
        string calldata agentProvider,
        VerificationLevel level,
        uint256 selfAgentId,
        uint256 humanNullifier
    ) internal returns (uint256 certId) {
        certId = nextCertId++;
        certs[certId] = Certificate({
            certId:         certId,
            owner:          owner,
            agentKey:       agentKey,
            level:          level,
            selfAgentId:    selfAgentId,
            humanNullifier: humanNullifier,
            agentURI:       agentURI,
            agentProvider:  agentProvider,
            issuedAt:       uint64(block.timestamp),
            active:         true
        });

        agentKeyToCert[agentKey] = certId;
        ownerCerts[owner].push(certId);

        emit CertificateMinted(certId, owner, agentKey, level, selfAgentId, humanNullifier);
    }
}
