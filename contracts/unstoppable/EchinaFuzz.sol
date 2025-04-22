// @dev to run: echidna ./ --config contracts/unstoppable/config.yaml --contract EchinaUnstoppableFuzz



pragma solidity ^0.8.0;

//::: @dev In case of forge test
// forge install foundry-rs/forge-std --no-commit
// forge install dapphub/ds-test --no-commit
// import "forge-std/console.sol";
// import { Test } from "forge-std/Test.sol";
// to run: forge test --match-path contracts/unstoppable/EchinaPrint.sol -vvv

import "../unstoppable/UnstoppableLender.sol";
import "../unstoppable/ReceiverUnstoppable.sol";
import "../DamnValuableToken.sol";


contract EchinaUnstoppableFuzz {
  UnstoppableLender public lender;
  
  
  DamnValuableToken public DVT_Token = new DamnValuableToken();

  // We will send ETHER_IN_POOL to the flash loan pool.
  uint256 constant ETHER_IN_POOL = 1000000e18;
  // We will send INITIAL_ATTACKER_BALANCE to the attacker (which is the deployer) of this contract.
  uint256 constant INITIAL_ATTACKER_BALANCE = 100e18;

  constructor() payable {
    lender = new UnstoppableLender(address(DVT_Token));
    DVT_Token.approve(address(lender), ETHER_IN_POOL);
    lender.depositTokens(ETHER_IN_POOL);

    DVT_Token.transfer(msg.sender, INITIAL_ATTACKER_BALANCE);
  }

  function exec_flash_loan(uint256 amount) public {
    lender.flashLoan(amount);
  }

  function receiveTokens(address token_address, uint256 amount) external {
    DamnValuableToken(token_address).transfer(msg.sender, amount);
  }

  function echidna_check_lender_balance() public view returns (bool) {    
    return(DVT_Token.balanceOf(address(lender)) >= ETHER_IN_POOL);
  }

  function echidna_test_if_flashLoan_is_available() public returns (bool) {
    lender.flashLoan(10);
    return true;
  }

}

