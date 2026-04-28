# Appendix A: Smart Contract Architecture Diagram

## Sotility Ecosystem Architecture

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                                 SOTILITY ECOSYSTEM                                    │
└──────────────────────────────────────────────────────────────────────────────────────┘
                                          │
                ┌───────────────────┬─────┴─────┬───────────────────┐
                │                   │           │                   │
┌───────────────▼───────────┐  ┌────▼────┐  ┌───▼───┐  ┌───────────▼───────────┐
│    TOKEN LAYER            │  │ SOCIAL  │  │  DAO  │  │   FINANCIAL LAYER     │
└───────────────┬───────────┘  │  LAYER  │  │ LAYER │  └───────────┬───────────┘
                │              └────┬────┘  └───┬───┘              │
     ┌──────────┴──────────┐       │           │       ┌───────────┴────────────┐
     │                     │       │           │       │                        │
┌────▼─────┐  ┌────────────▼┐  ┌───▼───┐  ┌────▼────┐ │ ┌──────────┐  ┌────────▼─────┐
│   SST    │  │    SOT      │  │SoGood │  │Proposal │ │ │ Sotility │  │  Sotility    │
│(Stable)  │  │(Ownership)  │  │ Feed  │  │Manager  │ │ │ Exchange │  │  YieldEngine │
└────┬─────┘  └────────────┬┘  └───┬───┘  └────┬────┘ │ └─────┬────┘  └──────┬───────┘
     │                     │       │           │       │       │             │
┌────▼─────┐  ┌────────────▼┐  ┌───▼───┐  ┌────▼────┐ │ ┌─────▼────┐  ┌──────▼───────┐
│SotilityVe│  │    SUG      │  │Profile│  │SoGoodDAO│ │ │Business  │  │ Sotility     │
│  Token   │  │ (Utility)   │  │Registry│ │Factory  │ │ │Registry  │  │VaultFactory  │
└──────────┘  └─────────────┘  └───────┘  └─────────┘ │ └──────────┘  └──────────────┘
                                                       │
                                           ┌───────────┴────────────┐
                                           │                        │
                                       ┌───▼────────┐  ┌────────────▼─┐
                                       │ Treasury   │  │  Bridge     │
                                       │  Router    │  │  Adapter    │
                                       └────────────┘  └──────────────┘
```

## AI & Security Layer

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                          AI & SECURITY LAYER                                    │
└────────────────────────────────────────────────────────────────────────────────┘
                                     │
          ┌───────────────┬──────────┴─────────┬────────────────┐
          │               │                    │                │
┌─────────▼──────┐ ┌──────▼───────┐ ┌──────────▼────────┐ ┌────▼────────────┐
│  AIOracle      │ │ Autonomous   │ │ MultiOracle       │ │ Emergency       │
│  Manager       │ │ SoGoodAgent  │ │ Aggregator        │ │ Shutdown        │
└────────────────┘ └──────────────┘ └───────────────────┘ └─────────────────┘
```

## Identity & Reputation Layer

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                      IDENTITY & REPUTATION LAYER                                │
└────────────────────────────────────────────────────────────────────────────────┘
                                     │
                 ┌──────────────────┬┴─────────────────┐
                 │                  │                  │
┌────────────────▼───┐ ┌────────────▼────────┐ ┌──────▼─────────────┐
│ SotilityBadgeNFT   │ │ SotilityProfile     │ │ SotilityProof      │
│ (Soulbound)        │ │ Registry            │ │ ofPersonhood       │
└────────────────────┘ └─────────────────────┘ └────────────────────┘
```

## Cross-Contract Interactions

The Sotility ecosystem features extensive integration between contracts, with key interactions including:

1. **Token Interactions**:
   - SOT holders can lock tokens in SotilityVeToken for enhanced governance rights
   - SUG tokens are awarded by SoGoodFeed for valuable content contributions
   - SST is minted against verified revenue through SotilityExchange

2. **Social Layer & Verification**:
   - AIOracleManager verifies posts in SoGoodFeed
   - MultiOracleAggregator combines data from multiple AI sources for enhanced security
   - AutonomousSoGoodAgent monitors blockchain, evaluates content, and calls back contracts

3. **Financial Flows**:
   - SotilityTreasuryRouter directs protocol revenue to SOT dividends, SST minting, and SUG rewards
   - SotilityVaultFactory deploys isolated yield engines for different businesses
   - SotilityYieldEngine manages staking strategies with AI optimization

4. **Governance & Security**:
   - Emergency Shutdown can pause contracts during security incidents
   - ProposalManager facilitates on-chain governance voting
   - SoGoodDAOFactory deploys community-specific governance structures

This architecture maintains clear separation of concerns while ensuring secure cross-contract communication and modularity for future upgrades.