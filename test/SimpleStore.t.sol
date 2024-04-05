// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface SimpleStore {
    function store(uint256 num) external;

    function read() external view returns (uint256);
}

contract SimpleStoreTest is Test, NonMatchingSelectorHelper {
    SimpleStore public simpleStore;

    function setUp() public {
        simpleStore = SimpleStore(HuffDeployer.config().deploy("SimpleStore"));
    }

    function testSimpleStore(uint256 value) public {
        simpleStore.store(value);
        assertEq(simpleStore.read(), value, "read() returns the wrong value");
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](2);
        func_selectors[0] = SimpleStore.store.selector;
        func_selectors[1] = SimpleStore.read.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(simpleStore));
        assert(!success);
    }
}
