//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//standard libraries to import
import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe; // make it a storage or state variable

    address USER = makeAddr("user"); // this is a fake address that we will use to send transactions from
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether; // 10000000000000000000
    uint256 constant GAS_PRICE = 1; // 1 wei
    
    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe)); // fund using our scripts

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe)); // withdraw using our scripts

        assert(address(fundMe).balance == 0);
    }
}