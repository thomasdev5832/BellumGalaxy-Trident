// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TridentD} from "../../script/TridentD.s.sol";
import {Trident} from "../../src/Trident.sol";
import {TridentFunctions} from "../../src/TridentFunctions.sol";
import {TridentNFT} from "../../src/TridentNFT.sol";
import {CCIPLocalSimulator, IRouterClient, WETH9, LinkToken, BurnMintERC677Helper} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";


contract TridentTest is Test {
    Trident public trident;
    TridentFunctions functions;
    TridentD public tridentDeploy;
    CCIPLocalSimulator public ccipLocalSimulator;

    address Barba = makeAddr("Barba");
    address Cayo = makeAddr("Cayo");
    address Gabriel = makeAddr("Gabriel");
    address Raffa = makeAddr("Raffa");

    function setUp() public {
        ccipLocalSimulator = new CCIPLocalSimulator();

        (
            uint64 chainSelector,
            IRouterClient sourceRouter,
            IRouterClient destinationRouter,
            WETH9 wrappedNative,
            LinkToken linkToken,
            BurnMintERC677Helper ccipBnM,
            BurnMintERC677Helper ccipLnM
        ) = ccipLocalSimulator.configuration();

        vm.prank(Barba);
        tridentDeploy = new TridentD();
        (trident, functions) = tridentDeploy.run(Barba, destinationRouter, address(linkToken));
        
        //Transfer Functions ownership to Trident
        vm.prank(Barba);
        functions.transferOwnership(address(trident));
    }

    /// CONTRACT OWNER
    function test_contractOwerIsset() public view{
        address owner = trident.owner();
        assertEq(owner, Barba);
    }

    /// FUNCTION createNewGame
    function test_GameIsCreated() public {
        vm.prank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");

        Trident.GameRelease memory newGameCreated = trident.getGamesCreated(1);

        assertEq(newGameCreated.gameSymbol, "GTA12");
        assertEq(newGameCreated.gameName, "Grande Tatu Autonomo 12");
        assertTrue(address(newGameCreated.keyAddress) != address(0));
    }

    /// FUNCTION setReleaseConditions
    modifier createGame(){
        vm.prank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");
        _;
    }

    error Trident_SetAValidSellingPeriod(uint256 startingDate, uint256 dateNow);
    error Trident_NonExistantGame(TridentNFT trident);
    function test_functionRevertsOnInvalidTokenSymbol() public createGame{
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_NonExistantGame.selector, address(0)));
        trident.setReleaseConditions(0, 300, 150);

        vm.warp(301);
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_SetAValidSellingPeriod.selector, 300, 301));
        trident.setReleaseConditions(1, 300, 150);

    }

    ///gameScoreGetter///
    function test_ScoreSystem() public createGame{
        assertEq(trident.getScoreChecker().length, 1);
        
        string[] memory score = new string[](1);

        score = trident.getScoreChecker();

        assertEq(score[0], "Grande Tatu Autonomo 12");
    }
}
