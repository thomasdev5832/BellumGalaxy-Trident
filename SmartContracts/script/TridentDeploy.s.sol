// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { Trident } from "../src/Trident.sol";
import { TridentFunctions } from "../src/TridentFunctions.sol";
import { TridentNFT } from "../src/TridentNFT.sol";

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";

contract TridentDeploy is Script {
    Trident trident;
    TridentFunctions functions;

    function run() public returns(Trident){
        vm.startBroadcast();
        
        functions = new TridentFunctions(
            0xb83E47C2bC239B3bf370bc41e1459A34b41238D0, //_router
            0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000, //_donId
            2807, //_subId
            0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be //_owner
        );
        
        trident = new Trident(
            0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be, //_owner
            functions, //TridentFunctions
            IRouterClient(0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59), //IRouterClient
            LinkTokenInterface(0x779877A7B0D9E8603169DdbD7836e478b4624789) //LinkTokenInterface
        );
        vm.stopBroadcast();

        return trident;
    }
}

//Sepolia
    //Router: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0
    //DonId: 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000
    //SubId: 2807
    //Owner: 0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be

    //CCIP Router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59
    //Chain selector: 16015286601757825753
//  Link: 0x779877A7B0D9E8603169DdbD7836e478b4624789

//===============================================================================

//Opt
    //Router: 0xC17094E3A1348E5C7544D4fF8A36c28f2C6AAE28
    //DonId: 0x66756e2d6f7074696d69736d2d7365706f6c69612d3100000000000000000000
    //SubId: 191
    //Owner: 0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be

    //CCIP Router: 0x114A20A10b43D4115e5aeef7345a1A71d2a60C57
    //Chain selector: 5224473277236331295
//  Link: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410

//===============================================================================

//Avalanche
    //Router: 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0
    //DonId: 0x66756e2d6176616c616e6368652d66756a692d31000000000000000000000000
    //SubId: 191
    //Owner: 0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be

    //CCIP Router: 0xF694E193200268f9a4868e4Aa017A0118C9a8177
    //Chain selector: 14767482510784806043
//  Link: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846