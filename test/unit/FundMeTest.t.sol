// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    address USER = makeAddr("USER");
    uint256  constant SEND_VALUE = 10 ether;
    FundMe fundme;
    uint256 favnum = 3;
    bool goodcourse = true;
    uint256 constant STARTING_BALANCE = 10 ether;

    // Correct `setUp` function for initializing the test
    function setUp() external {
        favnum = 4;
        goodcourse = true;
    
        DeployFundMe deployfundme=new DeployFundMe();
        fundme=deployfundme.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    // Test function name must start with `test`
    function testDemo() public view{
        assertEq(favnum, 4, "favnum should be updated to 4");
        assertEq(goodcourse, true, "goodcourse should be true");
    }
    function testmin_usd() public view{
        assertEq(fundme.MINIMUM_USD(),5e18);
    }
   
  
//     function testOwnerIsMsgSender() public view{
//          console.log(fundme.i_owner());
//         console.log(msg.sender);
//     assertEq(fundme.i_owner(), msg.sender);

// }
 function testPriceFeedVersionIsAccurate() public{
    uint256 Version = fundme.getVersion();
    assertEq(Version,4);
 }
 function testFundFailsWIthoutEnoughETH() public{
    vm.expectRevert();
    fundme.fund();
 }
 function testFundUpdatesFundDataStructure() public{
    vm.prank(USER);
    fundme.fund{value:SEND_VALUE}();
    uint256 amountfunded = fundme.getAddresstoAmountFunded(USER);
    assertEq(amountfunded,SEND_VALUE);
 }
 modifier funded(){
    vm.prank(USER);
    fundme.fund{value:SEND_VALUE}();
    assert(address(fundme).balance>0);
    _;
 }
  function testAddsFunderToArrayOfFunders() public{
    vm.startPrank(USER);
    fundme.fund{value:SEND_VALUE}();
    vm.stopPrank();
    address funder = fundme.getfunders(0);
    assertEq(USER,funder);
  }
  function testOnlyOwnerCanWithdraw() public funded{
   
    
    vm.expectRevert();
    vm.prank(USER);
    fundme.cheaperWithdraw();
  }
    function testWithdrawFromASingleFunder() public funded{
        uint256 startingFundMeBalance = address(fundme).balance;
        uint256 startingOwnerBalance = fundme.getowner().balance;

        vm.startPrank(fundme.getowner());
        fundme.cheaperWithdraw();
        vm.stopPrank();
        uint256 endingFundMeBalance = address(fundme).balance;
        uint256 endingOwnerBalance = fundme.getowner().balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance + startingOwnerBalance,endingOwnerBalance);

    }
   function testWithdrawFromMultipleFunders() public funded {
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;
    for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
        // we get hoax from stdcheats
        // prank + deal
        hoax(address(i), SEND_VALUE);
        fundme.fund{value: SEND_VALUE}();
    }

    uint256 startingFundMeBalance = address(fundme).balance;
    uint256 startingOwnerBalance = fundme.getowner().balance;

    vm.startPrank(fundme.getowner());
    fundme.cheaperWithdraw();
    vm.stopPrank();

    assert(address(fundme).balance == 0);
    assert(startingFundMeBalance + startingOwnerBalance == fundme.getowner().balance);
    assert((numberOfFunders + 1) * SEND_VALUE == fundme.getowner().balance - startingOwnerBalance);

}
function testPrintStorageData() public {
    for (uint256 i = 0; i < 3; i++) {
        bytes32 value = vm.load(address(fundme), bytes32(i));
        console.log("Value at location", i, ":");
        console.logBytes32(value);
    }
    console.log("PriceFeed address:", address(fundme.getPriceFeed()));

}
    }
