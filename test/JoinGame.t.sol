// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameFactory.sol";

contract JoinGame is Test {
    GameFactory public gameFactory;
    address p1 = address(0x35524A1a02D6C89C8FceAd21644cB61b032BD3DE);
    address p2 = address(0x35524a1A02d6C89C8FCEAD21644CB61B032Bd3Df);
    address p3 = address(0x35524A1A02d6c89C8fceAd21644cB61b032bd3dD);

    function setUp() public {
        gameFactory = new GameFactory();
        // Create a game of board size 3
        vm.prank(p1, p1); // should only be valid for creating the game and not subsequent calls
        gameFactory.createPvP(3); // game created by p1
    }

    // P1 joins own game
    function testFailJoinOwnGame()public{
        vm.prank(p1, p1);
        gameFactory.join(0);
    }

    // P2 joins P1 game
    function testP1JoinP2Game()public{
        vm.prank(p2, p2);
        gameFactory.join(0);
    }

    // P1 tries to join random (unexisting) games with id > 0
    function testFailJoinRandom(uint id)public{
        vm.prank(p1, p1);
        gameFactory.join(id);
    }

    // P3 joins a game with P1, P2
    function testFailJoinP3() public{
        vm.prank(p3, p3);
        gameFactory.join(0);
    }

    // P2 joins a game with P1, P2
    function testFailJoinP2() public{
        vm.prank(p2, p2);
        gameFactory.join(0);
    }

    // Contract joins a game
    function testJoinContract() public {
        vm.expectRevert(abi.encodePacked("Not a valid player"));
        gameFactory.join(0);
    }
}