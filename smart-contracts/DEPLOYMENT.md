# Sotility Protocol — Deployment Guide

This document describes the deployment order, dependencies, constructor parameters, and post-deployment configuration for all 20 Sotility Protocol smart contracts.

---

## Prerequisites

```bash
cd smart-contracts
npm install
cp .env.example .env
# Fill in your PRIVATE_KEY and RPC_URL in .env
```

**Required environment variables:**
```
PRIVATE_KEY=           # Deployer wallet private key (no 0x prefix)
BASE_SEPOLIA_RPC=      # Base Sepolia RPC URL (e.g., from Alchemy or QuickNode)
BASE_MAINNET_RPC=      # Base Mainnet RPC URL (for production)
BASESCAN_API_KEY=      # For contract verification on Basescan
```

---

## Deployment Order

The contracts have dependencies and **must be deployed in this exact order**:

### Phase 1 — Core Tokens (No Dependencies)

| # | Contract | Description |
|---|---|---|
| 1 | `SotilityOwnershipToken.sol` | SOT governance/equity token (1B supply) |
| 2 | `SoGoodUtilityGovernance.sol` | SUG utility token (earned via contributions) |

### Phase 2 — Identity & Verification (Depends on Phase 1)

| # | Contract | Dependencies | Description |
|---|---|---|---|
| 3 | `SotilityProfileRegistry.sol` | None | On-chain user identity + org profiles |
| 4 | `SotilityProofOfPersonhood.sol` | ProfileRegistry | Sybil-resistant proof-of-personhood |
| 5 | `SotilityZKIdentity.sol` | ProfileRegistry | Zero-knowledge identity verification |
| 6 | `SotilityCrossChainIdentity.sol` | ZKIdentity | Cross-chain identity portability |

### Phase 3 — Governance (Depends on Phases 1–2)

| # | Contract | Dependencies | Description |
|---|---|---|---|
| 7 | `SotilityVeToken.sol` | SOT address | Vote-escrowed token for governance weight |
| 8 | `SoGoodFeed.sol` | ProfileRegistry, SUG | On-chain social feed + reputation scoring |

### Phase 4 — Stablecoin (Depends on Phases 1–3)

| # | Contract | Dependencies | Description |
|---|---|---|---|
| 9 | `SotilityStableToken.sol` | SOT, ProfileRegistry | SST stablecoin (USD-pegged, efficiency-backed) |

### Phase 5 — Oracle Layer (Depends on Phase 4)

| # | Contract | Dependencies | Description |
|---|---|---|---|
| 10 | `AIOracleManager.sol` | None | AI-managed oracle price feeds |
| 11 | `MultiOracleAggregator.sol` | AIOracleManager | Aggregates multiple oracle sources |

### Phase 6 — DeFi Infrastructure (Depends on Phases 1–5)

| # | Contract | Dependencies | Description |
|---|---|---|---|
| 12 | `SotilityTreasuryRouter.sol` | SOT, SST, Oracle | Routes DeFi yield back to community treasury |
| 13 | `SotilityYieldEngine.sol` | TreasuryRouter, Oracle | Autonomous flash loan + arbitrage yield |
| 14 | `SotilityVaultFactory.sol` | YieldEngine | Creates user-controlled yield vaults |
| 15 | `SotilityLiquidStaking.sol` | SOT, TreasuryRouter | Liquid staking with fee distribution |
| 16 | `SotilityExchange.sol` | SOT, SUG, SST | DEX for SOT/SUG/SST token swaps |
| 17 | `SotilityInsurance.sol` | TreasuryRouter | On-chain insurance pool for protocol risk |

### Phase 7 — Cross-Chain & Safety (Depends on Phases 1–6)

| # | Contract | Dependencies | Description |
|---|---|---|---|
| 18 | `SotilityBridgeAdapter.sol` | SOT, SST | Cross-chain asset bridging |
| 19 | `SotilityEmergencyShutdown.sol` | All contracts | Circuit breaker for protocol emergencies |

### Phase 8 — Social Layer (Depends on Phases 1–7)

| # | Contract | Dependencies | Description |
|---|---|---|---|
| 20 | `SotilityBadgeNFT.sol` | ProfileRegistry, VeToken | Achievement NFTs for governance participation |

---

## Automated Deployment

The `scripts/deploy.js` script handles the full deployment sequence:

```bash
# Deploy to Base Sepolia testnet
npx hardhat run scripts/deploy.js --network baseSepolia

# Deploy to Base Mainnet (production)
npx hardhat run scripts/deploy.js --network base
```

The script will:
1. Deploy all 20 contracts in the correct order
2. Wire up cross-contract references (e.g., grant minting roles)
3. Output all deployed addresses to `deployments/addresses.json`
4. Log a deployment summary to the console

---

## Post-Deployment Configuration

After deployment, the following manual steps are required:

1. **Transfer ownership** of `SotilityEmergencyShutdown` to a multisig wallet
2. **Set oracle feeds** in `AIOracleManager` for SOT/USD, SUG/USD price pairs
3. **Initialize treasury** in `SotilityTreasuryRouter` with initial liquidity parameters
4. **Verify all contracts** on Basescan:
   ```bash
   npx hardhat verify --network baseSepolia <CONTRACT_ADDRESS> <CONSTRUCTOR_ARGS>
   ```

---

## Testnet Deployment Addresses

> *Addresses will be populated after Base Sepolia deployment.*

| Contract | Address |
|---|---|
| SotilityOwnershipToken | `TBD` |
| SotilityStableToken | `TBD` |
| SoGoodUtilityGovernance | `TBD` |
| ... | ... |

---

## Security Considerations

- All contracts use OpenZeppelin v5 with `AccessControl` for role-based permissions
- `SotilityEmergencyShutdown` can pause the entire protocol in case of an exploit
- The deployer wallet should be a hardware wallet or multisig — never a hot wallet in production
- Run `npx hardhat test` and review all test results before any mainnet deployment

---

*For questions, open an issue or contact the Elevation Foundation at contact@elevationfoundation.org*
