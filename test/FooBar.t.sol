// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface FooBar {
    function foo() external pure returns (uint256);

    function bar() external pure returns (uint256);
}

contract FooBarTest is Test, NonMatchingSelectorHelper {
    FooBar public fooBar;

    function setUp() public {
        fooBar = FooBar(HuffDeployer.config().deploy("FooBar"));
    }

    function testFooBar() public {
        assertEq(fooBar.foo(), 2, "Foo expected to return 2");
        assertEq(fooBar.bar(), 3, "Bar expected to return 3");
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](2);
        func_selectors[0] = FooBar.foo.selector;
        func_selectors[1] = FooBar.bar.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(fooBar));
        assert(!success);
    }
}
