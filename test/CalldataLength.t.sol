// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface CalldataLength {}

contract CalldataLengthTest is Test {
    CalldataLength public calldataLength;

    function setUp() public {
        calldataLength = CalldataLength(HuffDeployer.config().deploy("CalldataLength"));
    }

    function testCalldataLength(bytes memory data) public {
        (bool success, bytes memory retdata) = address(calldataLength).call(data);
        require(success, "call failed");
        assertEq(abi.decode(retdata, (uint256)), data.length, "Expected retdata to be the length of data sent");
    }
}
