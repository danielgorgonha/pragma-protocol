# Autopsy de Tokenomics: Axie Infinity
### Economia Dual-Token, Espiral Inflacionária e Redesign

**Curso:** Economia Tokenizada (Tokenomics) — NearX  
**Atividade:** Aula 03 — Obrigatória  
**Autor:** Daniel Gorgonha  
**Data:** Março 2026

---

## 1. Introdução

Poucos casos na história do Web3 são tão instrutivos quanto o Axie Infinity. O jogo da Sky Mavis chegou a **2,7 milhões de jogadores ativos diários** e **US$ 1,3 bilhão em receita em 2021** — números que rivalizavam com games tradicionais. Dois anos depois, a economia havia colapsado mais de **99%**. Analistas da Naavik e da Delphi Digital descreveram a estrutura como "Ponzi-adjacente". A própria Sky Mavis confirmou o diagnóstico em fevereiro de 2022, admitindo risco de *"colapso total e permanente"* do ecossistema.

O que exatamente deu errado? Este relatório percorre três eixos: como SLP e AXS interagiam mecanicamente, por que a economia entrou em espiral inflacionária e o que um redesign estrutural poderia ter feito diferente — com referência ao modelo veTokenomics da Curve Finance e ao real yield da Aave.

---

## 2. A Mecânica Dual-Token que Sustentou a Bolha

O sistema do Axie girava em torno de dois tokens com funções distintas, mas fatalmente dependentes um do outro.

### 2.1 SLP — Smooth Love Potion (token de recompensa)

Na prática, o SLP funcionava como salário dos jogadores. Era emitido de três formas: modo Aventura (PvE) pagava até **100 SLP/dia** antes da Season 18; missões diárias adicionavam **50 SLP/dia**; e o Arena PvP rendia de 1 a 21 SLP por vitória, conforme o ranking. Um jogador médio acumulava **170–200 SLP/dia** no pico — e o supply não tinha teto.

O único mecanismo real de queima era o **breeding**. Criar um novo Axie consumia SLP de forma crescente: **150 SLP** no primeiro breed, chegando a **3.150 SLP** no sétimo. A Season 19 dobrou esses custos; em dezembro de 2021 foram triplicados. Mas naquele momento a economia já estava desequilibrada e as correções chegaram tarde.

### 2.2 AXS — Axie Infinity Shards (token de governança)

O AXS tinha supply fixo de **270 milhões de tokens**, distribuídos entre staking rewards (29%), equipe Sky Mavis (21%), play-to-earn (20%), venda pública (11%) e fundo do ecossistema (8%). Quando o staking foi lançado em **30 de setembro de 2021**, o APY inicial era de ~400% — caindo para ~190% em outubro. O incentivo era poderoso, mas alimentado inteiramente por emissão, não por receita real.

Há um detalhe importante sobre o breeding: o AXS gasto **não era queimado**. Era depositado no Community Treasury. Isso criava pressão de compra sobre o AXS sem reduzir o supply em circulação — sustentando o preço enquanto a receita do protocolo dependia, cada vez mais, da entrada de novos jogadores.

### 2.3 O ciclo reflexivo e sua fragilidade

O fluxo econômico era elegante no papel: *(1) jogadores ganham SLP → (2) breeders usam SLP + AXS para criar Axies → (3) novos Axies vão ao marketplace → (4) novos jogadores entram para ganhar SLP*. A Sky Mavis capturava **4,25%** em cada venda do marketplace.

O problema é que o ciclo inteiro dependia de uma condição: crescimento contínuo de novos jogadores. O próprio whitepaper reconhecia isso: *"In the beginning, by design the Axie economy will be dependent on new entrants."* O que faltava era qualquer mecanismo de transição para quando esse crescimento, inevitavelmente, desacelerasse.

---

## 3. A Espiral Inflacionária: Causas e Aceleradores

### 3.1 Hiperinflação do SLP

Os números falam por si. Em janeiro de 2022, a Sky Mavis admitiu que a criação de SLP havia crescido **160x (16.000%)** ao longo de 2021. Dados on-chain de julho de 2021 já mostravam o problema: **208 milhões de SLP emitidos em um único dia contra apenas 37 milhões queimados** — uma razão de **5,6:1**. No início de 2022, essa proporção havia piorado para ~**6,25:1** (250M emitidos vs. 40M queimados por dia). E 84% das emissões vinham de Adventure e Daily Quests — modos que não exigiam nenhuma habilidade específica.

