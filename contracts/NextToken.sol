// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./INextTokens.sol";

contract NextDevToken is ERC20, Ownable {
  uint256 public constant tokenPrice = 0.001 ether;

  uint256 public constant tokensPerNFT = 10 * 10**18;
  uint256 public constant maxTotalSupply = 10000 * 10**18;
  INextTokens NextTokensNFT;

  mapping(uint256 => bool) public tokendIdsClaimed;

  constructor(address _nextDevTokenContract) ERC20("Next Dev Token", "NDT") {
    NextTokensNFT = INextTokens(_nextDevTokenContract);
  }

  function mint(uint256 amount) public payable {
    uint256 _requiredAmount = tokenPrice * amount;
    require(msg.value >= _requiredAmount, "Ether sent is incorrect");

    uint256 amountWithDecimals = amount * 10**18;
    require((totalSupply() + amountWithDecimals) <= maxTotalSupply,
      "Exceeds the max total supply available."
    );
    _mint(msg.sender, amountWithDecimals);
  }

  function claim() public {
    address sender = msg.sender;
    uint256 balance = NextTokensNFT.balanceOf(sender);
    require(balance > 0, "You don't own any Next Tokens NFT");
    uint256 amount = 0;

    for(uint256 i = 0; i < balance; i++) {
      uint256 tokenId = NextTokensNFT.tokenOfOwnerByIndex(sender, i);
      if(!tokendIdsClaimed[tokenId]) {
        amount += 1;
        tokendIdsClaimed[tokenId] = true;
      }
    }
    require(amount > 0, "You have already claimed all the tokens");
    _mint(msg.sender, amount * tokensPerNFT);
  }

  function withdraw() public onlyOwner {
    uint256 amount = address(this).balance;
    require(amount > 0, "Nothing to withdraw, contract balance empty");

    address _owner = owner();
    (bool sent, ) = _owner.call{value: amount}("");
    require(sent, "Failed to send Ether");
  }

  receive() external payable {}

  fallback() external payable {}
}
