// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface CountTime {
    function getTimeElapsed(uint256) external returns (uint256);
    function getTimeUntil(uint256) external returns (uint256);
}

contract CountTimeTest is Test, NonMatchingSelectorHelper {
    CountTime public countTime;

    function setUp() public {
        countTime = CountTime(HuffDeployer.config().deploy("CountTime"));
    }

    function testCountTime(uint256 skipBlocks, uint256 timestamp) external {
        vm.assume(skipBlocks < type(uint256).max);
        skip(skipBlocks);

        uint256 timeElapsed = countTime.getTimeElapsed(timestamp);
        uint256 expectedTimeElapsed = (block.timestamp > timestamp ? block.timestamp - timestamp : 0);
        assertEq(
            timeElapsed,
            expectedTimeElapsed,
            string.concat(
                "The returned timeElapsed differs from the correct: ",
                vm.toString(timeElapsed),
                " != ",
                vm.toString(expectedTimeElapsed)
            )
        );

        uint256 timeUntil = countTime.getTimeUntil(timestamp);
        uint256 expectedTimeUntil = (block.timestamp < timestamp ? timestamp - block.timestamp : 0);
        assertEq(
            timeUntil,
            expectedTimeUntil,
            string.concat(
                "The returned timeUntil differs from the correct: ",
                vm.toString(timeUntil),
                " != ",
                vm.toString(expectedTimeUntil)
            )
        );
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](2);
        func_selectors[0] = CountTime.getTimeElapsed.selector;
        func_selectors[1] = CountTime.getTimeUntil.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(countTime));
        assert(!success);
    }
}
