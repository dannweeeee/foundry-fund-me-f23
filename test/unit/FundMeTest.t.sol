//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

//standard libraries to import
import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe; // make it a storage or state variable

    address USER = makeAddr("user"); // this is a fake address that we will use to send transactions from
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether; // 10000000000000000000
    uint256 constant GAS_PRICE = 1; // 1 wei

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
        assertEq(fundMe.getOwner(), msg.sender);
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

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); // this should be USER as we only have 1 funder in here
        assertEq(funder, USER);
    }

    modifier funded() { // any test after this modifier can be added to the test function to avoid repetition of same code
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        /*vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // fund the contract with 10 ETH*/

        vm.expectRevert(); // saying that the next transaction should revert (because the next line is a vm cheatcode, it will revert on fundMe.withdraw() instead)
        vm.prank(USER); // user is not the owner
        fundMe.withdraw(); // have the user to withdraw because the user is not the owner
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange (Setup the test)
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act (Action for the test)
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert (Assert the test)
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance); // starting fundme balance + starting owner balance = ending owner balance
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange (Setup the test)
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        // go through a loop to keep creating new addresses
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address 
            // vm.deal new address
            // address(0) or address(1) --> but instead of uint256, they have to be uint160, because as of Solidity v0.8.0, explicit conversions between address and uint types are now required.   
            // therefore if we want to use numbers to generate address, it has to be uint160 (because uint160 essentially has the same number of bytes as an address)
            hoax(address(i), SEND_VALUE); // does both prank and deal combined
            // fund the fundMe
            fundMe.fund{value:SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act (Action for the test)
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        
        // Assert (Assert the test)
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        // Arrange (Setup the test)
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        // go through a loop to keep creating new addresses
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address 
            // vm.deal new address
            // address(0) or address(1) --> but instead of uint256, they have to be uint160, because as of Solidity v0.8.0, explicit conversions between address and uint types are now required.   
            // therefore if we want to use numbers to generate address, it has to be uint160 (because uint160 essentially has the same number of bytes as an address)
            hoax(address(i), SEND_VALUE); // does both prank and deal combined
            // fund the fundMe
            fundMe.fund{value:SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act (Action for the test)
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        
        // Assert (Assert the test)
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }
}
