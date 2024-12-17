// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PaidNFT.sol";

contract DeployPaidNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        PaidNFT nft = new PaidNFT(0x036CbD53842c5426634e7929541eC2318f3dCF7e);
        
        vm.stopBroadcast();
        
        console.log("PaidNFT deployed to:", address(nft));
    }
}