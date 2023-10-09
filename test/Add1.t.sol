// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface Add1 {
    function add1(uint256 num) external pure returns (uint256);
}

contract Add1Test is Test, NonMatchingSelectorHelper {
    Add1 public add1;

    function setUp() public {
        add1 = Add1(HuffDeployer.config().deploy("Add1"));
    }

    function testAdd1(uint256 n) public {
        unchecked {
            assertEq(add1.add1(n), n + 1, "Wrong return number");
        }
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = Add1.add1.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(add1));
        assert(!success);
    }
}
