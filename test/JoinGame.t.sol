// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameFactory.sol";

// Act as certain address, how to make this work so we can pass tx.origin == msg.sender ? 
// https://stackoverflow.com/questions/73670446/foundry-call-smart-contract-from-with-eoa-address
interface CheatCodes {
    function prank(address) external;    
}

contract CreateGame is Test {
    GameFactory public gameFactory;
    CheatCodes cheatCodes;
    address p1 = address(0x35524A1a02D6C89C8FceAd21644cB61b032BD3DE);
    address p2 = address(0x35524a1A02d6C89C8FCEAD21644CB61B032Bd3Df);

    function setUp() public {
        gameFactory = new GameFactory();
        cheatCodes = CheatCodes(HEVM_ADDRESS);
        // Create a game of board size 3
        cheatCodes.prank(p1); // should only be valid for creating the game and not subsequent calls
        gameFactory.createPvP(3); // game created by p1
    }

    // P1 joins own game
    function testFailJoinOwnGame()public{
        cheatCodes.prank(p1);
        gameFactory.join(0);
    }

    // P2 joins P1 game
    function testP1JoinP2Game()public{
        cheatCodes.prank(p2);
        gameFactory.join(0);
    }

    // P1 tries to join random games with id > 0
    function testFailJoinRandom(uint id)public{
        cheatCodes.prank(p1);
        gameFactory.join(id);
    }
}