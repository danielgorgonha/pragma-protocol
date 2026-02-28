# Case Study: Ethereum EIP-1559

Burn mechanism, deflationary periods, and implications for investors.

Tokenomics — Lesson 02. Data: ultrasound.money (February 2026). Author: Daniel Gorgonha, Pragma Protocol.

## 1. The ETH burn mechanism

The London Hard Fork (August 2021) introduced EIP-1559: a protocol-set **base fee** and an optional validator tip. The base fee is **permanently destroyed** instead of going to miners.

Each unit of gas consumed burns the corresponding base fee, reducing ETH supply in line with network usage.

Monetary balance:

```
ΔSupply = Emission − Burn
```

When burn exceeds daily emission to validators (~1,700 ETH/day since The Merge), net supply falls. ultrasound.money reports over 4.4 million ETH destroyed since August 2021.

## 2. Deflationary vs inflationary periods

| Period        | Context                    | Burn/day (ETH) | Emission/day | Net supply        |
|---------------|----------------------------|----------------|--------------|--------------------|
| Aug–Dec 2021  | Bull, DeFi/NFTs             | 8k–20k         | ~13k (PoW)   | Predom. inflationary |
| Sep 2022      | Merge, PoS                 | 4k–6k          | ~1.7k        | Deflationary       |
| Nov 2022      | Post-FTX, low activity     | 1k–1.5k        | ~1.7k        | Mildly inflationary |
| Mar–May 2023  | Resurgence                 | 3k–5k          | ~1.7k        | Deflationary       |
| 2024          | L2 growth                  | 2k–3.5k        | ~1.7k        | Variable           |
| Jan 2026      | High L1+L2 activity       | 3.5k–5k        | ~1.7k        | Deflationary       |

The Merge (September 2022) cut emission by ~90%. In bear markets with low usage, emission can exceed burn; ETH becomes mildly inflationary (~0.1–0.3% per year). Annualised inflation:

```
(Emission − Burn) × 365 / Total Supply
```

With ~1,700 emitted and ~1,200 burned per day on ~120M supply: inflation ≈ 0.15% p.a.

## 3. Implications for investors

EIP-1559 creates **demand-driven supply** — unlike Bitcoin’s fixed schedule. Burn rate acts as a leading indicator of network activity.

Three structural risks:

1. **Usage-dependent deflation** — In prolonged bear markets, burn can fall below emission. ETH has no guarantee of absolute scarcity; contraction depends on activity.
2. **L2 compression** — Arbitrum, Base, Optimism etc. reduce burn per unit of activity; risk is compression, not elimination.
3. **Protocol risk** — Ethereum governance can change burn or emission rules.

Summary: post–EIP-1559 ETH has greater deflationary potential than Bitcoin but lower monetary predictability. The investment thesis is that adoption keeps supply neutral or declining; ultrasound.money allows monitoring in real time.

## References

- Ethereum Foundation. [EIP-1559](https://eips.ethereum.org/EIPS/eip-1559)
- [Ultrasound Money](https://ultrasound.money)
- Ethereum Foundation. [The Merge](https://ethereum.org/en/roadmap/merge)
- Roughgarden, T. (2021). Transaction Fee Mechanism Design for the Ethereum Blockchain. arXiv:2012.00854
