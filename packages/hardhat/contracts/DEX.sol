pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT
// import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DEX {

  using SafeMath for uint256;

  IERC20 token;

  constructor(address token_addr) {
    token = IERC20(token_addr);
  }

  // write your functions here...
  uint256 public totalLiquidity;
  mapping (address => uint256) public liquidity;

  function init(uint256 tokens) public payable returns (uint256) {
    require(totalLiquidity == 0, "DEX:init - already has liquidity");
    totalLiquidity = address(this).balance;
    liquidity[msg.sender] = totalLiquidity;
    require(token.transferFrom(msg.sender, address(this), tokens));
    return totalLiquidity;
  }

  function price(uint256 inputAmount, uint256 inputReserve, uint256 outputReserve) public view returns (uint256) {
    uint256 inputAmountWithFee = inputAmount.mul(997);
    uint256 numerator = inputAmountWithFee.mul(outputReserve);
    uint256 denominator = inputReserve.mul(1000).add(inputAmountWithFee);
    return numerator / denominator;
  }
  
  function ethToToken() public payable returns (uint256) {
    uint256 tokenReserve = token.balanceOf(address(this));
    uint256 tokenBought = price(msg.value, address(this).balance - msg.value, tokenReserve);
    require(token.transfer(msg.sender, tokenBought));
    return tokenBought;
  }

  function tokenToEth(uint256 tokens) public returns (uint256) {
    uint256 tokenReserve = token.balanceOf(address(this));
    uint256 ethBought = price(tokens, tokenReserve, address(this).balance);
    (bool sent, ) = msg.sender.call{value: ethBought}("");
    require(sent, "Failed to send user eth");
    require(token.transferFrom(msg.sender, address(this), tokens));
    return ethBought;
  }
}