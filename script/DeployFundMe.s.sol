//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before startBroadcast -> Not a 'real' transaction
        HelperConfig helperConfig = new HelperConfig(); // reason why this is before startBroadcast() is so that we do not have to spend the gas to run this command on the blockchain
        (address ethUsdPriceFeed) = helperConfig.activeNetworkConfig(); // normally when we return a struct, we have to wrap it in parentheses (struct)

        // After startBroadcast -> 'real' transaction
        vm.startBroadcast();
        // We can create a Mock Contract
        // On our local Anvil Chain, we can deploy our own fake priceFeed and interact with that for the duration of our local test
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}