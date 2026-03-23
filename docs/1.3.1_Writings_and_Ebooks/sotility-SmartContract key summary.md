# Sotility Ecosystem: Smart Contract Overview and Architecture

## Smart Contract Overview

### TOKEN LAYER

1. **SotilityStableToken (SST)**
   - Revenue-backed stablecoin (1:1 USD peg)
   - Minted only against verified business revenue
   - IPFS receipt tracking for transparent auditability
   - Only approved minters (SotilityExchange) can create tokens

2. **SotilityOwnershipToken (SOT)**
   - Equity token representing ownership in the Sotility ecosystem
   - Dividend-eligible from protocol revenue
   - Governance rights for protocol-level decisions
   - Initial supply: 1 billion tokens with predefined distribution

3. **SoGoodUtilityGovernance (SUG)**
   - Utility and governance token for the social platform
   - Time-locked to encourage long-term commitment
   - Earned through verified contributions to the ecosystem
   - Merit-based reward allocation with algorithmic distribution

4. **SotilityVeToken (veSOT)**
   - Vote-escrowed token implementation for SOT holders
   - Allows locking SOT for enhanced governance weight (up to 2x)
   - Linear decay mechanism for voting power as lock time decreases
   - Maximum lock time: 4 years

5. **SotilityLiquidStaking (lstSOT)**
   - Enables staking SOT while maintaining liquidity
   - Issues lstSOT tokens representing staked SOT plus accrued rewards
   - Dynamic exchange rate based on total rewards in the system
   - Maintains partial governance rights (0.8x multiplier)

### SOCIAL LAYER

6. **SoGoodFeed**
   - On-chain registry for social utility posts
   - AI-verified tipping mechanism
   - IPFS content storage with on-chain references
   - Tracks contribution and engagement history

7. **SotilityProfileRegistry**
   - Stores reputation metrics for ecosystem participants
   - Tracks Sotilitarian Status (long-term) and Utilitier Level/Score (short-term)
   - Four-tier system: Bronze, Silver, Gold, Platinum
   - Provides eligibility for rewards and governance boosts

8. **SotilityBadgeNFT**
   - Soulbound NFT badges for achievements and status
   - Non-transferable credentials for expertise and contribution
   - IPFS metadata for detailed achievement verification
   - Revocable by authorized minters if needed

9. **SotilityContentGovernance**
   - Decentralized content moderation with economic incentives
   - Stake-based moderation system with rewards for consensus
   - Slashing mechanism for misaligned votes
   - Escalation and dispute resolution framework

### FINANCIAL LAYER

10. **SotilityExchange**
    - Business onboarding and verification platform
    - Revenue proof submission and verification
    - SST issuance against verified revenue
    - Maintains registry of approved businesses

11. **SotilityTreasuryRouter**
    - Routes protocol revenue to different ecosystem components
    - Configurable allocation percentages (default: 40% SOT dividends, 40% SST reserves, 20% SUG campaigns)
    - Event-driven for transparent tracking
    - Updateable allocation targets for flexibility

12. **SotilityYieldEngine**
    - AI-managed yield strategies for protocol assets
    - Laddered leverage and risk-adjusted allocation
    - Strategy management for maximizing returns
    - Integration with external DeFi protocols

13. **SotilityVaultFactory**
    - Deploys isolated SotilityYieldEngine instances
    - Business-specific yield strategies
    - IPFS metadata storage for strategy documentation
    - Registry for tracking all deployed vaults

14. **SotilityBridgeAdapter**
    - Multi-chain token bridging facility
    - Chain registry with destination bridging contracts
    - AI-enhanced fraud detection for suspicious transactions
    - Event emission for relayer pickup

15. **SotilityAdaptiveTokenomics**
    - Automatically adjusts tokenomic parameters based on ecosystem health
    - Monitors user growth, retention, transaction value, content creation, and TVL
    - Adapts inflation rates, reward amounts, and economic parameters
    - Historical tracking for transparency and analysis

### DAO LAYER

16. **ProposalManager**
    - On-chain governance mechanism for protocol decisions
    - Time-based quorum and voting system
    - Multi-stage process (creation, signal voting, formal vote, execution)
    - IPFS integration for detailed proposal documentation

17. **SoGoodDAOFactory**
    - Deploys dedicated governance structures for communities
    - Customizable governance parameters
    - Enables localized decision-making
    - Integration with main protocol governance

### AI & SECURITY LAYER

18. **AIOracleManager**
    - Registry for verified AI oracle agents
    - Metadata tracking for version and capabilities
    - Access control for oracle activation/deactivation
    - Used by other contracts for verification requests

19. **MultiOracleAggregator**
    - Combines results from multiple AI oracles
    - Deviation thresholding for consensus
    - Sybil-resistant aggregation
    - Prevents oracle manipulation attacks

