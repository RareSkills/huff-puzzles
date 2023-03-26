// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface Multiply {
    function multiply(
        uint256 num1,
        uint256 num2
    ) external pure returns (uint256);
}

contract MultiplyTest is Test, NonMatchingSelectorHelper {
    Multiply public multiply;

    function setUp() public {
        multiply = Multiply(HuffDeployer.config().deploy("Multiply"));
    }

    function testMultiply() public {
        assertEq(
            multiply.multiply(2, 3),
            6,
            "Multiply(2, 3) expected to return 6"
        );
        assertEq(
            multiply.multiply(0, 1),
            0,
            "Multiply(0, 1) expected to return 0"
        );

        vm.expectRevert();
        multiply.multiply(2, type(uint256).max);
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = Multiply.multiply.selector;

        bool success = nonMatchingSelectorHelper(
            func_selectors,
            callData,
            address(multiply)
        );
        assert(!success);
    }
}
