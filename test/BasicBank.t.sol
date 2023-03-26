// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface BasicBank {
    function balanceOf(address user) external view returns (uint256);

    function withdraw(uint256 amount) external;
}

contract BasicBankTest is Test {
    BasicBank public basicBank;

    function setUp() public {
        basicBank = BasicBank(HuffDeployer.config().deploy("BasicBank"));
    }

    function testDeposit() external {
        vm.deal(address(this), 1 ether);
        (bool success, ) = address(basicBank).call{value: 1 ether}("");
        require(success, "deposit failed");
        assertEq(
            address(basicBank).balance,
            1 ether,
            "expected balance of basic bank contract to be 1 ether"
        );
        assertEq(
            basicBank.balanceOf(address(this)),
            1 ether,
            "expected balance of basic bank contract to be 1 ether"
        );
    }

    function testRemoveEther() external {
        vm.deal(address(this), 1 ether);
        vm.expectRevert();
        basicBank.withdraw(1);
        (bool success, ) = address(basicBank).call{value: 1 ether}("");
        require(success, "deposit failed");
        basicBank.withdraw(1 ether);
        assertEq(
            address(this).balance,
            1 ether,
            "expected balance of address(this) to be 1 ether"
        );
        assertEq(
            basicBank.balanceOf(address(this)),
            0 ether,
            "expected balance of basic bank contract to be 1 ether"
        );
    }

    receive() external payable {}
}
