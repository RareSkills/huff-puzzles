// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface MyEtherBalance {}

contract MyEtherBalanceTest is Test {
    MyEtherBalance public myEtherBalance;

    function setUp() public {
        myEtherBalance = MyEtherBalance(
            HuffDeployer.config().deploy("MyEtherBalance")
        );
    }

    function testMyEtherBalance() public {
        vm.startPrank(address(this), address(this));
        (bool success, bytes memory data) = address(myEtherBalance).call("");
        require(success, "call failed");
        assertEq(
            abi.decode(data, (uint256)),
            79228162514264337593543950335, // uint256(0xffffffffffffffffffffffff) -> default ether balance of an address with 0 initial balance making a call/staticcall/delegatecall
            "expected ether balance of caller to be 79228162514264337593543950335"
        );

        vm.deal(address(this), 1 ether);
        (success, data) = address(myEtherBalance).call("");
        require(success, "call failed");
        assertEq(
            abi.decode(data, (uint256)),
            1 ether,
            "expected ether balance of caller to be 1"
        );

        vm.deal(address(this), 2 ether);
        (success, data) = address(myEtherBalance).call("");
        require(success, "call failed");
        assertEq(
            abi.decode(data, (uint256)),
            2 ether,
            "expected ether balance of caller to be 2"
        );
    }
}
