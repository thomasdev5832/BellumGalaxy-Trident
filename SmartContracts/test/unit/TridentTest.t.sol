// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TridentDeploy} from "../../script/TridentDeploy.s.sol";
import {Trident} from "../../src/Trident.sol";
import {TridentNFT} from "../../src/TridentNFT.sol";

contract TridentTest is Test {
    Trident public trident;
    TridentDeploy public tridentDeploy;

    address Barba = makeAddr("Barba");
    address Cayo = makeAddr("Cayo");
    address Gabriel = makeAddr("Gabriel");
    address Raffa = makeAddr("Raffa");

    function setUp() public {
        vm.prank(Barba);
        tridentDeploy = new TridentDeploy();
        trident = tridentDeploy.run(Barba);
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

        Trident.GameRelease memory newGameCreated = trident.getGamesCreated("GTA12");

        assertEq(newGameCreated.gameSymbol, "GTA12");
        assertEq(newGameCreated.gameName, "Grande Tatu Autonomo 12");
        assertTrue(address(newGameCreated.keyAddress) != address(0));
    }

    error Trident_GameAlreadyReleased(TridentNFT trident);
    function test_GameIsCreatedReverts() public {
        vm.prank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");

        Trident.GameRelease memory newGameCreated = trident.getGamesCreated("GTA12");

        vm.expectRevert(abi.encodeWithSelector(Trident_GameAlreadyReleased.selector, address(newGameCreated.keyAddress)));
        vm.prank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");
    }


    /// FUNCTION setReleaseConditions
    modifier createGame(){
        vm.prank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");
        _;
    }

    function test_setReleaseConditions() public createGame{
        vm.prank(Barba);
        trident.setReleaseConditions("GTA12", 300, 150);

        Trident.GameInfos memory info = trident.getGamesInfo("GTA12");

        assertEq(info.sellingDate, 300);
        assertEq(info.price, 150 ether);
        assertEq(info.copiesSold, 0);
    }

    error Trident_SetAValidSellingPeriod(uint256 startingDate, uint256 dateNow);
    error Trident_NonExistantGame(TridentNFT trident);
    function test_functionRevertsOnInvalidTokenSymbol() public createGame{
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_NonExistantGame.selector, address(0)));
        trident.setReleaseConditions("GTA22", 300, 150);

        vm.warp(301);
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_SetAValidSellingPeriod.selector, 300, 301));
        trident.setReleaseConditions("GTA12", 300, 150);

    }
}
