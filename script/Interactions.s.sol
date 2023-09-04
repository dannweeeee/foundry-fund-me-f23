// Fund Script
// Withdraw Script

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "lib/forge-std/src/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract with %s wei", SEND_VALUE);
    }
    function run() external { 
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); 
        // it looks inside the broadcast folder based off the chainid and picks up the run-latest.json and grab the most recently deployed contract in that file
        fundFundMe(mostRecentlyDeployed); // have our run function call the fundFundMe function
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }
    function run() external {  
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid); 
        // it looks inside the broadcast folder based off the chainid and picks up the run-latest.json and grab the most recently deployed contract in that file
        withdrawFundMe(mostRecentlyDeployed); // have our run function call the fundFundMe function
    }
}