
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./Stakeable.sol";

contract ContractToken is ERC20, Pausable, Ownable, Stakeable {
    /**
     * @notice
      rewardPerHour is 1000 because it is used to represent 0.001, since we only use integer numbers
      This will give users 0.1% reward for each staked token / H
     */
    uint256 internal rewardPerHour;
    
    constructor(string memory name, string memory symbol, uint256 totalSupply, uint256 _rewardPerHour) ERC20(name, symbol) {
        rewardPerHour = _rewardPerHour;
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
    
    /**
    * Add functionality like burn to the _stake afunction
    *
     */
    function stake(uint256 _amount) public virtual whenNotPaused {
        // Make sure staker actually is good for it
        require(_amount < balanceOf(_msgSender()), "Contract: Cannot stake more than you own");

        _stake(_amount);
        // Burn the amount of tokens on the sender
        _burn(_msgSender(), _amount);
    }
    
    /**
    * @notice withdrawStake is used to withdraw stakes from the account holder
     */
    function withdrawStake(uint256 amount, uint256 stake_index)  public {
      uint256 amount_to_mint = _withdrawStake(amount, stake_index);
      // Return staked tokens to user
      _mint(_msgSender(), amount_to_mint);
    }

    
    function pause() public virtual onlyOwner {
        _pause();
    }
    
    function unpause() public virtual onlyOwner {
        _unpause();
    }
    
}