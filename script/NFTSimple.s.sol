// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Script, console2 } from "forge-std/src/Script.sol";
import { NFTSimple } from "../src/NFTSimple.sol";

contract NFTScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        NFTSimple nft = new NFTSimple("ArmruoTestToken", "ATT");
        vm.stopBroadcast();
    }
}
