const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Account address:", deployer.address);
  
  const balance = await deployer.provider.getBalance(deployer.address);
  console.log("Balance in wei:", balance.toString());
  console.log("Balance in ETH:", ethers.formatEther(balance));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 