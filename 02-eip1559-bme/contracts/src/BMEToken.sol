// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title BMEToken — Burn Mechanism Equilibrium Token
 * @author Daniel Gorgonha — Pragma Protocol
 *
 * @notice Implements an EIP-1559-inspired adaptive burn mechanism: the burn rate per transfer
 *         adjusts automatically each block based on transaction volume, aiming to stabilize supply.
 *
 * @dev Equilibrium model:
 *
 *      ΔSupply = Emission − Burn
 *
 *      Adjustment rule (mirroring EIP-1559):
 *        - Txs/block > TARGET → burnRate += delta (up to MAX_BURN_RATE)
 *        - Txs/block < TARGET → burnRate -= delta (down to MIN_BURN_RATE)
 *        - Max adjustment per block: ±12.5% of current burnRate
 *
 *      Per-transfer flow:
 *        1. burnAmount = amount × burnRate / PRECISION
 *        2. netAmount   = amount - burnAmount
 *        3. Burned tokens are destroyed (transfer to address(0))
 */
contract BMEToken {
    // ──────────────────────────────────────────────────────────
    // EVENTS
    // ──────────────────────────────────────────────────────────

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event BurnRateUpdated(uint256 oldRate, uint256 newRate, uint256 txsThisBlock);
    event Burned(address indexed from, uint256 amount, uint256 newTotalSupply);
    event Minted(address indexed to, uint256 amount, uint256 newTotalSupply);

    // ──────────────────────────────────────────────────────────
    // CONSTANTS
    // ──────────────────────────────────────────────────────────

    string public constant name     = "BME Token";
    string public constant symbol   = "BME";
    uint8  public constant decimals = 18;

    uint256 public constant PRECISION       = 10_000;   // 100.00%
    uint256 public constant MIN_BURN_RATE   = 10;       // 0.10%
    uint256 public constant MAX_BURN_RATE   = 500;      // 5.00%
    uint256 public constant INITIAL_BURN    = 100;      // 1.00%
    uint256 public constant TARGET_TXS      = 10;       // target txs per block
    uint256 public constant MAX_ADJUST_PCT  = 1250;     // 12.5% (based on PRECISION=10000)

    // ──────────────────────────────────────────────────────────
    // STATE
    // ──────────────────────────────────────────────────────────

    address public immutable owner;

    uint256 public totalSupply;
    uint256 public burnRate;        // bps (e.g. 100 = 1%)
    uint256 public totalBurned;     // burned tokens (accumulated)

    // Block adjustment control
    uint256 public lastAdjustBlock;
    uint256 public txsThisBlock;

    mapping(address => uint256)                     private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // ──────────────────────────────────────────────────────────
    // CONSTRUCTOR
    // ──────────────────────────────────────────────────────────

    /**
     * @param initialSupply Initial supply in token units (no decimals).
     *                     E.g. 1_000_000 → 1 million BME (1e24 raw units).
     */
    constructor(uint256 initialSupply) {
        owner    = msg.sender;
        burnRate = INITIAL_BURN;
        lastAdjustBlock = block.number;

        uint256 amount = initialSupply * (10 ** decimals);
        _mint(msg.sender, amount);
    }

    // ──────────────────────────────────────────────────────────
    // ERC-20 PADRÃO
    // ──────────────────────────────────────────────────────────

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return _allowances[tokenOwner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transferWithBurn(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 currentAllowance = _allowances[from][msg.sender];
        require(currentAllowance >= amount, "BME: allowance exceeded");
        _approve(from, msg.sender, currentAllowance - amount);
        _transferWithBurn(from, to, amount);
        return true;
    }

    // ──────────────────────────────────────────────────────────
    // LOGIC: TRANSFER WITH ADAPTIVE BURN
    // ──────────────────────────────────────────────────────────

    /**
     * @notice Performs transfer with adaptive burn. Updates tx counter and adjusts burnRate on block boundary.
     */
    function _transferWithBurn(address from, address to, uint256 amount) internal {
        require(from != address(0), "BME: transfer from zero address");
        require(to   != address(0), "BME: transfer to zero address");
        require(_balances[from] >= amount, "BME: insufficient balance");

        // 1. Register tx in current block and adjust rate if necessary
        _trackAndAdjust();

        // 2. Calculate burn
        uint256 burnAmount   = (amount * burnRate) / PRECISION;
        uint256 netAmount    = amount - burnAmount;

        // 3. Debit the sender's balance
        _balances[from] -= amount;

        // 4. Burn: subtract from supply (send to address(0))
        if (burnAmount > 0) {
            totalSupply  -= burnAmount;
            totalBurned  += burnAmount;
            emit Transfer(from, address(0), burnAmount);
            emit Burned(from, burnAmount, totalSupply);
        }

        // 5. Credit the net amount to the recipient
        _balances[to] += netAmount;
        emit Transfer(from, to, netAmount);
    }

    // ──────────────────────────────────────────────────────────
    // ADAPTIVE BURN RATE ADJUSTMENT — CORE OF THE BME MODEL
    // ──────────────────────────────────────────────────────────

    /**
     * @notice Mirrors EIP-1559 algorithm: records txs in current block; on new block, adjusts burnRate from txsThisBlock vs TARGET.
     * @dev Adjustment formula: delta = burnRate × MAX_ADJUST_PCT / PRECISION × |txs - TARGET| / TARGET; newRate = burnRate ± delta (clamped MIN..MAX).
     */
    function _trackAndAdjust() internal {
        if (block.number == lastAdjustBlock) {
            // Same block: only increment counter
            txsThisBlock++;
            return;
        }

        // New block: adjust burnRate based on previous block
        uint256 prevTxs = txsThisBlock;
        uint256 oldRate = burnRate;
        uint256 newRate;

        if (prevTxs > TARGET_TXS) {
            // High demand → increase burn (deflationary pressure)
            uint256 excess  = prevTxs - TARGET_TXS;
            uint256 delta   = (burnRate * MAX_ADJUST_PCT * excess) / (PRECISION * TARGET_TXS);
            newRate = _min(burnRate + delta, MAX_BURN_RATE);
        } else if (prevTxs < TARGET_TXS) {
            // Low demand → reduce burn (softens deflation)
            uint256 deficit = TARGET_TXS - prevTxs;
            uint256 delta   = (burnRate * MAX_ADJUST_PCT * deficit) / (PRECISION * TARGET_TXS);
            newRate = burnRate > delta ? burnRate - delta : MIN_BURN_RATE;
        } else {
            newRate = burnRate;
        }

        burnRate        = _clamp(newRate, MIN_BURN_RATE, MAX_BURN_RATE);
        lastAdjustBlock = block.number;
        txsThisBlock    = 1; // count the current tx

        if (burnRate != oldRate) {
            emit BurnRateUpdated(oldRate, burnRate, prevTxs);
        }
    }

    // ──────────────────────────────────────────────────────────
    // MINT (only owner)
    // ──────────────────────────────────────────────────────────

    /**
     * @notice Mints new tokens (emission); analogous to validator rewards in EIP-1559. Used to simulate Emission vs Burn.
     */
    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "BME: only owner can mint");
        _mint(to, amount);
    }

    // ──────────────────────────────────────────────────────────
    // ANALYTIC VIEWS
    // ──────────────────────────────────────────────────────────

    /// @notice Supply trend: positive = more emission than burn, negative = more burn than emission.
    /// @return int256(totalSupply - totalBurned) for regime analysis (deflationary when totalBurned is high).
    function netSupplyFlow() external view returns (int256) {
        return int256(totalSupply) - int256(totalBurned);
    }

    /// @notice Burn rate as integer and hundredths (e.g. 150 → whole=1, frac=50 for "1.50%").
    function burnRatePct() external view returns (uint256 whole, uint256 frac) {
        whole = burnRate / 100;
        frac  = burnRate % 100;
    }

    /// @notice Simulates how much would be burned and received in a transfer of `amount`.
    function previewBurn(uint256 amount) external view returns (uint256 burned, uint256 received) {
        burned   = (amount * burnRate) / PRECISION;
        received = amount - burned;
    }

    // ──────────────────────────────────────────────────────────
    // INTERNAL FUNCTIONS
    // ──────────────────────────────────────────────────────────

    function _mint(address to, uint256 amount) internal {
        require(to != address(0), "BME: mint to zero address");
        totalSupply    += amount;
        _balances[to]  += amount;
        emit Transfer(address(0), to, amount);
        emit Minted(to, amount, totalSupply);
    }

    function _approve(address tokenOwner, address spender, uint256 amount) internal {
        require(tokenOwner != address(0), "BME: approve from zero");
        require(spender    != address(0), "BME: approve to zero");
        _allowances[tokenOwner][spender] = amount;
        emit Approval(tokenOwner, spender, amount);
    }

    function _min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function _clamp(uint256 val, uint256 lo, uint256 hi) internal pure returns (uint256) {
        if (val < lo) return lo;
        if (val > hi) return hi;
        return val;
    }
}
