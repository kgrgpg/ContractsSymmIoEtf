import { ethers } from "hardhat";

async function main() {
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Get the contract factory for ETFMintToken
  const ETFMintToken = await ethers.getContractFactory("ETFMintToken");
  // Deploy the contract
  const token = await ETFMintToken.deploy();
  // Wait for deployment to complete (ethers v6)
  await token.waitForDeployment();
  
  // In ethers v6, the contract address is available as token.target
  console.log("ETFMintToken deployed to:", token.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });