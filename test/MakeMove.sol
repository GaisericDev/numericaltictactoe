// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameFactory.sol";

contract MakeMove is Test, GameFactory {
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
    // Assert P1 Turn
    function testP1Turn() public {
        // turn == false => p1 turn
        // turn == true => p2 turn
        Game memory game = gameFactory.getGame(0);
        assertEq(game.turn, false);
     }
    // P1 can make a move during p1 turn
    function testP1MoveP1Turn() public {
        vm.prank(p1, p1);
        gameFactory.makeMove(0, 0, 0, 9);
    }
    // P2 should not be able to make a move during p1 turn
    function testP2MoveP1Turn()public{
        vm.expectRevert(abi.encodePacked("It is not your turn!"));
        vm.prank(p2, p2);
        gameFactory.makeMove(0, 0, 0, 9);
    }
    // Turns update after a turn is made
    function testTurnUpdate()public{
        // P1 makes a move (turn should be false)
        assertEq(gameFactory.getGame(0).turn, false);
        vm.prank(p1,p1);
        gameFactory.makeMove(0, 0, 0, 9);
        // P2 makes a move (turn should be true)
        assertEq(gameFactory.getGame(0).turn, true);
        assertEq(p2, gameFactory.getGame(0).p2);
        vm.prank(p2, p2);
        gameFactory.makeMove(0, 1, 0, 6);
        // Turn should now be false
        assertEq(gameFactory.getGame(0).turn, false);
    }
    // P1 should not be able to make a move during p2 turn
    function testP1MoveP2Turn()public{
        // P1 makes a move (is p1 turn)
        assertEq(gameFactory.getGame(0).turn, false);
        vm.prank(p1,p1);
        gameFactory.makeMove(0, 0, 0, 9);
        // P1 makes a move (is p2 turn)
        vm.expectRevert(abi.encodePacked("It is not your turn!"));
        vm.prank(p1, p1);
        gameFactory.makeMove(0, 1, 0, 6);
    }
    // Contract should not be able to make move
    function testMoveContract()public{
        vm.expectRevert(abi.encodePacked("Only players can do this!"));
        gameFactory.makeMove(0, 0, 0, 9);
    }
    // P3 should not be able to make a move
    function testMoveP3()public{
        vm.expectRevert(abi.encodePacked("Only players can do this!"));
        gameFactory.makeMove(0, 0, 0, 9);
    }
    // Reentrancy turns
}