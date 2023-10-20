const { expect } = require("chai")
const { BigNumber } = require("ethers")
const { ethers } = require("hardhat")

describe("SupplyChainStorage", function () {
    let scs, addr0, addr1, batchNo;
    
    this.beforeAll(async () => {
        const SupplyChainStorage = await ethers.getContractFactory(
            "SupplyChainStorage"
        );
        [addr0, addr1, addr2] = await ethers.getSigners()
        scs = await SupplyChainStorage.deploy()
        await scs.deployed()
        // deployment and configuration data common to all unit tests
    })

    it("allows adding basic details", async function () {

        await scs.setBasicDetails("123", "JInGEL", "Bits Pilani")
        batchNo = await scs.getLastHandledBatch();

        const returnVal = await scs.getBasicDetails(batchNo)
        expect(
            returnVal.filter((_, i) => i <= 2)
        ).to.deep.equal(["123", "JInGEL", "Bits Pilani"])
    })

    it("allows adding raw material extraction data", async function () {
        /* batch address, 
           materialname string, 
           weight uint256, 
           carbonEmission uint256, 
           workerAge uint256 
          */
        await scs.setRawMaterialExtractorData(batchNo, "plastic", BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("42"))

        const returnVal = await scs.getRawMaterialExtractorData(batchNo)
        expect(
            returnVal
        ).to.deep.equal(["plastic", BigNumber.from("234"), BigNumber.from("123")])
    })

    it("allows adding chemical processing data", async function () {
        /* address batchNo,
            string memory _refinedComponent,
            uint256 _refinedOutput,
            uint256 _carbonEmission 
            uint256 amountDisposed;
        */
        await scs.setChemicalProcessorData(batchNo, "plastic", BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("2345"))

        const returnVal = await scs.getChemicalProcessorData(batchNo)
        expect(
            returnVal
        ).to.deep.equal(["plastic", BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("2345")])


    })
    
    it("allows adding polymerization data", async function () {
        /* address batchNo,
            string memory _companyName,
            string memory _companyAddress,
            string memory _componentName,
            uint256 _componentOutput,
            uint256 _recycledMaterialsUsed,
            uint256 _carbonEmission,
            uint256 _amountDisposed 
            */
        await scs.setPolymerizationCompanyData(batchNo, "JInGEL", "Bits Pilani", "plastic", BigNumber.from("12"), BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("2345"))

        const returnVal = await scs.getPolymerizationCompanyData(batchNo)
        expect(
            returnVal
        ).to.deep.equal(["JInGEL", "Bits Pilani", "plastic", BigNumber.from("12"), BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("2345")])
    })

    it("allows adding filament production data", async function () {
        /* address batchNo,
            string memory _companyAddress,
            string memory _componentName,
            string _filamentType,
            uint256 _filamentOutput,
            uint256 _recycledMaterialsUsed,
            uint256 _carbonEmission,
            uint256 _amountDisposed */
        await scs.setFilamentProducerData(batchNo, "Bits Pilani", "metallic", "plastic", BigNumber.from("12"), BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("2345"))

        const returnVal = await scs.getFilamentProducerData(batchNo)
        expect(
            returnVal
        ).to.deep.equal(["Bits Pilani", "metallic", "plastic", BigNumber.from("12"), BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("2345")])
    })

        it("allows adding 3D printing data", async function () {
            
        /* address batchNo, 
            uint256 _printime,
            uint256 _energyUsed,
            uint256 _carbonEmission,
            uint256 _partWeight,
            uint256 _scrapWeight,
            uint256 _amountDisposed */
        await scs.set3DPrintingCompanyData(batchNo, BigNumber.from("112"), BigNumber.from("1234"), BigNumber.from("12"), BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("2345"))

        const returnVal = await scs.get3DPrintingCompanyData(batchNo)
        expect(
            returnVal
        ).to.deep.equal([BigNumber.from("112"), BigNumber.from("1234"), BigNumber.from("12"), BigNumber.from("234"), BigNumber.from("123"), BigNumber.from("2345")])
    })

    it("allows adding recycle company data", async function () {
        /* address batchNo, uint256 _amountDisposed */

        await scs.setRecycleCompanyData(batchNo, BigNumber.from("112"))

        const returnVal = await scs.getRecycleCompanyData(batchNo)
        expect(
            returnVal
        ).to.deep.equal(BigNumber.from("112"))
    })

    it("allows querying for carbon emission", async function () {
        /* address batchNo, uint256 _amountDisposed */

        let emission = await scs.cumulatedCarbonEmission(batchNo, "POLYMERIZATIONCOMPANY")
        expect(emission).to.deep.equal(BigNumber.from("369"))

        emission = await scs.cumulatedCarbonEmission(batchNo, "THREEDPRINTING")
        expect(emission).to.deep.equal(BigNumber.from("504"))
    })
})
