// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ILogAutomation, Log } from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

import {TridentNFT} from "./TridentNFT.sol";
import {TridentFunctions} from "./TridentFunctions.sol";

//////////////
/// ERRORS ///
//////////////
///@notice emitted when a contract is initialized with an address(0) param
error Trident_InvalidAddress(address owner, TridentFunctions functions);
///@notice emitted when the keeper forwarder address is invalid
error Trident_InvalidKeeperAddress(address forwarderAddress);
///@notice emitted when publisher tries to deploy duplicate game
error Trident_GameAlreadyReleased(TridentNFT trident);
///@notice emitted when the selling period is invalid
error Trident_SetAValidSellingPeriod(uint256 startingDate, uint256 dateNow);
///@notice emitted when an invalid game is selected
error Trident_NonExistantGame(address invalidAddress);
///@notice emitted when an user don't have enough balance
error Trident_NotEnoughBalance(uint256 gamePrice);
///@notice emitted when the caller is not the keeper forwarder
error Trident_InvalidCaller(address caller);
///@notice emitted when publisher input wrong address value
error Trident_InvalidTokenAddress(ERC20 tokenAddress);
///@notice emitted when publisher input a wrong value
error Trident_ZeroOneOption(uint256 isAllowed);
///@notice emitted when a user tries to use a token that is not allowed
error Trident_TokenNotAllowed(ERC20 choosenToken);
///@notice emitted when the selling period is not open yet
error Trident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
///@notice emitted when ccip receives a message from a chain that is not allowed
error Trident_SourceChainNotAllowed(uint64 sourceChainSelector);
///@notice emitted when ccip receives a message from a not allowed sender
error Trident_SenderNotAllowed(address sender);

