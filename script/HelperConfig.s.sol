//SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD & Mainnet ETH/USD has a different address

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil, we deploy mocks
    // otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8; // 8 is the default decimals for ETH/USD price feed
    int256 public constant INITIAL_PRICE = 2000e8; // 2000e8 is the initial price of eth

    // in case we need more than just price feed address, we can turn this config into their own types
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) { // block.chainid is the current chainid (from chainlist.org) as every network has their own chainid
            // sepolia chainid is 11155111 --> can refer to chainlist.org
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) { // this will return a configuration for everything that we need on Sepolia
        // price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig; // therefore we can grab the address from the existing network using this method
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) { // this will return a configuration for everything that we need on Sepolia
        // price feed address
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig; // therefore we can grab the address from the existing network using this method
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)){ // checking if we have set the priceFeed to something, default of priceFeed is 0
            return activeNetworkConfig;
        } // essential because if we were to call getOrCreateAnvilEthConfig, without the Eth statement, we would just create a new priceFeed, so if we have already deployed 1 priceFeed, we wouldnt want to deploy another one

        // 1. Deploy the mocks -> a mock contract is a fake dummy contract (it simulates a real contract but it is a contract that we own and can control etc.)
        // 2. Return the mock address

        vm.startBroadcast(); // because we use vm, we cannot have the getOrCreateAnvilEthConfig() as a public pure function && HelperConfig has to be is Script to have access to the vm keyword
        // put fake dummy contracts in mocks folder that is located in the test folder to show that this is a mock contract that is different from the real contract
        // MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8); // decimals for eth usd is 8, 2000e8 is the initial price of eth --> Magic Numbers are bad, so we should use constants instead
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)}); // we can deploy our own fake pricefeed

        return anvilConfig;
    }
}