// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import "./libraries/PayrollLib.sol";


contract Payroll {
    mapping(uint256 => PayrollLibrary.Job) public jobs;
    uint256 public jobCounter;


    error InvalidAddress();
    error InvalidAmount();
    error InvalidDuration();
    error InsufficientBalance();
    error JobNotFound();
    error JobDone();
    error Unauthorized();

    
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
    
    function postJob(uint256 _salary, address _preferredToken, uint256 _milestoneCount) external {
        require(_salary > 0, "Salary must be greater than zero");
        require(_milestoneCount > 0, "Must have at least one milestone");
        
        jobCounter++;
        jobs[jobCounter] = PayrollLibrary.Job(msg.sender, address(0),_preferredToken,  _salary, _salary/_milestoneCount, _milestoneCount, _salary,  block.timestamp);
        emit JobPosted(jobCounter, msg.sender, _salary, _preferredToken);
    }

    
}