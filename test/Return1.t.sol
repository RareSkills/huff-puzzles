// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

contract Return1Test is Test {
    address public return1;

    function setUp() public {
        return1 = HuffDeployer.config().deploy("Return1");
    }

    function testReturn1() public {
        (bool success, bytes memory ret) = return1.call("");
        require(success, "call to return1 address failed");
        assertEq(abi.decode(ret, (uint256)), 1, "Expected a call to return1 address to return 1");
    }
}
