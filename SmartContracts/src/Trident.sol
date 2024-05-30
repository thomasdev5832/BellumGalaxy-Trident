// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

import {TridentNFT} from "./TridentNFT.sol";
import {TridentFunctions} from "./TridentFunctions.sol";

//////////////
/// ERRORS ///
//////////////
///@notice emitted when owner input an invalid sourceChain id
error Trident_InvalidSouceChain(uint64 sourceChainSelector);
///@notice emitted when owner input an invalid chainId
error Trident_InvalidChainId(uint64 destinationChainId);
///@notice emitted when owner input an address(0) as param
error Trident_InvalidReceiver(address receiver);
///@notice emitted when publisher tries to deploy duplicate game
error Trident_InvalidGameSymbolOrName(string symbol, string name);
///@notice emitted when the selling period is invalid
error Trident_SetAValidSellingPeriod(uint256 startingDate, uint256 dateNow);
///@notice emitted when an invalid game is selected
error Trident_NonExistantGame(address invalidAddress);
///@notice emitted when owner inputs an invalid price
error Trident_InvalidGamePrice(uint256 price);
///@notice emitted when there is no game to check for score
error Trident_GameNotCreatedYet();
///@notice emitted when an user don't have enough balance
error Trident_NotEnoughBalance(uint256 gamePrice);
///@notice emitted when publisher input wrong address value
error Trident_InvalidTokenAddress(ERC20 tokenAddress);
///@notice emitted when a user tries to use a token that is not allowed
error Trident_TokenNotAllowed(ERC20 choosenToken);
///@notice emitted when the selling period is not open yet
error Trident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
///@notice emitted when ccip receives a message from a chain that is not allowed
error Trident_SourceChainOrSenderNotAllowed(uint64 sourceChainSelector, address sender);
///@notice emitted when the contract doesn't have enough balance
error Trident_NotEnoughLinkBalance(uint256 currentBalance, uint256 calculatedFees);