O resultado era previsível. O supply total saltou de **541,7 milhões** em julho de 2021 para **5,13 bilhões** seis meses depois. Antes de o cap ser imposto em 2024, o supply havia ultrapassado os 41 bilhões de tokens.

### 3.2 Dependência estrutural de novos entrantes

O sistema de **scholars** tornava tudo ainda mais frágil. Nele, "managers" emprestavam equipes de Axies a jogadores em troca de 40–70% dos ganhos. Mais de 1,5 milhão de scholars foram registrados via guilds como a Yield Guild Games. O detalhe crítico: a grande maioria vendia o SLP imediatamente para cobrir despesas do dia a dia — criando pressão de venda constante e estrutural sobre o token.

Quando o crescimento de novos jogadores desacelerou no Q4 2021, a lógica do ciclo se inverteu: menos compradores de Axies → menos breeding → menos queima de SLP → mais inflação → SLP desvaloriza → ganhos caem → jogadores saem → menos compradores ainda.

| Período | Preço SLP | DAU | Receita Mensal |
|---|---|---|---|
| Jul/2021 (pré-pico) | US$ 0,15 | ~1M | ~US$ 84,9M |
| Nov/2021 (ATH AXS) | US$ 0,07 | **2,7M** | US$ 364M |
| Jan/2022 | US$ 0,01 | ~1,5M | US$ 30M |
| Jun/2022 | US$ 0,003 | ~400K | US$ 2M |
| Dez/2022 | US$ 0,002 | ~100K | US$ 330K |
| 2024 (atual) | US$ 0,001 | ~53K | ~US$ 330K/mês |

### 3.3 O hack da Ronin Bridge — o acelerador final

Em **23 de março de 2022**, atacantes associados ao **Lazarus Group** (Coreia do Norte) comprometeram 5 dos 9 validadores da rede Ronin via engenharia social e roubaram **173.600 ETH + 25,5 milhões de USDC** — cerca de **US$ 620–625 milhões** no total, o maior exploit DeFi registrado até então. O hack só foi descoberto **seis dias depois**, quando um usuário tentou sacar 5.000 ETH e percebeu que o dinheiro não estava lá. O FBI confirmou a autoria em abril de 2022. Para compensar as vítimas, a Sky Mavis levantou **US$ 150 milhões** em rodada emergencial e expandiu os validadores de 9 para mais de 18.

Vale deixar claro: o hack não causou o colapso econômico. Ele já estava em curso desde janeiro. O que o hack fez foi destruir a confiança que restava. O sinal mais contundente veio de quem menos se esperava: a **Delphi Digital**, que havia **projetado o próprio AXS**, vendeu toda a sua posição de 600.000 tokens via Coinbase. Quando os arquitetos saem, a mensagem é clara.

---

## 4. O Redesign que Poderia ter Evitado o Colapso

### 4.1 O que a Sky Mavis tentou (e quando)

As tentativas de correção vieram, mas sempre atrasadas.

**Fevereiro 2022 (Season 20):** Emissões de SLP de Adventure e Daily Quests foram zeradas, eliminando ~56% da emissão diária de uma vez. O AXS subiu 40% no curto prazo.

**Abril 2022 (Axie Origin):** Lançamento do modelo free-to-play com Axies iniciais gratuitos — eliminando a barreira de entrada de US$ 1.000+ que havia travado o crescimento. Novos sinks de SLP foram introduzidos via Runes e Charms sazonais.

**2024:** Supply de SLP formalmente limitado a **44 bilhões** + Stability Fund de US$ 60.000 para compras programáticas. Em 2023, pela primeira vez, o SLP tornou-se deflacionário: -2,8% ao ano.

**Janeiro 2026 (bAXS):** Token ERC-20 vinculado 1:1 ao AXS mas **intransferível por padrão**, com taxas de conversão baseadas em reputação via Axie Score. O AXS subiu **123%** no anúncio — confirmando que o mercado teria recebido bem esse mecanismo muito antes.

### 4.2 O que deveria ter existido desde o início

**Emissão adaptativa (BME-like):** O SLP precisava de um freio automático. Uma fórmula simples resolveria: quando a razão `supply_circulante / supply_queimado` excedesse 3:1, a emissão diária cairia 20% automaticamente. É o mesmo princípio do BME Token analisado na Aula 02 — e teria evitado a hiperinflação sem depender de intervenções manuais de emergência.

