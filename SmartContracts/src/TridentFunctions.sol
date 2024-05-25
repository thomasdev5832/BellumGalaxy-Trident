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
    struct FunctionsResponse{
        bytes lastResponse;
        bytes lastError;
        bool exists;
    }

    struct GameScore{
        bytes lastResponse;
        bytes lastError;
        bool exists;
        uint256 score;
    }
    /////////////////////
    ///State variables///
    /////////////////////

    address endereco = 0x6f09A3ED4E1a231a34EA8d726b6c2a69207Dd379;

    // @Update with protocol info.
    string private constant SOURCE_POST =
        "const name = args[0];"
        "const symbol = args[1];"
        "const gameAddress = args[2];"
        "const previousOwner = args[3];"
        "const receiver = args[4];"
        "const nftId = args[5];"
        "const response = await Functions.makeHttpRequest({"
        "url: http://64.227.122.74:3000/order"
        "method: POST,"
        "data:{gameAddress: `${gameAddress}`,"
            "previousOwner: `${previousOwner}`,"
            "receiver: `${receiver}`,"
            "nftId: `${nftId}`,"
            "gameName: `${name}`,"
            "gameSymbol:`${symbol}`"
        "});"
        "if (response.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = response;"
        "return Functions.encodeString(data);"
    ;
    
    string private constant SOURCE_GET =
        "const gameAddress = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://swapi.info/api/people/${characterId}/`"
        "method: GET"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeUint(data.score);"
    ;

    mapping(bytes32 requestId => FunctionsResponse) private s_responses;
    mapping(bytes32 requestId => GameScore) private s_responsesGet;
    mapping(address nftAddress => uint256 isAllowed) private s_allowedAddresses;

    ///////////////
    ///CONSTANTS///
    ///////////////
    uint32 private constant GAS_LIMIT = 300_000;
    uint256 private constant ONE = 1;

    ////////////////
    ///IMMUTABLES///
    ////////////////
    //https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 private immutable i_donID;
    uint64 private immutable i_subscriptionId;

    ////////////
    ///Events///
    ////////////
    event TridentFunctions_Response(bytes32 indexed requestId, bytes response, bytes err);
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
    constructor(address _router, bytes32 _donId, uint64 _subId, address _owner) FunctionsClient(_router) Ownable(_owner) {
        i_donID = _donId;
        i_subscriptionId = _subId;
    }

    //////////////
    ///external///
    //////////////
    function setAllowedContracts(address _caller, uint256 _isAllowed) external onlyOwner{
        s_allowedAddresses[_caller] = _isAllowed;

        emit TridentFunctions_AllowedCallerContracts(_caller, _isAllowed);
    }

    /**
     * @notice Sends an HTTP request for character information
     * @param _bytesArgs The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequestToPost(bytes[] memory _bytesArgs) external onlyOwner returns (bytes32 requestId) {
        if(s_allowedAddresses[msg.sender] != ONE) revert TridentFunctions_CallerNotAllowed();
        if(_bytesArgs.length < ONE) revert TridentFunctions_EmptyArgs();

        FunctionsRequest.Request memory req;
        // Initialize the request with JS code
        req.initializeRequestForInlineJavaScript(SOURCE_POST);

        // Set the arguments for the request
        req.setBytesArgs(_bytesArgs);

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
     * @param _bytesArgs The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequestToGet(bytes[] memory _bytesArgs) external onlyOwner returns (bytes32 requestId) {
        if(s_allowedAddresses[msg.sender] != ONE) revert TridentFunctions_CallerNotAllowed();
        if(_bytesArgs.length < ONE) revert TridentFunctions_EmptyArgs();

        FunctionsRequest.Request memory req;
        // Initialize the request with JS code
        req.initializeRequestForInlineJavaScript(SOURCE_GET);

        // Set the arguments for the request
        req.setBytesArgs(_bytesArgs);

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
            score: 0
        });
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
        if (s_responses[_requestId].exists == false ) revert TridentFunctions_UnexpectedRequestID(_requestId);
        
        FunctionsResponse storage functions = s_responses[_requestId];
        GameScore storage score = s_responsesGet[_requestId];

        if(functions.exists == true){
            // Update the contract's state variables with the response and any errors
            functions.lastResponse = _response;
            functions.lastError = _err;
        } else if(score.exists == true){
            score.lastResponse = _response;
            score.lastError = _err;
            score.score = abi.decode(_response, (uint256));
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