/**
    *@author Barba - Bellum Galaxy Hackathon Division
    *@title Trident Project
    *@dev This is a Hackathon Project, this codebase didn't go through a cautious analysis or audit
    *@dev do not use in production
    *@custom:contact www.bellumgalaxy.com - https://linktr.ee/bellumgalaxy
*/
contract Trident is CCIPReceiver, Ownable{
    using SafeERC20 for ERC20;
    
    ////////////////////
    /// CUSTOM TYPES ///
    ////////////////////
    ///@notice Struct to track new games NFTs
    struct GameRelease{
        string gameSymbol;
        string gameName;
        TridentNFT keyAddress;
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
    uint256 private constant DECIMALS = 10**6;


    ///@notice link token contract address
    LinkTokenInterface private immutable i_link;
    ///@notice CCIP router address
    IRouterClient private immutable i_router;
    ///@notice functions constract instance
    TridentFunctions private immutable i_functions;

    ///////////////////////
    /// STATE VARIABLES ///
    ///////////////////////
    uint256 private s_gameIdCounter;
    uint256 private s_ccipCounter;


    string[] private scoreCheck;

    ///@notice Mapping to keep track of allowed stablecoins. ~ 0 = not allowed | 1 = allowed
    mapping(ERC20 tokenAddress => uint256 allowed) public s_tokenAllowed;
    ///@notice Mapping to keep track of future launched games
    mapping(uint256 gameIdCounter => GameRelease) private s_gamesCreated;
    ///@notice Mapping to keep track of games an user has
    mapping(address client => ClientRecord[]) private s_clientRecords;
    ///@notice Mapping to keep track of CCIP transactions
    mapping(uint256 ccipCounter => CCIPInfos) private s_ccipMessages;
    ///@notice Mapping to keep track of allowlisted source chains & senders. ~ 0 = not allowed | 1 = allowed
    mapping(uint64 chainID => mapping(address sender => uint256 allowed)) public s_allowlistedSourceChainsAndSenders;
    ///@notice Mapping to keep track of allowlist cross-chain receivers ~ 0 = not allowed | 1 = allowed
    mapping(uint64 chainId => address receiver) private s_crossChainReceivers;

    //////////////
    /// EVENTS ///
    //////////////
    ///@notice event emitted when a source chain is updated
    event Trident_CCIPAllowlistUpdated(uint64 sourceChainSelector, address sender, uint256 allowed);
    ///@notice event emitted when a token is updated or added
    event Trident_AllowedTokensUpdated(string tokenName, string tokenSymbol, ERC20 tokenAddress, uint256 isAllowed);
    ///@notice event emitted when a Cross-chain receiver is created
    event Trident_CrossChainReceiverUpdated(uint64 destinationChainId, address receiver);
    ///@notice event emitted when a new game nft is created
    event Trident_NewGameCreated(uint256 gameId, string tokenSymbol, string gameName, TridentNFT tridentNFT);
    ///@notice event emitted when infos about a new game is released
    event Trident_ReleaseConditionsSet(uint256 gameId, uint256 startingDate, uint256 price);
    ///@notice event emitted when a new copy is sold.
    event Trident_NewGameSold(uint256 gameId, string gameName, address payer, uint256 date, address gameReceiver);
    ///@notice event emitted when a CCIP message is received
    event Trident_MessageReceived(bytes32 messageId, uint64 sourceChainSelector, address sender);
    ///@notice event emitted when a CCIP message is sent
    event Trident_MessageSent(bytes32 messageId, uint64 destinationChainSelector, address receiver, bytes permission, address feeToken, uint256 fees);

    ///////////////
    ///MODIFIERS///
    ///////////////
    /**
     * @dev Modifier that checks if the chain with the given sourceChainSelector is allowlisted and if the sender is allowlisted.
     * @param _sourceChainSelector The selector of the destination chain.
     * @param _sender The address of the sender.
     */
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (s_allowlistedSourceChainsAndSenders[_sourceChainSelector][_sender] != ONE) revert Trident_SourceChainOrSenderNotAllowed(_sourceChainSelector, _sender);
        _;
    }

    /////////////////
    ///CONSTRUCTOR///
    /////////////////
    constructor(address _owner, TridentFunctions _functionsAddress, IRouterClient _router, LinkTokenInterface _link) CCIPReceiver(address(_router)) Ownable(_owner){
        i_functions = _functionsAddress;
        i_link = _link;
        i_router = _router;
    }

    /////////////////////////////////////////////////////////////////
    /////////////////////////// FUNCTIONS ///////////////////////////
    /////////////////////////////////////////////////////////////////

    ////////////////////////////////////
    /// EXTERNAL onlyOwner FUNCTIONS ///
    ////////////////////////////////////
    /**
        * @dev Updates the allowlist status of a source chain
        * @notice This function can only be called by the owner.
        * @param _sourceChainSelector The selector of the source chain to be updated.
        * @param _isAllowed The allowlist status to be set for the source chain.
    */
    function manageCCIPAllowlist(uint64 _sourceChainSelector, address _sender, uint256 _isAllowed) external payable onlyOwner {
        if(_sourceChainSelector < ONE) revert Trident_InvalidSouceChain(_sourceChainSelector);

        s_allowlistedSourceChainsAndSenders[_sourceChainSelector][_sender] = _isAllowed;

        emit Trident_CCIPAllowlistUpdated(_sourceChainSelector, _sender, _isAllowed);
    }

    /**
        * @notice Function to manage whitelisted tokens
        * @param _tokenAddress Address of the token
        * @param _isAllowed 0 = False / 1 True
        * @dev we opted for not deleting the token because we still need to withdraw it.
    */
    function manageAllowedTokens(ERC20 _tokenAddress, uint256 _isAllowed) external onlyOwner {
        if(address(_tokenAddress) == address(0)) revert Trident_InvalidTokenAddress(_tokenAddress);

        s_tokenAllowed[_tokenAddress] = _isAllowed;

        emit Trident_AllowedTokensUpdated(_tokenAddress.name(), _tokenAddress.symbol(), _tokenAddress, _isAllowed);
    }

    /**
     * @notice function to track allowed cross-chain addresses
     * @param _destinationChainId blockchain Id
     * @param _receiver destination contract
     */
    function manageCrossChainReceiver(uint64 _destinationChainId, address _receiver) external onlyOwner{
        if(_destinationChainId < ONE) revert Trident_InvalidChainId(_destinationChainId);
        if(_receiver == address(0)) revert Trident_InvalidReceiver(_receiver);

        s_crossChainReceivers[_destinationChainId] = _receiver;

        emit Trident_CrossChainReceiverUpdated(_destinationChainId, _receiver);
    }

    /**
        *@notice Function for Publisher to create a new game NFT
        *@param _gameSymbol game's identifier
        *@param _gameName game's name
        *@dev we deploy a new NFT key everytime a game is created.
    */
    function createNewGame(string memory _gameSymbol, string memory _gameName) external onlyOwner {
        // CHECKS
        if(bytes(_gameSymbol).length < ONE || bytes(_gameName).length < ONE) revert Trident_InvalidGameSymbolOrName(_gameSymbol, _gameName);

        s_gameIdCounter = s_gameIdCounter + ONE;

        //EFFECTS
        s_gamesCreated[s_gameIdCounter] = GameRelease({
            gameSymbol:_gameSymbol,
            gameName: _gameName,
            keyAddress: TridentNFT(address(0)),
            sellingDate: 0,
            price: 0,
            copiesSold: 0
        });

        scoreCheck.push(_gameName);

        emit Trident_NewGameCreated(s_gameIdCounter, _gameSymbol, _gameName, s_gamesCreated[s_gameIdCounter].keyAddress);

        s_gamesCreated[s_gameIdCounter].keyAddress = new TridentNFT(_gameName, _gameSymbol, address(this));

        s_gamesCreated[s_gameIdCounter].keyAddress.setFunctionsContract(address(i_functions));

        i_functions.setAllowedContracts(address(s_gamesCreated[s_gameIdCounter].keyAddress), ONE);
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
        if(address(release.keyAddress) == address(0)) revert Trident_NonExistantGame(address(0));
        
        if(_startingDate < block.timestamp) revert Trident_SetAValidSellingPeriod(_startingDate, block.timestamp);
        
        if(_price < ONE) revert Trident_InvalidGamePrice(_price);

        //EFFECTS
        s_gamesCreated[_gameId].sellingDate = _startingDate;
        s_gamesCreated[_gameId].price = _price * 10**6;

        emit Trident_ReleaseConditionsSet(_gameId, _startingDate, _price);
    }

    function dispatchCrossChainInfo(uint256 _gameId, uint64 _destinationChainId) external payable onlyOwner returns(bytes32 messageId){       
        if(address(s_gamesCreated[_gameId].keyAddress) == address(0)) revert Trident_NonExistantGame(address(0));
        
        GameRelease memory info = s_gamesCreated[_gameId];

        //Hackathon Purpouses
        bytes memory permission = abi.encode(_gameId, info.sellingDate, info.price);

        messageId = _sendMessage(_destinationChainId, permission);
    }

    /**
     * @notice function to request AI information about games created.
     */
    function gameScoreGetter() external {
        //need to whitelist caller
        uint256 gamesNumber = scoreCheck.length;

        if(gamesNumber < ONE) revert Trident_GameNotCreatedYet();

        for(uint256 i; i < gamesNumber; ++i){
            string[] memory args = new string[](1);

            args[0] = scoreCheck[i];

            i_functions.sendRequestToGet(args);
        }
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
        
        GameRelease memory gameNft = s_gamesCreated[_gameId];

        if(block.timestamp < gameNft.sellingDate) revert Trident_GameNotAvailableYet(block.timestamp, gameNft.sellingDate);

        if(_chosenToken.balanceOf(msg.sender) < gameNft.price ) revert Trident_NotEnoughBalance(gameNft.price);

        address buyer = msg.sender;

        _handleExternalCall(_gameId, gameNft.keyAddress, block.timestamp, gameNft.price, buyer, _gameReceiver, _chosenToken);
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

        if(any2EvmMessage.destTokenAmounts.length >= ONE){

            s_ccipMessages[s_ccipCounter] = CCIPInfos({
                lastReceivedMessageId: any2EvmMessage.messageId,
                sourceChainSelector: any2EvmMessage.sourceChainSelector,
                lastReceivedTokenAddress: any2EvmMessage.destTokenAmounts[0].token,
                lastReceivedAmount: any2EvmMessage.destTokenAmounts[0].amount
            });

        } else {

            s_ccipMessages[s_ccipCounter] = CCIPInfos({
                lastReceivedMessageId: any2EvmMessage.messageId,
                sourceChainSelector: any2EvmMessage.sourceChainSelector,
                lastReceivedTokenAddress: address(0),
                lastReceivedAmount: 0
            });

            (uint256 gameId, uint256 buyingTime, uint256 price, address gameReceiver) = abi.decode(any2EvmMessage.data, (uint256, uint256, uint256, address));

            GameRelease memory release = s_gamesCreated[gameId];

            ClientRecord memory newGame = ClientRecord({
                gameName: release.gameName,
                game: release.keyAddress,
                buyingDate: buyingTime,
                paidValue: price
            });

            s_clientRecords[gameReceiver].push(newGame);
            ++s_gamesCreated[gameId].copiesSold;

            emit Trident_MessageReceived(any2EvmMessage.messageId, any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address)));

            release.keyAddress.safeMint(gameReceiver);
        }

        s_ccipCounter = s_ccipCounter + 1;
    }

    /////////////
    ///PRIVATE///
    /////////////
    /**
     * @notice function to deal with storage update and external call's
     * @param _gameId the ID of the buyed game
     * @param _keyAddress the game's contract address
     * @param _buyingDate the date of buying
     * @param _value the value to be paid
     * @param _buyer the user that is buying
     * @param _gameReceiver the address that will receive the game
     * @param _chosenToken the token to pay.
     */
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
        ++s_gamesCreated[_gameId].copiesSold;

        emit Trident_NewGameSold(_gameId, gameNft.gameName, _buyer, _buyingDate, _gameReceiver);

        //INTERACTIONS
        _chosenToken.safeTransferFrom(_buyer, address(this), _value);
        gameNft.keyAddress.safeMint(_gameReceiver);
    }

    /**
        * @notice Sends data to receiver on the destination chain.
        * @dev Assumes your contract has sufficient LINK.
        * @param _destinationChainId The destination chain to receive the message
        * @param _permission The bytes32 permission to be sent.
        * @return messageId The ID of the message that was sent.
    */
    function _sendMessage(uint64 _destinationChainId, bytes memory _permission) private onlyOwner returns(bytes32 messageId) {

        address crossChainReceiver = s_crossChainReceivers[_destinationChainId];

        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(crossChainReceiver),
            data: _permission,
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 400_000})
            ),
            feeToken: address(i_link)
        });

        uint256 fees = i_router.getFee(_destinationChainId, evm2AnyMessage);


        if (fees > i_link.balanceOf(address(this))) revert Trident_NotEnoughLinkBalance(i_link.balanceOf(address(this)), fees);

        i_link.approve(address(i_router), fees);

        emit Trident_MessageSent(messageId, _destinationChainId, crossChainReceiver, _permission, address(i_link), fees);

        messageId = i_router.ccipSend(_destinationChainId, evm2AnyMessage);

        return messageId;
    }

    /////////////////
    ///VIEW & PURE///
    /////////////////
    /**
     * @notice function to verify if an address is allowed in a specific chain
     * @param _destinationChainId the blockchain Id
     */
    function getAllowedCrossChainReceivers(uint64 _destinationChainId) external view returns(address){
        return s_crossChainReceivers[_destinationChainId];
    }

    /**
     * @notice function to get about game creation
     * @param _gameId the game id
     */
    function getGamesCreated(uint256 _gameId) external view returns(GameRelease memory){
        return s_gamesCreated[_gameId];
    }

    /**
     * @notice Function to get client infos
     * @param _client the address of the client
     */
    function getClientRecords(address _client) external view returns(ClientRecord[] memory){
        return s_clientRecords[_client];
    }

    function getScoreChecker() external view returns(string[] memory){
        return scoreCheck;
    }
}
