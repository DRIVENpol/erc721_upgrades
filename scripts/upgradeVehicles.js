const { ethers, upgrades } = require("hardhat");

async function main() {
  const ledgerAddress = process.env.LEDGER_ACCOUNTS.split(",")[0].trim();
  const [deployer] = await ethers.getSigners();
  console.log("Upgrading contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());

  // The address of the proxy contract
  const proxyAddress = process.env.PROXY_ADDRESS_VEHICLES;
  if (!proxyAddress) {
    throw new Error("PROXY_ADDRESS environment variable is not set");
  }

  // Deploy the new implementation
  const TCGWorldPlotsUpdated = await ethers.getContractFactory("TCG_World_Vehicles_Updated");
  console.log("Upgrading TCG World Plots at:", proxyAddress);

  const upgraded = await upgrades.upgradeProxy(proxyAddress, TCGWorldPlotsUpdated, {
    kind: 'transparent',
    signer: deployer
  });

  await upgraded.waitForDeployment();
  const upgradedAddress = await upgraded.getAddress();

  console.log("TCG World Plots upgraded at:", upgradedAddress);
  const deploymentTx = upgraded.deploymentTransaction && upgraded.deploymentTransaction();
  console.log("Transaction hash:", deploymentTx ? deploymentTx.hash : "N/A (upgrade does not create a new deployment tx)");

  // Verify the upgrade
  console.log("\nVerifying upgrade...");
  console.log("Proxy address:", proxyAddress);
  console.log("New implementation address:", upgradedAddress);
  console.log("Network:", network.name);
  console.log("Upgrader address:", deployer.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 

// npx hardhat run scripts/upgradeVehicles.js --network mainnet