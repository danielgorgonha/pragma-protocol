# Lesson 02 — Economic Design and Ecosystem Sustainability

Tokenomics course. Author: Dan, DeegaLabs. February 2026.

This folder contains the required report and the bonus BME smart contract. The contract implements the economic model described in the report.

## Structure

```
02-eip1559-bme/
├── reports/
│   ├── EIP1559_BME.md
│   └── EIP1559_BME.docx
└── contracts/
    ├── src/BMEToken.sol
    ├── test/BMEToken.t.sol
    ├── script/Deploy.s.sol
    └── foundry.toml
```

## Required: Case study (EIP-1559)

[reports/EIP1559_BME.md](./reports/EIP1559_BME.md)

Analysis of post–London Fork ETH burn mechanics using [ultrasound.money](https://ultrasound.money) data: deflationary vs inflationary periods, implications for investors.

Contents: base fee and burn; formula ΔSupply = Emission − Burn; six historical periods; impact of The Merge; annualised inflation; three structural risks (usage dependency, L2 compression, protocol risk).

## Bonus: BME contract

[contracts/](./contracts/)

ERC-20 with **Burn Mechanism Equilibrium (BME)** — adaptive burn rate that mirrors EIP-1559 at token level (target txs per block, ±12.5% adjustment, burn to `address(0)`).

Run from `contracts/`: `forge install foundry-rs/forge-std`, `forge build`, `forge test -vvv`.

## References

- [EIP-1559](https://eips.ethereum.org/EIPS/eip-1559)
- [Ultrasound Money](https://ultrasound.money)
- [The Merge](https://ethereum.org/en/roadmap/merge)
- Roughgarden, T. (2021). Transaction Fee Mechanism Design for the Ethereum Blockchain. arXiv:2012.00854
