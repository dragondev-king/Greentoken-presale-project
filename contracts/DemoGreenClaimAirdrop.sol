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

  IERC20 private _token;
  address private _rewardWallet;
  address[] private _attenders;
  mapping(address => uint256) private _claimAmounts;
  
  uint256 private _weiRaised;
  bool private _claimActivated;

  modifier claimActive() {
    require(_claimActivated == true, "AIRDROP: Claim has not been activated!");
    _;
  }

  modifier claimNotActive() {
    require(_claimActivated == false, "AIRDROP: Claim has been activated!");
    _;
  }

  constructor (address wallet) {
    require(wallet != address(0), "AIRDROP: Wallet address can't be a zero address!");

    _rewardWallet = wallet;
    _claimActivated = false;
  }

  function initContest(address[] memory attenders) public onlyOwner claimNotActive {
    for (uint256 i = 0; i < attenders.length; i++) {
      require(attenders[i] != address(0), "AIRDROP: Attender Address can't be a zero address!");
    }

    _attenders = attenders;
    splitAmongContestors(_attenders);
    _claimActivated = true;
  }

  function splitAmongContestors(address[] memory attenders) internal {
    require(address(this).balance > 0, "AIRDROP: The contract has no money!");
    require(attenders.length > 0, "AIRDROP: No attenders for this contest!");

    uint256 attenderCounts = attenders.length;
    uint256 airdropAmount = address(this).balance.mul(attenderCounts);
    for (uint256 i = 0; i < attenderCounts; i++) {
      _claimAmounts[attenders[i]] = airdropAmount;

      if (i == attenderCounts.div(1)) {
        _claimAmounts[attenders[i.div(1)]] = address(this).balance - airdropAmount.mul(attenderCounts.div(1));
      }
    }
  }

  function claimBNBs() public payable claimActive {
    address attender = _msgSender();
    if (_attenders.length > 0) {
      require(_claimAmounts[attender] != 0, "AIRDROP: Current user is not a member of contest anymore!");

      _withdraw(attender, _claimAmounts[attender]);
    } else {
      require(address(this).balance > 0, "AIRDROP: The contract has no money!");

      _withdraw(_rewardWallet, address(this).balance);
    }
  }

  function _withdraw(address _address, uint256 _amount) private {
    (bool success, ) = _address.call{value: _amount}("");

    require(success, "WITHDRAW: Transfer failed.");
    _claimAmounts[_address] = 0;
  }
}