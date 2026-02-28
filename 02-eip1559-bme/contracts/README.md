# BME Token — Contracts

ERC-20 with EIP-1559-inspired adaptive burn. Lesson 02 bonus.

## Setup

```bash
forge install foundry-rs/forge-std
forge build
forge test -vvv
```

## Deploy (Sepolia)

1. Copy `.env.example` to `.env` and set `SEPOLIA_RPC_URL`, `PRIVATE_KEY`, `ETHERSCAN_API_KEY`.

2. Run:

```bash
source .env
forge script script/Deploy.s.sol:DeployBME \
  --rpc-url $SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

## Parameters

| Parameter       | Value | Description |
|-----------------|-------|-------------|
| MIN_BURN_RATE   | 0.10% | Floor |
| MAX_BURN_RATE   | 5.00% | Ceiling |
| INITIAL_BURN    | 1.00% | Initial rate |
| TARGET_TXS      | 10    | Target transfers per block |
| MAX_ADJUST_PCT  | 12.5% | Max adjustment per block |

## Tests

Twelve tests cover: initial supply, balances, burn on transfer, previewBurn, rate increase/decrease with demand, MIN/MAX clamping, deflationary regime, mint (owner only, supply increase).
