//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//standard libraries to import
import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; // make it a storage or state variable

    address USER = makeAddr("user"); // this is a fake address that we will use to send transactions from
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether; // 10000000000000000000

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // initialise a new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // cheatcode to give USER some ETH
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // asserts that two expressions are equal to each other
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // hey, the next line should revert!
        // assert(This transaction fails/reverts)
        fundMe.fund(); // send 0 ETH
    }

    function testFundUpdatesFundedDataStructure() public {
        // create a fakenew address to send all of our transactions
        vm.prank(USER); // the next line (transaction) will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // magic number: send 10 ETH

        // then need to check address to amount funded is getting updated
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER); // need to be explicit with who is sendign what transactions --> this is where we use the prank cheatcode
        assertEq(amountFunded, SEND_VALUE);
    }
}
