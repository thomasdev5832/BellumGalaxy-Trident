// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { Trident } from "../src/Trident.sol";
import { TridentFunctions } from "../src/TridentFunctions.sol";
import { TridentNFT } from "../src/TridentNFT.sol";

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";

contract TridentD is Script {

    function run(address _owner, IRouterClient _router, address _link) public returns(Trident trident, TridentFunctions functions){
        vm.startBroadcast();

        functions = new TridentFunctions(
            address(0), //address _router
            0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000, //bytes32 _donId
            2807, //uint64 _subId
            _owner //address _owner
        );

        trident = new Trident(
            _owner, //address _owner
            functions, //TridentFunctions _functionsAddress
            IRouterClient(_router), //IRouterClient _router
            LinkTokenInterface(_link) //LinkTokenInterface _link
        );

        vm.stopBroadcast();
    }
}