**veAXS — velocity control via lock temporal:** Inspirado no veCRV da Curve Finance, o mecanismo funcionaria assim: jogadores bloqueiam AXS por 1 semana a 6 meses e recebem em troca (a) multiplicador de ganhos de SLP de até 2x, (b) voto na distribuição de recompensas entre modos de jogo e (c) parcela das taxas do marketplace. Guilds como a YGG passariam a competir por veAXS, replicando a dinâmica das Curve Wars — e criando **demanda estrutural por AXS que não dependeria de novos jogadores entrando no sistema**.

**Múltiplos sinks de SLP:** Ter o breeding como único mecanismo de queima era uma fragilidade óbvia. Alternativas que distribuiriam a demanda: crafting de itens consumíveis, staking de SLP para boost no Arena, queima para reduzir cooldowns de breeding. Quanto mais vetores de consumo, mais resiliente a economia.

**Receita real como base:** A Aave ganha dinheiro com spread sobre capital real depositado — independente de quantos novos usuários entram a cada semana. O Axie chegou a **US$ 364M/mês em agosto de 2021**. O problema é que não construiu os mecanismos necessários para sustentar essa receita quando o crescimento inevitavelmente desacelerou.

---

## 5. Comparativo Estrutural

| Critério | Axie Infinity | Curve Finance | Aave |
|---|---|---|---|
| **Modelo de receita** | Taxas de marketplace (4,25%) | Trading fees (50% para veCRV) | Spread de lending + flash loans |
| **Receita anual** | ~US$ 4M (2024); pico US$ 1,3B | ~US$ 13,6M para holders (2025) | **US$ 141,8M** (2025) |
| **Sustentabilidade** | ❌ Insustentável (original) | ⚠️ Moderada | ✅ Alta |
| **Controle de supply** | SLP ilimitado até 2024 | Lock de até 4 anos (~42% bloqueado) | Supply fixo + buyback US$ 50M/ano |
| **Sink principal** | Breeding (único) | veCRV lock (intransferível) | Safety Module + buyback |
| **Velocidade (V)** | **Muito alta** (earn-and-dump) | **Muito baixa** (lock médio 3,65 anos) | Baixa-moderada |
| **Real yield** | Inexistente (receita << emissões) | US$ 159M em 5 anos | US$ 142,9M rolling anual |
| **Resultado** | Colapso 99%+ | Referência DeFi | Líder em lending |

---

## 6. Conclusão

O colapso do Axie não foi surpresa — foi a conclusão lógica de três falhas de design empilhadas: **emissão ilimitada** sem queima proporcional, **sink único** dependente de crescimento exponencial de usuários, e **velocidade descontrolada** num modelo onde jogadores precisavam converter tudo em fiat para sobreviver. O hack da Ronin acelerou o processo, mas não o causou.

O comparativo com Curve e Aave deixa claro o caminho: economias tokenizadas sustentáveis precisam de **receita real independente de crescimento de userbase**, de sinks distribuídos em múltiplos vetores e de mecanismos que reduzam a velocidade de circulação dos tokens. O bAXS lançado em 2026 é, na prática, a confirmação de que princípios ve-like eram a resposta certa — só chegaram com quatro anos de atraso.

A lição central continua simples: **tokens de utilidade precisam de demanda real, não forçada**. É exatamente o princípio que orienta o design do Pragma Token (PGM) desde a Aula 01.

---

## Referências

- Sky Mavis. *Dev Journal: Economic Balancing* (fev. 2022). blog.axieinfinity.com  
- Sky Mavis. *Axie Economy & Long-term Sustainability*. whitepaper.axieinfinity.com  
- Naavik. *Axie Infinity Part 2: Redemption or Ruin?* (2022). naavik.co  
- Outlier Ventures. *Understanding P2E 2.0: Axie Infinity Deep Dive* (2022).  
- Delphi Digital. *Ethereum Burns, Axie's Inflection Point* (2021).  
- Nansen Research. *Curve Finance and veCRV Tokenomics* (2023).  
- CoinDesk. *Axie Infinity Reduces SLP Emissions to Prevent 'Collapse'* (fev. 2022).  
- Cointelegraph. *The aftermath of Axie Infinity's $650M Ronin Bridge hack* (2022).  
- Aave. *Safety Module documentation*. docs.aave.com  
- Curve Finance. *veCRV Overview*. resources.curve.finance  
