async function main() {
    // We get the contract to deploy
    const [acc0, acc1] = await ethers.getSigners()
    const SCS = await ethers.getContractFactory("SupplyChainStorage")
    const scs = await SCS.deploy()
    await scs.deployed()

    console.log("SupplyChainStorage deployed to:", scs.address)
    console.log("Owner is: ", acc0.address)
    console.log("Another account is: ", acc1.address)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
