//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//standard libraries to import
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe; // make it a storage or state variable

    function setUp() external {
        fundMe = new FundMe(); // initialise a new FundMe();
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18); // asserts that two expressions are equal to each other
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }
}
