pragma solidity ^0.8.0;



import "./SideEntranceLenderPool.sol";

contract LenderPoolFactory {
  function createLenderPool() public payable returns (SideEntranceLenderPool) {
    SideEntranceLenderPool lenderPool = new SideEntranceLenderPool();
    lenderPool.deposit{value: msg.value}();
    return lenderPool;
  }
}

contract SideEntranceFuzzer {

    SideEntranceLenderPool public lenderPool;

    uint256 constant INITIAL_ETHER_IN_POOL = 1 ether;
    uint256 constant ETHER_TO_BE_EXPLOITED = 0.5 ether;

    constructor() payable {
      LenderPoolFactory lenderPoolFactory = new LenderPoolFactory();

      lenderPool = lenderPoolFactory.createLenderPool{value: INITIAL_ETHER_IN_POOL}();      
    }

    function deposit() public payable {
      lenderPool.deposit{value: msg.value}();
    }

    function withdraw() public returns (bool) {
      uint256 balanceThisContractBefore = address(this).balance;
      lenderPool.withdraw();
      uint256 balanceThisContractAfter = address(this).balance;
      return(balanceThisContractAfter >= balanceThisContractBefore);
    }

    function execute() payable public {
      lenderPool.deposit{value: msg.value}();
    }

    function do_flash_loan(uint256 amount) public {      
      require(amount <= address(lenderPool).balance, "Amount is greater than the balance of the lender pool");
      lenderPool.flashLoan(amount);      
    }

    function echidna_test_withdraw() public returns (bool) {
      lenderPool.withdraw();
      return(address(lenderPool).balance >= INITIAL_ETHER_IN_POOL);
    }
    
    receive() external payable {}

}