20. **AutonomousSoGoodAgent**
    - Off-chain AI agent for content evaluation
    - Monitors blockchain events
    - OpenAI integration for scoring
    - IPFS upload of evaluation results
    - Automatic on-chain transaction execution

21. **SotilityEmergencyShutdown**
    - Circuit breaker for security incidents
    - Timelocked emergency activation
    - Guardian committee control
    - Granular contract pausing capabilities

### IDENTITY & REPUTATION LAYER

22. **SotilityZKIdentity**
    - Zero-knowledge proofs of reputation and credentials
    - Privacy-preserving verification
    - Selective disclosure capabilities
    - Category-based proof verification

23. **SotilityCrossChainIdentity**
    - Aggregates identity and reputation from multiple blockchains
    - Weighted reputation scoring
    - Bridge-based verification
    - Chain-agnostic identity portability

24. **SotilityProofOfPersonhood**
    - Sybil-resistant human verification
    - Time-limited credentials with renewal
    - Revocation capabilities for fraudulent accounts
    - Privacy-preserving implementation

25. **SotilityInsurance**
    - Protocol insurance against exploits and failures
    - Policy-based coverage for ecosystem participants
    - Claim submission and processing workflow
    - Premium adjustments based on governance token holdings

## Sotility Ecosystem Architecture

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                                 SOTILITY ECOSYSTEM                                    │
└──────────────────────────────────────────────────────────────────────────────────────┘
                                          │
          ┌───────────────────┬───────────┼───────────┬───────────────────┐
          │                   │           │           │                   │
┌─────────▼─────────┐ ┌───────▼───────┐ ┌─▼─┐ ┌───────▼───────┐ ┌─────────▼─────────┐
│    TOKEN LAYER    │ │  SOCIAL LAYER │ │DAO│ │FINANCIAL LAYER│ │ IDENTITY LAYER    │
└─────────┬─────────┘ └───────┬───────┘ └─┬─┘ └───────┬───────┘ └─────────┬─────────┘
          │                   │           │           │                   │
┌─────────┴─────────┐ ┌───────┴───────┐ ┌─┴─┐ ┌───────┴───────┐ ┌─────────┴─────────┐
│• SST (Stable)     │ │• SoGoodFeed   │ │   │ │• Exchange     │ │• ZKIdentity      │
│• SOT (Ownership)  │ │• Profile      │ │   │ │• Treasury     │ │• CrossChain      │
│• SUG (Utility)    │ │  Registry     │ │   │ │  Router       │ │  Identity        │
│• veSOT            │ │• BadgeNFT     │ │   │ │• YieldEngine  │ │• ProofOfPerson   │
│• lstSOT           │ │• Content      │ │   │ │• VaultFactory │ │  hood            │
│                   │ │  Governance   │ │   │ │• Bridge       │ │• Insurance       │
└───────────────────┘ └───────────────┘ └───┘ └───────────────┘ └───────────────────┘
                                          │                              
                          ┌───────────────┴────────────────┐              
                          │                                │              
                 ┌────────▼─────────┐         ┌────────────▼───────┐     
                 │  AI & SECURITY   │         │   GOVERNANCE       │     
                 └────────┬─────────┘         └────────────┬───────┘     
                          │                                │              
                 ┌────────┴─────────┐         ┌────────────┴───────┐     
                 │• AIOracleManager │         │• ProposalManager   │     
                 │• MultiOracle     │         │• SoGoodDAOFactory  │     
                 │  Aggregator      │         │• Guardian Committee│     
                 │• Autonomous      │         │• Dispute Resolution│     
                 │  SoGoodAgent     │         └────────────────────┘     
                 │• Emergency       │                                    
                 │  Shutdown        │                                    
                 └──────────────────┘                                    
```

## AI & Security Architecture

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                          AI & SECURITY LAYER                                    │
└────────────────────────────────────────────────────────────────────────────────┘
                                     │
      ┌─────────────────┬────────────┼─────────────┬─────────────────┐
      │                 │            │             │                 │
┌─────▼─────┐    ┌──────▼─────┐ ┌────▼────┐  ┌─────▼─────┐    ┌──────▼─────┐
│ Oracle    │    │ Multi      │ │Autonomous│  │ Emergency │    │ Insurance  │
│ Manager   │    │ Oracle     │ │ Agent    │  │ Shutdown  │    │ Protocol   │
└───────────┘    └────────────┘ └──────────┘  └───────────┘    └────────────┘
      │                 │            │             │                 │
      │                 │            │             │                 │
┌─────▼─────┐    ┌──────▼─────┐ ┌────▼────┐  ┌─────▼─────┐    ┌──────▼─────┐
│Registry of│    │Consensus-  │ │OpenAI   │  │Circuit    │    │Policy-     │
│verified AI│    │based score │ │scoring  │  │breaker for│    │based       │
│oracles    │    │aggregation │ │& IPFS   │  │emergencies│    │protection  │
│with roles │    │with fraud  │ │storage  │  │with       │    │with        │
│and access │    │detection   │ │& on-chain│ │timelock   │    │claims      │
│control    │    │mechanisms  │ │callbacks │ │activation │    │processing  │
└───────────┘    └────────────┘ └──────────┘  └───────────┘    └────────────┘
```

