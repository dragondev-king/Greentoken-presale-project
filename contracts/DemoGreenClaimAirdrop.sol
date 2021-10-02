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

  address private _rewardWallet;
  mapping (address => Attender) private _attenders;
  address[] private _addresses;
  mapping(address => uint256) private _claimAmounts;
  
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

<<<<<<< HEAD
  constructor (address wallet, uint256 endContest) {
=======
  constructor(address wallet) {
>>>>>>> 5de066e (Update addresses)
    require(wallet != address(0), "AIRDROP: Wallet address can't be a zero address!");
    require(endContest > 0, "AIRDROP: End contest can't be zero");

    _rewardWallet = wallet;
    _claimActivated = false;
    _endContest = endContest;
  }

  function initContest(address[] memory addresses, uint256[] memory ratios) public onlyOwner claimNotActive {
    require(addresses.length == ratios.length, "AirDROP: attender addresses and ratios arrays should have the same length");
    require(address(this).balance > 0, "AIRDROP: The contract has no money!");
    require(addresses.length > 0, "AIRDROP: No attenders for this contest!");
    uint256 totalRatios = 0;
    uint256 i = 0;
    for (i = 0; i < addresses.length; i++) {
      require(addresses[i] != address(0), "AIRDROP: Attender Address can't be a zero address!");
      totalRatios += ratios[i];
    }

    uint256 totalAmount = address(this).balance;
    uint256 tmpAmount = 0;
    uint256 realTotalAmount = 0;
    for (i = 0; i < addresses.length; i++) {
      tmpAmount = totalAmount.mul(ratios[i]).div(totalRatios);
      realTotalAmount += tmpAmount;
      _attenders[addresses[i]] = Attender(addresses[i], ratios[i], tmpAmount, true);
      _addresses[i] = addresses[i];
    }

    if (totalAmount - realTotalAmount > 0) {
      if (_attenders[_rewardWallet].flag) {
        _attenders[_rewardWallet] = Attender(_rewardWallet, 0, totalAmount - realTotalAmount + _attenders[_rewardWallet].amount, true);
      } else {
        _attenders[_rewardWallet] = Attender(_rewardWallet, 0, totalAmount - realTotalAmount, true);
        _addresses[i] = _rewardWallet;
      }
    }

    _claimActivated = true;
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

  function stopAirDrop() public claimActive {
    _endContest = 0;
    _claimActivated = false;
  }
  function _withdraw(address hisAddress, uint256 amount) private claimActive {
    (bool success, ) = hisAddress.call{value: amount}("");

    require(success, "WITHDRAW: Transfer failed.");
    _attenders[hisAddress].amount = 0;
  }

<<<<<<< HEAD
  //to recieve ETH from uniswapV2Router when swaping
  receive() external payable {}
=======
  function stopContest() public pure claimActive {
    _claimActivated = false;
  }
>>>>>>> 5de066e (Update addresses)
}