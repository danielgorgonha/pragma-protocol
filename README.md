# Pragma Protocol

Repository for the Tokenomics postgraduate course. Each lesson adds a layer to the same Web3 services ecosystem.

**Token:** Pragma (PGM) — ERC-20, fixed supply 10,000,000 PGM  
**Network:** Ethereum (Sepolia Testnet)  
**Stack:** Solidity, Foundry

## Contents

Two lesson folders. Each has **reports** (required deliverables) and **contracts** (bonus implementation).

| Folder | Reports | Contracts |
|--------|---------|-----------|
| [01-token-design/](./01-token-design/) | One-pager (PGM tokenomics), pitch script | PGM ERC-20 — utility token, 10M supply, 2% fee, premium access (Sepolia) |
| [02-eip1559-bme/](./02-eip1559-bme/) | EIP-1559 case study (burn, deflationary periods, investors) | BMEToken — adaptive burn rate, EIP-1559 style (Foundry) |

**01** defines the base token (design, distribution, payment + access). **02** adds the economic model: BME adaptive burn inspired by EIP-1559. The PGM token can later be extended with the BME mechanism.

## Structure

```
bme-model/
├── README.md
├── 01-token-design/
│   ├── reports/       OnePager_PGM.md, Pitch_Roteiro.md (+ .docx/.pptx)
│   └── contracts/     PragmaToken.sol, tests, deploy script
├── 02-eip1559-bme/
│   ├── reports/       EIP1559_BME.md (+ .docx)
│   └── contracts/     BMEToken.sol, tests, deploy script
```

## References

- Voshmgir, S. (2020). Token Economy. Token Kitchen.
- Ethereum Foundation. [EIP-1559](https://eips.ethereum.org/EIPS/eip-1559)
- [Ultrasound Money](https://ultrasound.money)
- [Snapshot](https://snapshot.org)
- [Token Terminal](https://tokenterminal.com)
