// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/levels/09-King/KingFactory.sol";
import "../src/levels/09-King/KingAttack.sol";
import "../src/core/Ethernaut.sol";

contract KingTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        // Sets an address' balance, (who, newBalance)
        vm.deal(attacker, 1.001 ether);
    }

    function testKingHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        KingFactory kingFactory = new KingFactory();
        ethernaut.registerLevel(kingFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance{
            value: 0.001 ether
        }(kingFactory);
        King kingContract = King(payable(levelAddress));
        KingAttack attackContract = new KingAttack(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        attackContract.attack{value: 1 ether}();
        emit log_named_address("king: ", kingContract._king());

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
