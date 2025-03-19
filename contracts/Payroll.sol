// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Payroll {
    error InvalidAddress();
    error InvalidAmount();
    error InvalidDuration();
    error InsufficientBalance();
    error JobNotFound();
    error JobDone();
    error Unauthorized();

    struct Job {
        address from;
        address to;
        address token;
        uint256 depositAmount;
        uint256 amountPerMileStone;
        uint256 numOfMileStone;
        // case should we do it by mile stone or by timeframe
        uint256 remainingBalance;
        uint256 lastUpdate;
    }
    mapping(uint256 => Job) public jobs;
    uint256 public jobId;
    // tracks num of jobs and provides unique ids for each

    // events here ...

     modifier onlyValidAddress(address _address) {
        if (_address == address(0) || _address == address(this)) {
            revert InvalidAddress();
        }
        _;
    }

    
}