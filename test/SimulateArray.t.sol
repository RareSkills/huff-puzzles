// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface SimulateArray {
    function pushh(uint256 num) external;

    function popp() external;

    function read(uint256 index) external view returns (uint256);

    function length() external view returns (uint256);

    function write(uint256 index, uint256 num) external;
}

contract SimulateArrayTest is Test, NonMatchingSelectorHelper {
    SimulateArray public simulateArray;

    function setUp() public {
        simulateArray = SimulateArray(
            HuffDeployer.config().deploy("SimulateArray")
        );
    }

    function testSimulateArrayReverts() external {
        assertEq(
            simulateArray.length(),
            0,
            "length is initially meant to be 0"
        );

        vm.expectRevert(bytes4(keccak256("ZeroArray()")));
        simulateArray.popp();

        vm.expectRevert(bytes4(keccak256("OutOfBounds()")));
        simulateArray.read(0);

        vm.expectRevert(bytes4(keccak256("OutOfBounds()")));
        simulateArray.write(0, 1);
    }

    function testSimulateArray() external {
        assertEq(
            simulateArray.length(),
            0,
            "length is initially meant to be 0"
        );

        simulateArray.pushh(42);
        assertEq(simulateArray.length(), 1, "expected length to be 1");
        assertEq(simulateArray.read(0), 42, "expected arr[0] to be 42");

        simulateArray.pushh(24);
        assertEq(simulateArray.length(), 2, "expected length to be 2");
        assertEq(simulateArray.read(0), 42, "expected arr[0] to be 42");
        assertEq(simulateArray.read(1), 24, "expected arr[1] to be 24");

        simulateArray.write(0, 122);
        assertEq(simulateArray.length(), 2, "expected length to be 2");
        assertEq(simulateArray.read(0), 122, "expected arr[0] to be 122");
        assertEq(simulateArray.read(1), 24, "expected arr[1] to be 24");

        simulateArray.write(1, 346);
        assertEq(simulateArray.length(), 2, "expected length to be 2");
        assertEq(simulateArray.read(0), 122, "expected arr[0] to be 122");
        assertEq(simulateArray.read(1), 346, "expected arr[1] to be 346");

        simulateArray.popp();
        assertEq(simulateArray.length(), 1, "expected length to be 1");
        assertEq(simulateArray.read(0), 122, "expected arr[0] to be 122");
        vm.expectRevert(bytes4(keccak256("OutOfBounds()")));
        simulateArray.read(1);
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](5);
        func_selectors[0] = SimulateArray.pushh.selector;
        func_selectors[1] = SimulateArray.popp.selector;
        func_selectors[2] = SimulateArray.read.selector;
        func_selectors[3] = SimulateArray.length.selector;
        func_selectors[4] = SimulateArray.write.selector;

        bool success = nonMatchingSelectorHelper(
            func_selectors,
            callData,
            address(simulateArray)
        );
        assert(!success);
    }
}
