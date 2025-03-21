// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";


// will contain all functions in payroll contract
interface IPayroll {
    function registerFreelancer(address _freelancer, string memory _name, bytes memory _description, bytes calldata _stacks) external ;
    function postJob(uint256 _amount, address _preferredToken, uint256 _milestoneCount, bytes memory _jobDescription) external;
    function bidJob(uint256 _jobId, uint256 _bidAmount) external;
    function assignJob(uint256 _jobId,address _freelancer) external;
    function tickMileStoneAsCompleted(uint256 _jobId, bool isEmployer, uint256 milestone) external;
    function receivePayment(uint256 _jobId) external;
}