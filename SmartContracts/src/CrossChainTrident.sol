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
///@notice emitted when a contract is initialized with an address(0) param
error CrossChainTrident_InvalidAddress(address owner);
///@notice emitted when publisher input wrong address value
error CrossChainTrident_InvalidTokenAddress(IERC20 tokenAddress);
///@notice emitted when owner input an invalid sender address
error CrossChainTrident_InvalidSender(address sender);
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
///@notice emitted when the owner enters an invalid sourceChainSelector or sender
error CrossChainTrident_SourceChainOrSenderNotAllowed(uint64 sourceChainSelector, address sender);

///////////////
///INTERFACE///
///////////////

/**
    *@author Barba - Bellum Galaxy Hackathon Division
    *@title Trident Project
    *@dev This is a Hackathon Project, this codebase didn't go through a cautious analysis or audit
    *@dev do not use in production
    *@custom:contact www.bellumgalaxy.com - https://linktr.ee/bellumgalaxy
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
    ///@notice Mapping to keep track of allowlisted source chains & senders. ~ 0 = not allowed | 1 = allowed
    mapping(uint64 chainID => mapping(address sender => uint256 allowed)) public s_allowlistedSourceChainsAndSenders;

    //////////////
    /// EVENTS ///
    //////////////
    ///@notice event emitted when a token is updated or added
    event CrossChainTrident_AllowedTokensUpdated(IERC20 tokenAddress, uint256 isAllowed);
    ///@notice event emitted when a source chain is updated
    event CrossChainTrident_SourceChainUpdated(uint64 sourceChainSelector, address sender, uint256 allowed);
    ///@notice event emitted when a CCIP receiver is updated
    event CrossChainTrident_ReceiverUpdated(address previousReceiver, address newReceiver);
    ///@notice event emitted when a new copy is sold.
    event CrossChainTrident_NewGameSold(uint256 gameId, address payer, uint256 date, address gameReceiver, uint256 value);
    ///@notice event emitted when a CCIP message is sent
    event CrossChainTrident_MessageSent(bytes32 messageId, uint64 destinationChainSelector, address receiver, IERC20 token, uint256 tokenAmount, address feeToken, uint256 fees);
    ///@notice event emitted when a CCIP message is received
    event CrossChainTrident_MessageReceived(bytes32 messageId, uint64 sourceChainSelector, address sender, uint256 gameId, uint256 price);
    
    /**
     * @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
     * @param _sourceChainSelector The selector of the destination chain.
     * @param _sender The address of the sender.
     */
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (s_allowlistedSourceChainsAndSenders[_sourceChainSelector][_sender] != ONE) revert CrossChainTrident_SourceChainOrSenderNotAllowed(_sourceChainSelector, _sender);
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

    /**
     * @notice Function to update the main contract address
     * @param _mainContract the address of the new contract.
     */
    function manageMainContract(address _mainContract) external payable onlyOwner{
        if(_mainContract == address(0)) revert CrossChainTrident_InvalidAddress(_mainContract);

        address previousReceiver = s_mainContractAddress;
        
        s_mainContractAddress = _mainContract;

        emit CrossChainTrident_ReceiverUpdated(previousReceiver, _mainContract);
    }

    /**
        * @dev Updates the allowlist status of a source chain
        * @notice This function can only be called by the owner.
        * @param _sourceChainSelector The selector of the source chain to be updated.
        * @param _isAllowed The allowlist status to be set for the source chain.
        * @dev 1 == allowed. Any other value == Not.
    */
    function manageCCIPAllowlist(uint64 _sourceChainSelector, address _sender, uint256 _isAllowed) external payable onlyOwner {
        if(_sourceChainSelector < ONE) revert CrossChainTrident_InvalidSouceChain(_sourceChainSelector);
        if(_sender == address(0)) revert CrossChainTrident_InvalidSender(_sender);

        s_allowlistedSourceChainsAndSenders[_sourceChainSelector][_sender] = _isAllowed;

        emit CrossChainTrident_SourceChainUpdated(_sourceChainSelector, _sender, _isAllowed);
    }

    /**
        * @notice Sends data to receiver on the destination chain.
        * @dev Assumes your contract has sufficient LINK.
        * @param _token The address of token to be sent
        * @param _amount The token amount
        * @return messageId The ID of the message that was sent.
        * @dev decimals here are 6 because of USDC.
    */
    function sendAdminMessage(IERC20 _token, uint256 _amount) external payable onlyOwner returns (bytes32 messageId) {
        messageId = _sendMessage("", _token, _amount *10**6);
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
        if(s_tokenAllowed[_chosenToken] != ONE) revert CrossChainTrident_TokenNotAllowed(_chosenToken);
        
        GameInfos memory game = s_gamesInfo[_gameId];

        if(block.timestamp < game.startingDate || game.startingDate == 0 ) revert CrossChainTrident_GameNotAvailableYet(block.timestamp, game.startingDate);

        if(_chosenToken.balanceOf(msg.sender) < game.price ) revert CrossChainTrident_NotEnoughBalance(game.price);

        address buyer = msg.sender;

        _handleExternalCall(buyer, _gameId, game.price, _gameReceiver, _chosenToken);
    }

    /////////////
    ///PRIVATE///
    /////////////
    /**
     * @notice function to deal with storage update and external call's
     * @param _buyer the user that is buying
     * @param _gameId the ID of the buyed game
     * @param _price game price
     * @param _gameReceiver the address that will receive the game
     * @param _chosenToken the token to pay.
     */
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

    /**
     * @notice CCIP function to send tokens and messages cross-chain
     * @param _text the data to sent through CCIP
     * @param _token the address of the token
     * @param _amount the amount of the token
     */
    function _sendMessage(bytes memory _text, IERC20 _token, uint256 _amount) private returns(bytes32 messageId) {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        
        Client.EVM2AnyMessage memory evm2AnyMessage;

        if(_amount > 0){

            Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
                token: address(_token),
                amount: _amount
            });

            tokenAmounts[0] = tokenAmount;

            evm2AnyMessage = Client.EVM2AnyMessage({
                receiver: abi.encode(s_mainContractAddress),
                data: _text,
                tokenAmounts: tokenAmounts,
                extraArgs: Client._argsToBytes(
                    Client.EVMExtraArgsV1({gasLimit: 500_000})
                ),
                feeToken: address(i_linkToken)
            });
        } else {
            evm2AnyMessage = Client.EVM2AnyMessage({
                receiver: abi.encode(s_mainContractAddress),
                data: _text,
                tokenAmounts: new Client.EVMTokenAmount[](0),
                extraArgs: Client._argsToBytes(
                    Client.EVMExtraArgsV1({gasLimit: 750_000})
                ),
                feeToken: address(i_linkToken)
            });
        }

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
    /**
     * @notice CCIP function to receive Cross-chain tokens and messages
     * @param any2EvmMessage the CCIP messaging struct data
     * @dev this function can only be called by allowed senders and chains.
     */
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override onlyAllowlisted(any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address))){

        (uint256 gameId, uint256 sellingDate, uint256 price) = abi.decode(any2EvmMessage.data, (uint256, uint256, uint256));

        s_gamesInfo[gameId] = GameInfos({
            startingDate: sellingDate,
            price: price
        });
        
        emit CrossChainTrident_MessageReceived(any2EvmMessage.messageId, any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address)), gameId, price);
    }

    /////////////////
    ///VIEW & PURE///
    /////////////////

    function getGamesInfo(uint256 _gameId) external view returns(GameInfos memory info){
        info = s_gamesInfo[_gameId];
    }
}
