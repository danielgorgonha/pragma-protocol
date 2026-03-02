// SPDX-License-Identifier: MIT
pragma solidity ^0.8.33;

/**
 * @title PragmaToken (PGM)
 * @author Daniel Gorgonha — Pragma Protocol
 * @notice ERC-20 utility token for the decentralized Web3 services marketplace.
 *
 * Functions of the token:
 *  1. PAYMENT  — native exchange medium for the decentralized Web3 services marketplace (2% tax per transaction)
 *  2. ACCESS   — utility gate: holders above 500 PGM unlock premium features
 *
 * Tokenomics:
 *  - Fixed supply: 10.000.000 PGM (no mint after deployment)
 *  - Decimals: 18
 *  - Distribution: defined in the deployment via constructor
 *
 * Developed as bonus for Lesson 01 — Fundamentals and Architecture of Tokens
 * Tokenomics Course — February 2026
 */
contract PragmaToken {

    // ─── METADATA ──────────────────────────────────────────────────────────────
    string public constant name     = "Pragma Token";
    string public constant symbol   = "PGM";
    uint8  public constant decimals = 18;

    // ─── SUPPLY ────────────────────────────────────────────────────────────────
    uint256 public constant TOTAL_SUPPLY = 10_000_000 * 10 ** 18;

    // ─── MARKETPLACE ───────────────────────────────────────────────────────────
    /// @notice Platform fee: 2% (200 bps). Reduced to 1% for premium holders.
    uint256 public constant PLATFORM_FEE_BPS     = 200;  // 2.00%
    uint256 public constant PREMIUM_FEE_BPS      = 100;  // 1.00%

    /// @notice Minimum balance for premium access (service providers)
    uint256 public constant PREMIUM_THRESHOLD    = 500 * 10 ** 18;  // 500 PGM

    /// @notice Minimum balance for access to verified providers (buyers)
    uint256 public constant BUYER_THRESHOLD      = 200 * 10 ** 18;  // 200 PGM

    uint256 private constant BPS_DENOMINATOR     = 10_000;

    // ─── RESERVA ───────────────────────────────────────────────────────────────
    address public ecosystemReserve;
    address public owner;

    // ─── ERC-20 STATE ──────────────────────────────────────────────────────────
    uint256 public totalSupply;

    mapping(address => uint256)                     public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // ─── EVENTS ────────────────────────────────────────────────────────────────
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);
    event MarketplaceFeeCollected(address indexed from, address indexed to, uint256 fee);
    event EcosystemReserveUpdated(address indexed oldReserve, address indexed newReserve);

    // ─── ERRORS ────────────────────────────────────────────────────────────────
    error InsufficientBalance(address account, uint256 available, uint256 required);
    error InsufficientAllowance(address spender, uint256 available, uint256 required);
    error ZeroAddress();
    error OnlyOwner();

    // ─── CONSTRUCTOR ───────────────────────────────────────────────────────────
    /**
     * @param _publicSale     Public sale wallet     (40% — 4.000.000 PGM)
     * @param _ecosystem      Ecosystem wallet       (30% — 3.000.000 PGM)
     * @param _team           Team wallet            (20% — 2.000.000 PGM)
     * @param _reserve        Reserve wallet         (10% — 1.000.000 PGM)
     */
    constructor(
        address _publicSale,
        address _ecosystem,
        address _team,
        address _reserve
    ) {
        if (_publicSale == address(0) || _ecosystem == address(0) ||
            _team == address(0)       || _reserve == address(0)) revert ZeroAddress();

        owner           = msg.sender;
        ecosystemReserve = _ecosystem;
        totalSupply      = TOTAL_SUPPLY;

        // Initial distribution — fixed supply, no mint after deployment
        uint256 publicAmount    = (TOTAL_SUPPLY * 40) / 100; // 4.000.000 PGM
        uint256 ecosystemAmount = (TOTAL_SUPPLY * 30) / 100; // 3.000.000 PGM
        uint256 teamAmount      = (TOTAL_SUPPLY * 20) / 100; // 2.000.000 PGM
        uint256 reserveAmount   = TOTAL_SUPPLY - publicAmount - ecosystemAmount - teamAmount; // 1.000.000 PGM

        balanceOf[_publicSale] = publicAmount;
        balanceOf[_ecosystem]  = ecosystemAmount;
        balanceOf[_team]       = teamAmount;
        balanceOf[_reserve]    = reserveAmount;

        emit Transfer(address(0), _publicSale, publicAmount);
        emit Transfer(address(0), _ecosystem,  ecosystemAmount);
        emit Transfer(address(0), _team,       teamAmount);
        emit Transfer(address(0), _reserve,    reserveAmount);
    }

    // ─── ERC-20 CORE ───────────────────────────────────────────────────────────

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        if (spender == address(0)) revert ZeroAddress();
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            if (allowed < amount) revert InsufficientAllowance(msg.sender, allowed, amount);
            allowance[from][msg.sender] = allowed - amount;
        }
        _transfer(from, to, amount);
        return true;
    }

    // ─── MARKETPLACE TRANSFER ──────────────────────────────────────────────────

    /**
     * @notice Service transfer with platform fee.
     *         Premium holders (>= 500 PGM) pay 1% instead of 2%.
     *         The fee is automatically sent to ecosystemReserve.
     * @param  to     Service provider that will receive the payment
     * @param  amount Amount to be paid by the buyer
     * @return netAmount Net amount received by the service provider
     * @return fee       Tax collected for the ecosystem
     */
    function marketplaceTransfer(address to, uint256 amount)
        external
        returns (uint256 netAmount, uint256 fee)
    {
        uint256 feeBps = isPremium(msg.sender) ? PREMIUM_FEE_BPS : PLATFORM_FEE_BPS;
        fee            = (amount * feeBps) / BPS_DENOMINATOR;
        netAmount      = amount - fee;

        _transfer(msg.sender, to,                netAmount);
        _transfer(msg.sender, ecosystemReserve,  fee);

        emit MarketplaceFeeCollected(msg.sender, to, fee);
    }

    // ─── VIEWS ─────────────────────────────────────────────────────────────────

    /// @notice Returns true if the holder qualifies for premium access (>= 500 PGM)
    function isPremium(address account) public view returns (bool) {
        return balanceOf[account] >= PREMIUM_THRESHOLD;
    }

    /// @notice Returns true if the buyer qualifies for access to verified providers (>= 200 PGM)
    function isBuyer(address account) public view returns (bool) {
        return balanceOf[account] >= BUYER_THRESHOLD;
    }

    /// @notice Returns the applicable fee for a given sender (in BPS)
    function applicableFeeBps(address account) external view returns (uint256) {
        return isPremium(account) ? PREMIUM_FEE_BPS : PLATFORM_FEE_BPS;
    }

    /// @notice Simulates the result of a marketplaceTransfer
    function previewMarketplaceTransfer(address sender, uint256 amount)
        external view
        returns (uint256 netAmount, uint256 fee)
    {
        uint256 feeBps = isPremium(sender) ? PREMIUM_FEE_BPS : PLATFORM_FEE_BPS;
        fee       = (amount * feeBps) / BPS_DENOMINATOR;
        netAmount = amount - fee;
    }

    // ─── ADMIN ─────────────────────────────────────────────────────────────────

    /// @notice Updates the address of the ecosystem reserve
    function setEcosystemReserve(address newReserve) external {
        if (msg.sender != owner) revert OnlyOwner();
        if (newReserve == address(0)) revert ZeroAddress();
        emit EcosystemReserveUpdated(ecosystemReserve, newReserve);
        ecosystemReserve = newReserve;
    }

    // ─── INTERNAL ──────────────────────────────────────────────────────────────

    function _transfer(address from, address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();
        uint256 balance = balanceOf[from];
        if (balance < amount) revert InsufficientBalance(from, balance, amount);
        unchecked {
            balanceOf[from] = balance - amount;
            balanceOf[to]  += amount;
        }
        emit Transfer(from, to, amount);
    }
}
