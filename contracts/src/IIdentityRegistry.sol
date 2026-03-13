// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IIdentityRegistry — ERC-8004 Agent Identity Registry interface
interface IIdentityRegistry {
    function register(address owner, string calldata agentURI) external returns (uint256 agentId);
    function setMetadata(uint256 agentId, string calldata key, bytes calldata value) external;
    function getMetadata(uint256 agentId, string calldata key) external view returns (bytes memory);
    function ownerOf(uint256 agentId) external view returns (address);
    function isRegistered(uint256 agentId) external view returns (bool);
}
