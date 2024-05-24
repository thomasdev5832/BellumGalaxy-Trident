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

    function run(/*address _owner, IRouterClient _router, address _link*/) public returns(Trident){
        vm.startBroadcast();

        functions = new TridentFunctions(0xb83E47C2bC239B3bf370bc41e1459A34b41238D0, 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000, 2807, 0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be);
        trident = new Trident(0xB015a6318f1D19DC3E135C8cEBa4bda00845c9Be, functions, IRouterClient(0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59), LinkTokenInterface(0x779877A7B0D9E8603169DdbD7836e478b4624789));
        vm.stopBroadcast();

        return trident;
    }
}
