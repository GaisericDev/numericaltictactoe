// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameFactory.sol";

contract MoveInput is Test, GameFactory {
    GameFactory public gameFactory;
    address p1 = address(0x35524A1a02D6C89C8FceAd21644cB61b032BD3DE);
    address p2 = address(0x35524a1A02d6C89C8FCEAD21644CB61B032Bd3Df);
    address p3 = address(0x35524A1A02d6c89C8fceAd21644cB61b032bd3dD);
    function setUp() public {
        gameFactory = new GameFactory();
        // Create a game of board size 3
        vm.prank(p1, p1); // should only be valid for creating the game and not subsequent calls
        gameFactory.createPvP(3); // game created by p1
        // P2 joins P1 game
        vm.prank(p2, p2);
        gameFactory.join(0);
    }
    
    // Make move at random games with id > 0
    function testRandomGameMove(uint id)public{
        vm.assume(id > 0);
        vm.expectRevert(abi.encodePacked("Only players can do this!"));
        vm.prank(p1, p1);
        gameFactory.makeMove(id, 0, 0, 9);
    }

    // P1 makes move with all allowed odd numbers
    function testP1OddAllowed(uint8 num)public{
        vm.assume(num < 10 && num % 2 == 1);
        vm.prank(p1, p1);
        gameFactory.makeMove(0, 0, 0, num);
    }

    // P1 makes move with all allowed even numbers
    function testP1EvenAllowed(uint8 num)public{
        vm.assume(num < 10 && num % 2 == 0 && num != 0);
        vm.expectRevert(abi.encodePacked("That number does not belong to you!"));
        vm.prank(p1, p1);
        gameFactory.makeMove(0, 0, 0, num);
    }

    // P1 makes move with all numbers that are not allowed
    function testFailP1NotAllowed(uint8 num)public{
        vm.assume(num == 0 || num > 9);
        vm.prank(p1, p1);
        gameFactory.makeMove(0, 0, 0, num);
    }

    // P2 makes a move  with all allowed odd numbers
    // P2 makes a move with all allowed even numbers
    // P1 makes a move with different x and y coords
    // P2 repeats P1 move (move at same coords)
    // P1 makes move with an already used number
    // P2 makes a move with an already used number
}