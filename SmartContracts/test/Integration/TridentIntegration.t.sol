// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {TridentDeploy} from "../../script/TridentDeploy.s.sol";
import {Trident} from "../../src/Trident.sol";
import {TridentNFT} from "../../src/TridentNFT.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract TridentIntegration is Test {
    Trident public trident;
    TridentDeploy public tridentDeploy;
    ERC20Mock tokenOne;
    ERC20Mock tokenTwo;
    ERC20Mock tokenThree;

    address Barba = makeAddr("Barba");
    address Cayo = makeAddr("Cayo");
    address Gabriel = makeAddr("Gabriel");
    address Raffa = makeAddr("Raffa");

    uint256 constant SELLING_DATE = 300;
    uint256 constant GAME_PRICE = 150;
    uint256 constant TIME_LOCK = 180 days;

    uint256 constant USER_INITIAL_BALANCE = 1000 *10**18;

    function setUp() public {
        vm.prank(Barba);
        tridentDeploy = new TridentDeploy();
        trident = tridentDeploy.run(Barba);

        tokenOne = new ERC20Mock();
        tokenTwo = new ERC20Mock();
        tokenThree = new ERC20Mock();
    }

    modifier createGame(){
        vm.startPrank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");
        trident.setReleaseConditions("GTA12", SELLING_DATE, GAME_PRICE, TIME_LOCK);
        trident.manageAllowedTokens(tokenOne, 1);
        vm.stopPrank();
        _;
    }

    ///FUNCTION manageAllowedTokens
    function test_testIfCanAddANewToken() public {
        vm.prank(Barba);
        trident.manageAllowedTokens(tokenOne, 1);

        uint256 allowed = trident.getAllowedTokens(tokenOne);

        assertEq(allowed, 1);
    }

    error Trident_InvalidTokenAddress(ERC20 tokenAddress);
    error Trident_ZeroOneOption(uint256 isAllowed);
    function test_ifManageReverts() public {
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidTokenAddress.selector, ERC20(address(0))));
        trident.manageAllowedTokens(ERC20(address(0)), 1);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_ZeroOneOption.selector, 2));
        trident.manageAllowedTokens(tokenOne, 2);
    }

    ///FUNCTION buyGame
    function test_ifAUserCanByAGame() public createGame{
        tokenOne.mint(Gabriel, USER_INITIAL_BALANCE);
        vm.prank(Gabriel);
        tokenOne.approve(address(trident), USER_INITIAL_BALANCE);

        vm.warp(301);

        vm.prank(Gabriel);
        trident.buyGame("GTA12", tokenOne, Gabriel);

        Trident.GameRelease memory game = trident.getGamesCreated("GTA12");
        assertEq(TridentNFT(game.keyAddress).balanceOf(Gabriel), 1);

        assertEq(tokenOne.balanceOf(Gabriel), USER_INITIAL_BALANCE - GAME_PRICE*10**18);
    }

    error Trident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
    error Trident_TokenNotAllowed(ERC20 choosenToken);
    error Trident_NotEnoughBalance(uint256 gamePrice);
    function testIfbuyGameReverts() public createGame{

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(Trident_GameNotAvailableYet.selector, block.timestamp, SELLING_DATE));
        trident.buyGame("GTA12", tokenOne, Gabriel);

        vm.warp(SELLING_DATE +1);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(Trident_TokenNotAllowed.selector, tokenTwo));
        trident.buyGame("GTA12", tokenTwo, Gabriel);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(Trident_NotEnoughBalance.selector, GAME_PRICE *10**18));
        trident.buyGame("GTA12", tokenOne, Gabriel);
    }
}
