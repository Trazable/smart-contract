// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (a master) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyMaster`, which can be applied to your functions to restrict their use to
 * the master.
 */
abstract contract Masterable is Context {
    address private _master;

    /**
     * @dev Initializes the contract setting the master.
     */
    constructor(address master_) {
        _master = master_;
    }

    /**
     * @dev Returns the address of the current master.
     */
    function master() public view virtual returns (address) {
        return _master;
    }

    /**
     * @dev Throws if called by any account other than the master.
     */
    modifier onlyMaster() {
        require(master() == _msgSender(), "Masterable: caller is not the master");
        _;
    }
}