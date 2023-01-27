const { deployments, ethers } = require("@nomiclabs/buidler");

async function main() {
  // Deploy USDCtoUSDT contract
  const USDCtoUSDT = await deployments.get("USDCtoUSDT");
  
  // Get Compound, USDC, and USDT addresses
  const compound = await ethers.getContractAt("Compound", "0x3fda67f7583380e67ef93072294a7fac882fd7f7");
  const usdc = await ethers.getContractAt("USDC", "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
  const usdt = await ethers.getContractAt("USDT", "0xdac17f958d2ee523a2206206994597c13d831ec7");
  
  // Initialize USDCtoUSDT contract
  await USDCtoUSDT.initialize(compound.address, usdc.address, usdt.address);
  
  // Swap and lend USDC to USDT
  await USDCtoUSDT.swapAndLend(1000000);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });