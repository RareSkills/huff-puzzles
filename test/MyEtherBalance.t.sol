// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface MyEtherBalance {}

contract MyEtherBalanceTest is Test {
    MyEtherBalance public myEtherBalance;

    function setUp() public {
        myEtherBalance = MyEtherBalance(HuffDeployer.config().deploy("MyEtherBalance"));
    }

    function testMyEtherBalance(uint256 balance) public {
        vm.startPrank(address(this), address(this));
        (bool success, bytes memory data) = address(myEtherBalance).call("");
        vm.deal(address(this), balance);
        (success, data) = address(myEtherBalance).call("");
        require(success, "call failed");
        assertEq(abi.decode(data, (uint256)), balance, "Wrong returned balance of caller");
    }
}
