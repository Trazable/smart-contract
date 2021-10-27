
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";


contract ContractToken is ERC20, Pausable, Ownable {
    
    constructor(string memory name, string memory symbol, uint256 totalSupply) ERC20(name, symbol) {
        _mint(_msgSender(), totalSupply);
        _pause();
    }
    
    function burn(uint256 amount) public virtual onlyOwner whenNotPaused {
        _burn(_msgSender(), amount);
    }
    
    function transfer(address recipient, uint256 amount) public virtual whenNotPaused override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function unpause() public virtual onlyOwner {
        _unpause();
    }
    
}