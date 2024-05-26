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

contract TridentIntegration is Test {
    Trident public trident;
    CrossChainTrident public ccTrident;
    TridentD public tridentDeploy;
    TridentFunctions functions;

    CrossChainTridentDeploy public ccTridentDeploy;
    CCIPLocalSimulator public ccipLocalSimulator;
    ERC20Mock tokenOne;
    ERC20Mock tokenTwo;
    ERC20Mock tokenThree;
    
    IRouterClient router;
    uint64 destinationChainSelector;

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
        router = sourceRouter;

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
        tokenThree = new ERC20Mock();        

        //mint some faucet link 
        ccipLocalSimulator.requestLinkFromFaucet(address(ccTrident), LINK_BALANCE);
    }

    modifier createGame(){
        vm.startPrank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");
        trident.setReleaseConditions(1, SELLING_DATE, GAME_PRICE);
        trident.manageAllowedTokens(tokenOne, 1);
        vm.stopPrank();
        _;
    }

    ////////////////////////////////
    ///manageAllowlistSourceChain///
    ////////////////////////////////
    function test_manageAllowlistSourceChain() public {
        uint64 sourceChainToTest = 4546454664;
        vm.prank(Barba);
        trident.manageCCIPAllowlist(sourceChainToTest, address(ccTrident), 1);

        uint256 allowed = trident.s_allowlistedSourceChainsAndSenders(sourceChainToTest, address(ccTrident));

        assertEq(allowed, 1);
    }

    error Trident_InvalidSouceChain(uint64 sourceChainSelector);
    error OwnableUnauthorizedAccount(address caller);
    function test_revertManageAllowlistSourceChain() public {
        uint64 fakeChain;

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidSouceChain.selector, fakeChain));
        trident.manageCCIPAllowlist(fakeChain, address(ccTrident), 1);

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(this)));
        trident.manageCCIPAllowlist(fakeChain, address(ccTrident), 1);
    }

    /////////////////////////
    ///manageAllowedTokens///
    /////////////////////////
    function test_manageAllowedTokens() public {
        vm.prank(Barba);
        trident.manageAllowedTokens(tokenOne, 1);

        uint256 allowed = trident.getAllowedTokens(tokenOne);

        assertEq(allowed, 1);
    }

    error Trident_InvalidTokenAddress(ERC20 tokenAddress);
    function test_revertManageAllowedTokens() public {
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidTokenAddress.selector, ERC20(address(0))));
        trident.manageAllowedTokens(ERC20(address(0)), 1);

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(this)));
        trident.manageAllowedTokens(ERC20(address(0)), 1);
    }

    //////////////////////////////
    ///manageCrossChainReceiver///
    //////////////////////////////
    event Trident_CrossChainReceiverUpdated(uint64 destinationChainId, address receiver);
    function test_manageCrossChainReceiver() public {
        vm.prank(Barba);
        vm.expectEmit();
        emit Trident_CrossChainReceiverUpdated(destinationChainSelector, address(ccTrident));
        trident.manageCrossChainReceiver(destinationChainSelector, address(ccTrident));

        assertEq(trident.getAllowedCrossChainReceivers(destinationChainSelector), address(ccTrident));
    }

    error Trident_InvalidChainId(uint64 destinationChainId);
    error Trident_InvalidReceiver(address receiver);
    function test_revertManageCrossChainReceiver() public {
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidChainId.selector, 0));
        trident.manageCrossChainReceiver(0, address(ccTrident));

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidReceiver.selector, address(0)));
        trident.manageCrossChainReceiver(destinationChainSelector, address(0));

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(this)));
        trident.manageCrossChainReceiver(destinationChainSelector, address(0));
    }

    ///////////////////
    ///createNewGame///
    ///////////////////
    event Trident_NewGameCreated(uint256 s_gameIdCounter, string _gameSymbol, string _gameName, address  keyAddress);
    function test_createNewGame() public {
        vm.startPrank(Barba);
        vm.expectEmit();
        emit Trident_NewGameCreated(1, "GTA12", "Grande Tatu Autonomo 12", address(0));
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");

        Trident.GameRelease memory game = trident.getGamesCreated(1);

        assertEq(game.gameName, "Grande Tatu Autonomo 12");
        assertEq(game.gameSymbol, "GTA12");
        assertTrue(address(game.keyAddress) != address(0));
    }

    error Trident_InvalidGameSymbolOrName(string symbol, string name);
    function test_revertCreateNewGame() public {

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(this)));
        trident.createNewGame("", "");

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidGameSymbolOrName.selector, "GTAXII", ""));
        trident.createNewGame("GTAXII", "");

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidGameSymbolOrName.selector, "", "Grande Tatu Autonomo 12"));
        trident.createNewGame("", "Grande Tatu Autonomo 12");
    }

    //////////////////////////
    ///setReleaseConditions///
    //////////////////////////
    event Trident_ReleaseConditionsSet(uint256 gameId, uint256 startingTime, uint256 gamePrice);
    function test_setReleaseConditions() public {
        uint256 gamePrice = 30;
        
        vm.startPrank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");
        
        vm.warp(300);

        vm.expectEmit();
        emit Trident_ReleaseConditionsSet(1, 301, gamePrice);
        trident.setReleaseConditions(1, 301, gamePrice);
        vm.stopPrank();

        Trident.GameInfos memory infos = trident.getGamesInfo(1);

        assertEq(infos.sellingDate, 301);
        assertEq(infos.price, 30*10**18);
        assertEq(infos.copiesSold, 0);
    }

    error Trident_NonExistantGame(address invalid);
    error Trident_SetAValidSellingPeriod(uint256 startingDate, uint256 timeNow);
    error Trident_InvalidGamePrice(uint256 price);
    function test_revertSetReleaseConditions() public {
        uint256 gamePrice = 30;

        vm.prank(Barba);
        trident.createNewGame("GTA12", "Grande Tatu Autonomo 12");

        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, address(this)));
        trident.setReleaseConditions(100, 301, gamePrice);
        
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_NonExistantGame.selector, address(0)));
        trident.setReleaseConditions(100, 301, gamePrice);

        vm.warp(1000);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_SetAValidSellingPeriod.selector, 301, 1000));
        trident.setReleaseConditions(1, 301, gamePrice);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidGamePrice.selector, 0));
        trident.setReleaseConditions(1, 1100, 0);
    }

    /////////////
    ///buyGame///
    /////////////
    event Trident_NewGameSold(uint256 gameId, string gameName, address payer, uint256 date, address gameReceiver);
    // function test_buyAGame() public createGame{
    //     tokenOne.mint(Gabriel, USER_INITIAL_BALANCE);
    //     vm.prank(Gabriel);
    //     tokenOne.approve(address(trident), USER_INITIAL_BALANCE);

    //     vm.warp(301);

    //     vm.prank(Gabriel);
    //     vm.expectEmit();
    //     emit Trident_NewGameSold(1, "Grande Tatu Autonomo 12", Gabriel, block.timestamp, Gabriel);
    //     trident.buyGame(1, tokenOne, Gabriel);

    //     Trident.GameRelease memory game = trident.getGamesCreated(1);

    //     assertEq(TridentNFT(game.keyAddress).balanceOf(Gabriel), 1);
    //     assertEq(tokenOne.balanceOf(Gabriel), USER_INITIAL_BALANCE - GAME_PRICE*10**18);

    //     Trident.ClientRecord[] memory client = trident.getClientRecords(Gabriel);

    //     assertEq(client[0].gameName, "Grande Tatu Autonomo 12");
    //     assertTrue(address(client[0].game) != address(0));
    //     assertEq(client[0].paidValue, GAME_PRICE * 10**18);
    // }

    error Trident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
    error Trident_TokenNotAllowed(ERC20 choosenToken);
    error Trident_NotEnoughBalance(uint256 gamePrice);
    function test_revertBuyGame() public createGame{

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(Trident_GameNotAvailableYet.selector, block.timestamp, SELLING_DATE));
        trident.buyGame(1, tokenOne, Gabriel);

        vm.warp(SELLING_DATE +1);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(Trident_TokenNotAllowed.selector, tokenTwo));
        trident.buyGame(1, tokenTwo, Gabriel);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(Trident_NotEnoughBalance.selector, GAME_PRICE *10**18));
        trident.buyGame(1, tokenOne, Gabriel);
    }
}
