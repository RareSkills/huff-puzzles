// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

contract KeccakTest is Test, NonMatchingSelectorHelper {
    address public keccak;

    function setUp() public {
        keccak = HuffDeployer.config().deploy("Keccak");
    }

    function testKeccak(bytes memory data) public {
        bytes32 expectedHash;
        assembly {
            expectedHash := keccak256(add(0x20, data), mload(data))
        }
        (bool success, bytes memory res) = keccak.call(data);
        require(success, "call failed");
        assertEq(
            expectedHash,
            abi.decode(res, (bytes32)),
            "huff keccak hash != expectedHash"
        );
    }
}
