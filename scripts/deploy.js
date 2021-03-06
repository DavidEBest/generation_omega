const main = async () => {

  const GOFactory = await hre.ethers.getContractFactory("GenerationOmega");
  const GORFactory = await hre.ethers.getContractFactory("GenerationOmegaRenderer");

  const contract = await GOFactory.deploy();
  await contract.deployed();
  console.log("Contract deployed to:", contract.address);

  const rendererContract = await GORFactory.deploy();
  await rendererContract.deployed();
  console.log("Renderer Contract deployed to:", rendererContract.address);

  let txn = await contract.setRendererContractAddress(rendererContract.address);
  txn = await contract.ownerClaim(0);
  console.log('owner claim tx', txn);
  txn = await contract.toggleSaleStatus();
  console.log('enable sale tx', txn);
  // txn = await contract.buy(1, { value: ethers.utils.parseEther("0.02") });
  // console.log('tx', txn);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
