import { ethers } from "hardhat";

async function main() {
  const Swap = await ethers.getContractFactory("SwapToken");
  const swap = await Swap.deploy("0x0FA8781a83E46826621b3BC094Ea2A0212e71B23");

  await swap.deployed();

  console.log(`Contract is deployed to ${swap.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
