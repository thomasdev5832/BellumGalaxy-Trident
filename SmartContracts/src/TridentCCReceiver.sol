//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/////////////
///Imports///
/////////////
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

//////////////
/// ERRORS ///
//////////////

contract TridentCCReceiver is CCIPReceiver, Ownable{
     ///////////////////////
    ///Type declarations///
    ///////////////////////

    /////////////////////
    ///State variables///
    /////////////////////

    bytes32 private s_lastReceivedMessageId;
    string private s_lastReceivedText;
    ////////////
    ///Events///
    ////////////
    event TridentCCReceiver_MessageReceived(bytes32 indexed messageId, uint64 indexed sourceChainSelector, address sender, string text);

    ///////////////
    ///Modifiers///
    ///////////////

    ///////////////
    ///Functions///
    ///////////////

    /////////////////
    ///constructor///
    /////////////////
    constructor(address _router, address _owner) CCIPReceiver(_router) Ownable(_owner) {}

    ///////////////////////
    ///receive function ///
    ///fallback function///
    ///////////////////////

    //////////////
    ///external///
    //////////////

    ////////////
    ///public///
    ////////////

    //////////////
    ///internal///
    //////////////
    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        s_lastReceivedMessageId = any2EvmMessage.messageId;
        s_lastReceivedText = abi.decode(any2EvmMessage.data, (string));

        emit TridentCCReceiver_MessageReceived(any2EvmMessage.messageId, any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address)),  abi.decode(any2EvmMessage.data, (string)));
    }

    /////////////
    ///private///
    /////////////

    /////////////////
    ///view & pure///
    /////////////////
    function getLastReceivedMessageDetails() external view returns (bytes32 messageId, string memory text){
        return (s_lastReceivedMessageId, s_lastReceivedText);
    }
}