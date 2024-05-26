//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/////////////
///Imports///
/////////////
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";


//////////////
/// ERRORS ///
//////////////
error TridentFunctions_UnexpectedRequestID(bytes32 requestId);
error TridentFunctions_EmptyArgs();
error TridentFunctions_CallerNotAllowed();

contract TridentFunctions is FunctionsClient, Ownable{
    using FunctionsRequest for FunctionsRequest.Request;

    ///////////////////////
    ///Type declarations///
    ///////////////////////
    ///@notice 
    struct FunctionsResponse{
        bytes lastResponse;
        bytes lastError;
        bool exists;
    }

    ///@notice 
    struct GameScore{
        bytes lastResponse;
        bytes lastError;
        bool exists;
        string name;
        uint256 score;
    }
    
    /////////////
    ///Storage///
    /////////////
    ///@notice 
    mapping(bytes32 requestId => FunctionsResponse) private s_responses;
    ///@notice 
    mapping(bytes32 requestId => GameScore) private s_responsesGet;
    ///@notice 
    mapping(address nftAddress => uint256 isAllowed) private s_allowedAddresses;
    ///@notice mapping to keep track of game score avaliation
    mapping(string gameName => uint256[]) public s_dailyAvaliation;

    ///////////////
    ///CONSTANTS///
    ///////////////
    ///@notice 
    uint256 private constant ONE = 1;
    ///@notice 
    uint32 private constant GAS_LIMIT = 300_000;
    ///@notice 
    string private constant SOURCE_POST = 
        "const name = args[0];"
        "const symbol = args[1];"
        "const gameAddress = args[2];"
        "const previousOwner = args[3];"
        "const receiver = args[4];"
        "const nftId = args[5];"
        "const response = await Functions.makeHttpRequest({"
        "url: `http://64.227.122.74:3000/order/gameAddress/${gameAddress}/previousOwner/${previousOwner}/receiver/${receiver}/nftId/${nftId}/gameName/${name}/gameSymbol/${symbol}`,"
        "method: 'POST',"
        "});"
        "if (response.error) {"
        "  throw Error(`Request failed message ${response.message}`);"
        "}"
        "const { data } = response;"
        "return Functions.encodeString(data);"
    ;
    ///@notice 
    string private constant SOURCE_GET =
        "const gameName = args[0];"
        "const response = await Functions.makeHttpRequest({"
        "url: `http://64.227.122.74:3000/score/name/${gameName}`,"
        "method: 'GET',"
        "});"
        "if (response.error) {"
        "  throw Error(`Request failed message ${response.message}`);"
        "}"
        "const { data } = response;"
        "return Functions.encodeUint256(data.score);"
    ;

    ////////////////
    ///IMMUTABLES///
    ////////////////
    ///@notice 
    bytes32 private immutable i_donID;
    ///@notice 
    uint64 private immutable i_subscriptionId;

    ////////////
    ///Events///
    ////////////
    ///@notice 
    event TridentFunctions_Response(bytes32 indexed requestId, bytes response, bytes err);
    ///@notice 
    event TridentFunctions_AllowedCallerContracts(address caller, uint256 isAllowed);

    ///////////////
    ///Modifiers///
    ///////////////

    /////////////////////////////////////////////////////////////////////////
    ////////////////////////////////Functions////////////////////////////////
    /////////////////////////////////////////////////////////////////////////

    /////////////////
    ///constructor///
    /////////////////
    /**
     * 
     * @param _router Chainlink Functions Router Address
     * @param _donId Chainlink Functions DonId
     * @param _subId Chainlink Functions Subscription Id
     * @param _owner Chainlink Functions Contract Owner
     */
    constructor(address _router, bytes32 _donId, uint64 _subId, address _owner) FunctionsClient(_router) Ownable(_owner) {
        i_donID = _donId;
        i_subscriptionId = _subId;
    }

    //////////////
    ///external///
    //////////////
    /**
     * @notice function to updated contracts that can call the Chainlink Functions functionalities
     * @param _caller Allowlisted caller
     * @param _isAllowed 1 == true | Any other value false
     */
    function setAllowedContracts(address _caller, uint256 _isAllowed) external onlyOwner{
        s_allowedAddresses[_caller] = _isAllowed;

        emit TridentFunctions_AllowedCallerContracts(_caller, _isAllowed);
    }

    /**
     * @notice Sends an HTTP request for character information
     * @param _args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
    */
    function sendRequestToPost(string[] memory _args) external returns(bytes32 requestId) {
        if(s_allowedAddresses[msg.sender] != ONE) revert TridentFunctions_CallerNotAllowed();

        if(_args.length < ONE) revert TridentFunctions_EmptyArgs();

        FunctionsRequest.Request memory req;
        // Initialize the request with JS code
        req.initializeRequestForInlineJavaScript(SOURCE_POST);

        // Set the arguments for the request
        req.setArgs(_args);

        // Send the request and store the request ID
        requestId = _sendRequest(
            req.encodeCBOR(),
            i_subscriptionId,
            GAS_LIMIT,
            i_donID
        );

        s_responses[requestId] = FunctionsResponse({
            lastResponse: "",
            lastError: "",
            exists: true
        });
    }

    /**
     * @notice Sends an HTTP request for character information
     * @param _args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequestToGet(string[] memory _args) external onlyOwner returns(bytes32 requestId) {
        // if(s_allowedAddresses[msg.sender] != ONE) revert TridentFunctions_CallerNotAllowed();
        if(_args.length < ONE) revert TridentFunctions_EmptyArgs();

        FunctionsRequest.Request memory req;
        // Initialize the request with JS code
        req.initializeRequestForInlineJavaScript(SOURCE_GET);

        // Set the arguments for the request
        req.setArgs(_args);

        // Send the request and store the request ID
        requestId = _sendRequest(
            req.encodeCBOR(),
            i_subscriptionId,
            GAS_LIMIT,
            i_donID
        );

        s_responsesGet[requestId] = GameScore({
            lastResponse: "",
            lastError: "",
            exists: true,
            name: _args[0],
            score: 0
        });
    }

    function getScoreDailyHistory(string memory _name) external view returns(uint256[] memory score){
        score = s_dailyAvaliation[_name];
    }
    
    //////////////
    ///internal///
    //////////////
    /**
     * @notice Callback function for fulfilling a request
     * @param _requestId The ID of the request to fulfill
     * @param _response The HTTP response data
     * @param _err Any errors from the Functions request
    */
    function fulfillRequest(bytes32 _requestId, bytes memory _response, bytes memory _err) internal override {
        if (s_responses[_requestId].exists == false && s_responsesGet[_requestId].exists == false) revert TridentFunctions_UnexpectedRequestID(_requestId);
        
        FunctionsResponse storage post = s_responses[_requestId];
        GameScore storage score = s_responsesGet[_requestId];

        if(post.exists == true){
            // Update the contract's state variables with the response and any errors
            post.lastResponse = _response;
            post.lastError = _err;
        } else {
            uint256 scoreNow = abi.decode(_response, (uint256));
            score.lastResponse = _response;
            score.lastError = _err;
            score.score = scoreNow;
            s_dailyAvaliation[score.name].push(scoreNow);
        }

        emit TridentFunctions_Response(_requestId, _response, _err);
    }
    /////////////
    ///private///
    /////////////

    /////////////////
    ///view & pure///
    /////////////////
}