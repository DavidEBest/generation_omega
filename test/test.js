const { ethers } = require("hardhat");

describe("GenOmega", function () {
  it("Should mint 1 NFT", async function () {
    const Contract = await ethers.getContractFactory("GenerationOmega");

    const contract = await Contract.deploy();
    await contract.deployed();
  });
});
