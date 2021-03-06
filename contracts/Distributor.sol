// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.5.8;
import "./IToken.sol";


contract Distributor {
  /* address of the TRC20-token, to be used to airdrop */
  address public tokenAddress;
  /* only caller call sendAirdrop*/
  address public caller;
  /* owner*/
  address public owner;
  constructor(address _tokenAddress, address _caller) public {
    tokenAddress = _tokenAddress;
    caller = _caller;
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(owner == msg.sender, "only owner");
    _;
  }

  modifier onlyCaller() {
    require(caller == msg.sender, "only caller");
    _;
  }

  function upgradeOwner(address newOwner) external onlyOwner {
      require(newOwner != owner && newOwner != address(0), "invalid newOwner");
      owner = newOwner;
  }

  function upgradeCaller(address newCaller) external onlyOwner {
      require(newCaller != caller && newCaller != address(0), "invalid newOwner");
      caller = newCaller;
  }
  
  function sendAirdrop(address receiver, uint256 amount) external onlyCaller returns (bool) {
    require(Token(tokenAddress).transfer(receiver, amount));
    return true;
  }

  function balance() public view returns (uint) {
      return Token(tokenAddress).balanceOf(address(this));
  }
}