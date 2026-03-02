// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

import "forge-std/Test.sol";
import "../src/PragmaToken.sol";

contract PragmaTokenTest is Test {
    PragmaToken public token;

    address public owner     = address(0x1);
    address public publicSale= address(0x2);
    address public ecosystem = address(0x3);
    address public team      = address(0x4);
    address public reserve   = address(0x5);
    address public buyer     = address(0x6);
    address public seller    = address(0x7);
    address public random    = address(0x8);

    uint256 constant DECIMALS  = 1e18;
    uint256 constant TOTAL     = 10_000_000 * DECIMALS;

    function setUp() public {
        vm.prank(owner);
        token = new PragmaToken(publicSale, ecosystem, team, reserve);
    }

    // ─── SUPPLY & DISTRIBUTION ─────────────────────────────────────────────────

    function test_totalSupplyIsFixed() public view {
        assertEq(token.totalSupply(), TOTAL);
    }

    function test_distributionIsCorrect() public view {
        assertEq(token.balanceOf(publicSale), (TOTAL * 40) / 100);
        assertEq(token.balanceOf(ecosystem),  (TOTAL * 30) / 100);
        assertEq(token.balanceOf(team),       (TOTAL * 20) / 100);
        assertEq(token.balanceOf(reserve),    (TOTAL * 10) / 100);
    }

    function test_sumOfDistributionEqualsTotal() public view {
        uint256 sum = token.balanceOf(publicSale)
                    + token.balanceOf(ecosystem)
                    + token.balanceOf(team)
                    + token.balanceOf(reserve);
        assertEq(sum, TOTAL);
    }

    function test_noMintAfterDeploy() public view {
        // No mint function in the contract — supply cannot grow
        assertEq(token.totalSupply(), TOTAL);
    }

    // ─── ERC-20 BASIC ─────────────────────────────────────────────────────────

    function test_transfer() public {
        uint256 amount = 1000 * DECIMALS;
        vm.prank(publicSale);
        token.transfer(buyer, amount);
        assertEq(token.balanceOf(buyer), amount);
        assertEq(token.balanceOf(publicSale), (TOTAL * 40) / 100 - amount);
    }

    function test_transferRevertsOnInsufficientBalance() public {
        uint256 tooMuch = token.balanceOf(buyer) + 1;
        vm.prank(buyer);
        vm.expectRevert();
        token.transfer(random, tooMuch);
    }

    function test_approveAndTransferFrom() public {
        uint256 amount = 500 * DECIMALS;
        vm.prank(publicSale);
        token.approve(buyer, amount);

        assertEq(token.allowance(publicSale, buyer), amount);

        vm.prank(buyer);
        token.transferFrom(publicSale, seller, amount);

        assertEq(token.balanceOf(seller), amount);
        assertEq(token.allowance(publicSale, buyer), 0);
    }

    function test_transferFromRevertsOnInsufficientAllowance() public {
        vm.prank(publicSale);
        token.approve(buyer, 100 * DECIMALS);

        vm.prank(buyer);
        vm.expectRevert();
        token.transferFrom(publicSale, seller, 101 * DECIMALS);
    }

    // ─── PREMIUM ACCESS ────────────────────────────────────────────────────────

    function test_isPremiumFalseBeforeThreshold() public {
        // buyer tem 0 PGM
        assertFalse(token.isPremium(buyer));
    }

    function test_isPremiumTrueAtThreshold() public {
        uint256 amt = token.PREMIUM_THRESHOLD();
        vm.prank(publicSale);
        token.transfer(buyer, amt);
        assertTrue(token.isPremium(buyer));
    }

    function test_isBuyerFalseBeforeThreshold() public {
        assertFalse(token.isBuyer(buyer));
    }

    function test_isBuyerTrueAtThreshold() public {
        uint256 amt = token.BUYER_THRESHOLD();
        vm.prank(publicSale);
        token.transfer(buyer, amt);
        assertTrue(token.isBuyer(buyer));
    }

    // ─── MARKETPLACE TRANSFER ──────────────────────────────────────────────────

    function test_marketplaceTransferApplies2PercentFee() public {
        // Use 400 PGM so buyer stays below premium threshold (500)
        uint256 amount = 400 * DECIMALS;
        vm.prank(publicSale);
        token.transfer(buyer, amount);

        uint256 ecosystemBefore = token.balanceOf(ecosystem);

        vm.prank(buyer);
        (uint256 net, uint256 fee) = token.marketplaceTransfer(seller, amount);

        assertEq(fee, (amount * 200) / 10_000);
        assertEq(net, amount - fee);
        assertEq(token.balanceOf(seller), net);
        assertEq(token.balanceOf(ecosystem), ecosystemBefore + fee);
    }

    function test_marketplaceTransferApplies1PercentFeeForPremium() public {
        // Give 600 PGM to the buyer (above the threshold of 500)
        uint256 premiumAmount = 600 * DECIMALS;
        uint256 paymentAmount = 500 * DECIMALS;
        vm.prank(publicSale);
        token.transfer(buyer, premiumAmount + paymentAmount);

        assertTrue(token.isPremium(buyer));

        vm.prank(buyer);
        (, uint256 fee) = token.marketplaceTransfer(seller, paymentAmount);

        // 1% fee for premium
        assertEq(fee, (paymentAmount * 100) / 10_000);
    }

    function test_previewMatchesActualMarketplaceTransfer() public {
        uint256 amount = 2000 * DECIMALS;
        vm.prank(publicSale);
        token.transfer(buyer, amount);

        (uint256 previewNet, uint256 previewFee) = token.previewMarketplaceTransfer(buyer, amount);

        vm.prank(buyer);
        (uint256 actualNet, uint256 actualFee) = token.marketplaceTransfer(seller, amount);

        assertEq(previewNet, actualNet);
        assertEq(previewFee, actualFee);
    }

    function test_applicableFeeBpsReturns200ForNonPremium() public view {
        assertEq(token.applicableFeeBps(buyer), 200);
    }

    function test_applicableFeeBpsReturns100ForPremium() public {
        uint256 amt = token.PREMIUM_THRESHOLD();
        vm.prank(publicSale);
        token.transfer(buyer, amt);
        assertEq(token.applicableFeeBps(buyer), 100);
    }

    // ─── ADMIN ─────────────────────────────────────────────────────────────────

    function test_setEcosystemReserveByOwner() public {
        address newReserve = address(0x99);
        vm.prank(owner);
        token.setEcosystemReserve(newReserve);
        assertEq(token.ecosystemReserve(), newReserve);
    }

    function test_setEcosystemReserveRevertsForNonOwner() public {
        vm.prank(random);
        vm.expectRevert();
        token.setEcosystemReserve(address(0x99));
    }

    function test_setEcosystemReserveRevertsForZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert();
        token.setEcosystemReserve(address(0));
    }
}
