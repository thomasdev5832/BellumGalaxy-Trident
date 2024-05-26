// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

//////////////
/// ERRORS ///
//////////////
///@notice emitted when a invalid param is passed to constructor
error CrossChainTrident_InvalidDeployParameters(address owner, IRouterClient router, LinkTokenInterface link, uint64 destinationChainSelector);
///@notice emitted when a contract is initialized with an address(0) param
error CrossChainTrident_InvalidAddress(address owner);
///@notice emitted when the keeper forwarder address is invalid
error CrossChainTrident_InvalidKeeperAddress(address forwarderAddress);
///@notice emitted when an invalid game is selected
error CrossChainTrident_NonExistantGame(address invalidAddress);
///@notice emitted when publisher input wrong address value
error CrossChainTrident_InvalidTokenAddress(IERC20 tokenAddress);
///@notice emitter when a not allowed caller calls checkUpkeep function
error CrossChainTrident_InvalidCaller(address caller);
///@notice emitted when owner input an invalid sender address
error CrossChainTrident_InvalidSender(address sender);
///@notice emitted when the contract receives an log from a invalid sender
error CrossChainTrident_InvalidLogEmissor(address senderAddress);
///@notice emitted when owner input an invalid sourceChain id
error CrossChainTrident_InvalidSouceChain(uint64 sourceChainSelector);
///@notice emitted when a user tries to use a token that is not allowed
error CrossChainTrident_TokenNotAllowed(IERC20 choosenToken);
///@notice emitted when the selling period is not open yet
error CrossChainTrident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
///@notice emitted when an user don't have enough balance
error CrossChainTrident_NotEnoughBalance(uint256 gamePrice);
///@notice emitted when the contract doesn't have enough balance
error CrossChainTrident_NotEnoughLinkBalance(uint256 currentBalance, uint256 calculatedFees);
///@notice emitted when ccip receives a message from a chain that is not allowed
error CrossChainTrident_SourceChainNotAllowed(uint64 sourceChainSelector);
///@notice emitted when ccip receives a message from a not allowed sender
error CrossChainTrident_SenderNotAllowed(address sender);

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
contract CrossChainTrident is CCIPReceiver, Ownable{
    using SafeERC20 for IERC20;
    
    ////////////////////
    /// CUSTOM TYPES ///
    ////////////////////
    ///@notice Struct to track info about games to be released
    struct GameInfos {
        uint256 startingDate;
        uint256 price;
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
    mapping(IERC20 tokenAddress => uint256 allowed) private s_tokenAllowed;
    ///@notice Mapping to keep track of game's info
    mapping(uint256 gameId => GameInfos) private s_gamesInfo;
    ///@notice Mapping to keep track of allowlisted source chains. ~ 0 = not allowed | 1 = allowed
    mapping(uint64 chainID=> uint256 allowed) private s_allowlistedSourceChains;
    ///@notice Mapping to keep track of allowlisted senders. ~ 0 = not allowed | 1 = allowed
    mapping(address sender => uint256 allowed) private s_allowlistedSenders;

    //////////////
    /// EVENTS ///
    //////////////
    ///@notice event emitted when a token is updated or added
    event CrossChainTrident_AllowedTokensUpdated(IERC20 tokenAddress, uint256 isAllowed);
    ///@notice event emitted when a forwarded is updated or added
    event CrossChainTrident_NewForwarderAllowd(address forwarderAddress);
    ///@notice event emitted when a source chain is updated
    event CrossChainTrident_SourceChainUpdated(uint64 sourceChainSelector, uint256 allowed);
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
    event CrossChainTrident_MessageSent(bytes32 messageId, uint64 destinationChainSelector, address receiver, IERC20 token, uint256 tokenAmount, address feeToken, uint256 fees);
    ///@notice event emitted when a game is buyed and a CCIP message is sent
    event CrossChainTrident_UserMessageSent(bytes32 messageId, uint64 destinationChainSelector, address receiver, bytes text, address feeToken, uint256 fees);
    ///@notice event emitted when a CCIP message is received
    event CrossChainTrident_MessageReceived(bytes32 messageId, uint64 sourceChainSelector, address sender);
    
    /**
     * @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
     * @param _sourceChainSelector The selector of the destination chain.
     * @param _sender The address of the sender.
     */
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (s_allowlistedSourceChains[_sourceChainSelector] != 1)
            revert CrossChainTrident_SourceChainNotAllowed(_sourceChainSelector);
        if (s_allowlistedSenders[_sender]  != 1 ) revert CrossChainTrident_SenderNotAllowed(_sender);
        _;
    }
    constructor(address _owner, IRouterClient _router, LinkTokenInterface _link, uint64 _destinationChainSelector) CCIPReceiver(address(_router)) Ownable(_owner){
        i_router = _router;
        i_linkToken = _link;
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
    function manageAllowedTokens(IERC20 _tokenAddress, uint256 _isAllowed) external payable onlyOwner {
        if(address(_tokenAddress) == address(0)) revert CrossChainTrident_InvalidTokenAddress(_tokenAddress);

        s_tokenAllowed[_tokenAddress] = _isAllowed;

        emit CrossChainTrident_AllowedTokensUpdated(_tokenAddress, _isAllowed);
    }

    function manageMainContract(address _mainContract) external payable onlyOwner{
        if(_mainContract == address(0)) revert CrossChainTrident_InvalidAddress(_mainContract);

        address previousReceiver = s_mainContractAddress;
        
        s_mainContractAddress = _mainContract;

        emit CrossChainTrident_ReceiverUpdated(previousReceiver, _mainContract);
    }

    function manageAllowlistSourceChain(uint64 _sourceChainSelector, uint256 _isAllowed) external payable onlyOwner {
        if(_sourceChainSelector < ONE) revert CrossChainTrident_InvalidSouceChain(_sourceChainSelector);

        s_allowlistedSourceChains[_sourceChainSelector] = _isAllowed;

        emit CrossChainTrident_SourceChainUpdated(_sourceChainSelector, _isAllowed);
    }

    /**
        * @dev Updates the allowlist status of a sender for transactions.
        * @notice This function can only be called by the owner.
        * @param _sender The address of the sender to be updated.
        * @param _isAllowed The allowlist status to be set for the sender.
    */
    function manageAllowlistSender(address _sender, uint256 _isAllowed) external payable onlyOwner {
        if(_sender == address(0)) revert CrossChainTrident_InvalidSender(_sender);

        s_allowlistedSenders[_sender] = _isAllowed;

        emit CrossChainTrident_AllowedSenderUpdated(_sender, _isAllowed);
    }

    /**
        * @notice Sends data to receiver on the destination chain.
        * @dev Assumes your contract has sufficient LINK.
        * @param _token The address of token to be sent
        * @param _amount The token amount
        * @return messageId The ID of the message that was sent.
    */
    function sendAdminMessage(IERC20 _token, uint256 _amount) external payable onlyOwner returns (bytes32 messageId) {
        messageId = _sendMessage("", _token, _amount *10**18);
    }

    //////////////////////////
    /// EXTERNAL FUNCTIONS ///
    //////////////////////////
    /**
        * @notice Function for users to buy games
        * @param _gameId game identifier
        * @param _chosenToken token used to pay for the game
        *@dev _gameSymbol param it's an easier explanation option.
    */
    function buyGame(uint256 _gameId, IERC20 _chosenToken, address _gameReceiver) external {
        //CHECKS
        if(s_tokenAllowed[_chosenToken] != ONE) revert CrossChainTrident_TokenNotAllowed(_chosenToken);//@Test
        
        GameInfos memory game = s_gamesInfo[_gameId];

        if(block.timestamp < game.startingDate) revert CrossChainTrident_GameNotAvailableYet(block.timestamp, game.startingDate);//@Test

        if(_chosenToken.balanceOf(msg.sender) < game.price ) revert CrossChainTrident_NotEnoughBalance(game.price);//@Test

        address buyer = msg.sender;

        _handleExternalCall(buyer, _gameId, game.price, _gameReceiver, _chosenToken);
    }

    /////////////
    ///PRIVATE///
    /////////////
    function _handleExternalCall(address _buyer, 
                                 uint256 _gameId,
                                 uint256 _price,
                                 address _gameReceiver,
                                 IERC20 _chosenToken) private {

        uint256 buyingTime = block.timestamp;

        emit CrossChainTrident_NewGameSold(_gameId, _buyer, buyingTime, _gameReceiver, _price);

        bytes memory data = abi.encode(_gameId, buyingTime, _price, _gameReceiver);

        //INTERACTIONS
        _sendMessage(data, _chosenToken, 0);
        _chosenToken.safeTransferFrom(msg.sender, address(this), _price);
    }

    function _sendMessage(bytes memory _text, IERC20 _token, uint256 _amount) private returns(bytes32 messageId) {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);

        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: address(_token),
            amount: _amount
        });

        tokenAmounts[0] = tokenAmount;

        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(s_mainContractAddress),
            data: _text,
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 500_000})
            ),
            feeToken: address(i_linkToken)
        });

        uint256 fees = i_router.getFee(i_destinationChainSelector, evm2AnyMessage);


        if (fees > i_linkToken.balanceOf(address(this))) revert CrossChainTrident_NotEnoughLinkBalance(i_linkToken.balanceOf(address(this)), fees);

        i_linkToken.approve(address(i_router), fees);
        _token.approve(address(i_router), _amount);

        messageId = i_router.ccipSend(i_destinationChainSelector, evm2AnyMessage);

        emit CrossChainTrident_MessageSent(messageId, i_destinationChainSelector, s_mainContractAddress, _token, _amount, address(i_linkToken), fees);
        
        return messageId;
    }

    //////////////
    ///INTERNAL///
    //////////////
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override onlyAllowlisted(any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address))){

        (uint256 gameId, uint256 sellingDate, uint256 price) = abi.decode(any2EvmMessage.data, (uint256, uint256, uint256));

        s_gamesInfo[gameId] = GameInfos({
            startingDate: sellingDate,
            price: price
        });
        
        emit CrossChainTrident_MessageReceived(any2EvmMessage.messageId, any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address)));
    }

    /////////////////
    ///VIEW & PURE///
    /////////////////
    function getMainContractAddress() external view returns(address){
        return s_mainContractAddress;
    }

    function getAllowedTokens(IERC20 _tokenAddress) external view returns(uint256){
        return s_tokenAllowed[_tokenAddress];
    }

    function getGamesInfo(uint256 _gameId) external view returns(GameInfos memory info){
        info = s_gamesInfo[_gameId];
    }
}
