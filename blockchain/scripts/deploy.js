const {ethers} = require('hardhat')

async function deploy() {
    const Con = await ethers.getContractFactory("Contract")
    const con = await Con.deploy()

    const fs = require('fs')
    const path = require('path')

    const file = path.join(__dirname, "../../app/src/artifacts/contracts/contract.sol/Contract.json")

    const data = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file)) : {}
    data.address = con.target

    fs.writeFileSync(file, JSON.stringify(data))
}

deploy()
.then(() => {
    console.log('Success')
    process.exit(0)
})
.catch(err => {
    console.error(err)
    process.exit(1)
})