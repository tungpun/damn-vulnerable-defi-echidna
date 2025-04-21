// echidna ./ --config contracts/naive-receiver/config.yaml --contract FLTest    


pragma solidity ^0.8.0;

import "./FlashLoanReceiver.sol";
import "./NaiveReceiverLenderPool.sol";

contract FLTest {

  uint256 public ETHER_IN_POOL = 1000 ether;
  uint256 public ETHER_IN_RECEIVER = 10 ether;

  NaiveReceiverLenderPool public pool;
  FlashLoanReceiver public receiver;

  constructor() payable {
    pool = new NaiveReceiverLenderPool();
    receiver = new FlashLoanReceiver(payable(address(pool)));
    payable(address(pool)).transfer(ETHER_IN_POOL);
    payable(address(receiver)).transfer(ETHER_IN_RECEIVER);
  }

  // function init_eth() public payable {
  //   // Send ETH to pool
  //   (bool success, ) = payable(address(pool)).call{value: ETHER_IN_POOL}("");
  //   require(success, "Failed to send ETH to pool");

  //   // Send ETH to receiver
  //   (bool success2, ) = payable(address(receiver)).call{value: ETHER_IN_RECEIVER}("");
  //   require(success2, "Failed to send ETH to receiver");

  //   // Verify balances
  //   require(address(pool).balance == ETHER_IN_POOL, "Balance of the pool is set");
  //   require(address(receiver).balance == ETHER_IN_RECEIVER, "Balance of the receiver is set");
  // }
  
  function echidna_test_pool_balance() public view returns (bool) {
    return address(pool).balance == ETHER_IN_POOL;
  }

  function echidna_test_receiver_balance() public view returns (bool) {
    return address(receiver).balance >= ETHER_IN_RECEIVER;
  }
  

  // function echidna_test_eth_transfer() public payable returns (bool) {
  //   // Send ETH to pool
  //   require(address(pool).balance == ETHER_IN_POOL, "Balance of the pool is set");
  //   require(address(receiver).balance == ETHER_IN_RECEIVER, "Balance of the receiver is set");

  //   // Return true if pool has the expected balance
  //   return address(pool).balance == ETHER_IN_POOL;
  // }

}
