// SPDX-License-Identifier: GPL-3.0
    
pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/ContractToken.sol";

// File name has to end with '_test.sol
contract testSuite {
    // Contract instance
    ContractToken tokenContract;
    address acc0 = TestsAccounts.getAccount(0); //owner by default
    address acc1 = TestsAccounts.getAccount(1);
    address acc2 = TestsAccounts.getAccount(2);
    address acc3 = TestsAccounts.getAccount(3);
    address recipient = TestsAccounts.getAccount(4); //recipient
    
    // Reinitialice the contract before each test
    function beforeEach() public payable {
        tokenContract = new ContractToken('ContractToken', 'TKN', 1000000);
        tokenContract.unpause();
        
        tokenContract.transfer(acc0, 10000);
        tokenContract.transfer(acc2, 100);
    }
    
    function checkBalance() public {
        uint256 balance0 = tokenContract.balanceOf(acc0);
        Assert.ok(balance0 == 10000, 'should be true');
        
        uint256 balance2 = tokenContract.balanceOf(acc2);
        Assert.ok(balance2 == 100, 'should be true');
    }
    
    function shouldTransfer() public {
        bool transferResponse = tokenContract.transfer(acc1, 100);
        Assert.ok(transferResponse, 'should be transfer true');
        
        uint256 targetBalance = tokenContract.balanceOf(acc1);
        Assert.ok(targetBalance == 100, 'should be balance true');
    }

}
