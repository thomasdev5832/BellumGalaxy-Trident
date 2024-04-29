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
error TridentAFunctions_UnexpectedRequestID(bytes32 requestId);
error TridentAFunctions_EmptyArgs();

contract TridentAFunctions is FunctionsClient, Ownable{
    using FunctionsRequest for FunctionsRequest.Request;

    ///////////////////////
    ///Type declarations///
    ///////////////////////
    struct FunctionsResponse{
        bytes lastResponse;
        bytes lastError;
        bool exists;
    }

    /////////////////////
    ///State variables///
    /////////////////////
    // @Update with protocol info.
    string private constant SOURCE =
        "const characterId = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://swapi.info/api/people/${characterId}/`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data.name);";


    mapping(bytes32 requestId => FunctionsResponse) private s_responses;

    ///////////////
    ///CONSTANTS///
    ///////////////
    uint32 private constant GAS_LIMIT = 300000;
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
    event TridentAFunctions_Response(bytes32 indexed requestId, bytes response, bytes err);

    ///////////////
    ///Modifiers///
    ///////////////

    ///////////////
    ///Functions///
    ///////////////

    /////////////////
    ///constructor///
    /////////////////
    constructor(address _router, bytes32 _donId, uint64 _subId, address _owner) FunctionsClient(_router) Ownable(_owner) {
        i_donID = _donId;
        i_subscriptionId = _subId;
    }

    ///////////////////////
    ///receive function ///
    ///fallback function///
    ///////////////////////

    //////////////
    ///external///
    //////////////
    /**
     * @notice Sends an HTTP request for character information
     * @param _args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequest(string[] calldata _args) external onlyOwner returns (bytes32 requestId) {
        if(_args.length < ONE) revert TridentAFunctions_EmptyArgs();

        FunctionsRequest.Request memory req;
        // Initialize the request with JS code
        req.initializeRequestForInlineJavaScript(SOURCE);

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

    ////////////
    ///public///
    ////////////

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
        if (s_responses[_requestId].exists == false ) revert TridentAFunctions_UnexpectedRequestID(_requestId);
        
        FunctionsResponse memory functions = s_responses[_requestId];

        // Update the contract's state variables with the response and any errors
        functions.lastResponse = _response;
        functions.lastError = _err;

        emit TridentAFunctions_Response(_requestId, _response, _err);
    }

    /////////////
    ///private///
    /////////////

    /////////////////
    ///view & pure///
    /////////////////
}