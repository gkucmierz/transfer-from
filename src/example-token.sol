// SPDX-License-Identifier: MIT

pragma solidity ^0.7.2;

contract ERC20 {

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowed;

  function _transfer(address sender, address recipient, uint256 amount) internal virtual returns (bool) {
    require(balanceOf[sender] >= amount);
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
  }

  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
  }

  function allowance(address holder, address spender) public view returns (uint256) {
    return allowed[holder][spender];
  }

  function approve(address spender, uint256 amount) public returns (bool) {
    require(balanceOf[msg.sender] >= amount);
    allowed[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
  }

  function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
    require(allowed[sender][msg.sender] >= amount);
    _transfer(sender, recipient, amount);
    allowed[sender][msg.sender] -= amount;
  }

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed holder, address indexed spender, uint256 value);
}

contract ERCTransferFrom is ERC20 {
  function transferFrom(address recipient, uint256 amount, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
    bytes32 hash = keccak256(abi.encodePacked('transferFrom', recipient, amount));
    address from = ecrecover(hash, _v, _r, _s);
    return super._transfer(from, recipient, amount);
  }

  function transferFromUntil(address recipient, uint256 untilBlock, uint256 amount, uint8 _v, bytes32 _r, bytes32 _s) public returns (bool) {
    require (untilBlock <= block.number);
    bytes32 hash = keccak256(abi.encodePacked('transferFrom', recipient, amount, untilBlock));
    address from = ecrecover(hash, _v, _r, _s);
    return super._transfer(from, recipient, amount);
  }
}

contract ExtendedToken is ERCTransferFrom {
  constructor() {
    name = 'Token Name';
    symbol = 'TFT';
    decimals = 18;
    totalSupply = 10 ** decimals * 1000_000_000;
    balanceOf[msg.sender] = totalSupply;
  }

  function _transfer(address sender, address recipient, uint256 amount) internal override returns (bool) {
    super._transfer(sender, recipient, amount);
  }
}
