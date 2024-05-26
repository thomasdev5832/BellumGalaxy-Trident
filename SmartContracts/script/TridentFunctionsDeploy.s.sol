// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { Trident } from "../src/Trident.sol";
import { TridentFunctions } from "../src/TridentFunctions.sol";
import { TridentNFT } from "../src/TridentNFT.sol";

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";

contract TridentFunctionsDeploy is Script {
    Trident trident;
    TridentFunctions functions;

    function run() public returns(Trident){
        vm.startBroadcast();
        //address _router, bytes32 _donId, uint64 _subId, address _owner
        functions = new TridentFunctions(
            0xb83E47C2bC239B3bf370bc41e1459A34b41238D0, 
            0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000, 
            2807, 
            0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be);

        return trident;
    }
}

//Sepolia
    //Router: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0
    //DonId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000
    //SubId: 2807
    //Owner: 0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be

//===============================================================================

//Opt
    //Router: 0xC17094E3A1348E5C7544D4fF8A36c28f2C6AAE28
    //DonId: 0x66756e2d6f7074696d69736d2d7365706f6c69612d3100000000000000000000
    //SubId: 191
    //Owner: 0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be

//===============================================================================

//Avalanche
    //Router: 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0
    //DonId: 0x66756e2d6176616c616e6368652d66756a692d31000000000000000000000000
    //SubId: 191
    //Owner: 0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be