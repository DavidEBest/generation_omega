const main = async () => {
  const ContractFactory = await hre.ethers.getContractFactory("GenerationOmega");

  const contract = await ContractFactory.deploy();
  await contract.deployed();
  console.log("Contract deployed to:", contract.address);
  let txn = await contract.ownerClaim(0);
  console.log('tx', txn);
  txn = await contract.ownerClaim(1);
  console.log('tx', txn);
  txn = await contract.ownerClaim(2);
  console.log('tx', txn);
  txn = await contract.tokenURI(0);
  console.log('tx', txn);
  txn = await contract.tokenURI(1);
  console.log('tx', txn);
  txn = await contract.tokenURI(2);
  console.log('tx', txn);
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
