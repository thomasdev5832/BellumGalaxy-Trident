// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { ILogAutomation } from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol"; 

import {TridentNFT} from "./TridentNFT.sol";
import {TridentFunctions} from "./TridentFunctions.sol";

//////////////
/// ERRORS ///
//////////////
///@notice emitter when a contract is initialized with an address(0) param
error Trident_InvalidAddress(address owner, TridentFunctions functions);
///@notice emitted when publisher tries to deploy duplicate game
error Trident_GameAlreadyReleased(TridentNFT trident);
///@notice emitted when the selling period is invalid
error Trident_SetAValidSellingPeriod(uint256 startingDate, uint256 dateNow);
///@notice emitted when an invalid game is selected
error Trident_NonExistantGame(address invalidAddress);
///@notice emitted when publisher input wrong address value
error Trident_InvalidTokenAddress(ERC20 tokenAddress);
///@notice emitted when publisher input a wrong value
error Trident_ZeroOneOption(uint256 isAllowed);
///@notice emitted when a user tries to use a token that is not allowed
error Trident_TokenNotAllowed(ERC20 choosenToken);
///@notice emitted when the selling period is not open yet
error Trident_GameNotAvailableYet(uint256 timeNow, uint256 releaseTime);
///@notice emitted when an user don't have enough balance
error Trident_NotEnoughBalance(uint256 gamePrice);

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
contract CrossChainTrident is ILogAutomation, Ownable{
    using SafeERC20 for ERC20;
    
    ////////////////////
    /// CUSTOM TYPES ///
    ////////////////////
    ///@notice Struct to track info about games to be released
    struct GameInfos {
        uint256 sellingDate;
        uint256 price;
        uint256 copiesSold;
    }

    ///@notice Struct to track buying info.
    struct Client {
        string gameSymbol;
        TridentNFT game;
        uint256 buyingDate;
        uint256 paidValue;
    }

    //////////////////////////////
    /// CONSTANTS & IMMUTABLES ///
    //////////////////////////////


    ///////////////////////
    /// STATE VARIABLES ///
    ///////////////////////

    ///@notice Mapping to keep track of game's info
    mapping(string gameSymbol => GameInfos) private s_gamesInfo;
    ///@notice Mapping to keep track of allowed stablecoins ~ 0 = not allowed | 1 = allowed
    mapping(ERC20 tokenAddress => uint256 allowed) private s_tokenAllowed;
    ///@notice Mapping to keep track of games an user has
    mapping(address client => Client[]) private s_clientRecords;

    //////////////
    /// EVENTS ///
    //////////////
    ///@notice event emitted when a new game nft is created
    event Trident_NewGameCreated(string gameName, string tokenSymbol, TridentNFT trident);
    ///@notice event emitted when infos about a new game is released
    event Trident_ReleaseConditionsSet(string tokenSymbol, uint256 startingDate, uint256 price, uint256 timeLock);
    ///@notice event emitted when a whitelisted token is updated
    event Trident_AllowedTokensUpdated(string tokenName, string tokenSymbol, ERC20 tokenAddress, uint256 isAllowed);
    ///@notice event emitted when a new copy is sold.
    event Trident_NewGameSold(string _gameSymbol, address payer, uint256 date, address gameReceiver);

    constructor(address _owner) Ownable(_owner){
        if(_owner == address(0) ) revert Trident_InvalidAddress(_owner);
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
    function manageAllowedTokens(ERC20 _tokenAddress, uint256 _isAllowed) external onlyOwner {
        if(address(_tokenAddress) == address(0)) revert Trident_InvalidTokenAddress(_tokenAddress);
        if(_isAllowed > ONE) revert Trident_ZeroOneOption(_isAllowed);

        s_tokenAllowed[_tokenAddress] = _isAllowed;

        emit Trident_AllowedTokensUpdated(_tokenAddress.name(), _tokenAddress.symbol(), _tokenAddress, _isAllowed);
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

        _handleExternalCall(buyer, gameNft.gameSymbol, gameNft.keyAddress, game.price, _gameReceiver, _chosenToken);
    }

    //https://docs.chain.link/chainlink-automation/guides/log-trigger
    //This functions will listen to setRealeseConditionsFunction -> Trident_ReleaseConditionsSet(string tokenSymbol, uint256 startingDate, uint256 price);
    function checkLog(Log calldata log, bytes memory) external pure returns (bool upkeepNeeded, bytes memory performData) {
        // upkeepNeeded = true;
        // address logSender = bytes32ToAddress(log.topics[1]);
        // performData = abi.encode(logSender);
    }

    //perform precisa escrever os dados recebidos do evento em um storage.
    //https://docs.chain.link/chainlink-automation/reference/automation-interfaces#ilogautomation
    function performUpkeep(bytes calldata performData) external override {
        // counted += 1;
        // address logSender = abi.decode(performData, (address));
        // emit CountedBy(logSender);
    }

    function bytes32ToAddress(bytes32 _address) public pure returns (address) {
        return address(uint160(uint256(_address)));
    }

    //////////////////// To implement
    //CCIP to allow game purchases crosschain

    /////////////
    ///PRIVATE///
    /////////////
    function _handleExternalCall(address _buyer, string memory _gameSymbol, TridentNFT _keyAddress, uint256 _value, address _gameReceiver, ERC20 _chosenToken) private {

        GameRelease memory gameNft = s_gamesCreated[_gameSymbol];

        //EFFECTS
        Client memory newGame = Client({
            gameSymbol: _gameSymbol,
            game: _keyAddress,
            buyingDate: block.timestamp,
            paidValue: _value
        });

        s_clientRecords[_gameReceiver].push(newGame);

        emit Trident_NewGameSold(_gameSymbol, _buyer, block.timestamp, _gameReceiver);

        //INTERACTIONS
        // i_functions.sendRequest(); //@AJUSTE Quais infos mando para o banco? Wallet Address / NFT Game Address / 
        _chosenToken.safeTransferFrom(msg.sender, address(this), _value);
    }

    /////////////////
    ///VIEW & PURE///
    /////////////////
    function getClientRecords(address _client) external view returns(Client[] memory){
        return s_clientRecords[_client];
    }

    function getAllowedTokens(ERC20 _tokenAddress) external view returns(uint256){
        return s_tokenAllowed[_tokenAddress];
    }
}
