pragma solidity ^0.8.0;



import "./SideEntranceLenderPool.sol";

contract SideEntranceFuzzer {

    SideEntranceLenderPool public lenderPool;

    uint256 constant ETHER_IN_POOL = 1 ether;

    constructor() payable {
      lenderPool = new SideEntranceLenderPool();
      lenderPool.deposit{value: ETHER_IN_POOL}();

      require(address(lenderPool).balance == ETHER_IN_POOL, "Initial balance is not correct");
    }

    function execute() external payable {
      lenderPool.deposit{value: msg.value}();
    }

    function echidna_withdraw() public returns (bool) {
      uint256 balanceThisContractBefore = address(this).balance;
      lenderPool.withdraw();
      uint256 balanceThisContractAfter = address(this).balance;
      return(balanceThisContractAfter >= balanceThisContractBefore);
    }

    function do_flash_loan() public returns (bool){
      uint256 balanceBefore = address(lenderPool).balance;
      uint256 amount = 1 ether;
      lenderPool.flashLoan(amount);      
      return(address(lenderPool).balance == balanceBefore);
    }

    function echidna_do_flash_loan() public returns (bool){
      uint256 balanceBefore = address(lenderPool).balance;
      uint256 amount = 1 ether;
      lenderPool.flashLoan(amount);      
      return(address(lenderPool).balance == balanceBefore);
    }

    function echidna_test_balance() public view returns (bool) {
      return(address(lenderPool).balance >= ETHER_IN_POOL);
    }
    
    receive() external payable {}    

}
