
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./Masterable.sol";

/**
 * Real token
 */
contract ContractToken is ERC20, Pausable, Ownable, Masterable {
    constructor(address master_, string memory name, string memory symbol, uint256 totalSupply) ERC20(name, symbol) Masterable(master_) {
        _mint(master(), totalSupply);
        _pause();
    }
    
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual onlyMaster {
        _burn(master(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual onlyOwner {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ContractToken: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
    
    /**
     * @dev Mint `amount` tokens from the account.
     *
     * See {ERC20-_mint}.
     */
    function mint(address account, uint256 amount) public virtual onlyOwner {
        _mint(account, amount);
    }
    
    function transfer(address recipient, uint256 amount) public virtual whenNotPaused override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function unpause() public virtual onlyMaster {
        _unpause();
    }
}