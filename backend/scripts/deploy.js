// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
// const ethers = require("hardhat");

// async function main() {
  // const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  // const unlockTime = currentTimestampInSeconds + 60;

  // const lockedAmount = hre.ethers.parseEther("0.001");

  // const lock = await hre.ethers.deployContract("Contract", [unlockTime], {
  //   value: lockedAmount,
  // });

  // await lock.waitForDeployment();

  // console.log(
  //   `Lock with ${ethers.formatEther(
  //     lockedAmount
  //   )}ETH and unlock timestamp ${unlockTime} deployed to ${lock.target}`
  // );
// }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
// main().catch((error) => {
  // console.error(error);
  // process.exitCode = 1;
// });

const { ethers } = require("hardhat");

async function main() {
  const Contract = await ethers.getContractFactory("Contract");
  const contract = await Contract.deploy();

  const Users = await ethers.getContractFactory("Users");
  const users = await Users.deploy();

  // await myContract.waitForDeployment();


  // пуш адресса контракта в файл json 
  const fs = require("fs");
  const path = require("path");
  
  const filePath = path.join(__dirname, "../artifacts/contracts/contract.sol/Contract.json");
  const filePathUsers = path.join(__dirname, "../artifacts/contracts/user.sol/Users.json");
  
  let data = fs.existsSync(filePath) ? JSON.parse(fs.readFileSync(filePath)) : {};
  data.address = contract.target;  
  // data.address = contract.address; //for home
  fs.writeFileSync(filePath, JSON.stringify(data));

  let dataUsers = fs.existsSync(filePathUsers) ? JSON.parse(fs.readFileSync(filePathUsers)) : {};
  dataUsers.address = users.target;  
  // dataUsers.address = users.address; //for home
  fs.writeFileSync(filePathUsers, JSON.stringify(dataUsers));
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
});
