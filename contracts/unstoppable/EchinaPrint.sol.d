// echidna ./ --config contracts/unstoppable/config.yaml --contract EchinaUnstoppableFuzz
// forge test --match-path contracts/unstoppable/EchinaFuzz.sol -vvv

pragma solidity ^0.8.0;

//::: In case of forge test
// forge install foundry-rs/forge-std --no-commit
// forge install dapphub/ds-test --no-commit
import "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";

import "../unstoppable/UnstoppableLender.sol";
import "../unstoppable/ReceiverUnstoppable.sol";
import "../DamnValuableToken.sol";


contract EchinaUnstoppableFuzz is Test {
  UnstoppableLender public lender;
  
  uint256 public initialAmount = 2 ether;
  DamnValuableToken public DVT_Token = new DamnValuableToken();

  constructor() payable {
    
    // console.log("balance of this contract (before)", DVT_Token.balanceOf(address(this)));
    // console.log("balance of lender (before)", DVT_Token.balanceOf(address(lender)));

    lender = new UnstoppableLender(address(DVT_Token));
    DVT_Token.approve(address(lender), initialAmount);
    lender.depositTokens(initialAmount);
    // console.log("balance of this contract (after )", DVT_Token.balanceOf(address(this)));
    // console.log("balance of lender (after )", DVT_Token.balanceOf(address(lender)));
  }

  function exec_flash_loan(uint256 amount) public {
    lender.flashLoan(amount);
  }

  function receiveTokens(address token_address, uint256 amount) external {
    DamnValuableToken(token_address).transfer(msg.sender, 8);
  }

  function test_echidna_flash_loan() public returns (bool) {
    console.log("Starting flash loan test");
    console.log("Initial lender balance:", DVT_Token.balanceOf(address(lender)));
    console.log("Initial contract balance:", DVT_Token.balanceOf(address(this)));
    console.log("Initial amount:", initialAmount);
    
    uint256 amountBefore = DVT_Token.balanceOf(address(lender));
    console.log("Amount before flash loan:", amountBefore);
    
    // lender.flashLoan(initialAmount);

    try lender.flashLoan(1) {
      console.log("Flash loan successful");
      uint256 amountAfter = DVT_Token.balanceOf(address(lender));
      console.log("Amount after flash loan:", amountAfter);
      console.log("Balance difference:", amountAfter - amountBefore);
      return true;
    } catch Error(string memory reason) {
      console.log("Flash loan failed with error:", reason);
      return false;
    } catch (bytes memory) {
      console.log("Flash loan failed with unknown error");
      return false;
    }
  }

  function echidna_check_lender_balance() public view returns (bool) {
    // console.log("Testtttttt");
    // console.log("DVT balance of this contract", DVT_Token.balanceOf(address(this)));
    // lender.flashLoan(0);
    return(DVT_Token.balanceOf(address(lender)) == initialAmount);
  }

}

