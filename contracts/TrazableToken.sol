// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract TrazableToken is ERC20, Ownable {
    
    uint256 public maxSupply = 500000000 ether;
    
    constructor() ERC20("Trazable", "TRZ") {
        _mint(_msgSender(), maxSupply);
    }
    
    function burn(uint256 amount) public onlyOwner {
        _burn(_msgSender(), amount);
    }
    
}


