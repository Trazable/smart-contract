// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";


/**
* @notice Stakeable is a contract who is ment to be inherited by other contract that wants Staking capabilities
*/
abstract contract Stakeable is Context {
    /**
     * @notice
     * A stake struct is used to represent the way we store stakes, 
     * A Stake will contain the users address, the amount staked and a timestamp, 
     * Since which is when the stake was made
     */
    struct Stake {
        // Stakeholder address
        address account;
        // Amount of tokens staked
        uint256 amount;
        // Creation timestamp
        uint256 createdAt;
        // This claimable field used to tell how big of a reward is currently available
        uint256 claimable;
    }
    
    /**
     * @notice Stakeholder is a staker that has active stakes
     */
    struct Stakeholder{
        address account;
        Stake[] addressStakes;
        
    }
    
    /**
     * @notice
     * StakingSummary is a struct that is used to contain all stakes performed by a certain account
     */ 
     struct StakingSummary{
         uint256 totalAmount;
         Stake[] stakes;
     }
    
    /**
     * @notice
     * StakeWithdraw is a struct that is used to contain the withdraw result to some stake
     */ 
     struct StakeWithdraw{
         uint256 amount;
         uint256 reward;
         address staker;
     }

    /**
     * @notice 
     *   This is a array where we store all Stakes that are performed on the Contract
     *   The stakes for each address are stored at a certain index, the index can be found using the stakes mapping
     */
    Stakeholder[] internal stakeholders;
    
    /**
     * @notice 
     * stakes is used to keep track of the INDEX for the stakers in the stakes array
     */
    mapping(address => uint256) internal stakes;
    
    /**
     * @notice Staked event is triggered whenever a user stakes tokens, address is indexed to make it filterable
     */
     event Staked(address indexed staker, uint256 amount, uint256 index, uint256 timestamp);

    /**
     * @notice _addStakeholder takes care of adding a stakeholder to the stakeholders array
     */
    function _addStakeholder(address staker) internal returns (uint256){
        // Push a empty item to the Array to make space for our new stakeholder
        stakeholders.push();
        // Calculate the index of the last item in the array by Len-1
        uint256 userIndex = stakeholders.length - 1;
        // Assign the address to the new index
        stakeholders[userIndex].account = staker;
        // Add index to the stakeHolders
        stakes[staker] = userIndex;
        return userIndex; 
    }

    /**
     * @notice
     * _Stake is used to make a stake for an sender. It will remove the amount staked from the stakers account and place those tokens inside a stake container
     * StakeID 
     */
    function _stake(uint256 _amount) internal{
        // Simple check so that user does not stake 0 
        require(_amount > 0, "Stakeable: Cannot stake nothing");
        
        // Mappings in solidity creates all values, but empty, so we can just check the address
        uint256 index = stakes[_msgSender()];
        
        // block.timestamp = timestamp of the current block in seconds since the epoch
        uint256 timestamp = block.timestamp;
        
        // See if the staker already has a staked index or if its the first time
        if(index == 0){
            // This stakeholder stakes for the first time
            // We need to add him to the stakeHolders and also map it into the Index of the stakes
            // The index returned will be the index of the stakeholder in the stakeholders array
            index = _addStakeholder(_msgSender());
        }

        // Use the index to push a new Stake
        // push a newly created Stake with the current block timestamp.
        stakeholders[index].addressStakes.push(Stake(_msgSender(), _amount, timestamp, 0));
        
        // Emit an event that the stake has occured
        emit Staked(_msgSender(), _amount, index,timestamp);
    }

    /** 
     * @notice
     * _calculateStakeReward is used to calculate how much an account should be rewarded for their stakes
     * and the duration the stake has been active
     */
    function _calculateStakeReward(Stake memory _current_stake, uint256 rewardPerMonth, uint256 minimumStakeTime) internal view returns(uint256){
        // First calculate how long the stake has been active
        // Use current seconds since epoch - the seconds since epoch the stake was made
        // The output will be duration in SECONDS,
        uint256 stakedTime = block.timestamp - _current_stake.createdAt;
        
        // If the staked time is lower than the minumum required to have rewards return zero
        if (stakedTime < minimumStakeTime) return 0;
        
        // We will reward the staker per Month So thats rewardPerMonth per 2592000 seconds
        // the alghoritm is  seconds = block.timestamp - stake seconds (block.timestap - _stake.createdAt)
        // month = Seconds / 2592000 (seconds /2592000) 86400 is an variable in Solidity names days and multiply to 30
        // we then multiply each token by the moths staked , then divide by the rewardPerMonth rate 
        return ((stakedTime / 30 days) * _current_stake.amount) / rewardPerMonth;
      }

    /**
     * @notice
     * withdrawStake takes in an amount and a index of the stake and will remove tokens from that stake
     * Notice index of the stake is the users stake counter, starting at 0 for the first stake
     * Will return the amount to MINT onto the acount
     * Will also _calculateStakeReward and reset timer
    */
     function _withdrawStake(uint256 amount, uint256 index, uint256 rewardPerMonth, uint256 minimumStakeTime) internal returns(StakeWithdraw memory){
         // Grab user_index which is the index to use to grab the Stake[]
        uint256 user_index = stakes[_msgSender()];
        Stake memory current_stake = stakeholders[user_index].addressStakes[index];
        require(current_stake.amount >= amount, "Staking: Cannot withdraw more than you have staked");

         // Calculate available Reward first before we start modifying data
         uint256 reward = _calculateStakeReward(current_stake, rewardPerMonth, minimumStakeTime);
         // Remove by subtracting the money unstaked 
         current_stake.amount = current_stake.amount - amount;
         // If stake is empty, 0, then remove it from the array of stakes
         if(current_stake.amount == 0){
             delete stakeholders[user_index].addressStakes[index];
         }else {
             // If not empty then replace the value of it
             stakeholders[user_index].addressStakes[index].amount = current_stake.amount;
             // Reset timer of stake
            stakeholders[user_index].addressStakes[index].createdAt = block.timestamp;    
         }
         
         StakeWithdraw memory stakeWithdraw = StakeWithdraw(amount, reward, _msgSender());

         return stakeWithdraw;
     }

     /**
     * @notice
     * _getStakes is used to check if a account has stakes and the total amount along with all the seperate stakes
     */
    function _getStakes(address _staker, uint256 rewardPerMonth, uint256 minimumStakeTime) public view returns(StakingSummary memory){
        // totalStakeAmount is used to count total staked amount of the address
        uint256 totalStakeAmount; 
        // Keep a summary in memory since we need to calculate this
        StakingSummary memory summary = StakingSummary(0, stakeholders[stakes[_staker]].addressStakes);
        // Itterate all stakes and grab amount of stakes
        for (uint256 s = 0; s < summary.stakes.length; s += 1) {
           uint256 availableReward = _calculateStakeReward(summary.stakes[s], rewardPerMonth, minimumStakeTime);
           summary.stakes[s].claimable = availableReward;
           totalStakeAmount = totalStakeAmount+summary.stakes[s].amount;
       }
       
       // Assign calculate amount to summary
       summary.totalAmount = totalStakeAmount;
        return summary;
    }

}