/**
    *@author Barba - Bellum Galaxy Hackathon Division
    *@title Trident Project
    *@dev This is a Hackathon Project, this codebase didn't go through a cautious analysis or audit
    *@dev do not use in production
    *contact www.bellumgalaxy.com - https://linktr.ee/bellumgalaxy
*/
contract Trident is  Ownable, ILogAutomation, CCIPReceiver{
    using SafeERC20 for ERC20;
    
    ////////////////////
    /// CUSTOM TYPES ///
    ////////////////////
    ///@notice Struct to track new games NFTs
    struct GameRelease{
        string gameName;
        string gameSymbol;
        TridentNFT keyAddress;
    }

    ///@notice Struct to track info about games to be released
    struct GameInfos {
        uint256 sellingDate;
        uint256 price;
        uint256 copiesSold;
    }

    ///@notice Struct to track buying info.
    struct ClientRecord {
        string gameSymbol;
        TridentNFT game;
        uint256 buyingDate;
        uint256 paidValue;
    }

    ///@notice Struct to track CCIPMessages
    struct CCIPInfos{
        bytes32 lastReceivedMessageId;
        uint64 sourceChainSelector;
        string lastReceivedText;
        address lastReceivedTokenAddress;
        uint256 lastReceivedAmount;
    }

    //////////////////////////////
    /// CONSTANTS & IMMUTABLES ///
    //////////////////////////////
    ///@notice magic number removal
    uint256 private constant ZERO = 0;
    ///@notice magic number removal
    uint256 private constant ONE = 1;
    ///@notice magic number removal
    uint256 private constant DECIMALS = 10**18;
    ///@notice functions constract instance
    TridentFunctions private immutable i_functions;

    ///////////////////////
    /// STATE VARIABLES ///
    ///////////////////////
    uint256 private s_ccipCounter;

    ///@notice Mapping to keep track of allowed stablecoins. ~ 0 = not allowed | 1 = allowed
    mapping(ERC20 tokenAddress => uint256 allowed) private s_tokenAllowed;
    ///@notice Mapping to keep track of allowed forwarders. ~ 0 = not allowed | 1 = allowed
    mapping(address keeperForwarder => uint256 allowed) private s_allowedKeeperForwarders;
    ///@notice Mapping to keep track of future launched games
    mapping(string gameSymbol => GameRelease) private s_gamesCreated;
    ///@notice Mapping to keep track of game's info
    mapping(string gameSymbol => GameInfos) private s_gamesInfo;
    ///@notice Mapping to keep track of games an user has
    mapping(address client => ClientRecord[]) private s_clientRecords;
    ///@notice Mapping to keep track of CCIP transactions
    mapping(uint256 ccipCounter => CCIPInfos) private s_ccipMessages;
    ///@notice Mapping to keep track of allowlisted source chains. ~ 0 = not allowed | 1 = allowed
    mapping(uint64 chainID=> uint256 allowed) private allowlistedSourceChains;
    ///@notice Mapping to keep track of allowlisted senders. ~ 0 = not allowed | 1 = allowed
    mapping(address sender => uint256 allowed) private allowlistedSenders;

    //////////////
    /// EVENTS ///
    //////////////
    ///@notice event emitted when a token is updated or added
    event Trident_AllowedTokensUpdated(string tokenName, string tokenSymbol, ERC20 tokenAddress, uint256 isAllowed);
    ///@notice event emitted when a forwarded is updated or added
    event Trident_NewForwarderAllowed(address forwarderAddress, uint256 isAllowed);
    ///@notice event emitted when a source chain is updated
    event Trident_SourceChainUpdated(uint64 sourceChainSelector, uint256 allowed);
    ///@notice event emitted when a sender is updated
    event Trident_AllowedSenderUpdated(address sender, uint256 allowed);
    ///@notice event emitted when a new game nft is created
    event Trident_NewGameCreated(string gameName, string tokenSymbol, TridentNFT trident);
    ///@notice event emitted when infos about a new game is released
    event Trident_ReleaseConditionsSet(string tokenSymbol, uint256 startingDate, uint256 price);
    ///@notice event emitted when a new copy is sold.
    event Trident_NewGameSold(string _gameSymbol, address payer, uint256 date, address gameReceiver);
    ///@notice event emitted when a Cross-chain transaction occur
    event Trident_CrossChainBuyingPerformed(string gameSymbol, uint256 transactionTime, uint256 price);
    ///@notice event emitted when a CCIP message is received
    event TridentCCReceiver_MessageReceived(bytes32 messageId, uint64 sourceChainSelector, address sender, string text);

    ///////////////
    ///MODIFIERS///
    ///////////////
    /// @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
    /// @param _sourceChainSelector The selector of the destination chain.
    /// @param _sender The address of the sender.
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (allowlistedSourceChains[_sourceChainSelector] != 1)
            revert Trident_SourceChainNotAllowed(_sourceChainSelector);
        if (allowlistedSenders[_sender]  != 1 ) revert Trident_SenderNotAllowed(_sender);
        _;
    }

    /////////////////////////////////////////////////////////////////
    /////////////////////////// FUNCTIONS ///////////////////////////
    /////////////////////////////////////////////////////////////////
    /////////////////
    ///CONSTRUCTOR///
    /////////////////
    constructor(address _owner, TridentFunctions _functionsAddress, address _router) CCIPReceiver(_router) Ownable(_owner){
        if(_owner == address(0) || address(_functionsAddress) == address(0)) revert Trident_InvalidAddress(_owner, _functionsAddress);
        i_functions = _functionsAddress;
    }

    ////////////////////////////////////
    /// EXTERNAL onlyOwner FUNCTIONS ///
    ////////////////////////////////////
    /**
        *@notice Function for Publisher to create a new game NFT
        *@param _gameSymbol game's identifier
        *@param _gameName game's name
        *@dev _gameSymbol param it's an easier explanation option.
        *@dev we deploy a new NFT key everytime a game is created.
    */
    function createNewGame(string memory _gameSymbol, string memory _gameName) external onlyOwner {
        // CHECKS
        if(address(s_gamesCreated[_gameSymbol].keyAddress) != address(0)) revert Trident_GameAlreadyReleased(s_gamesCreated[_gameSymbol].keyAddress);

        s_gamesCreated[_gameSymbol] = GameRelease({
            gameName: _gameName,
            gameSymbol:_gameSymbol,
            keyAddress: new TridentNFT(_gameName, _gameSymbol, address(this))
        });

        emit Trident_NewGameCreated(_gameName, _gameSymbol, s_gamesCreated[_gameSymbol].keyAddress);
    }

    /**
        *@notice Function to set game release conditions
        *@param _gameSymbol game identifier
        *@param _startingDate start selling date
        *@param _price game starting price
        *@dev _gameSymbol param it's an easier explanation option.
    */
    function setReleaseConditions(string memory _gameSymbol, uint256 _startingDate, uint256 _price) external onlyOwner {
        GameRelease memory release = s_gamesCreated[_gameSymbol];
        //CHECKS
        if(address(release.keyAddress) == address(0)) revert Trident_NonExistantGame(address(0));
        
        if(_startingDate < block.timestamp) revert Trident_SetAValidSellingPeriod(_startingDate, block.timestamp);
        //value check is needed

        //EFFECTS
        s_gamesInfo[_gameSymbol] = GameInfos({
            sellingDate: _startingDate,
            price: _price * DECIMALS,
            copiesSold: 0
        });

        emit Trident_ReleaseConditionsSet(_gameSymbol, _startingDate, _price);
    }

    /**
        * @notice Function to manage whitelisted tokens
        * @param _tokenAddress Address of the token
        * @param _isAllowed 0 = False / 1 True
        * @dev we opted for not deleting the token because we still need to withdraw it.
    */
    function manageAllowedTokens(ERC20 _tokenAddress, uint256 _isAllowed) external onlyOwner {
        if(address(_tokenAddress) == address(0)) revert Trident_InvalidTokenAddress(_tokenAddress);
        if(_isAllowed > ONE) revert Trident_ZeroOneOption(_isAllowed);

        s_tokenAllowed[_tokenAddress] = _isAllowed;

        emit Trident_AllowedTokensUpdated(_tokenAddress.name(), _tokenAddress.symbol(), _tokenAddress, _isAllowed);
    }

    function manageAllowedForwarders(address _forwarderAddress, uint256 _isAllowed) external payable onlyOwner{
        if(_forwarderAddress == address(0)) revert Trident_InvalidKeeperAddress(_forwarderAddress);
        if(_isAllowed > ONE) revert Trident_ZeroOneOption(_isAllowed);

        s_allowedKeeperForwarders[_forwarderAddress] = _isAllowed;

        emit Trident_NewForwarderAllowed(_forwarderAddress, _isAllowed);
    }

    /**
        * @dev Updates the allowlist status of a source chain
        * @notice This function can only be called by the owner.
        * @param _sourceChainSelector The selector of the source chain to be updated.
        * @param _isAllowed The allowlist status to be set for the source chain.
    */
    function allowlistSourceChain(uint64 _sourceChainSelector, uint256 _isAllowed) external payable onlyOwner {
        if(_isAllowed > ONE) revert Trident_ZeroOneOption(_isAllowed);

        allowlistedSourceChains[_sourceChainSelector] = _isAllowed;

        emit Trident_SourceChainUpdated(_sourceChainSelector, _isAllowed);
    }

    /**
        * @dev Updates the allowlist status of a sender for transactions.
        * @notice This function can only be called by the owner.
        * @param _sender The address of the sender to be updated.
        * @param _isAllowed The allowlist status to be set for the sender.
    */
    function allowlistSender(address _sender, uint256 _isAllowed) external payable onlyOwner {
        if(_isAllowed > ONE) revert Trident_ZeroOneOption(_isAllowed);

        allowlistedSenders[_sender] = _isAllowed;

        emit Trident_AllowedSenderUpdated(_sender, _isAllowed);
    }

    //////////////////////////
    /// EXTERNAL FUNCTIONS ///
    //////////////////////////
    /**
        * @notice Function for users to buy games
        * @param _gameSymbol game identifier
        * @param _chosenToken token used to pay for the game
        *@dev _gameSymbol param it's an easier explanation option.
    */
    function buyGame(string memory _gameSymbol, ERC20 _chosenToken, address _gameReceiver) external {
        //CHECKS
        if(s_tokenAllowed[_chosenToken] != ONE) revert Trident_TokenNotAllowed(_chosenToken);
        
        GameInfos memory game = s_gamesInfo[_gameSymbol];
        GameRelease memory gameNft = s_gamesCreated[_gameSymbol];

        if(block.timestamp < game.sellingDate) revert Trident_GameNotAvailableYet(block.timestamp, game.sellingDate);

        if(_chosenToken.balanceOf(msg.sender) < game.price ) revert Trident_NotEnoughBalance(game.price);

        address buyer = msg.sender;

        _handleExternalCall(gameNft.gameSymbol, gameNft.keyAddress, block.timestamp, game.price, buyer, _gameReceiver, _chosenToken);
    }

    //https://docs.chain.link/chainlink-automation/guides/log-trigger
    function checkLog(Log calldata log, bytes memory) external view returns (bool upkeepNeeded, bytes memory performData){
        if(s_allowedKeeperForwarders[msg.sender] != ONE) revert Trident_InvalidCaller(msg.sender);

        string memory gameSymbol = bytes32ToString(log.topics[1]);
        address buyer = address(uint160(uint256(log.topics[2])));
        uint256 transactionTime = uint256(log.topics[3]);
        address gameReceiver = address(uint160(uint256(log.topics[4])));

        performData = abi.encode(gameSymbol, buyer, transactionTime, gameReceiver);
        upkeepNeeded = true;
    }

    //perform precisa escrever os dados recebidos do evento em um storage.
    //https://docs.chain.link/chainlink-automation/reference/automation-interfaces#ilogautomation
    function performUpkeep(bytes calldata performData) external {
        if(s_allowedKeeperForwarders[msg.sender] != ONE) revert Trident_InvalidCaller(msg.sender);

        string memory gameSymbol;
        address buyer;
        uint256 transactionTime;
        address gameReceiver;
        uint256 price;

        (gameSymbol, buyer, transactionTime, gameReceiver, price) = abi.decode(performData, (string, address, uint256, address, uint256));

        emit Trident_CrossChainBuyingPerformed(gameSymbol, transactionTime, price);

        // i_functions.sendRequest(); //@AJUSTE Quais infos mando para o banco? Wallet Address / NFT Game Address / 
        s_gamesCreated[gameSymbol].keyAddress.safeMint(gameReceiver, "");
    }

    //////////////
    ///INTERNAL///
    //////////////
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override onlyAllowlisted(any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address))){

        s_ccipMessages[s_ccipCounter] = CCIPInfos({
            lastReceivedMessageId: any2EvmMessage.messageId,
            sourceChainSelector: any2EvmMessage.sourceChainSelector,
            lastReceivedText: abi.decode(any2EvmMessage.data, (string)),
            lastReceivedTokenAddress: any2EvmMessage.destTokenAmounts[0].token,
            lastReceivedAmount: any2EvmMessage.destTokenAmounts[0].amount
        });

        emit TridentCCReceiver_MessageReceived(any2EvmMessage.messageId, any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address)),  abi.decode(any2EvmMessage.data, (string)));
    }

    /////////////
    ///PRIVATE///
    /////////////
    function _handleExternalCall(string memory _gameSymbol,
                                 TridentNFT _keyAddress,
                                 uint256 _buyingDate,
                                 uint256 _value,
                                 address _buyer,
                                 address _gameReceiver,
                                 ERC20 _chosenToken) private {

        GameRelease memory gameNft = s_gamesCreated[_gameSymbol];

        //EFFECTS
        ClientRecord memory newGame = ClientRecord({
            gameSymbol: _gameSymbol,
            game: _keyAddress,
            buyingDate: _buyingDate,
            paidValue: _value
        });

        s_clientRecords[_gameReceiver].push(newGame);

        emit Trident_NewGameSold(_gameSymbol, _buyer, _buyingDate, _gameReceiver);

        //INTERACTIONS
        // i_functions.sendRequest(); //@AJUSTE Quais infos mando para o banco? Wallet Address / NFT Game Address / 
        gameNft.keyAddress.safeMint(_gameReceiver, "");
        _chosenToken.safeTransferFrom(_buyer, address(this), _value);
    }

    /////////////////
    ///VIEW & PURE///
    /////////////////
    function getGamesCreated(string memory _gameSymbol) external view returns(GameRelease memory){
        return s_gamesCreated[_gameSymbol];
    }

    function getGamesInfo(string memory _gameSymbol) external view returns(GameInfos memory){
        return s_gamesInfo[_gameSymbol];
    }

    function getClientRecords(address _client) external view returns(ClientRecord[] memory){
        return s_clientRecords[_client];
    }

    function getAllowedTokens(ERC20 _tokenAddress) external view returns(uint256){
        return s_tokenAllowed[_tokenAddress];
    }

    function getLastReceivedMessageDetails(uint256 _messageId) external view returns (CCIPInfos memory){
        return s_ccipMessages[_messageId];
    }

    //We use string just to turn it more redable in the Pitch. This functions is temporary.
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i = 0; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }

        uint256 lastIndex = 32;
        for (uint256 j = 0; j < 32; j++) {
            if (bytesArray[j] != 0) {
                lastIndex = j + 1;
            }
        }

        bytes memory trimmedBytes = new bytes(lastIndex);
        for (uint256 k = 0; k < lastIndex; k++) {
            trimmedBytes[k] = bytesArray[k];
        }

        return string(trimmedBytes);
    }
}
