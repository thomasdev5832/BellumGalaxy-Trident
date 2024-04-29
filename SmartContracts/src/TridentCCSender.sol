//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/////////////
///Imports///
/////////////
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

//////////////
/// ERRORS ///
//////////////
error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // Used to make sure contract has enough balance.


contract TridentCCSender is Ownable{
     ///////////////////////
    ///Type declarations///
    ///////////////////////

    /////////////////////
    ///State variables///
    /////////////////////

    

    IRouterClient immutable private i_router;
    LinkTokenInterface immutable private i_linkToken;

    ////////////
    ///Events///
    ////////////
    event MessageSent(bytes32 indexed messageId, uint64 indexed destinationChainSelector, address receiver, string text, address feeToken, uint256 fees);

    ///////////////
    ///Modifiers///
    ///////////////

    ///////////////
    ///Functions///
    ///////////////

    /////////////////
    ///constructor///
    /////////////////
    constructor(address _router, address _link, address _owner) Ownable(_owner){
        i_router = IRouterClient(_router);
        i_linkToken = LinkTokenInterface(_link);
    }

    ///////////////////////
    ///receive function ///
    ///fallback function///
    ///////////////////////

    //////////////
    ///external///
    //////////////
    /// @notice Sends data to receiver on the destination chain.
    /// @dev Assumes your contract has sufficient LINK.
    /// @param destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param receiver The address of the recipient on the destination blockchain.
    /// @param text The string text to be sent.
    /// @return messageId The ID of the message that was sent.
    function sendMessage(uint64 destinationChainSelector, address receiver, string calldata text) external onlyOwner returns (bytes32 messageId) {
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(text),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000})
            ),
            
            feeToken: address(i_linkToken)
        });

        uint256 fees = i_router.getFee(destinationChainSelector, evm2AnyMessage);

        emit MessageSent(messageId, destinationChainSelector, receiver, text, address(i_linkToken), fees);

        if (fees > i_linkToken.balanceOf(address(this))) revert NotEnoughBalance(i_linkToken.balanceOf(address(this)), fees);

        i_linkToken.approve(address(i_router), fees);

        messageId = i_router.ccipSend(destinationChainSelector, evm2AnyMessage);

        return messageId;
    }

    ////////////
    ///public///
    ////////////

    //////////////
    ///internal///
    //////////////

    /////////////
    ///private///
    /////////////

    /////////////////
    ///view & pure///
    /////////////////
}