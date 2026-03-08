# Aula 03 — Utility Tokens & Análise de Casos

## Atividade obrigatória: Autopsy de Tokenomics — Axie Infinity

Relatório analisando a ascensão e colapso da economia dual-token do Axie Infinity (SLP + AXS), as causas da espiral inflacionária e um redesign baseado em princípios de velocity control (veTokenomics) e real yield.

### Conteúdo

| Arquivo | Descrição |
|---|---|
| `reports/Axie_Autopsy.md` | Relatório completo em Markdown |
| `reports/Axie_Autopsy.docx` | Relatório formatado em Word |

### Principais pontos do relatório

- Mecânica dual-token SLP/AXS e o ciclo reflexivo de dependência de novos entrantes
- Espiral inflacionária: razão emissão/queima de 6,25:1, supply SLP saltando de 541M para 41B
- Colapso em dados: DAU de 2,7M → 53K (-98%), receita de US$364M/mês → US$330K (-99,9%)
- Hack Ronin Bridge (US$625M, Lazarus Group) como acelerador, não causa
- Redesign proposto: emissão adaptativa (BME-like), veAXS para velocity control, múltiplos sinks
- Comparativo estrutural: Axie vs Curve Finance (veTokenomics) vs Aave (real yield)

---

## Atividade bônus: Pragma Access Gate — DApp

DApp de página única demonstrando a utilidade do PGM Token deployado na Aula 01. Conecta à MetaMask (Sepolia), lê o saldo PGM e exibe o nível de acesso do usuário ao ecossistema Pragma Protocol.

### Conteúdo

| Arquivo | Descrição |
|---|---|
| `dapp/index.html` | DApp completa — single file, sem build step |

### Como usar

1. Abra `dapp/index.html` no browser (ou sirva com `npx serve dapp/`)
2. Conecte MetaMask na rede **Sepolia Testnet**
3. O DApp lê o saldo PGM e exibe o tier de acesso automaticamente
4. Use o formulário de transferência para enviar PGM

### Níveis de acesso (PGM gating)

| Tier | Requisito | Benefícios |
|---|---|---|
| 👑 Premium | ≥ 500 PGM | Marketplace completo, analytics avançado, fee reduzida |
| 🛒 Buyer | ≥ 200 PGM | Acesso ao marketplace para compra de serviços |
| 🔒 Sem acesso | < 200 PGM | Obter PGM via faucet ou compra |

### Contrato

| Contrato | Endereço | Rede |
|---|---|---|
| PragmaToken (PGM) | `0xC7b1Fff31eC9ce8075C1fCE0339E751135e310eb` | Sepolia |

[Ver no Etherscan](https://sepolia.etherscan.io/address/0xC7b1Fff31eC9ce8075C1fCE0339E751135e310eb)

### Stack

- HTML + CSS + Vanilla JS (sem framework)
- [ethers.js v5](https://docs.ethers.org/v5/) via CDN
- MetaMask para assinatura de transações

---

## Conexão com as aulas anteriores

Esta atividade fecha o arco narrativo do repositório:

- **Aula 01** definiu o PGM Token com dupla função (pagamento + acesso) e supply fixo de 10M
- **Aula 02** adicionou o mecanismo de queima adaptativa (BME) que teria evitado o colapso do Axie
- **Aula 03** analisa o colapso do Axie como caso de estudo e demonstra a utilidade do PGM via DApp

O design do PGM evita os erros do Axie com supply fixo, fee direcionada ao ecossistema e gating de acesso que cria razão genuína para manter o token — demanda real, não forçada.
