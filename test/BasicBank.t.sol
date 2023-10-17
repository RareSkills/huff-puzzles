// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

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

    function testDeposit(uint256 value) external {
        vm.deal(address(this), value);
        (bool success,) = address(basicBank).call{value: value}("");
        require(success, "deposit failed");
        assertEq(address(basicBank).balance, value, "Wrong balance of basic bank contract");
        assertEq(basicBank.balanceOf(address(this)), value, "Wrong balance of depositor");
    }

    function testRemoveEther(uint256 value) external {
        vm.deal(address(this), value);
        vm.expectRevert();
        basicBank.withdraw(1);
        (bool success,) = address(basicBank).call{value: value}("");
        require(success, "deposit failed");
        basicBank.withdraw(value);
        assertEq(address(this).balance, value, "Wrong balance of depositor");
        assertEq(basicBank.balanceOf(address(this)), 0 ether, "Balance of basic bank contract should be 0");
    }

    receive() external payable {}
}
