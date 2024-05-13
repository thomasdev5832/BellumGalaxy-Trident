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

    ////////////////////////////////
    ///AUTOMATION HELPER FUNCTION///
    ////////////////////////////////
    function createMockLog() public view returns (Log memory) {
        bytes32[] memory topics = new bytes32[](4);
        topics[1] = bytes32(abi.encodePacked(uint256(1))); // _gameId
        topics[2] = bytes32(abi.encodePacked(uint256(10000))); // _startingDate
        topics[3] = bytes32(abi.encodePacked(uint256(30_000_000_000_000_000_000))); // _price

        return Log({
            index: 1,
            timestamp: 9_950,  // Ou um valor fixo para testes consistentes
            txHash: bytes32(abi.encodePacked(uint256(0xabc123))),   // Hash de transação fictício
            blockNumber: 12345,
            blockHash: bytes32(abi.encodePacked(uint256(0xdef456))),  // Hash de bloco fictício
            source: fakeReceiver,
            topics: topics,
            data: bytes("0x77656c636f6d65")  // Dados fictícios em hexadecimal
        });
    }

    /////////////////////////
    ///manageAllowedTokens///
    /////////////////////////
    function test_testIfCanAddANewToken() public {
        vm.prank(Barba);
        ccTrident.manageAllowedTokens(tokenOne, 1);

        uint256 allowed = ccTrident.getAllowedTokens(tokenOne);

        assertEq(allowed, 1);
    }

    error CrossChainTrident_InvalidTokenAddress(ERC20 tokenAddress);
    error CrossChainTrident_ZeroOneOption(uint256 isAllowed);
    function test_ifManageReverts() public createGame{
        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_InvalidTokenAddress.selector, ERC20(address(0))));
        ccTrident.manageAllowedTokens(ERC20(address(0)), 1);

        Log memory log = createMockLog();

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_ZeroOneOption.selector, 2));
        ccTrident.manageAllowedTokens(tokenOne, 2);
    }

    ////////////////////////
    ///manageMainContract///
    ////////////////////////
    function test_manageCCIPReceiver() public {
        vm.prank(Barba);
        ccTrident.manageMainContract(fakeReceiver);

        address receiver = ccTrident.getMainContractAddress();

        assertEq(fakeReceiver, receiver);
    }

    error CrossChainTrident_InvalidAddress(address receiver);
    function test_revertManageCCIPReceiver() public {
        address fakeContract = address(0);

        vm.prank(Barba);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_InvalidAddress.selector, fakeContract));
        ccTrident.manageMainContract(fakeContract);
    }

    /////////////
    ///buyGame///
    /////////////
    //@Ajuste
    function test_ifAUserCanByAGameCC() public createGame{
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
    //@Ajuste
    function testIfbuyGameRevertsCC() public createGame{
        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_GameNotAvailableYet.selector, block.timestamp, SELLING_DATE));
        ccTrident.buyGame(1, tokenOne, Gabriel);

        vm.warp(SELLING_DATE +1);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_TokenNotAllowed.selector, tokenTwo));
        ccTrident.buyGame(1, tokenTwo, Gabriel);

        vm.prank(Gabriel);
        vm.expectRevert(abi.encodeWithSelector(CrossChainTrident_NotEnoughBalance.selector, GAME_PRICE *10**18));
        ccTrident.buyGame(1, tokenOne, Gabriel);
    }
}
