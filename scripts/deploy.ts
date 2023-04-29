import { ethers } from "hardhat";

async function main() {
  const Swap = await ethers.getContractFactory("SwapToken");
  const swap = await Swap.deploy("0xDbF2F58549D2ea579069c386Fe1a54129c510498", "0xB7B6035d19C1B2BbDa54126Af00873C2c3c7f0a2", "0x3c6f7C63D33CD4dBA8f0190ee0B60C8f56B1BA3A");

  await swap.deployed();

  console.log(`Contract is deployed to ${swap.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
