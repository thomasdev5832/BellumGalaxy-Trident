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
///@notice emitted when the keeper forwarder address is invalid
error Trident_InvalidKeeperAddress(address forwarderAddress);
///@notice emitted when publisher input a wrong value
error Trident_ZeroOneOption(uint256 isAllowed);
///@notice emitted when owner input an invalid sourceChain id
error Trident_InvalidSouceChain(uint64 sourceChainSelector);
///@notice emitted when owner input an invalid sender address
error Trident_InvalidSender(address sender);
///@notice emitted when a contract is initialized with an address(0) param
error Trident_InvalidAddress(address owner, TridentFunctions functions);
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
///@notice emitted when the contract receives an log from a invalid sender
error Trident_InvalidLogEmissor(address senderAddress);
///@notice emitted when publisher input wrong address value
error Trident_InvalidTokenAddress(ERC20 tokenAddress);
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
        string gameSymbol;
        string gameName;
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
        string gameName;
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
    uint256 private s_gameIdCounter;
    uint256 private s_ccipCounter;

    ///@notice Mapping to keep track of allowed stablecoins. ~ 0 = not allowed | 1 = allowed
    mapping(ERC20 tokenAddress => uint256 allowed) private s_tokenAllowed;
    ///@notice Mapping to keep track of allowed forwarders. ~ 0 = not allowed | 1 = allowed
    mapping(address keeperForwarder => uint256 allowed) private s_allowedKeeperRelayers;
    ///@notice Mapping to keep track of future launched games
    mapping(uint256 gameIdCounter => GameRelease) private s_gamesCreated;
    ///@notice Mapping to keep track of game's info
    mapping(uint256 gameIdCounter => GameInfos) private s_gamesInfo;
    ///@notice Mapping to keep track of games an user has
    mapping(address client => ClientRecord[]) private s_clientRecords;
    ///@notice Mapping to keep track of CCIP transactions
    mapping(uint256 ccipCounter => CCIPInfos) private s_ccipMessages;
    ///@notice Mapping to keep track of allowlisted source chains. ~ 0 = not allowed | 1 = allowed
    mapping(uint64 chainID=> uint256 allowed) private s_allowlistedSourceChains;
    ///@notice Mapping to keep track of allowlisted senders. ~ 0 = not allowed | 1 = allowed
    mapping(address sender => uint256 allowed) private s_allowlistedSenders;

    //////////////
    /// EVENTS ///
    //////////////
    ///@notice event emitted when a token is updated or added
    event Trident_AllowedTokensUpdated(string tokenName, string tokenSymbol, ERC20 tokenAddress, uint256 isAllowed);
    ///@notice event emitted when a forwarded is updated or added
    event Trident_NewRelayerAllowed(address relayerAddress, uint256 isAllowed);
    ///@notice event emitted when a source chain is updated
    event Trident_SourceChainUpdated(uint64 sourceChainSelector, uint256 allowed);
    ///@notice event emitted when a sender is updated
    event Trident_AllowedSenderUpdated(address sender, uint256 allowed);
    ///@notice event emitted when a new game nft is created
    event Trident_NewGameCreated(uint256 gameId, string tokenSymbol, string gameName, TridentNFT trident);
    ///@notice event emitted when infos about a new game is released
    event Trident_ReleaseConditionsSet(uint256 gameId, uint256 startingDate, uint256 price);
    ///@notice event emitted when a new copy is sold.
    event Trident_NewGameSold(uint256 gameId, string gameName, address payer, uint256 date, address gameReceiver);
    ///@notice event emitted when a Cross-chain transaction occur
    event Trident_CrossChainBuyingPerformed(uint256 gameId, uint256 transactionTime, uint256 price);
    ///@notice event emitted when a CCIP message is received
    event TridentCCReceiver_MessageReceived(bytes32 messageId, uint64 sourceChainSelector, address sender, string text);

    ///////////////
    ///MODIFIERS///
    ///////////////
    /// @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
    /// @param _sourceChainSelector The selector of the destination chain.
    /// @param _sender The address of the sender.
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (s_allowlistedSourceChains[_sourceChainSelector] != 1)
            revert Trident_SourceChainNotAllowed(_sourceChainSelector);
        if (s_allowlistedSenders[_sender]  != 1 ) revert Trident_SenderNotAllowed(_sender);
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
        *@notice Function to add the Chainlink Relayer Automation Contract
        *@param _relayer the address of the relayer
        *@param _isAllowed 0 = Not Allowed | 1 = Allowed
        *@dev any value above 1 will be considerate invalid.
        *@dev it's payable to save gas.
    */
    function manageAllowedRelayers(address _relayer, uint256 _isAllowed) external payable onlyOwner{
        if(_relayer == address(0)) revert Trident_InvalidKeeperAddress(_relayer);
        if(_isAllowed > ONE) revert Trident_ZeroOneOption(_isAllowed);

        s_allowedKeeperRelayers[_relayer] = _isAllowed;

        emit Trident_NewRelayerAllowed(_relayer, _isAllowed);
    }

    /**
        * @dev Updates the allowlist status of a source chain
        * @notice This function can only be called by the owner.
        * @param _sourceChainSelector The selector of the source chain to be updated.
        * @param _isAllowed The allowlist status to be set for the source chain.
    */
    function manageAllowlistSourceChain(uint64 _sourceChainSelector, uint256 _isAllowed) external payable onlyOwner {
        if(_sourceChainSelector < ONE) revert Trident_InvalidSouceChain(_sourceChainSelector);
        if(_isAllowed > ONE) revert Trident_ZeroOneOption(_isAllowed);

        s_allowlistedSourceChains[_sourceChainSelector] = _isAllowed;

        emit Trident_SourceChainUpdated(_sourceChainSelector, _isAllowed);
    }

    /**
        * @dev Updates the allowlist status of a sender for transactions.
        * @notice This function can only be called by the owner.
        * @param _sender The address of the sender to be updated.
        * @param _isAllowed The allowlist status to be set for the sender.
    */
    function manageAllowlistSender(address _sender, uint256 _isAllowed) external payable onlyOwner {
        if(_sender == address(0)) revert Trident_InvalidSender(_sender);
        if(_isAllowed > ONE) revert Trident_ZeroOneOption(_isAllowed);

        s_allowlistedSenders[_sender] = _isAllowed;

        emit Trident_AllowedSenderUpdated(_sender, _isAllowed);
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

    /**
        *@notice Function for Publisher to create a new game NFT
        *@param _gameSymbol game's identifier
        *@param _gameName game's name
        *@dev we deploy a new NFT key everytime a game is created.
    */
    function createNewGame(string memory _gameSymbol, string memory _gameName) external onlyOwner {
        // CHECKS
        if(address(s_gamesCreated[s_gameIdCounter].keyAddress) != address(0)) revert Trident_GameAlreadyReleased(s_gamesCreated[s_gameIdCounter].keyAddress);//@Test

        s_gamesCreated[++s_gameIdCounter] = GameRelease({
            gameSymbol:_gameSymbol,
            gameName: _gameName,
            keyAddress: new TridentNFT(_gameName, _gameSymbol, address(this))
        });

        emit Trident_NewGameCreated(s_gameIdCounter, _gameSymbol, _gameName, s_gamesCreated[s_gameIdCounter].keyAddress);
    }

    /**
        *@notice Function to set game release conditions
        *@param _gameId game identifier
        *@param _startingDate start selling date
        *@param _price game starting price
    */
    function setReleaseConditions(uint256 _gameId, uint256 _startingDate, uint256 _price) external onlyOwner {
        GameRelease memory release = s_gamesCreated[_gameId];
        //CHECKS
        if(address(release.keyAddress) == address(0)) revert Trident_NonExistantGame(address(0));//@Test
        
        if(_startingDate < block.timestamp) revert Trident_SetAValidSellingPeriod(_startingDate, block.timestamp);//@Test
        //value check is needed

        //EFFECTS
        s_gamesInfo[_gameId] = GameInfos({
            sellingDate: _startingDate,
            price: _price * DECIMALS,
            copiesSold: 0
        });

        emit Trident_ReleaseConditionsSet(_gameId, _startingDate, _price);
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
    function buyGame(uint256 _gameId, ERC20 _chosenToken, address _gameReceiver) external {
        //CHECKS
        if(s_tokenAllowed[_chosenToken] != ONE) revert Trident_TokenNotAllowed(_chosenToken);
        
        GameInfos memory game = s_gamesInfo[_gameId];
        GameRelease memory gameNft = s_gamesCreated[_gameId];

        if(block.timestamp < game.sellingDate) revert Trident_GameNotAvailableYet(block.timestamp, game.sellingDate);

        if(_chosenToken.balanceOf(msg.sender) < game.price ) revert Trident_NotEnoughBalance(game.price);

        address buyer = msg.sender;

        _handleExternalCall(_gameId, gameNft.keyAddress, block.timestamp, game.price, buyer, _gameReceiver, _chosenToken);
    }

    //https://docs.chain.link/chainlink-automation/guides/log-trigger
    //@Test
    function checkLog(Log calldata log, bytes memory) external view returns (bool upkeepNeeded, bytes memory performData){
        if(s_allowedKeeperRelayers[msg.sender] != ONE) revert Trident_InvalidCaller(msg.sender); //@Test
        if(s_allowlistedSenders[log.source] != ONE) revert Trident_InvalidLogEmissor(log.source); //@Test

        uint256 gameId = uint256(log.topics[1]);
        address buyer = address(uint160(uint256(log.topics[2])));
        uint256 transactionTime = uint256(log.topics[3]);
        address gameReceiver = address(uint160(uint256(log.topics[4])));

        //emit CrossChainTrident_NewGameSold(_gameId, _buyer, block.timestamp, _gameReceiver, _value);
        performData = abi.encode(gameId, buyer, transactionTime, gameReceiver);
        upkeepNeeded = true;//@Test
    }

    //perform precisa escrever os dados recebidos do evento em um storage.
    //https://docs.chain.link/chainlink-automation/reference/automation-interfaces#ilogautomation
    function performUpkeep(bytes calldata performData) external {//@Test
        if(s_allowedKeeperRelayers[msg.sender] != ONE) revert Trident_InvalidCaller(msg.sender);

        uint256 gameId;
        address buyer;
        uint256 transactionTime;
        address gameReceiver;
        uint256 price;

        (gameId, buyer, transactionTime, gameReceiver, price) = abi.decode(performData, (uint256, address, uint256, address, uint256));//@Test

        emit Trident_CrossChainBuyingPerformed(gameId, transactionTime, price);//@Test

        // i_functions.sendRequest(); //@AJUSTE Quais infos mando para o banco? Wallet Address / NFT Game Address / 
        s_gamesCreated[gameId].keyAddress.safeMint(gameReceiver, "");//@Test
    }

    //////////////
    ///INTERNAL///
    //////////////
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override onlyAllowlisted(any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address))){//@Test

        s_ccipMessages[s_ccipCounter] = CCIPInfos({//@Test
            lastReceivedMessageId: any2EvmMessage.messageId,
            sourceChainSelector: any2EvmMessage.sourceChainSelector,
            lastReceivedText: abi.decode(any2EvmMessage.data, (string)),
            lastReceivedTokenAddress: any2EvmMessage.destTokenAmounts[0].token,
            lastReceivedAmount: any2EvmMessage.destTokenAmounts[0].amount
        });

        emit TridentCCReceiver_MessageReceived(any2EvmMessage.messageId, any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address)),  abi.decode(any2EvmMessage.data, (string)));//@Test
    }

    /////////////
    ///PRIVATE///
    /////////////
    function _handleExternalCall(uint256 _gameId,
                                 TridentNFT _keyAddress,
                                 uint256 _buyingDate,
                                 uint256 _value,
                                 address _buyer,
                                 address _gameReceiver,
                                 ERC20 _chosenToken) private {

        GameRelease memory gameNft = s_gamesCreated[_gameId];

        //EFFECTS
        ClientRecord memory newGame = ClientRecord({
            gameName: gameNft.gameName,
            game: _keyAddress,
            buyingDate: _buyingDate,
            paidValue: _value
        });

        s_clientRecords[_gameReceiver].push(newGame);

        emit Trident_NewGameSold(_gameId, gameNft.gameName, _buyer, _buyingDate, _gameReceiver);

        //INTERACTIONS
        // i_functions.sendRequest(); //@AJUSTE Quais infos mando para o banco? Wallet Address / NFT Game Address / 
        gameNft.keyAddress.safeMint(_gameReceiver, "");
        _chosenToken.safeTransferFrom(_buyer, address(this), _value);
    }

    /////////////////
    ///VIEW & PURE///
    /////////////////
    function getAllowedRelayers(address _relayer) external view returns(uint256){
        return s_allowedKeeperRelayers[_relayer];
    }

    function getAllowedSourceChains(uint64 _chainId) external view returns(uint256){
        return s_allowlistedSourceChains[_chainId];
    }

    function getAllowedSenders(address _sender) external view returns(uint256){
        return s_allowlistedSenders[_sender];
    }

    function getGamesCreated(uint256 _gameId) external view returns(GameRelease memory){
        return s_gamesCreated[_gameId];//@Test
    }

    function getGamesInfo(uint256 _gameId) external view returns(GameInfos memory){
        return s_gamesInfo[_gameId];//@Test
    }

    function getClientRecords(address _client) external view returns(ClientRecord[] memory){
        return s_clientRecords[_client];//@Test
    }

    function getAllowedTokens(ERC20 _tokenAddress) external view returns(uint256){
        return s_tokenAllowed[_tokenAddress];
    }

    function getLastReceivedMessageDetails(uint256 _messageId) external view returns (CCIPInfos memory){
        return s_ccipMessages[_messageId];
    }
}
