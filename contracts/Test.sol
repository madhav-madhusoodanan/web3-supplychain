//SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.4;

contract Test  {
    
    /*Events*/
    event Check(address indexed user, address indexed batchNo);


    function testing(address _caller) public returns(bool) {
        emit Check(msg.sender, _caller);
        return true;
    }



}
