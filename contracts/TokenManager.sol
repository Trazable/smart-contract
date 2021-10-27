// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./Stakeable.sol";
import "./ContractToken.sol";
import "./RewardToken.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";

/**
 * Contract manager to allow staking
 * 
 */
contract TokenManager is Context, Ownable, Stakeable {
    ContractToken contractToken;
    RewardToken rewardToken;
    
    /**
     * @notice
     * _rewardPerMonth is 1000 because it is used to represent 2592000 Seconds, since we only use integer numbers
     * This will give users 0.1% reward for each staked token / 30 days
     */
    uint256 internal _rewardPerMonth = 1000;
    
    /**
     * @notice
     * _minimumStakeTime is 30 days because it is used to represent 0.001, since we only use integer numbers
     * https://docs.soliditylang.org/en/v0.4.21/units-and-global-variables.html#time-units
     * This will give users 0.1% reward for each staked token / 30 days
     */
    uint256 private _minimumStakeTime = 30 days;
    
    constructor() {
        contractToken = new ContractToken(_msgSender(), "Token", "TKN", 5000000000);
        rewardToken = new RewardToken("Reward", "TKNR");
    }

    /**
     * @notice
     * Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID 
     */
    function stake(uint256 _amount) public {
        // Simple check so that user does not stake 0 
        require(_amount > 0, "TokenManager: Cannot stake nothing");
        
        // Simple check so that user does not stake more than own
        require(contractToken.balanceOf(_msgSender()) > 0, "TokenManager: Cannot stake more than own");
        
        // Burn ContractTokens amount from the sender and place those tokens inside a stake container
        contractToken.burnFrom(_msgSender(), _amount);
        _stake(_amount);
    }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Call getStakes to know all available stakes
     * Will return the reward amount to MINT onto the account
    */
     function withdrawStake(uint256 amount, uint256 index) internal returns(uint256){
        //  Get the withdraw details
         StakeWithdraw memory stakeWithdraw = _withdrawStake(amount, index, _rewardPerMonth, _minimumStakeTime);
         
        //  Mint the amount withdraw to ContractToken
        contractToken.mint(_msgSender(), stakeWithdraw.amount);
        
        // Mint reward tokens
        rewardToken.mint(_msgSender(), stakeWithdraw.reward);
         
         return stakeWithdraw.reward;
     }

     /**
     * @notice
     * getStakes is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function getStakes(address _staker) public view returns(StakingSummary memory){
        return _getStakes(_staker, _rewardPerMonth, _minimumStakeTime);
    }
}