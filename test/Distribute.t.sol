// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface Distributor {
    function distribute(address[] calldata) external payable;
}

contract DistributeTest is Test, NonMatchingSelectorHelper {
    Distributor public distributor;

    function setUp() public {
        distributor = Distributor(HuffDeployer.config().deploy("Distributor"));
    }

    function testDistribute(uint256 value, address[] memory receivers) public {
        vm.deal(address(this), value);
        // vm.assume(receivers.length <= 10);
        if (receivers.length == 0) vm.expectRevert();
        distributor.distribute{value: value}(receivers);
        for (uint256 i; i < receivers.length; ++i) {
            uint256 size;
            address receiver = receivers[i];
            assembly {
                size := extcodesize(receiver)
            }
            vm.assume(size == 0);
            assertGe(receiver.balance, value / receivers.length, "Wrong balance of receiver");
        }
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = Distributor.distribute.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(distributor));
        assert(!success);
    }
}