## Governance Framework

```
┌───────────────────────────────────────────────────────────────────────────┐
│                         SOTILITY GOVERNANCE STACK                          │
└───────────────────────────────────────────────────────────────────────────┘
                                     │
          ┌─────────────────────────┼─────────────────────────┐
          │                         │                         │
┌─────────▼─────────┐     ┌─────────▼─────────┐     ┌─────────▼─────────┐
│  PROTOCOL-LEVEL   │     │  COMMUNITY-LEVEL  │     │   CONTENT-LEVEL   │
│    GOVERNANCE     │     │    GOVERNANCE     │     │    GOVERNANCE     │
└─────────┬─────────┘     └─────────┬─────────┘     └─────────┬─────────┘
          │                         │                         │
┌─────────▼─────────┐     ┌─────────▼─────────┐     ┌─────────▼─────────┐
│• veSOT voting     │     │• Community DAOs   │     │• AI evaluation    │
│• Treasury usage   │     │• Local rules      │     │• Human moderation │
│• Param changes    │     │• Local resource   │     │• Dispute process  │
│• Contract upgrades│     │  allocation       │     │• Rewards & badges │
└───────────────────┘     └───────────────────┘     └───────────────────┘
```

## Protocol-Level Governance Flow

```
┌───────────┐     ┌───────────┐     ┌───────────┐     ┌───────────┐
│  Proposal │────►│   Signal  │────►│  Formal   │────►│ TimeGap   │
│ Creation  │     │  Voting   │     │   Vote    │     │  Period   │
└───────────┘     └───────────┘     └───────────┘     └─────┬─────┘
                                                            │
┌───────────┐     ┌───────────┐     ┌───────────┐     ┌─────▼─────┐
│Transaction│◄────│  Action   │◄────│  Executor │◄────│  Quorum   │
│ Execution │     │ Queueing  │     │ Selection │     │  Check    │
└───────────┘     └───────────┘     └───────────┘     └───────────┘
```

## Token Distribution Model

### SOT (SotilityOwnershipToken)

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

### SUG (SoGoodUtilityGovernance)

| Allocation Category | Percentage | Amount (Millions) | Distribution Schedule |
|---------------------|------------|-------------------|------------------------|
| Content Rewards | 50% | 125 | Continuous algorithmic distribution |
| DAO Treasury | 20% | 50 | Controlled by governance |
| Community Airdrops | 10% | 25 | Quarterly merit-based distributions |
| Platform Development | 15% | 37.5 | 3-year quarterly release |
| Early Adopter Incentives | 5% | 12.5 | First-year campaign rewards |
| **Total** | **100%** | **250** | |

### Protocol Revenue Allocation

| Allocation | Percentage | Purpose |
|------------|------------|---------|
| SOT Dividends | 40% | Distributed to SOT holders |
| SST Reserves | 40% | Backs SST stability and new mints |
| SUG Campaigns | 20% | Funds ecosystem growth and rewards |

## Key Features & Innovations

1. **AI-Powered Verification**: Autonomous AI agents that verify content quality and business revenue without requiring user understanding of blockchain technology.

2. **Multi-Token Economic Model**: Three-tier system (SOT, SUG, SST) creates separation of concerns while enabling powerful cross-token interactions.

3. **Reputation-Enhanced Economics**: Financial activities are weighted by reputation, creating meritocratic incentives aligned with positive social impact.

4. **Privacy-Preserving Identity**: Zero-knowledge proofs enable credential verification without revealing underlying data.

5. **Adaptive Tokenomics**: Automatically adjusts economic parameters based on ecosystem health metrics, creating counter-cyclical stability.

6. **Multi-Layered Governance**: Three interconnected governance layers (protocol, community, content) with appropriate mechanisms for each.

7. **Cross-Chain Identity Graph**: Unified reputation aggregation across multiple blockchains creates portable trust.

8. **Revenue-Backed Stability**: SST stablecoin backed by verified business revenue rather than traditional collateral.

9. **Liquid Governance**: Vote-escrowed and liquid staking mechanics enable capital efficiency without sacrificing governance rights.

10. **Progressive Decentralization Path**: Clear roadmap from centralized bootstrapping to fully decentralized community ownership.