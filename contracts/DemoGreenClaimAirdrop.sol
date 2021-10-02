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
  event Event1(address[] addresses, uint256[] ratios); 
  event Event0(uint256 length, uint256 length1);
  event Event2(uint256 totalRatios);
  event Event3(uint256 totalAmount);
  event Event4(uint256 i, uint256 tmpAmount);
  event Event5(address[] _addresses);
  event Event6(bool success);
  struct Attender {
    address addr;
    uint256 ratio;
    uint256 amount;
    bool flag;
  }

  address private _rewardWallet;
  mapping (address => Attender) private _attenders;

  address[] private _addresses;
  address[] private _remainingAddresses;

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

      emit Event4(i,tmpAmount);
      Attender storage attender = _attenders[addresses[i]];
      attender.addr = addresses[i];
      attender.ratio = ratios[i];
      attender.amount = tmpAmount;
      attender.flag = true;

      _addresses[i] = addresses[i];
    }
    _claimActivated = true;
    _endContest = endContest;
  }

  function claimBNBs() public payable claimActive {
    address attender = _msgSender();
    if (_addresses.length > 0) {
      require(_attenders[attender].flag, "AIRDROP: Current user is not a member of contest anymore!");

      _withdraw(attender, _attenders[attender].amount);
    } else {
      require(address(this).balance > 0, "AIRDROP: The contract has no money!");

      _withdraw(_rewardWallet, address(this).balance);
    }
  }

  function _withdrawRemaining() private onlyOwner {
    uint256 totalRemaining = 0;
    for (uint256 i = 0; i < _addresses.length; i++) {
      if (_attenders[_addresses[i]].amount > 0) {
        totalRemaining = _attenders[_addresses[i]].amount + totalRemaining;
        _attenders[_addresses[i]].amount = 0;
        _remainingAddresses[_remainingAddresses.length] = _addresses[i];
      }
    }
    if (totalRemaining > 0)
      _withdraw(_rewardWallet, totalRemaining);
  }
  function _withdraw(address hisAddress, uint256 amount) private claimActive {
    (bool success, ) = hisAddress.call{value: amount}("");
    emit Event6(success);
    require(success, "WITHDRAW: Transfer failed.");
    _attenders[hisAddress].amount = 0;
  }

  function getAddresses() public view returns(address[] memory) {
    return _addresses;
  }

  function getAttenders(address hisAddress) public view returns(address, uint256, uint256)  {
    return (_attenders[hisAddress].addr, _attenders[hisAddress].ratio, _attenders[hisAddress].amount);
  }

  function getActivated() public view returns(bool) {
    return _claimActivated;
  }

  function getEndContest() public view returns(uint256) {
    return _endContest;
  }

  function getRemaining() public view onlyOwner returns(address[] memory)  {
    return _remainingAddresses;
  }

  function stopAirDrop() public claimActive {
    _endContest = 0;
    _claimActivated = false;
    _withdrawRemaining();
  }

  receive() external payable {}
}