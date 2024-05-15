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
import { Log } from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract CrossChain is Test {
    Trident public trident;
    TridentDeploy public tridentDeploy;

    CrossChainTrident public ccTrident;
    CrossChainTridentDeploy public ccTridentDeploy;

    CCIPLocalSimulator public ccipLocalSimulator;
    IRouterClient tridentRouter;
    IRouterClient ccTridentRouter;
    uint64 destinationChainSelector;

    ERC20Mock tokenOne;

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
        tridentDeploy = new TridentDeploy();
        trident = tridentDeploy.run(Barba, destinationRouter, address(linkToken));

        //Deploy CrossChain Contract
        ccTridentDeploy = new CrossChainTridentDeploy();
        ccTrident = ccTridentDeploy.run(Barba, sourceRouter, address(linkToken), destinationChainSelector);

        //Deploy ERC20Mocks
        tokenOne = new ERC20Mock();      

        //mint some faucet link 
        ccipLocalSimulator.requestLinkFromFaucet(address(trident), LINK_BALANCE);
        ccipLocalSimulator.requestLinkFromFaucet(address(ccTrident), LINK_BALANCE);

        vm.startPrank(Barba);
        trident.manageAllowedTokens(tokenOne, 1);
        trident.manageAllowlistSourceChain(destinationChainSelector, 1);
        trident.manageAllowlistSender(address(ccTrident), 1);
        trident.manageCrossChainReceiver(destinationChainSelector, address(ccTrident));
        trident.manageCCIPRouter(tridentRouter);
        ccTrident.manageAllowedTokens(tokenOne, 1);
        ccTrident.manageMainContract(address(trident));
        ccTrident.manageAllowlistSourceChain(destinationChainSelector, 1);
        ccTrident.manageAllowlistSender(address(trident), 1);
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
    function test_dispatchCrossChainInfo() public {
        vm.prank(Barba);
        bytes32 messageId = trident.dispatchCrossChainInfo(1, destinationChainSelector);
        assertTrue(messageId != 0);

        CrossChainTrident.GameInfos memory info = ccTrident.getGamesInfo(1);

        assertEq(info.startingDate, SELLING_DATE);
        assertEq(info.price, GAME_PRICE);
    }






}