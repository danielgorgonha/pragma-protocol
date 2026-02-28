// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BMEToken.sol";

/**
 * @notice Deploy BMEToken to Sepolia testnet.
 *
 * Usage:
 *   forge script script/Deploy.s.sol:DeployBME \
 *     --rpc-url $SEPOLIA_RPC_URL \
 *     --private-key $PRIVATE_KEY \
 *     --broadcast \
 *     --verify \
 *     --etherscan-api-key $ETHERSCAN_API_KEY
 */
contract DeployBME is Script {
    function run() external returns (BMEToken token) {
        uint256 initialSupply = 1_000_000; // 1 million BME

        vm.startBroadcast();
        token = new BMEToken(initialSupply);
        vm.stopBroadcast();

        console.log("BMEToken deployed at:", address(token));
        console.log("Initial Supply:      ", initialSupply);
        console.log("Initial Burn Rate bps:", token.burnRate());
        console.log("Owner:               ", token.owner());
    }
}
