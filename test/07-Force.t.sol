// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/levels/07-Force/ForceFactory.sol";
import "../src/levels/07-Force/ForceAttack.sol";
import "../src/core/Ethernaut.sol";

contract ForceTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        // Sets an address' balance, (who, newBalance)
        vm.deal(attacker, 1 ether);
    }

    function testForceHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        ForceFactory forceFactory = new ForceFactory();
        ethernaut.registerLevel(forceFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(forceFactory);
        Force forceContract = Force(payable(levelAddress));
        ForceAttack attackContract = new ForceAttack(forceContract);

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        attackContract.attack{value: 1 ether}();
        assertEq(address(forceContract).balance, 1 ether);

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
