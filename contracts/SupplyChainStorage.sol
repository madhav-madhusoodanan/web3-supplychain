//SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.4;

import "./SupplyChainStorageOwnable.sol";

contract SupplyChainStorage is SupplyChainStorageOwnable {
    
    /*Events*/
    event AddedBasicDetails(address indexed user, address indexed batchNo);
    event DoneRawMaterialExtractor(address indexed user, address indexed batchNo);
    event DoneChemicalProcessor(address indexed user, address indexed batchNo);
    event DonePolymerizationCompany(address indexed user, address indexed batchNo);
    event DoneFilamentProducer(address indexed user, address indexed batchNo);
    event Done3DPrintingCompany(address indexed user, address indexed batchNo);
    event DoneRecycleCompany(address indexed user, address indexed batchNo);

    // address public lastAccess;
    mapping(address => uint8) authorizedCaller;
    mapping(address => address) lastHandledBatch;

    constructor() {
        authorizedCaller[msg.sender] = 1;
        emit AuthorizedCaller(msg.sender);
    }


    event AuthorizedCaller(address caller);
    event DeAuthorizedCaller(address caller);



    modifier onlyAuthCaller(uint8 role) {
        // lastAccess = msg.sender;

        /* 
        1: super user
        	2: batch initiator
            3: raw materials
            4. chemical processing
            5. polymerization
            6. filament production
            7. 3D printing
            8. recycling
             */
        require(authorizedCaller[msg.sender] == role || authorizedCaller[msg.sender] == 1);
        _;
    }
    modifier onlyAuthorized() {
        require(authorizedCaller[msg.sender] != 0);
        _;
    }


    struct user {
        string name;
        string contactNo;
        bool isActive;
        string profileHash;
    }

    mapping(address => user) userDetails;
    mapping(address => string) userRole;




    function authorizeCaller(address _caller, uint8 role) public onlyOwner returns(bool) {
        authorizedCaller[_caller] = role;
        emit AuthorizedCaller(_caller);
        return true;
    }


    function deAuthorizeCaller(address _caller) public onlyOwner returns(bool) {
        authorizedCaller[_caller] = 0;
        emit DeAuthorizedCaller(_caller);
        return true;
    }



    struct BasicDetails {
        string registrationNo;
        string companyName;
        string companyAddress;
    }


    struct RawMaterialExtractor {
        string rawMaterialName;
        uint256 rawMaterialWeight;
        uint256 carbonEmission;
        uint256 avgWorkerAge;
        bool isChildLabourUsed;
    }


    struct ChemicalProcessor {
        string refinedComponent;
        uint256 refinedOutput;
        uint256 carbonEmission;
        uint256 amountDisposed;
    }


    struct PolymerizationCompany {
        string companyName;
        string companyAddress;
        string componentName;
        uint256 componentOutput;
        uint256 recycledMaterialsUsed;
        uint256 carbonEmission;
        uint256 amountDisposed;

    }


    struct FilamentProducer {
        string companyAddress;
        string componentName;
        string filamentType;
        uint256 filamentOutput;
        uint256 recycledMaterialsUsed;
        uint256 carbonEmission;
        uint256 amountDisposed;

    }

    struct ThreeDPrintingCompany {
        // printed file
        uint256 printime;
        uint256 energyUsed;
        uint256 carbonEmission;
        uint256 partWeight;
        uint256 scrapWeight;
        uint256 amountDisposed;

    }

    struct RecyclingCompany {

        uint256 amountDisposed;

    }



    mapping(address => BasicDetails) batchBasicDetails;
    mapping(address => RawMaterialExtractor) batchRawMaterialExtractor;
    mapping(address => ChemicalProcessor) batchChemicalProcessor;
    mapping(address => PolymerizationCompany) batchPolymerizationCompany;
    mapping(address => FilamentProducer) batchFilamentProducer;
    mapping(address => ThreeDPrintingCompany) batch3DPrintingCompany;
    mapping(address => RecyclingCompany) batchRecyclingCompany;
    mapping(address => string) nextAction;


    user userDetail;
    BasicDetails basicDetailsData;
    RawMaterialExtractor rawMaterialExtractorData;
    ChemicalProcessor chemicalProcessorData;
    PolymerizationCompany polymerizationCompanyData;
    FilamentProducer filamentProducerData;
    ThreeDPrintingCompany threeDPrintingCompanyData;
    RecyclingCompany recyclingCompanyData;

    function compareStrings(string memory _str1, string memory _str2) public pure returns(bool) {
        return keccak256(abi.encodePacked(_str1)) == keccak256(abi.encodePacked(_str2));
    }

    function getLastHandledBatch() public view returns(address) {
        return lastHandledBatch[msg.sender];
        // optionally, delete the entry for optimization but then this will become a non-view function
        // delete lastHandledBatch[msg.sender];
    }

    function getUserRole() public view returns(uint8) {
        return authorizedCaller[msg.sender];
    }


    function getNextAction(address _batchNo) public onlyAuthorized view returns(string memory) {
        return nextAction[_batchNo];
    }


    function setUser(address _userAddress,
        string memory _name,
        string memory _contactNo,
        string memory _role,
        bool _isActive,
        string memory _profileHash) public onlyAuthorized returns(bool) {

        userDetail.name = _name;
        userDetail.contactNo = _contactNo;
        userDetail.isActive = _isActive;
        userDetail.profileHash = _profileHash;


        userDetails[_userAddress] = userDetail;
        userRole[_userAddress] = _role;

        return true;
    }


    function getUser(address _userAddress) public onlyAuthorized view returns(string memory name,
        string memory contactNo,
        string memory role,
        bool isActive,
        string memory profileHash
    ) {


        user memory tmpData = userDetails[_userAddress];

        return (tmpData.name, tmpData.contactNo, userRole[_userAddress], tmpData.isActive, tmpData.profileHash);
    }


    function getBasicDetails(address _batchNo) public onlyAuthorized view returns(string memory registrationNo,
        string memory companyName,
        string memory companyAddress) {

        BasicDetails memory tmpData = batchBasicDetails[_batchNo];

        return (tmpData.registrationNo, tmpData.companyName, tmpData.companyAddress);
    }


    function setBasicDetails(string memory _registrationNo,
        string memory _companyName,
        string memory _companyAddress
    ) public onlyAuthCaller(2) returns(bool) {

        address batchNo = address(
                            uint160(
                                uint256(
                                    keccak256(
                                        abi.encodePacked(msg.sender, block.timestamp)
                        ))));

        lastHandledBatch[msg.sender] = batchNo;
        basicDetailsData.registrationNo = _registrationNo;
        basicDetailsData.companyName = _companyName;
        basicDetailsData.companyAddress = _companyAddress;

        batchBasicDetails[batchNo] = basicDetailsData;

        nextAction[batchNo] = 'RAWMATERIALEXTRACTION';
        emit AddedBasicDetails(msg.sender, batchNo);

        return true;
    }

    function setRawMaterialExtractorData(address batchNo,
        string memory _rawMaterialName,
        uint256 _rawMaterialWeight,
        uint256 _carbonEmission,
        uint256 _workerAge) public onlyAuthCaller(3) returns(bool) {

        rawMaterialExtractorData.rawMaterialName = _rawMaterialName;
        rawMaterialExtractorData.rawMaterialWeight = _rawMaterialWeight;
        rawMaterialExtractorData.carbonEmission = _carbonEmission;
        rawMaterialExtractorData.avgWorkerAge = _workerAge;

        batchRawMaterialExtractor[batchNo] = rawMaterialExtractorData;

        nextAction[batchNo] = 'CHEMICALPROCESSING';
        emit DoneRawMaterialExtractor(msg.sender, batchNo);

        return true;
    }


    function getRawMaterialExtractorData(address batchNo) public onlyAuthorized view returns(string memory rawMaterialName,
        uint256 rawMaterialWeight,
        uint256 carbonEmission) {

        RawMaterialExtractor memory tmpData = batchRawMaterialExtractor[batchNo];
        return (tmpData.rawMaterialName, tmpData.rawMaterialWeight, tmpData.carbonEmission);
    }

    function setChemicalProcessorData(address batchNo,
        string memory _refinedComponent,
        uint256 _refinedOutput,
        uint256 _carbonEmission,
        uint256 amountDisposed) public onlyAuthCaller(4) returns(bool) {

        chemicalProcessorData.refinedComponent = _refinedComponent;
        chemicalProcessorData.refinedOutput = _refinedOutput;
        chemicalProcessorData.carbonEmission = _carbonEmission;
        chemicalProcessorData.amountDisposed = amountDisposed;

        batchChemicalProcessor[batchNo] = chemicalProcessorData;

        nextAction[batchNo] = 'POLYMERIZATION';
        emit DoneChemicalProcessor(msg.sender, batchNo);

        return true;
    }

    function getChemicalProcessorData(address batchNo) public onlyAuthorized view returns(string memory refinedComponent,
        uint256 refinedOutput,
        uint256 carbonEmission, uint256 amountDisposed) {

        ChemicalProcessor memory tmpData = batchChemicalProcessor[batchNo];
        return (tmpData.refinedComponent, tmpData.refinedOutput, tmpData.carbonEmission, tmpData.amountDisposed);
    }

    function setPolymerizationCompanyData(address batchNo,
        string memory _companyName,
        string memory _companyAddress,
        string memory _componentName,
        uint256 _componentOutput,
        uint256 _recycledMaterialsUsed,
        uint256 _carbonEmission,
        uint256 _amountDisposed) public onlyAuthCaller(5) returns(bool) {

        polymerizationCompanyData.companyName = _companyName;
        polymerizationCompanyData.companyAddress = _companyAddress;
        polymerizationCompanyData.componentName = _componentName;
        polymerizationCompanyData.componentOutput = _componentOutput;
        polymerizationCompanyData.recycledMaterialsUsed = _recycledMaterialsUsed;
        polymerizationCompanyData.carbonEmission = _carbonEmission;
        polymerizationCompanyData.amountDisposed = _amountDisposed;

        batchPolymerizationCompany[batchNo] = polymerizationCompanyData;

        nextAction[batchNo] = 'FILAMENTPRODUCER';
        emit DonePolymerizationCompany(msg.sender, batchNo);

        return true;
    }

    function getPolymerizationCompanyData(address batchNo) public onlyAuthorized view returns(string memory companyName,
        string memory companyAddress,
        string memory componentName,
        uint256 componentOutput,
        uint256 recycledMaterialsUsed,
        uint256 carbonEmission,
        uint256 amountDisposed) {

        PolymerizationCompany memory tmpData = batchPolymerizationCompany[batchNo];
        return (tmpData.companyName, tmpData.companyAddress, tmpData.componentName, tmpData.componentOutput, tmpData.recycledMaterialsUsed, tmpData.carbonEmission, tmpData.amountDisposed);
    }

    function setFilamentProducerData(address batchNo,
            string memory _companyAddress,
            string memory _componentName,
            string memory _filamentType,
            uint256 _filamentOutput,
            uint256 _recycledMaterialsUsed,
            uint256 _carbonEmission,
            uint256 _amountDisposed) public onlyAuthCaller(6) returns(bool) {

            filamentProducerData.companyAddress = _companyAddress;
            filamentProducerData.componentName = _componentName;
            filamentProducerData.filamentOutput = _filamentOutput;
            filamentProducerData.filamentType = _filamentType;
            filamentProducerData.recycledMaterialsUsed = _recycledMaterialsUsed;
            filamentProducerData.carbonEmission = _carbonEmission;
            filamentProducerData.amountDisposed = _amountDisposed;

            batchFilamentProducer[batchNo] = filamentProducerData;

            nextAction[batchNo] = 'THREEDPRINTING';
            emit DoneFilamentProducer(msg.sender, batchNo);

            return true;
        }

        function getFilamentProducerData(address batchNo) public onlyAuthorized view returns(
            string memory companyAddress,
            string memory componentName,
            string memory filamentType,
            uint256 filamentOutput,
            uint256 recycledMaterialsUsed,
            uint256 carbonEmission,
            uint256 amountDisposed) {

            FilamentProducer memory tmpData = batchFilamentProducer[batchNo];
            return (tmpData.companyAddress, tmpData.componentName, tmpData.filamentType, tmpData.filamentOutput, tmpData.recycledMaterialsUsed, tmpData.carbonEmission, tmpData.amountDisposed);
        }

    function set3DPrintingCompanyData(address batchNo, 
            uint256 _printime,
            uint256 _energyUsed,
            uint256 _carbonEmission,
            uint256 _partWeight,
            uint256 _scrapWeight,
            uint256 _amountDisposed) public onlyAuthCaller(7) returns(bool) {
                threeDPrintingCompanyData.printime = _printime;
                threeDPrintingCompanyData.energyUsed = _energyUsed;
                threeDPrintingCompanyData.carbonEmission = _carbonEmission;
                threeDPrintingCompanyData.partWeight = _partWeight;
                threeDPrintingCompanyData.scrapWeight = _scrapWeight;
                threeDPrintingCompanyData.amountDisposed = _amountDisposed;

                batch3DPrintingCompany[batchNo] = threeDPrintingCompanyData;

                nextAction[batchNo] = 'RECYCLE';
                emit Done3DPrintingCompany(msg.sender, batchNo);

                return true;
                
            }

    function get3DPrintingCompanyData (address batchNo) public onlyAuthorized view returns (uint256 _printime,
            uint256 _energyUsed,
            uint256 _carbonEmission,
            uint256 _partWeight,
            uint256 _scrapWeight,
            uint256 _amountDisposed){
                ThreeDPrintingCompany memory tmpData = batch3DPrintingCompany[batchNo];
                return (tmpData.printime, tmpData.energyUsed, tmpData.carbonEmission, tmpData.partWeight, tmpData.scrapWeight, tmpData.amountDisposed);
            }

    function setRecycleCompanyData(address batchNo, uint256 _amountDisposed) public onlyAuthCaller(8) returns(bool) {
        recyclingCompanyData.amountDisposed = _amountDisposed;

        batchRecyclingCompany[batchNo] = recyclingCompanyData;
        nextAction[batchNo] = 'DONE';
        emit DoneRecycleCompany(msg.sender, batchNo);

        return true;
    }

    function getRecycleCompanyData(address batchNo) public onlyAuthorized view returns(uint256 amountDisposed) {
        RecyclingCompany memory tmpData = batchRecyclingCompany[batchNo];
        return tmpData.amountDisposed;
    }

    function cumulatedCarbonEmission(address batchNo, string memory _stage) public view returns(uint256) {
        uint256 carbonEmission = 0;
        carbonEmission += batchRawMaterialExtractor[batchNo].carbonEmission;
        if (compareStrings(_stage, 'RAWMATERIALEXTRACTION')) {
            return carbonEmission;
        }

        carbonEmission += batchChemicalProcessor[batchNo].carbonEmission;
        if (compareStrings(_stage, 'CHEMICALPROCESSOR')) {
            return carbonEmission;
        }

        carbonEmission += batchPolymerizationCompany[batchNo].carbonEmission;
        if (compareStrings(_stage, 'POLYMERIZATIONCOMPANY')) {
            return carbonEmission;
        }

        carbonEmission += batchFilamentProducer[batchNo].carbonEmission;
        if (compareStrings(_stage, 'FILAMENTPRODUCER')) {
            return carbonEmission;
        }

        carbonEmission += batch3DPrintingCompany[batchNo].carbonEmission;
        if (compareStrings(_stage, 'THREEDPRINTING')) {
            return carbonEmission;
        }

        /* if (batchRecyclingCompany[batchNo].carbonEmission != 0) {
            carbonEmission += batchRecyclingCompany[batchNo].carbonEmission;
        } */
        return carbonEmission;
    }
}
