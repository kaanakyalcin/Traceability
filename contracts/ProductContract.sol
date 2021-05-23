// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

import "./Ownable.sol"; 
import "./TraceabilityContract.sol";
import "./TraceHelper.sol";

contract ProductContract is Ownable, TraceHelper {

    event NewProduct(string barcode, uint randId);
    event NewTrace(string barcode, string lotId, uint expirationDate);

    uint idDigits = 16;
    uint idModulus = 10 ** idDigits;

    struct Product{
        string Barcode;
        string Name;
        string Group;
        string ImageURL;
        address CreatedBy;
        uint randId;
    }

    Product[] public products;
    mapping (string => Product) barcodeToProduct;
    mapping (string => uint) barcodeCount;

    mapping(string => address) expirationDateContracts;
    mapping(string => address) lotContracts;

    function _createProduct(string memory _barcode, string memory _name, string memory _group, string memory _imageUrl, address _createdBy, uint randId) private {
        Product memory product = Product(_barcode, _name, _group, _imageUrl, _createdBy, randId);
        products.push(product);
        barcodeToProduct[_barcode] = product;
        barcodeCount[_barcode]++;
        emit NewProduct(_barcode, randId);
    }

    function _createTrace(string memory _barcode, string memory _lotId, uint _expirationDate, string memory _jsonData) private {
        
        TraceabilityContract traceContract = new TraceabilityContract(_barcode, _lotId, _expirationDate, _jsonData);

        if(_expirationDate > 0){
            string memory value = string(abi.encodePacked(_barcode, uint2str(_expirationDate)));
            expirationDateContracts[value] = address(traceContract);
        }

        if(keccak256(abi.encodePacked(_lotId)) != keccak256(abi.encodePacked(""))){
            string memory value = string(abi.encodePacked(_barcode, _lotId));
            lotContracts[value] = address(traceContract);
        }

        emit NewTrace(_barcode, _lotId, _expirationDate);
    }

    // function that returns entire products
    function getProducts() public view returns (Product[] memory) {
        return products;
    }

    // function that returns single product
    function getProduct(string memory _barcode) public view returns (Product memory) {
        return barcodeToProduct[_barcode];
    }

    function _generateId(string memory _str) private view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % idModulus;
    }

    function createNewProduct(string memory _barcode, string memory _name, string memory _group, string memory _imageUrl) public onlyOwner {
        require(barcodeCount[_barcode] == 0, 'Barcode already added.');
        
        //min. product name length constraint
        require(bytes(_name).length >= 3 && bytes(_name).length <= 64);

        //min. product code length constraint
        require(bytes(_barcode).length > 6);
        
        uint id = _generateId(_barcode);
        _createProduct(_barcode, _name, _group, _imageUrl, msg.sender, id);
    }

    function createNewTrace(string memory _barcode, string memory _lotId, uint _expirationDate, string memory _jsonData) external onlyOwner {
        require(_expirationDate > 0 || keccak256(abi.encodePacked(_lotId)) != keccak256(abi.encodePacked("")), 'Expiration Date or Lot Id must be provided.');
        _createTrace(_barcode, _lotId, _expirationDate, _jsonData);
    }

    // function that returns single trace
    function getTrace(string memory _barcode, string memory _lotId, uint _expirationDate) external view returns (string memory) {
        address contractAddress = address(0);
        require(_expirationDate > 0 || keccak256(abi.encodePacked(_lotId)) != keccak256(abi.encodePacked("")), 'Expiration Date or Lot Id must be provided.');
        if(_expirationDate > 0){
            string memory value = string(abi.encodePacked(_barcode, uint2str(_expirationDate)));
            contractAddress = expirationDateContracts[value];            
        }
        else if(keccak256(abi.encodePacked(_lotId)) != keccak256(abi.encodePacked(""))) {
            string memory value = string(abi.encodePacked(_barcode, _lotId));
            contractAddress = lotContracts[value];
        }

        if(contractAddress == address(0)){
            return '';
        }

        TraceabilityContract traceabilityContract = TraceabilityContract(contractAddress);
        return traceabilityContract.getJsonData();
    }
}