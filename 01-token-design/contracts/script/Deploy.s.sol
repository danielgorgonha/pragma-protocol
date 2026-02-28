// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PragmaToken.sol";

/**
 * @notice Deploy PragmaToken (PGM) on Sepolia Testnet
 *
 * Before running:
 *   1. Fill the .env with the variables below
 *   2. forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC --broadcast --verify
 *
 * Environment variables needed:
 *   PRIVATE_KEY       — private key of the deployer
 *   SEPOLIA_RPC       — endpoint RPC of Sepolia (ex: Infura, Alchemy)
 *   ETHERSCAN_API_KEY — for automatic contract verification
 *   ADDR_PUBLIC_SALE  — public sale wallet  (40%)
 *   ADDR_ECOSYSTEM    — ecosystem wallet    (30%)
 *   ADDR_TEAM         — team wallet         (20%)
 *   ADDR_RESERVE      — reserve wallet      (10%)
 */
contract DeployPragmaToken is Script {
    function run() external {
        address publicSale = vm.envAddress("ADDR_PUBLIC_SALE");
        address ecosystem  = vm.envAddress("ADDR_ECOSYSTEM");
        address team       = vm.envAddress("ADDR_TEAM");
        address reserve    = vm.envAddress("ADDR_RESERVE");

        uint256 deployerKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerKey);

        PragmaToken pgm = new PragmaToken(
            publicSale,
            ecosystem,
            team,
            reserve
        );

        vm.stopBroadcast();

        console.log("PragmaToken deployed at:", address(pgm));
        console.log("Total supply:", pgm.totalSupply());
        console.log("Public Sale balance:", pgm.balanceOf(publicSale));
        console.log("Ecosystem balance:", pgm.balanceOf(ecosystem));
        console.log("Team balance:", pgm.balanceOf(team));
        console.log("Reserve balance:", pgm.balanceOf(reserve));
    }
}
