// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ClaimMinter} from "../src/ClaimMinter.sol";

/// @notice Deploys ClaimMinter to Base Mainnet, Base Sepolia, or Status Network Sepolia
contract Deploy is Script {
    // ERC-8004 Identity Registry addresses
    // Confirmed from registration tx 0xa9e0afe...
    address constant REGISTRY_BASE_MAINNET  = 0x8004A169FB4a3325136EB29fA0ceB6D2e539a432;
    address constant REGISTRY_BASE_SEPOLIA  = 0x8004A169FB4a3325136EB29fA0ceB6D2e539a432; // confirm before use
    address constant REGISTRY_STATUS_SEPOLIA = address(0); // mock registry (no ERC-8004 on Status testnet)

    function run() external {
        uint256 chainId = block.chainid;
        address registryAddr;

        if (chainId == 8453) {
            registryAddr = REGISTRY_BASE_MAINNET;
            console.log("Deploying to Base Mainnet");
        } else if (chainId == 84532) {
            registryAddr = REGISTRY_BASE_SEPOLIA;
            console.log("Deploying to Base Sepolia");
        } else if (chainId == 1660990954) {
            // Status Network Sepolia — use mock registry
            registryAddr = address(0);
            console.log("Deploying to Status Network Sepolia");
        } else {
            revert("Unsupported chain");
        }

        vm.startBroadcast();

        ClaimMinter minter;
        if (registryAddr == address(0)) {
            // Deploy with mock (for Status Network testnet)
            MockRegistry mock = new MockRegistry();
            minter = new ClaimMinter(address(mock));
            console.log("MockRegistry deployed at:", address(mock));
        } else {
            minter = new ClaimMinter(registryAddr);
        }

        console.log("ClaimMinter deployed at:", address(minter));
        console.log("Chain ID:", chainId);

        vm.stopBroadcast();
    }
}

/// @dev Minimal mock registry for testnet deployments without a live ERC-8004 registry
contract MockRegistry {
    uint256 private _nextId = 1;
    mapping(uint256 => address) private _owners;
    mapping(uint256 => mapping(string => bytes)) private _metadata;

    function register(address owner, string calldata) external returns (uint256 agentId) {
        agentId = _nextId++;
        _owners[agentId] = owner;
    }

    function setMetadata(uint256 agentId, string calldata key, bytes calldata value) external {
        _metadata[agentId][key] = value;
    }

    function getMetadata(uint256 agentId, string calldata key) external view returns (bytes memory) {
        return _metadata[agentId][key];
    }

    function ownerOf(uint256 agentId) external view returns (address) {
        return _owners[agentId];
    }

    function isRegistered(uint256 agentId) external view returns (bool) {
        return _owners[agentId] != address(0);
    }
}
