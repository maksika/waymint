// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ClaimMinter} from "../src/ClaimMinter.sol";

/// @notice Deploy WayMint ClaimMinter to the target chain
///
/// Supported chains:
///   Base Mainnet       (8453)    — real ERC-8004 registry; needs ETH for gas
///   Celo Mainnet       (42220)   — Self Protocol live; SelfVerified tier works
///   Celo Sepolia       (11142220) — Self Protocol testnet
///   Status Net Sepolia (1660990954) — gasless; mock Self registry (no Self on Status)
///
/// Self Protocol SelfAgentRegistry addresses:
///   Celo Mainnet:  0xaC3DF9ABf80d0F5c020C06B04Cced27763355944
///   Celo Sepolia:  0x043DaCac8b0771DD5b444bCC88f2f8BBDBEdd379
contract Deploy is Script {

    // Self Protocol registry addresses
    address constant SELF_REGISTRY_CELO_MAINNET  = 0xaC3DF9ABf80d0F5c020C06B04Cced27763355944;
    address constant SELF_REGISTRY_CELO_SEPOLIA  = 0x043DaCac8b0771DD5b444bCC88f2f8BBDBEdd379;
    address constant SELF_REGISTRY_MOCK          = address(0); // mock/no-op for other chains

    function run() external {
        uint256 chainId = block.chainid;
        address selfRegistry;
        string memory chainName;

        if (chainId == 42220) {
            chainName = "Celo Mainnet";
            selfRegistry = SELF_REGISTRY_CELO_MAINNET;
        } else if (chainId == 11142220) {
            chainName = "Celo Sepolia";
            selfRegistry = SELF_REGISTRY_CELO_SEPOLIA;
        } else if (chainId == 8453) {
            chainName = "Base Mainnet";
            selfRegistry = SELF_REGISTRY_MOCK; // Self not on Base; use mock
        } else if (chainId == 84532) {
            chainName = "Base Sepolia";
            selfRegistry = SELF_REGISTRY_MOCK;
        } else if (chainId == 1660990954) {
            chainName = "Status Network Sepolia";
            selfRegistry = SELF_REGISTRY_MOCK; // gasless bounty chain
        } else {
            chainName = "Unknown";
            selfRegistry = SELF_REGISTRY_MOCK;
        }

        console.log("Deploying to", chainName);
        console.log("Self registry:", selfRegistry);

        vm.startBroadcast();

        ClaimMinter minter = new ClaimMinter(selfRegistry);
        console.log("ClaimMinter deployed at:", address(minter));
        console.log("Chain ID:", chainId);

        vm.stopBroadcast();
    }
}
