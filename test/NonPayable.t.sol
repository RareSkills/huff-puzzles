// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface NonPayable {}

contract NonPayableTest is Test {
    NonPayable public nonPayable;

    function setUp() public {
        nonPayable = NonPayable(HuffDeployer.config().deploy("NonPayable"));
    }

    function testNonPayable(uint256 value) public {
        vm.deal(address(this), value);

        bool expected;
        if (value == 0) {
            expected = true;
        }

        (bool success,) = address(nonPayable).call{value: value}("");
        assertEq(success, expected, "call did not pass as expected");
    }
}
