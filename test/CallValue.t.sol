// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface CallValue {}

contract CallValueTest is Test {
    CallValue public callValue;

    function setUp() public {
        callValue = CallValue(HuffDeployer.config().deploy("CallValue"));
    }

    function testCallValue(uint256 value) public {
        vm.deal(address(this), value);
        (bool success, bytes memory retdata) = address(callValue).call{value: value}("");
        require(success, "call failed");
        assertEq(abi.decode(retdata, (uint256)), value, "Wrong retdata");
    }
}
