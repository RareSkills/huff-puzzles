// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface SendEther {
    function sendEther(address) external payable;
}

contract SendEtherTest is Test, NonMatchingSelectorHelper {
    SendEther public sendEther;

    function setUp() public {
        sendEther = SendEther(HuffDeployer.config().deploy("SendEther"));
    }

    function testSendEther(uint256 value, address receiver) public {
        vm.deal(address(this), value);
        uint256 size;
        assembly {
            size := extcodesize(receiver)
        }
        vm.assume(size == 0);

        uint256 _balance = receiver.balance;
        sendEther.sendEther{value: value}(receiver);
        uint256 balance_ = receiver.balance;

        assertEq(balance_ - _balance, value, "balance of address(0xDEAD) is not 1 ether");
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = SendEther.sendEther.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(sendEther));
        assert(!success);
    }
}
