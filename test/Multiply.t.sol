// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface Multiply {
    function multiply(uint256 num1, uint256 num2) external pure returns (uint256);
}

contract MultiplyTest is Test, NonMatchingSelectorHelper {
    Multiply public multiply;

    function setUp() public {
        multiply = Multiply(HuffDeployer.config().deploy("Multiply"));
    }

    function testMultiply(uint256 a, uint256 b) public {
        unchecked {
            if (b == 0 || a == (a * b) / b) {
                assertEq(multiply.multiply(a, b), a * b, "Wrong result for Multiply(a, b)");
            } else {
                vm.expectRevert();
                multiply.multiply(a, b);
            }
        }
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = Multiply.multiply.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(multiply));
        assert(!success);
    }
}
