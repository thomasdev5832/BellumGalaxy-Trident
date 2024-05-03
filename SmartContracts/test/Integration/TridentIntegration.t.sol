// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {Trident} from "../../src/Trident.sol";
import {TridentNFT} from "../../src/TridentNFT.sol";
import {CrossChainTrident} from "../../src/CrossChainTrident.sol";

import {TridentDeploy} from "../../script/TridentDeploy.s.sol";
import {CrossChainTridentDeploy} from "../../script/CrossChainTridentDeploy.s.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {CCIPLocalSimulator, IRouterClient, WETH9, LinkToken, BurnMintERC677Helper} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";

contract TridentIntegration is Test {
    Trident public trident;
    CrossChainTrident public ccTrident;
    TridentDeploy public tridentDeploy;
    CrossChainTridentDeploy public ccTridentDeploy;
    CCIPLocalSimulator public ccipLocalSimulator;
    ERC20Mock tokenOne;
    ERC20Mock tokenTwo;
    ERC20Mock tokenThree;
    
    uint64 destinationChainSelector;

    address Barba = makeAddr("Barba");
    address Cayo = makeAddr("Cayo");
    address Gabriel = makeAddr("Gabriel");
    address Raffa = makeAddr("Raffa");

    uint256 constant SELLING_DATE = 300;
    uint256 constant GAME_PRICE = 150;
    uint256 constant TIME_LOCK = 180 days;
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

        vm.prank(Barba);
        //Deploy main contract
        tridentDeploy = new TridentDeploy();
        trident = tridentDeploy.run(Barba, address(destinationRouter));

        //Deploy CrossChain Contract
        ccTridentDeploy = new CrossChainTridentDeploy();
        ccTrident = ccTridentDeploy.run(Barba, address(sourceRouter), address(linkToken), destinationChainSelector);

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

    /////////////////////////////
    ///manageAllowedForwarders///
    /////////////////////////////
    function test_manageAllowedRelayers() public {
        address relayerToTest = address(1);
        vm.prank(Barba);
        trident.manageAllowedRelayers(relayerToTest, 1);

        uint256 allowed = trident.getAllowedRelayers(relayerToTest);

        assertEq(allowed, 1);
    }

    error Trident_InvalidKeeperAddress(address forwarderAddress);
    function test_revertManageAllowedRelayers() public {
        address wrongRelayer = address(0);
        address relayerToTest = address(1);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidKeeperAddress.selector, wrongRelayer));
        trident.manageAllowedRelayers(wrongRelayer, 1);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_ZeroOneOption.selector, 45454));
        trident.manageAllowedRelayers(relayerToTest, 45454);
    }

    //////////////////////////
    ///manageAllowlistSourceChain///
    //////////////////////////
    function test_manageAllowlistSourceChain() public {
        uint64 sourceChainToTest = 4546454664;
        vm.prank(Barba);
        trident.manageAllowlistSourceChain(sourceChainToTest, 1);

        uint256 allowed = trident.getAllowedSourceChains(sourceChainToTest);

        assertEq(allowed, 1);
    }

    error Trident_InvalidSouceChain(uint64 sourceChainSelector);
    function test_revertManageAllowlistSourceChain() public {
        uint64 fakeChain;
        uint64 sourceChainToTest = 51516161651;
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidSouceChain.selector, fakeChain));
        trident.manageAllowlistSourceChain(fakeChain, 1);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_ZeroOneOption.selector, 51616));
        trident.manageAllowlistSourceChain(sourceChainToTest, 51616);
    }

    ///////////////////////////
    ///manageAllowlistSender///
    ///////////////////////////
    function test_manageAllowlistSender() public {
        vm.prank(Barba);
        trident.manageAllowlistSender(Raffa, 1);

        uint256 allowed = trident.getAllowedSenders(Raffa);

        assertEq(allowed, 1);
    }

    error Trident_InvalidSender(address sender);
    function test_revertManageAllowlistSender() public {
        address invalidSender = address(0);
        address senderToTest = address(1);
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_InvalidSender.selector, invalidSender));
        trident.manageAllowlistSender(invalidSender, 1);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(Trident_ZeroOneOption.selector, 1000));
        trident.manageAllowlistSender(senderToTest, 1000);
    }

    /////////////////////////
    ///manageAllowedTokens///
    /////////////////////////
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

    /////////////
    ///buyGame///
    /////////////
    function test_ifAUserCanByAGame() public createGame{
        tokenOne.mint(Gabriel, USER_INITIAL_BALANCE);
        vm.prank(Gabriel);
        tokenOne.approve(address(trident), USER_INITIAL_BALANCE);

        vm.warp(301);

        vm.prank(Gabriel);
        trident.buyGame(1, tokenOne, Gabriel);

        Trident.GameRelease memory game = trident.getGamesCreated(1);
        assertEq(TridentNFT(game.keyAddress).balanceOf(Gabriel), 1);

        assertEq(tokenOne.balanceOf(Gabriel), USER_INITIAL_BALANCE - GAME_PRICE*10**18);
    }

    error Trident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
    error Trident_TokenNotAllowed(ERC20 choosenToken);
    error Trident_NotEnoughBalance(uint256 gamePrice);
    function testIfbuyGameReverts() public createGame{

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
