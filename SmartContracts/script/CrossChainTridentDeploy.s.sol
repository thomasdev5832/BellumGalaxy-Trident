// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import { CrossChainTrident } from "../src/CrossChainTrident.sol";

contract CrossChainTridentDeploy is Script {
    CrossChainTrident ccTrident;

    function run(address _owner,
                 address _router,
                 address _link,
                 uint64 _destinationChainSelector
                ) public returns(CrossChainTrident){
        vm.startBroadcast();

        ccTrident = new CrossChainTrident(_owner,
                                          _router,
                                          _link,
                                          _destinationChainSelector
                                        );
        
        vm.stopBroadcast();

        return ccTrident;
    }
}
