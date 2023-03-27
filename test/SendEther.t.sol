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

    function testSendEther() public {
        vm.deal(address(this), 4 ether);
        sendEther.sendEther{value: 1 ether}(address(0xABCD));
        sendEther.sendEther{value: 1 ether}(address(0xBABE));
        sendEther.sendEther{value: 1 ether}(address(0xCAFE));
        sendEther.sendEther{value: 1 ether}(address(0xDEAD));

        assertEq(
            address(0xABCD).balance,
            1 ether,
            "balance of address(0xABCD) is not 1 ether"
        );
        assertEq(
            address(0xBABE).balance,
            1 ether,
            "balance of address(0xBABE) is not 1 ether"
        );
        assertEq(
            address(0xCAFE).balance,
            1 ether,
            "balance of address(0xCAFE) is not 1 ether"
        );
        assertEq(
            address(0xDEAD).balance,
            1 ether,
            "balance of address(0xDEAD) is not 1 ether"
        );

        assertEq(
            address(sendEther).balance,
            0,
            "balance of distribute contract is not 0 ether"
        );
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = SendEther.sendEther.selector;

        bool success = nonMatchingSelectorHelper(
            func_selectors,
            callData,
            address(sendEther)
        );
        assert(!success);
    }
}
