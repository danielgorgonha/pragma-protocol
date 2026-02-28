# Pragma Token (PGM) — Contracts

ERC-20 utility token for the Web3 services marketplace. Lesson 01 bonus.

## Setup

```bash
forge install foundry-rs/forge-std
forge build
forge test
```

## Deploy (Sepolia)

1. Copy `.env.example` to `.env` and set: `PRIVATE_KEY`, `SEPOLIA_RPC`, `ETHERSCAN_API_KEY`, and the four distribution addresses (`ADDR_PUBLIC_SALE`, `ADDR_ECOSYSTEM`, `ADDR_TEAM`, `ADDR_RESERVE`).

2. Run:

```bash
source .env
forge script script/Deploy.s.sol:DeployPragmaToken \
  --rpc-url $SEPOLIA_RPC \
  --private-key $PRIVATE_KEY \
  --broadcast --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

## Parameters

| Item          | Value |
|---------------|-------|
| Total supply  | 10,000,000 PGM (fixed) |
| Distribution  | 40% public, 30% ecosystem, 20% team, 10% reserve |
| Platform fee  | 2% (1% for premium) |
| Premium       | ≥ 500 PGM (providers) |
| Buyer access  | ≥ 200 PGM |
