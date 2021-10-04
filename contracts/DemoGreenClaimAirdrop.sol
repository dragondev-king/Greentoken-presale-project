// SPDX-License-Identifier: MIT

/**
 *      &&&     &&&&& &&&&&&&&   &&&&&&&&   &&&&&&&&    &&&&&   &&&&&&&&
 *     &&&&&     &&&  &&&   &&&  &&&   &&&  &&&   &&&  &&&&&&&  &&&   &&&
 *    &&& &&&    &&&  &&&   &&&  &&&    &&& &&&   &&& &&&   &&& &&&   &&&
 *    &&& &&&    &&&  &&&&&&&&   &&&    &&& &&&&&&&&  &&&   &&& &&&&&&&&
 *   &&&   &&&   &&&  &&&   &&&  &&&    &&& &&&   &&& &&&   &&& &&&
 *   &&&&&&&&&   &&&  &&&   &&&  &&&   &&&  &&&   &&&  &&&&&&&  &&&
 *  &&&     &&& &&&&& &&&    &&& &&&&&&&&   &&&    &&&  &&&&&   &&&
 */

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// DemoGreen Airdrop & Claim Feature
contract AirDrop is Context, Ownable {
  using SafeMath for uint256;
  using Address for address;
  struct Attender {
    address addr;
    uint256 ratio;
    uint256 amount;
    bool flag;
  }

  event Event1(uint256 am, address addr);
  event Event2(address[] addr);
  address private _rewardWallet;
  mapping (address => Attender) private _attenders;

  address[] private _addresses;
  address[] private _remainingAddresses;
  mapping (address => uint256) _remainingAmounts;

  uint256 private _endContest = 0;
  bool private _claimActivated;

  modifier claimActive() {
    require(_claimActivated == true, "AIRDROP: Claim has not been activated!");
    require(_endContest > 0 && block.timestamp < _endContest , "AIRDROP: Claim has not been activated!");

    _;
  }

  modifier claimNotActive() {
    require(_claimActivated == false, "AIRDROP: Claim has been activated!");
    require(_endContest < block.timestamp, "AIRDROP: Claim has been expired!");

    _;
  }

  constructor (address wallet) {
    require(wallet != address(0), "AIRDROP: Wallet address can't be a zero address!");

    _rewardWallet = wallet;
    _claimActivated = false;
  }

  function initContest(address[] memory addresses, uint256[] memory ratios, uint256 endContest) public onlyOwner claimNotActive {
    require(addresses.length == ratios.length, "AIRDROP: attender addresses and ratios arrays should have the same length");
    require(address(this).balance > 0, "AIRDROP: The contract has no money!");
    require(addresses.length > 0, "AIRDROP: No attenders for this contest!");
    require(_endContest < block.timestamp, "AIRDROP: Claim has been started!");
    require( ! (_addresses.length > 0), "AIRDROP: Already Finished!");

    uint256 totalRatios = 0;

    for (uint256 i = 0; i < addresses.length; i++) {
      require(addresses[i] != address(0), "AIRDROP: Attender Address can't be a zero address!");
      totalRatios = totalRatios + ratios[i];
    }

    uint256 totalAmount = address(this).balance;
    uint256 tmpAmount = 0;
    uint256 realTotalAmount = 0;
    for (uint256 i = 0; i < addresses.length; i++) {
      if (i != addresses.length.sub(1)) {
        tmpAmount = totalAmount.mul(ratios[i]).div(totalRatios);
      } else {
        tmpAmount = totalAmount.sub(realTotalAmount);
      }

      realTotalAmount = realTotalAmount.add(tmpAmount);

      Attender memory newAttender;
      newAttender.addr = addresses[i];
      newAttender.amount = tmpAmount;
      newAttender.ratio = ratios[i];
      newAttender.flag = true;
      _attenders[addresses[i]] = newAttender;
      _addresses.push(addresses[i]);
    }
    _claimActivated = true;
    _endContest = endContest;
  }

  function claimBNBs() public payable claimActive {
    address attender = _msgSender();
    require(address(this).balance > 0, "AIRDROP: The contract has no money!");
    if (_addresses.length > 0) {
      require(_attenders[attender].flag, "AIRDROP: Current user is not a member of contest anymore!");
      require(_attenders[attender].amount > 0, "AIRDROP: Current user has no cryptocurrency to claim!");
      _withdraw(attender, _attenders[attender].amount);
    } else {
      _withdraw(_rewardWallet, address(this).balance);
    }
  }

  function stopAirDrop() public onlyOwner claimActive {
    _withdrawRemaining();
    _endContest = 0;
    _claimActivated = false;
  }

  function _withdrawRemaining() private {
    for (uint256 i = 0; i < _addresses.length; i++) {
      emit Event1(_attenders[_addresses[i]].amount, _addresses[i]);
      if (_attenders[_addresses[i]].amount > 0) {
        _remainingAmounts[_addresses[i]] = _attenders[_addresses[i]].amount;
        _attenders[_addresses[i]].amount = 0;
        _remainingAddresses.push(_addresses[i]);
        emit Event2(_remainingAddresses);
      }
    }
    if (address(this).balance > 0)
      _withdraw(_rewardWallet, address(this).balance);
  }
  function _withdraw(address hisAddress, uint256 amount) private claimActive {
    (bool success, ) = hisAddress.call{value: amount}("");
    require(success, "WITHDRAW: Transfer failed.");
    _attenders[hisAddress].amount = 0;
  }

  function getAddresses() public view returns(address[] memory) {
    return _addresses;
  }

  function getAttender(address hisAddress) public view returns(address, uint256, uint256)  {
    return (_attenders[hisAddress].addr, _attenders[hisAddress].ratio, _attenders[hisAddress].amount);
  }

  function getActivated() public view returns(bool) {
    return _claimActivated;
  }

  function getEndContest() public view returns(uint256) {
    return _endContest;
  }

  function getRemainingAddresses() public view returns(address[] memory) {
    return _remainingAddresses;
  }

  function getRemainingAmount(address hisAddress) public view returns (uint256) {
    return _remainingAmounts[hisAddress];
  }

  receive() external payable {}
}