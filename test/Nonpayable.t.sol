// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface NonPayable {}

contract NonPayableTest is Test {
    NonPayable public nonPayable;

    function setUp() public {
        nonPayable = NonPayable(HuffDeployer.config().deploy("NonPayable"));
    }

    function testNonPayable() public {
        vm.deal(address(this), 1 ether);

        (bool success, ) = address(nonPayable).call{value: 0 ether}("");
        assertEq(success, true, "call did not pass as expected");

        (success, ) = address(nonPayable).call{value: 1 ether}("");
        assertEq(success, false, "call did not fail as expected");
    }
}
