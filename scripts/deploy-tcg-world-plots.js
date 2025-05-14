const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

  // Deploy TCG World Plots
  const TCGWorldPlots = await ethers.getContractFactory("TCG_World_Plots");
  console.log("Deploying TCG World Plots...");
  
  const tcgWorldPlots = await upgrades.deployProxy(TCGWorldPlots, [
    deployer.address, // manager
    deployer.address, // pauser
    deployer.address, // upgrader
    deployer.address, // royalty receiver
    ethers.ZeroAddress, // initial validator (zero address for now)
    "TCG World Plots", // name
    "TCGWP", // symbol
    0 // lock duration (0 for no lock)
  ], {
    initializer: 'initialize',
    kind: 'transparent'
  });

  await tcgWorldPlots.waitForDeployment();
  const tcgWorldPlotsAddress = await tcgWorldPlots.getAddress();
  
  console.log("TCG World Plots deployed to:", tcgWorldPlotsAddress);
  console.log("Transaction hash:", tcgWorldPlots.deploymentTransaction().hash);

  // Verify the deployment
  console.log("\nVerifying deployment...");
  console.log("Contract address:", tcgWorldPlotsAddress);
  console.log("Network:", network.name);
  console.log("Deployer address:", deployer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 

  // npx hardhat run scripts/deploy-tcg-world-plots.js --network mainnet