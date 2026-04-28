# Appendix B: Token Distribution Model

## 1. SOT (SotilityOwnershipToken) Distribution

The SOT token represents equity ownership in the Sotility ecosystem and confers dividend rights and governance authority.

### 1.1 Initial Distribution

| Allocation Category | Percentage | Amount (Millions) | Vesting Period |
|---------------------|------------|-------------------|----------------|
| Treasury | 20% | 200 | Strategic releases by DAO vote |
| Team & Early Contributors | 15% | 150 | 2-year cliff, 4-year linear vesting |
| Ecosystem Development | 25% | 250 | Quarterly releases over 5 years |
| Initial Community Sale | 10% | 100 | Immediate (liquid) |
| Seed & Strategic Investors | 15% | 150 | 1-year cliff, 3-year linear vesting |
| Liquidity Provision | 10% | 100 | 80% initially locked for 2 years |
| Advisors & Partners | 5% | 50 | 1-year cliff, 2-year linear vesting |
| **Total** | **100%** | **1,000** | |

### 1.2 Vesting Schedule

The following chart illustrates the SOT token release schedule over 5 years:

```
SOT Token Release Schedule (Millions)
1000 │                                       ┌─────
     │                                  ┌────┘
 800 │                            ┌────┘
     │                       ┌────┘
 600 │                  ┌────┘
     │             ┌────┘
 400 │        ┌────┘
     │   ┌────┘
 200 │┌──┘
     │
   0 └───────────────────────────────────────────────
     0    1     2     3     4     5    Years
```

### 1.3 Governance Weighting

SOT tokens locked in the SotilityVeToken contract receive enhanced governance weight:
- 1-year lock: 1.25x voting power
- 2-year lock: 1.5x voting power
- 3-year lock: 1.75x voting power
- 4-year lock: 2x voting power

## 2. SUG (SoGoodUtilityGovernance) Distribution

The SUG token serves as a governance and utility token within the SoGood social platform, rewarding valuable content and transparent contributions.

### 2.1 Token Economics

**Supply Model**: Algorithmically controlled inflation with decay mechanism
- Initial supply: 250 million SUG
- Maximum annual inflation rate: 15% (Year 1), decreasing by 2% each year until stabilizing at 5%

### 2.2 Allocation Structure

| Allocation Category | Percentage | Amount (Millions) | Distribution Schedule |
|---------------------|------------|-------------------|------------------------|
| Content Rewards | 50% | 125 | Continuous algorithmic distribution |
| DAO Treasury | 20% | 50 | Controlled by governance |
| Community Airdrops | 10% | 25 | Quarterly merit-based distributions |
| Platform Development | 15% | 37.5 | 3-year quarterly release |
| Early Adopter Incentives | 5% | 12.5 | First-year campaign rewards |
| **Total** | **100%** | **250** | |

### 2.3 Merit-Based Content Rewards

SUG token rewards follow a transparent algorithm with the following parameters:
- Base reward per verified positive contribution: 0.1-10 SUG
- Multipliers based on:
  - Utilitier Level (Bronze: 1x, Silver: 1.2x, Gold: 1.5x, Platinum: 2x)
  - Content quality score (AI-verified)
  - Long-term impact measurement (recursive citations/use)
  - Geographic diversity bonuses

## 3. SST (SotilityStableToken) Mechanism

The SST token is a revenue-backed stablecoin pegged 1:1 to USD, minted only against verified business revenue.

### 3.1 Minting and Collateralization

- SST can only be minted by the SotilityExchange contract when verified revenue proof is submitted
- Each SST is backed by 1 USD equivalent of verified business revenue
- IPFS receipts provide transparent audit trails for all mint events
- Emergency redemption mechanism ensures stability

### 3.2 Protocol Revenue Allocation

Revenue collected by the protocol (from fees, services, etc.) is allocated as follows through the SotilityTreasuryRouter:

| Allocation | Percentage | Purpose |
|------------|------------|---------|
| SOT Dividends | 40% | Distributed to SOT holders |
| SST Reserves | 40% | Backs SST stability and new mints |
| SUG Campaigns | 20% | Funds ecosystem growth and rewards |

### 3.3 Anti-Inflation Mechanism

To maintain SST's value and prevent inflation:
- All SST in circulation must be backed by verified revenue
- Minting requires multisig approval and oracle verification
- Regular audits of backing reserves ensure transparency
- Any unbacked SST can be instantly bought back and burned by the protocol

## 4. Liquid Staking Mechanics

The Sotility Liquid Staking system promotes capital efficiency by allowing staked assets to be used throughout the ecosystem:

### 4.1 lstSOT (Liquid Staked SOT)

Users staking SOT receive lstSOT at the current exchange rate, which:
- Represents their staked SOT plus accrued rewards
- Can be used in yield strategies across the ecosystem
- Maintains governance rights (but at a 0.8x multiplier compared to direct SOT voting)
- Can be exchanged back for SOT (plus rewards) at any time

### 4.2 Exchange Rate Mechanism

The lstSOT to SOT exchange rate follows a compounding formula:
```
exchangeRate = (totalStakedSOT + totalRewards) / totalLstSOTSupply
```

This ensures that lstSOT automatically increases in value relative to SOT as rewards accumulate.

## 5. Cross-Token Interactions

The Sotility ecosystem creates powerful synergies between its tokens:

### 5.1 Reputation-Enhanced Yield

- Higher Utilitier Levels (from SUG activity) unlock enhanced SOT staking yields
- SoulBound reputation tokens can unlock preferential SST minting rates for businesses

### 5.2 Governance Multipliers

Users can amplify their governance weight through various mechanisms:
- Long-term SOT locking (via veSOT)
- Active SoGood social participation (SUG accumulation)
- Reputation badges (SoulBound NFTs)

This creates a system where both financial stake and positive contribution are rewarded with governance authority.