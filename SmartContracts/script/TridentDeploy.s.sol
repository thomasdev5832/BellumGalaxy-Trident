// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { Trident } from "../src/Trident.sol";
import { TridentFunctions } from "../src/TridentFunctions.sol";

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";

contract TridentDeploy is Script {
    Trident trident;
    TridentFunctions functions;

    function run(address _owner, IRouterClient _router, address _link) public returns(Trident){
        vm.startBroadcast();

        functions = new TridentFunctions(address(0), "1", 0, _owner);
        trident = new Trident(_owner, functions, _router, LinkTokenInterface(_link));
        
        vm.stopBroadcast();

        return trident;
    }
}
