// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ILogAutomation, Log } from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

import {TridentNFT} from "./TridentNFT.sol";
import {TridentFunctions} from "./TridentFunctions.sol";

//////////////
/// ERRORS ///
//////////////
///@notice emitted when a invalid param is passed to constructor
error CrossChainTrident_InvalidDeployParameters(address owner, address router, address link, uint64 destinationChainSelector);
///@notice emitted when a contract is initialized with an address(0) param
error CrossChainTrident_InvalidAddress(address owner);
///@notice emitted when the keeper forwarder address is invalid
error CrossChainTrident_InvalidKeeperAddress(address forwarderAddress);
///@notice emitted when an invalid game is selected
error CrossChainTrident_NonExistantGame(address invalidAddress);
///@notice emitted when publisher input wrong address value
error CrossChainTrident_InvalidTokenAddress(ERC20 tokenAddress);
///@notice emitter when a not allowed caller calls checkUpkeep function
error CrossChainTrident_InvalidCaller(address caller);
///@notice emitted when the contract receives an log from a invalid sender
error CrossChainTrident_InvalidLogEmissor(address senderAddress);
///@notice emitted when publisher input a wrong value
error CrossChainTrident_ZeroOneOption(uint256 isAllowed);
///@notice emitted when a user tries to use a token that is not allowed
error CrossChainTrident_TokenNotAllowed(ERC20 choosenToken);
///@notice emitted when the selling period is not open yet
error CrossChainTrident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
///@notice emitted when an user don't have enough balance
error CrossChainTrident_NotEnoughBalance(uint256 gamePrice);
///@notice emitted when the contract doesn't have enough balance
error CrossChainTrident_NotEnoughLinkBalance(uint256 currentBalance, uint256 calculatedFees);

///////////////
///INTERFACE///
///////////////



