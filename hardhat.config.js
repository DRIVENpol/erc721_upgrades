require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("@nomicfoundation/hardhat-ledger");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  networks: {
    hardhat: {},
    buildbear: {
      url: process.env.SEPOLIA_RPC_URL || "https://rpc.buildbear.io/motionless-vision-c15dab5c",
      chainId: 26045,
      ledgerAccounts: process.env.LEDGER_ACCOUNTS ? process.env.LEDGER_ACCOUNTS.split(",") : [],
      gasPrice: "auto",
      gas: "auto"
    },
    mainnet: {
      url: process.env.MAINNET_RPC_URL || "https://magical-dimensional-bush.quiknode.pro/849287506c39f29243340528b246bdf2ad2a1171/",
      chainId: 1,
      ledgerAccounts: process.env.LEDGER_ACCOUNTS ? process.env.LEDGER_ACCOUNTS.split(",") : [],
      gasPrice: "auto",
      gas: "auto"
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};
