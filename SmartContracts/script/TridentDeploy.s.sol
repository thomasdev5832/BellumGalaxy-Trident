// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { Trident } from "../src/Trident.sol";
import { TridentFunctions } from "../src/TridentFunctions.sol";

contract TridentDeploy is Script {
    Trident trident;
    TridentFunctions functions;

    function run(address _owner, address _router) public returns(Trident){
        vm.startBroadcast();

        functions = new TridentFunctions(address(0), "1", 0, _owner);
        trident = new Trident(_owner, functions, _router);
        
        vm.stopBroadcast();

        return trident;
    }
}
