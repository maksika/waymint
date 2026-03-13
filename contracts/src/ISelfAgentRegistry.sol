// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ISelfAgentRegistry
/// @notice Minimal interface for the Self Protocol SelfAgentRegistry on Celo
/// @dev Mainnet:  0xaC3DF9ABf80d0F5c020C06B04Cced27763355944
///      Sepolia:  0x043DaCac8b0771DD5b444bCC88f2f8BBDBEdd379
///      agentKey for wallet-based (EVM) agents: bytes32(uint256(uint160(walletAddress)))
///      agentKey for Ed25519-based agents: raw 32-byte public key
interface ISelfAgentRegistry {
    /// @notice Returns true if the agent has a valid, non-expired ZK human proof
    function isVerifiedAgent(bytes32 agentPubKey) external view returns (bool);

    /// @notice Returns the soulbound token ID for a given agent key (0 = not registered)
    function getAgentId(bytes32 agentPubKey) external view returns (uint256);

    /// @notice Returns true if the agent has any human proof attached (including expired)
    function hasHumanProof(uint256 agentId) external view returns (bool);

    /// @notice Returns the nullifier hash — proves uniqueness without revealing identity
    function getHumanNullifier(uint256 agentId) external view returns (uint256);
}
