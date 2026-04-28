# Sotility Smart Contract Suite

Complete smart contract documentation and code for the Sotilitarian ecosystem, built on Solidity for EVM-compatible blockchains.

## Contract Registry

### Token Contracts (`contracts/tokens/`)

| Contract | Token | Description |
|----------|-------|-------------|
| `SotilityOwnershipToken.sol` | SOT | Governance token — voting, proposals, steward elections |
| `SoGoodUtilityGovernance.sol` | SUG | Utility token — platform access, contribution rewards |
| `SotilityStableToken.sol` | SST | Stablecoin — USD-pegged for transactions and treasury |

### DeFi Contracts (`contracts/defi/`)

| Contract | Description |
|----------|-------------|
| `SotilityExchange.sol` | Decentralized exchange for SOT/SUG/SST trading |
| `SotilityYieldEngine.sol` | Autonomous yield generation through flash loans and arbitrage |
| `SotilityTreasuryRouter.sol` | Community treasury management and fund allocation |
| `SotilityVaultFactory.sol` | Factory for creating and managing investment vaults |

### Governance Contracts (`contracts/governance/`)

| Contract | Description |
|----------|-------------|
| `ProposalManager.sol` | Governance proposal lifecycle — creation, voting, execution |
| `SoGoodDAOFactory.sol` | Factory for creating DAOs within the Sotilitarian ecosystem |
| `BusinessRegistry.sol` | On-chain registry for participating businesses |

### Social Contracts (`contracts/social/`)

| Contract | Description |
|----------|-------------|
| `SotilityProfileRegistry.sol` | On-chain identity and profile management |
| `SoGoodFeed.sol` | Social feed for community interaction |
| `SotilityBadgeNFT.sol` | Achievement and contribution badge NFTs |

### Infrastructure (`contracts/infrastructure/`)

| Contract | Description |
|----------|-------------|
| `SotilityBridgeAdapter.sol` | Cross-chain bridge for multi-network interoperability |
| `AIORACLEManager.sol` | AI oracle for data verification and external feeds |

## Documentation (`docs/`)

| File | Description |
|------|-------------|
| [`contract-summary.md`](docs/contract-summary.md) | Complete contract registry and architecture overview |
| [`contracts-part-1.md`](docs/contracts-part-1.md) through [`part-4.md`](docs/contracts-part-4.md) | Detailed contract documentation in four parts |
| [`advanced-concepts.md`](docs/advanced-concepts.md) | Advanced Sotility smart contract patterns |
| [`enhancements.md`](docs/enhancements.md) | Proposed contract enhancements |
| [`governance-flow.md`](docs/governance-flow.md) | Governance process flowchart |
| [`token-distribution.md`](docs/token-distribution.md) | Token distribution architecture |

## Architecture

```
┌──────────────────────────────────────────────────┐
│              AI & Verification Layer              │
│         AIORACLEManager · Scoring Engine          │
├──────────────────────────────────────────────────┤
│              Governance Layer                     │
│   ProposalManager · DAOFactory · BusinessReg     │
├──────────────────────────────────────────────────┤
│              Financial Layer                      │
│   Exchange · YieldEngine · Treasury · Vaults     │
├──────────────────────────────────────────────────┤
│              Social Layer                         │
│     ProfileRegistry · SoGoodFeed · BadgeNFT      │
├──────────────────────────────────────────────────┤
│              Token Layer                          │
│            SOT · SUG · SST                        │
└──────────────────────────────────────────────────┘
```
