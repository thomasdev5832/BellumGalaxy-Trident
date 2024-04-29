// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import { Trident } from "../src/Trident.sol";

contract TridentDeploy is Script {
    Trident trident;

    function run(address _owner) public returns(Trident){
        vm.startBroadcast();

        trident = new Trident(_owner);
        
        vm.stopBroadcast();

        return trident;
    }
}
