const { ethers } = require("hardhat");

async function main() {
  const Contract = await ethers.getContractFactory("Contract");
  const contract = await Contract.deploy();
  
  // пуш адресса контракта в файл json 
  const fs = require("fs");
  const path = require("path");
  
  const filePath = path.join(__dirname, "../artifacts/contracts/contract.sol/Contract.json");
  const filePathUsers = path.join(__dirname, "../artifacts/contracts/user.sol/Users.json");
  
  let data = fs.existsSync(filePath) ? JSON.parse(fs.readFileSync(filePath)) : {};
  data.address = contract.target;  
  // data.address = contract.address; //for home
  fs.writeFileSync(filePath, JSON.stringify(data));
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
});
