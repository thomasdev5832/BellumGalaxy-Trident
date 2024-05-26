// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { CrossChainTrident } from "../src/CrossChainTrident.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract CCTridentDeploy is Script {
    CrossChainTrident ccTrident;

    function run() public returns(CrossChainTrident){
        vm.startBroadcast();

        ccTrident = new CrossChainTrident(0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be, //Owner
                                          IRouterClient(0x114A20A10b43D4115e5aeef7345a1A71d2a60C57), //CCIP Router
                                          LinkTokenInterface(0xE4aB69C077896252FAFBD49EFD26B5D171A32410), //Link
                                          16015286601757825753 //Destination Chain Selector
                                        );
        
        vm.stopBroadcast();

        return ccTrident;
    }
}

//Opt
    //Router: 0xC17094E3A1348E5C7544D4fF8A36c28f2C6AAE28
    //DonId: 0x66756e2d6f7074696d69736d2d7365706f6c69612d3100000000000000000000
    //SubId: 191
    //Owner: 0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be

    //CCIP Router: 0x114A20A10b43D4115e5aeef7345a1A71d2a60C57
    //Chain selector: 5224473277236331295
//  Link: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410

//SEP
    //Chain Selector: 16015286601757825753