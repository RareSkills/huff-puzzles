// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface MaxOfArray {
    function maxOfArray(uint256[] calldata nums) external pure returns (uint256);
}

contract MaxOfArrayTest is Test, NonMatchingSelectorHelper {
    MaxOfArray public maxOfArray;

    function setUp() public {
        maxOfArray = MaxOfArray(HuffDeployer.config().deploy("MaxOfArray"));
    }

    function testMaxOfArray() external {
        uint256[] memory arr = new uint256[](10);
        arr[0] = 2;
        arr[1] = 4;
        arr[2] = 262;
        arr[3] = 8;
        arr[4] = 4;
        arr[5] = 1;
        arr[6] = 0;
        arr[7] = 17;
        arr[8] = 67251781;
        arr[9] = 27;

        uint256 x = maxOfArray.maxOfArray(arr);
        assertEq(x, 67251781, "expected max of arr to be 67251781");

        uint256[] memory arr2 = new uint256[](0);
        vm.expectRevert();
        maxOfArray.maxOfArray(arr2);

        uint256[] memory arr3 = new uint256[](5);
        arr3[0] = 2;
        arr3[1] = 7;
        arr3[2] = 7;
        arr3[3] = 5;
        arr3[4] = 4;
        x = maxOfArray.maxOfArray(arr3);
        assertEq(x, 7, "expected max of arr to be 7");
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = MaxOfArray.maxOfArray.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(maxOfArray));
        assert(!success);
    }
}
