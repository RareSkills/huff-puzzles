// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface TimeAndBlock {
    function getTimeAndBlock() external returns (uint256, uint256);
}

contract TimeAndBlockTest is Test, NonMatchingSelectorHelper {
    TimeAndBlock public timeAndBlock;

    function setUp() public {
        timeAndBlock = TimeAndBlock(HuffDeployer.config().deploy("TimeAndBlock"));
    }

    function testTimeAndBlock(uint256 skipBlocks) external {
        vm.assume(skipBlocks < type(uint256).max);
        skip(skipBlocks);
        (uint256 timestamp, uint256 blockNumber) = timeAndBlock.getTimeAndBlock();

        assertEq(
            timestamp,
            block.timestamp,
            string.concat(
                "The returned timestamp differs from the current: ",
                vm.toString(timestamp),
                " != ",
                vm.toString(block.timestamp)
            )
        );
        assertEq(
            blockNumber,
            block.number,
            string.concat(
                "The returned block number differs from the current: ",
                vm.toString(blockNumber),
                " != ",
                vm.toString(block.number)
            )
        );
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = TimeAndBlock.getTimeAndBlock.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(timeAndBlock));
        assert(!success);
    }
}
