const { expect } = require("chai")
const { BigNumber } = require("ethers")
const { ethers } = require("hardhat")

describe("SupplyChainStorage", function () {
    it("allows checking for events", async function () {
        /* address batchNo, 
        uint256 _printime,
        uint256 _energyUsed,
        uint256 _carbonEmission,
        uint256 _partWeight,
        uint256 _scrapWeight,
        uint256 _amountDisposed */

        const Test = await ethers.getContractFactory("Test")
        const [addr0, addr1] = await ethers.getSigners()
        const test = await Test.deploy()
        await test.deployed()

        await test.testing(addr1.address)

        const filter = test.filters.Check()
        test.queryFilter(filter, 0, "latest").then((events) => {
            console.log("events length is ", events.length)
            const batches = events.map((event) => event.args)
            console.log(batches)
            console.log(batches[0].user)
        })
        /* const returnVal = await test.get3DPrintingCompanyData(batchNo)
        expect(returnVal).to.deep.equal([
            BigNumber.from("112"),
            BigNumber.from("1234"),
            BigNumber.from("12"),
            BigNumber.from("234"),
            BigNumber.from("123"),
            BigNumber.from("2345"),
        ]) */
    })
})
