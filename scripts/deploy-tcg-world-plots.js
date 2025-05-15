const { ethers, upgrades } = require("hardhat");
const { LedgerSigner } = require("@ethersproject/hardware-wallets");
require("dotenv").config();

async function deployTCGWorldPlots(name, symbol) {
  console.log("🔍 Checking Ledger connection...");
  
  const provider = ethers.provider;
  const deployer = new LedgerSigner(provider, "m/44'/60'/0'/0/0");
  
  console.log("👛 Ledger address:", await deployer.getAddress());
  console.log(`👷 Deploying TCGPlot with: ${await deployer.getAddress()}`);

  const ContractFactory = await ethers.getContractFactory("TCGPlot", deployer);

  // You can adjust these as needed
  const lockDuration = 0; // No lock
  const royaltyReceiver = await deployer.getAddress(); // Or set to a specific address
  const validator = ethers.ZeroAddress; // Or set to a specific validator address

  // Initialize arguments in the correct order as defined in BaseERC721.initialize
  const args = [
    await deployer.getAddress(),  // _manager
    await deployer.getAddress(),  // _pauser
    await deployer.getAddress(),  // _upgrader
    royaltyReceiver,   // _royaltyReceiver
    validator,         // _initialValidator
    name,             // _name
    symbol,           // _symbol
    lockDuration      // _lockDuration
  ];

  console.log("Deployment arguments:", args);

  const proxy = await upgrades.deployProxy(ContractFactory, args, {
    initializer: "initialize",
    kind: "transparent",
  });

  await proxy.waitForDeployment();
  const address = await proxy.getAddress();

  console.log(`✅ TCGPlot (${name}) deployed to: ${address}`);
}

async function main() {
  await deployTCGWorldPlots("TCG World Plots", "TCGWP");
}

main().catch((err) => {
  console.error("❌ Deployment failed:", err);
  process.exit(1);
});
