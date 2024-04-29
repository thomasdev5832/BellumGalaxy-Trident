// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {TridentNFT} from "./TridentNFT.sol";

//////////////
/// ERRORS ///
//////////////
///@notice emitted when publisher tries to deploy duplicate game
error Trident_GameAlreadyReleased(TridentNFT trident);
///@notice emitted when the selling period is invalid
error Trident_SetAValidSellingPeriod(uint256 startingDate, uint256 dateNow);
///@notice emitted when an invalid game is selected
error Trident_NonExistantGame(TridentNFT trident);
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

/**
    *@author Barba - Bellum Galaxy Hackathon Division
    *@title Trident Project
    *@dev This is a Hackathon Project, this codebase didn't go through a cautious analysis or audit
    *@dev do not use in production
    *contact www.bellumgalaxy.com - https://linktr.ee/bellumgalaxy
*/
contract Trident is Ownable{
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
        uint256 timeLock;
        uint256 copiesSold;
    }

    ///@notice Struct to track buying info.
    struct Client {
        string gameSymbol;
        TridentNFT game;
        uint256 buyingDate;
        uint256 paidValue;
    }

    /////////////////////////////
    /// CONSTANT & IMMUTABLES ///
    /////////////////////////////
    ///@notice magic number removal
    uint256 private constant ZERO = 0;
    ///@notice magic number removal
    uint256 private constant ONE = 1;
    ///@notice magic number removal
    uint256 private constant DECIMALS = 10**18;

    ///////////////////////
    /// STATE VARIABLES ///
    ///////////////////////
    
    ///@notice NFT key instace.
    TridentNFT private trident;

    ///@notice Mapping to keep track of future launched games
    mapping(string gameSymbol => GameRelease) private s_gamesCreated;
    ///@notice Mapping to keep track of game's info
    mapping(string gameSymbol => GameInfos) private s_gamesInfo;
    
    ///@notice Mapping to keep track of allowed stablecoins
    //0 = not allowed | 1 = allowed
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
    event Trident_NewGameSold(string _gameSymbol, address buyer, uint256 date);

    constructor(address _owner) Ownable(_owner){}

    /////////////////////////////////////////////////////////////////
    /////////////////////////// FUNCTIONS ///////////////////////////
    /////////////////////////////////////////////////////////////////

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
        *@param _timeLock Time during which a game will be blocked to re-selling.
        *@dev _gameSymbol param it's an easier explanation option.
    */
    function setReleaseConditions(string memory _gameSymbol, uint256 _startingDate, uint256 _price, uint256 _timeLock) external onlyOwner {
        //CHECKS
        if(address(s_gamesCreated[_gameSymbol].keyAddress) == address(0)) revert Trident_NonExistantGame(s_gamesCreated[_gameSymbol].keyAddress);
        
        if(_startingDate < block.timestamp) revert Trident_SetAValidSellingPeriod(_startingDate, block.timestamp);
        //value check is needed

        //EFFECTS
        s_gamesInfo[_gameSymbol] = GameInfos({
            sellingDate: _startingDate,
            price: _price * DECIMALS,
            timeLock: _timeLock,
            copiesSold: 0
        });

        emit Trident_ReleaseConditionsSet(_gameSymbol, _startingDate, _price, _timeLock);
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

    //////////////////////////
    /// EXTERNAL FUNCTIONS ///
    //////////////////////////
    /**
        * @notice Function for users to buy games
        * @param _gameSymbol game identifier
        * @param _chosenToken token used to pay for the game
        *@dev _gameSymbol param it's an easier explanation option.
    */
    function buyGame(string memory _gameSymbol, ERC20 _chosenToken) external {
        //CHECKS
        if(s_tokenAllowed[_chosenToken] != ONE) revert Trident_TokenNotAllowed(_chosenToken);
        
        GameInfos memory game = s_gamesInfo[_gameSymbol];
        GameRelease memory gameNft = s_gamesCreated[_gameSymbol];

        if(block.timestamp < game.sellingDate) revert Trident_GameNotAvailableYet(block.timestamp, game.sellingDate);

        if(_chosenToken.balanceOf(msg.sender) < game.price ) revert Trident_NotEnoughBalance(game.price);

        //EFFECTS
        Client memory newGame = Client({
            gameSymbol: gameNft.gameSymbol,
            game: gameNft.keyAddress,
            buyingDate: block.timestamp,
            paidValue: game.price
        });

        s_clientRecords[msg.sender].push(newGame);

        emit Trident_NewGameSold(_gameSymbol, msg.sender, block.timestamp);

        //INTERACTIONS
        gameNft.keyAddress.safeMint(msg.sender, "");
        _chosenToken.safeTransferFrom(msg.sender, address(this), game.price);
    }

    //////////////////// To implement
    //CCIP to allow game purchases crosschain
    //Functions to push information to DB offchain
    //Function to inform this chain that a buy on other chain was made.

    function getGamesCreated(string memory _gameSymbol) external view returns(GameRelease memory){
        return s_gamesCreated[_gameSymbol];
    }

    function getGamesInfo(string memory _gameSymbol) external view returns(GameInfos memory){
        return s_gamesInfo[_gameSymbol];
    }

    function getAllowedTokens(ERC20 _tokenAddress) external view returns(uint256){
        return s_tokenAllowed[_tokenAddress];
    }
}
