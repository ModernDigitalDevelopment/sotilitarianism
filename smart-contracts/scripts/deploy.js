/**
 * Sotility Protocol — Full Deployment Script
 * Network: Base Sepolia Testnet (chainId: 84532)
 * 
 * Deployment order respects constructor dependencies:
 * 1. No-arg contracts first (SOT, SST, SUG, AIOracleManager, etc.)
 * 2. Contracts that depend on deployed addresses
 * 3. Complex contracts last (TreasuryRouter, Exchange, etc.)
 */

const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("\n╔══════════════════════════════════════════════════════╗");
  console.log("║     SOTILITY PROTOCOL — BASE SEPOLIA DEPLOYMENT      ║");
  console.log("╚══════════════════════════════════════════════════════╝\n");
  console.log(`Deployer:  ${deployer.address}`);
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log(`Balance:   ${ethers.formatEther(balance)} ETH`);
  console.log(`Network:   Base Sepolia (chainId: 84532)\n`);

  if (balance < ethers.parseEther("0.01")) {
    throw new Error("Insufficient ETH balance. Need at least 0.01 ETH on Base Sepolia.");
  }

  const deployed = {};
  const results = [];

  async function deploy(name, args = [], label = null) {
    const displayName = label || name;
    process.stdout.write(`Deploying ${displayName}...`);
    try {
      const Factory = await ethers.getContractFactory(name);
      const contract = await Factory.deploy(...args);
      await contract.waitForDeployment();
      const address = await contract.getAddress();
      deployed[name] = address;
      results.push({ contract: displayName, address, args: args.map(String) });
      console.log(` ✓  ${address}`);
      return contract;
    } catch (err) {
      console.log(` ✗  FAILED: ${err.message.slice(0, 80)}`);
      results.push({ contract: displayName, address: "FAILED", error: err.message.slice(0, 100) });
      return null;
    }
  }

  // ─── LAYER 1: No-arg token contracts ──────────────────────────────────────
  console.log("── Layer 1: Token Contracts ──────────────────────────────");
  await deploy("SotilityOwnershipToken");       // SOT — governance token
  await deploy("SotilityStableToken");           // SST — efficiency-backed stablecoin
  await deploy("SoGoodUtilityGovernance", [30 * 24 * 60 * 60]); // SUG — 30-day lock duration

  // ─── LAYER 2: Identity & Social (no-arg) ──────────────────────────────────
  console.log("\n── Layer 2: Identity & Social ────────────────────────────");
  await deploy("SotilityProfileRegistry");
  await deploy("SotilityBadgeNFT");
  await deploy("SoGoodFeed");
  await deploy("SotilityZKIdentity");
  await deploy("SotilityCrossChainIdentity");
  await deploy("SotilityProofOfPersonhood");

  // ─── LAYER 3: Oracle & Verification ───────────────────────────────────────
  console.log("\n── Layer 3: Oracle & Verification ───────────────────────");
  await deploy("AIOracleManager");
  // MultiOracleAggregator: minimumOracleResponses=3, scoreDeviationThreshold=10%
  await deploy("MultiOracleAggregator", [3, 1000]);

  // ─── LAYER 4: VeToken (depends on SOT) ────────────────────────────────────
  console.log("\n── Layer 4: Governance Infrastructure ───────────────────");
  if (deployed["SotilityOwnershipToken"]) {
    await deploy("SotilityVeToken", [deployed["SotilityOwnershipToken"]]);
  }

  // ─── LAYER 5: DeFi Infrastructure ─────────────────────────────────────────
  console.log("\n── Layer 5: DeFi Infrastructure ──────────────────────────");
  await deploy("SotilityVaultFactory");

  if (deployed["SotilityOwnershipToken"]) {
    await deploy("SotilityLiquidStaking", [
      deployed["SotilityOwnershipToken"],
      200, // 2% initial fee (basis points)
    ]);
  }

  if (deployed["SotilityStableToken"]) {
    await deploy("SotilityBridgeAdapter", [deployed["SotilityStableToken"]]);
  }

  // ─── LAYER 6: Treasury & Exchange (depend on SST + addresses) ─────────────
  console.log("\n── Layer 6: Treasury & Exchange ──────────────────────────");
  // TreasuryRouter: dividendPool, stableVault, campaignPool
  // Using deployer address as placeholder pools for testnet demo
  await deploy("SotilityTreasuryRouter", [
    deployer.address, // dividendPool
    deployer.address, // stableVault
    deployer.address, // campaignPool
  ]);

  if (deployed["SotilityStableToken"] && deployed["SotilityTreasuryRouter"]) {
    await deploy("SotilityExchange", [
      deployed["SotilityStableToken"],
      deployed["SotilityTreasuryRouter"],
    ]);
  }

  if (deployed["SotilityStableToken"] && deployed["SotilityTreasuryRouter"]) {
    await deploy("SotilityYieldEngine", [
      deployed["SotilityStableToken"],
      deployed["SotilityTreasuryRouter"], // rewardDistributor
    ]);
  }

  // ─── LAYER 7: Insurance & Safety ──────────────────────────────────────────
  console.log("\n── Layer 7: Insurance & Safety ───────────────────────────");
  if (deployed["SotilityStableToken"] && deployed["SotilityOwnershipToken"]) {
    await deploy("SotilityInsurance", [
      deployed["SotilityStableToken"],
      deployed["SotilityOwnershipToken"],
    ]);
  }

  // EmergencyShutdown: guardians[] and recoveryTeam[]
  await deploy("SotilityEmergencyShutdown", [
    [deployer.address], // guardians
    [deployer.address], // recoveryTeam
  ]);

  // ─── SUMMARY ──────────────────────────────────────────────────────────────
  const successCount = results.filter(r => r.address !== "FAILED").length;
  const failCount = results.filter(r => r.address === "FAILED").length;

  console.log("\n╔══════════════════════════════════════════════════════╗");
  console.log(`║  DEPLOYMENT COMPLETE: ${successCount}/20 contracts deployed        ║`);
  console.log("╚══════════════════════════════════════════════════════╝\n");

  console.log("CONTRACT ADDRESSES:");
  console.log("─────────────────────────────────────────────────────────");
  results.forEach(r => {
    const status = r.address === "FAILED" ? "❌ FAILED" : "✓";
    console.log(`${status}  ${r.contract.padEnd(35)} ${r.address}`);
  });

  // Save deployment manifest
  const manifest = {
    network: "Base Sepolia",
    chainId: 84532,
    deployer: deployer.address,
    deployedAt: new Date().toISOString(),
    contracts: results,
    explorerBase: "https://sepolia.basescan.org/address/",
  };

  const outPath = path.join(__dirname, "..", "deployments", "base-sepolia.json");
  fs.mkdirSync(path.dirname(outPath), { recursive: true });
  fs.writeFileSync(outPath, JSON.stringify(manifest, null, 2));
  console.log(`\n✓ Deployment manifest saved to deployments/base-sepolia.json`);
  console.log(`\n🔍 View on BaseScan: https://sepolia.basescan.org/address/${deployed["SotilityOwnershipToken"] || ""}`);

  if (failCount > 0) {
    console.log(`\n⚠️  ${failCount} contract(s) failed to deploy. Check errors above.`);
  }

  return manifest;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("\n❌ Fatal deployment error:", error);
    process.exit(1);
  });
