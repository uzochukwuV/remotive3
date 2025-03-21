// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./libraries/PayrollLib.sol";
import "./libraries/Freelancer.sol";


contract Payroll is ReentrancyGuard {
    mapping(uint256 => PayrollLibrary.Job) public jobs;
    mapping(uint256 => FreelancerLibrary.Freelancer) public freelancers;
    mapping(address => bool) public isFreeLancerValid;
    uint256 public jobCounter;
    uint256 public freelancerCounter;


    error InvalidAddress();
    error InvalidAmount();
    error InvalidDuration();
    error InsufficientBalance();
    error JobNotFound();
    error JobDone();
    error Unauthorized();

    struct Bidder {
        address freelancer;
        uint256 amount;
    }

    struct Bid {
        address[] freelancers;
        mapping(address => uint256) freelancerBids;
    }
    mapping(uint256 => Bid) bids;

    // events here ...
    event FreelancerCreated(uint256,  string);
    event JobPosted(uint256, address, uint256, address);
    event JobBid(uint256, address, uint256);
    event JobAssigned(uint256, address);
    event MileStoneCompleted(uint256, bool, uint256);
    event PaymentRecieved(uint256, address, uint256);

    modifier onlyValidAddress(address _address) {
        if (_address == address(0) || _address == address(this)) {
            revert InvalidAddress();
        }
        _;
    }

    modifier onlyValidFreelancer(address _address) {
        if(!isFreeLancerValid[_address]){
            revert Unauthorized();
        }
        _;
    }

    modifier onlyValidJob(uint256 _jobId) {
        if (_jobId > jobCounter) {
            revert JobNotFound();
        }
        _;
    }

    modifier onlyValidAmount(uint256 amount) {
        if (amount <= 0) {
            revert InvalidAmount();
        }
        _;
    }

    function registerFreelancer(address _freelancer, string memory _name, bytes memory _description, uint256[] memory achieve, bytes calldata _stacks) external onlyValidAddress(_freelancer)   {
        require(msg.sender == _freelancer, "cant register another");
        
        freelancerCounter++;
        freelancers[freelancerCounter] = FreelancerLibrary.Freelancer(freelancerCounter, _freelancer,  _name, _description, 0, 0,_stacks, achieve);
        isFreeLancerValid[_freelancer] = true;
        emit FreelancerCreated(freelancerCounter, _name);

    }

    function postJob(uint256 _amount, address _preferredToken, uint256 _milestoneCount, bytes calldata _jobDescription) external {
        require(_amount > 0, "Salary must be greater than zero");
        require(_milestoneCount > 0, "Must have at least one milestone");
        
        jobCounter++;
        jobs[jobCounter] = PayrollLibrary.Job(jobCounter, msg.sender, _jobDescription, address(0),_preferredToken,  _amount, _amount/_milestoneCount, _milestoneCount, 1 , 0 ,_amount,  block.timestamp);
        emit JobPosted(jobCounter, msg.sender, _amount, _preferredToken);
    }

    function bidJob(uint256 _jobId, uint256 _bidAmount) 
        external 
        onlyValidJob(_jobId)
        onlyValidAmount(_bidAmount)
        onlyValidFreelancer(msg.sender)
            {
         Bid storage jobBid = bids[_jobId];
        uint256 nextBidID = jobBid.freelancers.length;
        jobBid.freelancers[nextBidID] = msg.sender;
        jobBid.freelancerBids[msg.sender] = _bidAmount;
        emit JobBid(_jobId, msg.sender, _bidAmount);
    }

    function assignJob(uint256 _jobId,address _freelancer)
        onlyValidJob(_jobId)
        onlyValidFreelancer(_freelancer)
        external 
        {
             PayrollLibrary.Job storage job = jobs[_jobId];
            require(job.freelancer != address(0), "Job Already assigned");
            job.freelancer = _freelancer;
            job.lastUpdate = block.timestamp;
            emit JobAssigned(_jobId, _freelancer);
        }

    function tickMileStoneAsCompleted(uint256 _jobId, bool isEmployer, uint256 milestone) 
        external 
        onlyValidJob(_jobId)
        {
            PayrollLibrary.Job storage job = jobs[_jobId];
            require(job.freelancer == address(0), "Job is not assigned");
            require(job.currentMileStone == milestone, "Last milestone not completed");
            require(job.numOfMileStone <= milestone, "Invalid MileStone");
            job.currentMileStone ++;
            job.amountReleased += job.amountPerMileStone;
            job.lastUpdate = block.timestamp;
            emit MileStoneCompleted(_jobId, isEmployer, milestone);
            
        }

    function receivePayment(uint256 _jobId) 
        external
        onlyValidFreelancer(msg.sender)
        {
             PayrollLibrary.Job storage job = jobs[_jobId];
            uint256 amount = job.amountReleased; 
            job.remainingBalance -= amount;
            job.lastUpdate = block.timestamp;
            IERC20(job.token).transfer(msg.sender, amount);
            emit PaymentRecieved(_jobId, msg.sender, amount);
        }

    // function terminateJob();
    // function chooseRandomFreelancer();

    //views

    function getBidders(uint256 _jobId) external view returns (Bidder[] memory bidders){
         Bid storage jobBid = bids[_jobId];

        for (uint256 i = 0; i < jobBid.freelancers.length; i++){
            bidders[i] = Bidder(jobBid.freelancers[i], jobBid.freelancerBids[jobBid.freelancers[i]]);
        }

    }

    // function getJobs(uint256 limit)
    // function getFreelancers(uint256 limit)
    // function getJobData()
    // function getFreelancerDetail()

}