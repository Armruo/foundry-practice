// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import "forge-std/src/Script.sol";
import "../src/NFT.sol";

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        NFT nft = new NFT("NFT_tutorial", "TUT", "baseUri");

        vm.stopBroadcast();
    }
}
