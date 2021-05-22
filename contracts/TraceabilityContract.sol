// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9.0;

contract TraceabilityContract {

    string public _barcode;
    string public _lotId;
    uint public _expirationDate;
    string public _jsonData;

    constructor (string memory barcode,
                 string memory lotId,
                 uint expirationDate,
                 string memory jsonData)
    {
        _barcode = barcode;
        _lotId = lotId;
        _expirationDate = expirationDate;
        _jsonData = jsonData;
    }

    function getJsonData() public view returns(string memory){
        return _jsonData;
    }
}