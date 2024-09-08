// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface SumArray {
    function sumArray(uint256[] calldata nums) external pure returns (uint256);
}

contract SumArrayTest is Test, NonMatchingSelectorHelper {
    SumArray public sumArray;

    function setUp() public {
        sumArray = SumArray(HuffDeployer.config().deploy("SumArray"));
    }

    function testSumArray(uint256[] memory array) external {
        uint256 expected;
        for (uint256 i; i < array.length; ++i) {
            unchecked {
                expected += array[i];
            }
        }

        uint256 sum = sumArray.sumArray(array);
        assertEq(sum, expected, "Wrong sum of array");
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = SumArray.sumArray.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(sumArray));
        assert(!success);
    }
}
