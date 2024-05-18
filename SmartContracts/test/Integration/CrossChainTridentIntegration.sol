// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console2} from "forge-std/Test.sol";

import {CrossChainTrident} from "../../src/CrossChainTrident.sol";

import {CrossChainTridentDeploy} from "../../script/CrossChainTridentDeploy.s.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

import {CCIPLocalSimulator, IRouterClient, WETH9, LinkToken, BurnMintERC677Helper} from "@chainlink/local/src/ccip/CCIPLocalSimulator.sol";
import { Log } from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";

contract TridentIntegration is Test {
    CrossChainTrident public ccTrident;
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
    address Keeper = makeAddr("Keeper");
    address fakeReceiver = makeAddr("fakeReceiver");

    uint256 constant SELLING_DATE = 10_000;
    uint256 constant GAME_PRICE = 30;
    uint256 constant TIME_LOCK = 180 days;
    uint256 constant LINK_BALANCE = 10 ether;
    uint256 constant USER_INITIAL_BALANCE = 1000 *10**18;
    uint256 constant ALLOWED = 1;
    

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

        //Deploy CrossChain Contract
        ccTridentDeploy = new CrossChainTridentDeploy();
        ccTrident = ccTridentDeploy.run(Barba, sourceRouter, address(linkToken), destinationChainSelector);

        //Deploy ERC20Mocks
        tokenOne = new ERC20Mock();
        tokenTwo = new ERC20Mock();
        tokenThree = new ERC20Mock();

    }

    modifier createGame(){
        vm.startPrank(Barba);
        ccTrident.manageMainContract(fakeReceiver);
        ccTrident.manageAllowedTokens(tokenOne, 1);
        vm.stopPrank();
        _;
    }

    /////////////////////////
    ///manageAllowedTokens///
    /////////////////////////
    function test_manageAllowedTokens() public {
        vm.prank(Barba);
        ccTrident.manageAllowedTokens(tokenOne, 1);

        uint256 allowed = ccTrident.getAllowedTokens(tokenOne);

        assertEq(allowed, 1);
    }

    error CrossChainTrident_InvalidTokenAddress(ERC20 tokenAddress);
    error CrossChainTrident_ZeroOneOption(uint256 isAllowed);
    function test_revertManageAllowedTokens() public createGame{
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_InvalidTokenAddress.selector, ERC20(address(0))));
        ccTrident.manageAllowedTokens(ERC20(address(0)), 1);
    }

    ////////////////////////
    ///manageMainContract///
    ////////////////////////
    function test_manageMainContract() public {
        vm.prank(Barba);
        ccTrident.manageMainContract(fakeReceiver);

        address receiver = ccTrident.getMainContractAddress();

        assertEq(fakeReceiver, receiver);
    }

    error CrossChainTrident_InvalidAddress(address receiver);
    function test_revertManageMainContract() public {
        address fakeContract = address(0);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_InvalidAddress.selector, fakeContract));
        ccTrident.manageMainContract(fakeContract);
    }

    ///manageAllowlistSourceChain///
    function test_manageAllowlistSourceChain() public{
        uint64 fakeChainId = 165161165161;

        vm.prank(Barba);
        ccTrident.manageAllowlistSourceChain(fakeChainId, 1);
    }

    error CrossChainTrident_InvalidSouceChain(uint64);
    function test_revertManageAllowlistSourceChain() public {

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_InvalidSouceChain.selector, 0));
        ccTrident.manageAllowlistSourceChain(0, 1);
    }

    ///manageAllowlistSender///
    event CrossChainTrident_AllowedSenderUpdated(address, uint256);
    function test_manageAllowlistSender() public {
        vm.prank(Barba);
        vm.expectEmit();
        emit CrossChainTrident_AllowedSenderUpdated(Raffa, 1);
        ccTrident.manageAllowlistSender(Raffa, 1);
    }

    error CrossChainTrident_InvalidSender(address);
    function test_revertManageAllowlistSender() public {
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_InvalidSender.selector, address(0)));
        ccTrident.manageAllowlistSender(address(0), 1);

    }
}