/**
    *@author Barba - Bellum Galaxy Hackathon Division
    *@title Trident Project
    *@dev This is a Hackathon Project, this codebase didn't go through a cautious analysis or audit
    *@dev do not use in production
    *contact www.bellumgalaxy.com - https://linktr.ee/bellumgalaxy
*/
contract CrossChainTrident is Ownable, ILogAutomation{
    using SafeERC20 for ERC20;
    
    ////////////////////
    /// CUSTOM TYPES ///
    ////////////////////
    ///@notice Struct to track info about games to be released
    struct GameInfos {
        uint256 startingDate;
        uint256 price;
    }

    ///@notice Struct to track buying info.
    struct ClientRecord {
        uint256 gameId;
        uint256 buyingDate;
        uint256 paidValue;
    }

    //////////////////////////////
    /// CONSTANTS & IMMUTABLES ///
    //////////////////////////////
    uint256 private constant ONE = 1;

    IRouterClient private immutable i_router;
    LinkTokenInterface private immutable i_linkToken;
    uint64 private immutable i_destinationChainSelector;

    ///////////////////////
    /// STATE VARIABLES ///
    ///////////////////////
    address private s_mainContractAddress;

    ///@notice Mapping to keep track of allowed stablecoins. ~ 0 = not allowed | 1 = allowed
    mapping(ERC20 tokenAddress => uint256 allowed) private s_tokenAllowed;
    ///@notice Mapping to keep track of allowed forwarders. ~ 0 = not allowed | 1 = allowed
    mapping(address keeperForwarder => uint256 allowed) private s_allowedKeeperForwarders;
    ///@notice Mapping to keep track of game's info
    mapping(uint256 gameId => GameInfos) private s_gamesInfo;
    ///@notice Mapping to keep track of games an user has
    mapping(address client => ClientRecord[]) private s_clientRecords;

    //////////////
    /// EVENTS ///
    //////////////
    ///@notice event emitted when a token is updated or added
    event CrossChainTrident_AllowedTokensUpdated(string tokenName, string tokenSymbol, ERC20 tokenAddress, uint256 isAllowed);
    ///@notice event emitted when a forwarded is updated or added
    event CrossChainTrident_NewForwarderAllowd(address forwarderAddress);
    ///@notice event emitted when a CCIP receiver is updated
    event CrossChainTrident_ReceiverUpdated(address previousReceiver, address newReceiver);
    ///@notice event emitted when a automation sender is updated
    event CrossChainTrident_AllowedSenderUpdated(address sender, uint256 isAllowed);
    ///@notice event emitted when a new game is available
    event CrossChainTrident_NewGameAvailable(uint256 gameId, uint256 startingDate, uint256 price);
    ///@notice
    event CrossChainTrident_AutomationTrigger(uint256 gameId, uint256 startingDate, uint256 price);
    ///@notice event emitted when a new copy is sold.
    event CrossChainTrident_NewGameSold(uint256 gameId, address payer, uint256 date, address gameReceiver, uint256 value);
    ///@notice event emitted when a CCIP message is sent
    event CrossChainTrident_MessageSent(bytes32 messageId, uint64 destinationChainSelector, address receiver, string text, address token, uint256 tokenAmount, address feeToken, uint256 fees);

    constructor(address _owner,address _router, address _link, uint64 _destinationChainSelector) Ownable(_owner){
        if(_owner == address(0) || _router == address(0) || _link == address(0) || _destinationChainSelector < ONE) revert CrossChainTrident_InvalidDeployParameters(_owner, _router, _link, _destinationChainSelector);
        i_router = IRouterClient(_router);
        i_linkToken = LinkTokenInterface(_link);
        i_destinationChainSelector = _destinationChainSelector;
    }

    /////////////////////////////////////////////////////////////////
    /////////////////////////// FUNCTIONS ///////////////////////////
    /////////////////////////////////////////////////////////////////

    ////////////////////////////////////
    /// EXTERNAL onlyOwner FUNCTIONS ///
    ////////////////////////////////////
    /**
        * @notice Function to manage whitelisted tokens
        * @param _tokenAddress Address of the token
        * @param _isAllowed 0 = False / 1 True
        * @dev we opted for not deleting the token because we still need to withdraw it.
    */
    function manageAllowedTokens(ERC20 _tokenAddress, uint256 _isAllowed) external payable onlyOwner {
        if(address(_tokenAddress) == address(0)) revert CrossChainTrident_InvalidTokenAddress(_tokenAddress);
        if(_isAllowed > ONE) revert CrossChainTrident_ZeroOneOption(_isAllowed);

        s_tokenAllowed[_tokenAddress] = _isAllowed;

        emit CrossChainTrident_AllowedTokensUpdated(_tokenAddress.name(), _tokenAddress.symbol(), _tokenAddress, _isAllowed);
    }

    function manageAllowedForwarders(address _forwarderAddress, uint256 _isAllowed) external payable onlyOwner{
        if(_forwarderAddress == address(0)) revert CrossChainTrident_InvalidKeeperAddress(_forwarderAddress);
        if(_isAllowed > ONE) revert CrossChainTrident_ZeroOneOption(_isAllowed);

        s_allowedKeeperForwarders[_forwarderAddress] = _isAllowed;

        emit CrossChainTrident_NewForwarderAllowd(_forwarderAddress);
    }

    function manageMainContract(address _mainContract) external payable onlyOwner{
        if(_mainContract == address(0)) revert CrossChainTrident_InvalidAddress(_mainContract);

        address previousReceiver = s_mainContractAddress;
        
        s_mainContractAddress = _mainContract;

        emit CrossChainTrident_ReceiverUpdated(previousReceiver, _mainContract);
    }

    /**
        * @notice Sends data to receiver on the destination chain.
        * @dev Assumes your contract has sufficient LINK.
        * @param _text The string text to be sent.
        * @param _token The address of token to be sent
        * @param _amount The token amount
        * @return messageId The ID of the message that was sent.
    */
    //@Test
    function sendMessage(string calldata _text, address _token, uint256 _amount) external payable onlyOwner returns (bytes32 messageId) {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);

        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });

        tokenAmounts[0] = tokenAmount;

        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(s_mainContractAddress),
            data: abi.encode(_text),
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 350_000})
            ),
            feeToken: address(i_linkToken)
        });

        uint256 fees = i_router.getFee(i_destinationChainSelector, evm2AnyMessage);

        emit CrossChainTrident_MessageSent(messageId, i_destinationChainSelector, s_mainContractAddress, _text, _token, _amount, address(i_linkToken), fees);

        if (fees > i_linkToken.balanceOf(address(this))) revert CrossChainTrident_NotEnoughLinkBalance(i_linkToken.balanceOf(address(this)), fees);

        i_linkToken.approve(address(i_router), fees);

        messageId = i_router.ccipSend(i_destinationChainSelector, evm2AnyMessage);

        return messageId;
    }

    //////////////////////////
    /// EXTERNAL FUNCTIONS ///
    //////////////////////////
    //https://docs.chain.link/chainlink-automation/guides/log-trigger
    function checkLog(Log calldata log, bytes memory) external returns (bool upkeepNeeded, bytes memory performData){
        if(s_allowedKeeperForwarders[msg.sender] != ONE) revert CrossChainTrident_InvalidCaller(msg.sender);//@Test
        if(s_mainContractAddress != log.source) revert CrossChainTrident_InvalidLogEmissor(log.source);
        
        uint256 gameId = uint256(log.topics[1]);
        uint256 startingDate = uint256(log.topics[2]);
        uint256 price = uint256(log.topics[3]);

        performData = abi.encode(gameId, startingDate, price);
        upkeepNeeded = true;

        emit CrossChainTrident_AutomationTrigger(gameId, startingDate, price);
    }

    //perform precisa escrever os dados recebidos do evento em um storage.
    //https://docs.chain.link/chainlink-automation/reference/automation-interfaces#ilogautomation
    function performUpkeep(bytes calldata performData) external{
        if(s_allowedKeeperForwarders[msg.sender] != ONE) revert CrossChainTrident_InvalidCaller(msg.sender);//@Test

        uint256 gameId;
        uint256 startingDate;
        uint256 price;

        (gameId, startingDate, price) = abi.decode(performData, (uint256, uint256, uint256));

        s_gamesInfo[gameId] = GameInfos({
            startingDate: startingDate,
            price: price
        });

        emit CrossChainTrident_NewGameAvailable(gameId, startingDate, price);
    }

    /**
        * @notice Function for users to buy games
        * @param _gameId game identifier
        * @param _chosenToken token used to pay for the game
        *@dev _gameSymbol param it's an easier explanation option.
    */
    function buyGame(uint256 _gameId, ERC20 _chosenToken, address _gameReceiver) external {
        //CHECKS
        if(s_tokenAllowed[_chosenToken] != ONE) revert CrossChainTrident_TokenNotAllowed(_chosenToken);
        
        GameInfos memory game = s_gamesInfo[_gameId];

        if(block.timestamp < game.startingDate) revert CrossChainTrident_GameNotAvailableYet(block.timestamp, game.startingDate);

        if(_chosenToken.balanceOf(msg.sender) < game.price ) revert CrossChainTrident_NotEnoughBalance(game.price);

        address buyer = msg.sender;

        _handleExternalCall(buyer, _gameId, game.price, _gameReceiver, _chosenToken);
    }

    /////////////
    ///PRIVATE///
    /////////////
    function _handleExternalCall(address _buyer, 
                                 uint256 _gameId,
                                 uint256 _value,
                                 address _gameReceiver,
                                 ERC20 _chosenToken) private {

        //EFFECTS
        ClientRecord memory newGame = ClientRecord({
            gameId: _gameId,
            buyingDate: block.timestamp,
            paidValue: _value
        });

        s_clientRecords[_gameReceiver].push(newGame);

        emit CrossChainTrident_NewGameSold(_gameId, _buyer, block.timestamp, _gameReceiver, _value);

        //INTERACTIONS
        _chosenToken.safeTransferFrom(msg.sender, address(this), _value);
    }

    /////////////////
    ///VIEW & PURE///
    /////////////////
    function getAllowedForwarder(address _forwarderAddress) external view returns(uint256){
        return s_allowedKeeperForwarders[_forwarderAddress];
    }

    function getMainContractAddress() external view returns(address){
        return s_mainContractAddress;
    }

    //@Test
    function getClientRecords(address _client) external view returns(ClientRecord[] memory){
        return s_clientRecords[_client];
    }

    function getAllowedTokens(ERC20 _tokenAddress) external view returns(uint256){
        return s_tokenAllowed[_tokenAddress];
    }
}
