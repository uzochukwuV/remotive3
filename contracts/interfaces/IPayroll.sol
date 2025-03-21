
// will contain all functions in payroll contract
interface IPayroll {
    function registerFreelancer(address _freelancer, string memory _name, bytes memory _description, bytes calldata _stacks) onlyValidAddress(_freelancer);
    function postJob(uint256 _amount, address _preferredToken, uint256 _milestoneCount, bytes _jobDescription);
    function bidJob(uint256 _jobId, uint256 _bidAmount);
    function assignJob(uint256 _jobId,address _freelancer);
    function tickMileStoneAsCompleted(uint256 _jobId, bool isEmployer, uint256 milestone);
    function receivePayment(uint256 _jobId);
}