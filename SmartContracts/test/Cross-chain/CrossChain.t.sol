// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {Trident} from "../../src/Trident.sol";
import {TridentNFT} from "../../src/TridentNFT.sol";
import {CrossChainTrident} from "../../src/CrossChainTrident.sol";
import {TridentFunctions} from "../../src/TridentFunctions.sol";

import {TridentD} from "../../script/TridentD.s.sol";
import {CrossChainTridentDeploy} from "../../script/CrossChainTridentDeploy.s.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {CCIPLocalSimulator, IRouterClient, WETH9, LinkToken, BurnMintERC677Helper} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import { Log } from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract CrossChain is Test {
    Trident public trident;
    TridentFunctions functions;
    TridentD public tridentDeploy;

    CrossChainTrident public ccTrident;
    CrossChainTridentDeploy public ccTridentDeploy;

    CCIPLocalSimulator public ccipLocalSimulator;
    IRouterClient tridentRouter;
    IRouterClient ccTridentRouter;
    uint64 destinationChainSelector;

    ERC20Mock tokenOne;
    ERC20Mock tokenTwo;

    address Barba = makeAddr("Barba");
    address Cayo = makeAddr("Cayo");
    address Gabriel = makeAddr("Gabriel");
    address Raffa = makeAddr("Raffa");
    address Keeper = makeAddr("Keeper");
    address fakeReceiver = makeAddr("fakeReceiver");
    address Exploiter = makeAddr("Exploiter");

    uint256 constant SELLING_DATE = 300;
    uint256 constant GAME_PRICE = 150;
    uint256 constant LINK_BALANCE = 10 ether;

    uint256 constant USER_INITIAL_BALANCE = 1000 *10**18;

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

        //turn the variable global
        destinationChainSelector = chainSelector;
        tridentRouter = sourceRouter;
        ccTridentRouter = destinationRouter;

        vm.prank(Barba);
        //Deploy main contract
        tridentDeploy = new TridentD();
        (trident, functions) = tridentDeploy.run(Barba, destinationRouter, address(linkToken));
        
        //Transfer Functions ownership to Trident
        vm.prank(Barba);
        functions.transferOwnership(address(trident));

        //Deploy CrossChain Contract
        ccTridentDeploy = new CrossChainTridentDeploy();
        ccTrident = ccTridentDeploy.run(Barba, sourceRouter, address(linkToken), destinationChainSelector);

        //Deploy ERC20Mocks
        tokenOne = new ERC20Mock();
        tokenTwo = new ERC20Mock();

        //mint some faucet link 
        ccipLocalSimulator.requestLinkFromFaucet(address(trident), LINK_BALANCE);
        ccipLocalSimulator.requestLinkFromFaucet(address(ccTrident), LINK_BALANCE);

        vm.startPrank(Barba);
        trident.manageAllowedTokens(tokenOne, 1);
        trident.manageCCIPAllowlist(destinationChainSelector, address(ccTrident), 1);
        trident.manageCrossChainReceiver(destinationChainSelector, address(ccTrident));

        ccTrident.manageAllowedTokens(tokenOne, 1);
        ccTrident.manageMainContract(address(trident));
        ccTrident.manageCCIPAllowlist(destinationChainSelector, address(trident), 1);
        vm.stopPrank();
    }
    
    modifier createGame(){
        vm.startPrank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");
        trident.setReleaseConditions(1, SELLING_DATE, GAME_PRICE);
        vm.stopPrank();
        _;
    }

    ///dispatchCrossChainInfo///
    function test_dispatchCrossChainInfo() public createGame{
        vm.prank(Barba);
        bytes32 messageId = trident.dispatchCrossChainInfo(1, destinationChainSelector);
        assertTrue(messageId != 0);

        CrossChainTrident.GameInfos memory info = ccTrident.getGamesInfo(1);

        assertEq(info.startingDate, SELLING_DATE);
        assertEq(info.price, GAME_PRICE *10**6);
    }

    /////////////
    ///buyGame///
    /////////////
    //It will fail because of functions in the destination
    function test_ifAUserCanByAGameCC() public createGame{
        vm.prank(Barba);
        bytes32 messageId = trident.dispatchCrossChainInfo(1, destinationChainSelector);

        tokenOne.mint(Gabriel, USER_INITIAL_BALANCE);

        vm.prank(Gabriel);
        tokenOne.approve(address(ccTrident), USER_INITIAL_BALANCE);

        vm.warp(10_001);

        vm.prank(Gabriel);
        ccTrident.buyGame(1, tokenOne, Gabriel);
    }

    error CrossChainTrident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
    error CrossChainTrident_TokenNotAllowed(ERC20 choosenToken);
    error CrossChainTrident_NotEnoughBalance(uint256 gamePrice);
    function testIfbuyGameRevertsCC() public createGame {
        vm.prank(Barba);
        bytes32 messageId = trident.dispatchCrossChainInfo(1, destinationChainSelector);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_GameNotAvailableYet.selector, block.timestamp, SELLING_DATE));
        ccTrident.buyGame(1, tokenOne, Gabriel);

        vm.warp(SELLING_DATE +1);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_TokenNotAllowed.selector, tokenTwo));
        ccTrident.buyGame(1, tokenTwo, Gabriel);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_NotEnoughBalance.selector, GAME_PRICE *10**6));
        ccTrident.buyGame(1, tokenOne, Gabriel);
    }

    ///sendAdminMessage///
    //It will fail because of functions in the destination
    function test_sendAdminMessage() public createGame{
        vm.prank(Barba);
        bytes32 messageId = trident.dispatchCrossChainInfo(1, destinationChainSelector);

        tokenOne.mint(Gabriel, USER_INITIAL_BALANCE);

        vm.prank(Gabriel);
        tokenOne.approve(address(ccTrident), USER_INITIAL_BALANCE);

        vm.warp(10_001);

        vm.prank(Gabriel);
        ccTrident.buyGame(1, tokenOne, Gabriel);

        ///====================================================

        vm.startPrank(Barba);
        ccTrident.sendAdminMessage(tokenOne, GAME_PRICE);
        vm.stopPrank();

        assertEq(tokenOne.balanceOf(address(ccTrident)), 0);
        assertEq(tokenOne.balanceOf(address(trident)), GAME_PRICE *10**6);
    }

}