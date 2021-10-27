// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

/**
 * ERC20 Mintable Token
 * Used as utility token
 */
contract RewardToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}
    
    /**
     * Mint reward tokens to desired address
     * Only Manager can mint
     */
    function mint(address account, uint256 amount) public virtual onlyOwner {
       _burn(account, amount);
    }
}