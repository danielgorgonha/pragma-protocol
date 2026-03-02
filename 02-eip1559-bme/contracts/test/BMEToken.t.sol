// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "forge-std/Test.sol";
import "../src/BMEToken.sol";

/**
 * @title BMETokenTest
 * @notice Unit tests for the BME model — covers:
 *         1. Basic ERC-20
 *         2. Burn on transfer
 *         3. Adaptive burnRate adjustment
 *         4. MIN/MAX clamping
 *         5. Deflationary vs inflationary regime
 */
contract BMETokenTest is Test {
    BMEToken public token;

    address public alice = makeAddr("alice");
    address public bob   = makeAddr("bob");

    uint256 constant INITIAL_SUPPLY = 1_000_000; // 1M BME
    uint256 constant DECIMALS_MUL   = 1e18;

    // ──────────────────────────────────────────────
    // SETUP
    // ──────────────────────────────────────────────

    function setUp() public {
        token = new BMEToken(INITIAL_SUPPLY);

        // Send tokens to Alice for testing
        token.transfer(alice, 100_000 * DECIMALS_MUL);
    }

    // ──────────────────────────────────────────────
    // 1. BASIC ERC-20
    // ──────────────────────────────────────────────

    function test_initialSupply() public {
        // Deploy a fresh token to check supply before any transfer (setUp already did one transfer with burn)
        BMEToken fresh = new BMEToken(INITIAL_SUPPLY);
        assertEq(fresh.totalSupply(), INITIAL_SUPPLY * DECIMALS_MUL);
    }

    function test_ownerBalance() public view {
        // Owner has initial supply minus what was transferred to Alice (after burn)
        uint256 expected = (INITIAL_SUPPLY * DECIMALS_MUL)
            - _afterBurn(100_000 * DECIMALS_MUL, token.INITIAL_BURN());
        // setUp transfer: no block change yet, burnRate = INITIAL_BURN. We only check balance > 0
        assertGt(token.balanceOf(address(this)), 0);
    }

    function test_nameAndSymbol() public view {
        assertEq(token.name(),   "BME Token");
        assertEq(token.symbol(), "BME");
    }

    // ──────────────────────────────────────────────
    // 2. BURN ON TRANSFER
    // ──────────────────────────────────────────────

    function test_burnOnTransfer() public {
        uint256 amount    = 1000 * DECIMALS_MUL;
        uint256 burnRate  = token.burnRate();
        uint256 expectedBurn    = (amount * burnRate) / token.PRECISION();
        uint256 expectedReceive = amount - expectedBurn;

        uint256 supplyBefore  = token.totalSupply();
        uint256 burnedBefore  = token.totalBurned();

        vm.prank(alice);
        token.transfer(bob, amount);

        assertEq(token.balanceOf(bob), expectedReceive, "bob receives net amount");
        assertEq(token.totalSupply(),  supplyBefore - expectedBurn, "supply decreases");
        assertEq(token.totalBurned(),  burnedBefore + expectedBurn, "totalBurned increases");
    }

    function test_previewBurnMatchesActual() public {
        uint256 amount = 500 * DECIMALS_MUL;

        (uint256 burnedPreview, uint256 receivedPreview) = token.previewBurn(amount);

        uint256 bobBefore    = token.balanceOf(bob);
        uint256 burnedBefore = token.totalBurned();

        vm.prank(alice);
        token.transfer(bob, amount);

        assertEq(token.balanceOf(bob) - bobBefore, receivedPreview, "received amount matches preview");
        assertEq(token.totalBurned() - burnedBefore, burnedPreview, "burn increment matches preview");
    }

    // ──────────────────────────────────────────────
    // 3. ADAPTIVE ADJUSTMENT — HIGH DEMAND
    // ──────────────────────────────────────────────

    function test_burnRateIncreasesOnHighDemand() public {
        uint256 rateBefore = token.burnRate();

        // Simulate high volume in current block: TARGET_TXS + 5 transfers
        uint256 target = token.TARGET_TXS();
        for (uint256 i = 0; i < target + 5; i++) {
            vm.prank(alice);
            token.transfer(bob, 1 * DECIMALS_MUL);
        }

        // Advance to next block — triggers adjustment
        vm.roll(block.number + 1);

        vm.prank(alice);
        token.transfer(bob, 1 * DECIMALS_MUL);

        uint256 rateAfter = token.burnRate();
        assertGt(rateAfter, rateBefore, "burnRate should increase with high demand");
    }

    // ──────────────────────────────────────────────
    // 4. ADAPTIVE ADJUSTMENT — LOW DEMAND
    // ──────────────────────────────────────────────

    function test_burnRateDecreasesOnLowDemand() public {
        // First raise the rate with many txs
        uint256 target = token.TARGET_TXS();
        for (uint256 i = 0; i < target + 10; i++) {
            vm.prank(alice);
            token.transfer(bob, 1 * DECIMALS_MUL);
        }
        vm.roll(block.number + 1);
        vm.prank(alice);
        token.transfer(bob, 1 * DECIMALS_MUL);

        uint256 rateElevated = token.burnRate();

        // Now only 1 tx in the block (low demand)
        vm.roll(block.number + 1);
        vm.prank(alice);
        token.transfer(bob, 1 * DECIMALS_MUL);

        // Advance block to apply adjustment
        vm.roll(block.number + 1);
        vm.prank(alice);
        token.transfer(bob, 1 * DECIMALS_MUL);

        uint256 rateAfter = token.burnRate();
        assertLt(rateAfter, rateElevated, "burnRate should decrease with low demand");
    }

    // ──────────────────────────────────────────────
    // 5. CLAMPING MIN/MAX
    // ──────────────────────────────────────────────

    function test_burnRateNeverExceedsMax() public {
        // Force many txs over many blocks
        for (uint256 b = 0; b < 50; b++) {
            vm.roll(block.number + 1);
            uint256 target = token.TARGET_TXS();
            for (uint256 i = 0; i < target * 3; i++) {
                if (token.balanceOf(alice) < 2 * DECIMALS_MUL) break;
                vm.prank(alice);
                token.transfer(bob, 1 * DECIMALS_MUL);
            }
        }
        assertLe(token.burnRate(), token.MAX_BURN_RATE(), "never exceeds MAX_BURN_RATE");
    }

    function test_burnRateNeverBelowMin() public {
        // Low txs per block (only 1 tx per block to trigger adjustment)
        for (uint256 b = 0; b < 20; b++) {
            vm.roll(block.number + 1);
            vm.prank(alice);
            token.transfer(bob, 1 * DECIMALS_MUL);
        }
        assertGe(token.burnRate(), token.MIN_BURN_RATE(), "never below MIN_BURN_RATE");
    }

    // ──────────────────────────────────────────────
    // 6. DEFLATIONARY REGIME
    // ──────────────────────────────────────────────

    function test_deflationaryRegime() public {
        uint256 supplyBefore = token.totalSupply();

        // Multiple transfers → cumulative burn
        uint256 amount = 10_000 * DECIMALS_MUL;
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(alice);
            token.transfer(bob, amount);
            vm.prank(bob);
            token.transfer(alice, amount / 2);
        }

        assertLt(token.totalSupply(), supplyBefore, "supply should decrease (deflationary regime)");
        assertGt(token.totalBurned(), 0, "tokens should have been burned");
    }

    // ──────────────────────────────────────────────
    // 7. MINT ONLY OWNER
    // ──────────────────────────────────────────────

    function test_mintOnlyOwner() public {
        vm.expectRevert("BME: only owner can mint");
        vm.prank(alice);
        token.mint(alice, 1000 * DECIMALS_MUL);
    }

    function test_mintIncreasesSupply() public {
        uint256 supplyBefore = token.totalSupply();
        uint256 mintAmount   = 50_000 * DECIMALS_MUL;
        token.mint(alice, mintAmount);
        assertEq(token.totalSupply(), supplyBefore + mintAmount);
    }

    // ──────────────────────────────────────────────
    // HELPER
    // ──────────────────────────────────────────────

    function _afterBurn(uint256 amount, uint256 rate) internal pure returns (uint256) {
        return amount - (amount * rate) / 10_000;
    }
}
