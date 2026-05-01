// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title SotilityInsurance
 * @dev Decentralized insurance protocol for the Sotility ecosystem.
 */
contract SotilityInsurance is AccessControl, ReentrancyGuard {
    bytes32 public constant CLAIM_APPROVER_ROLE = keccak256("CLAIM_APPROVER_ROLE");
    bytes32 public constant PREMIUM_ADJUSTER_ROLE = keccak256("PREMIUM_ADJUSTER_ROLE");

    enum PolicyStatus { Active, Expired, Claimed, Cancelled }
    enum ClaimStatus { Pending, Approved, Rejected }

    struct Policy {
        address holder;
        uint256 coverageAmount;
        uint256 premium;
        uint256 startTime;
        uint256 endTime;
        PolicyStatus status;
    }
    
    struct Claim {
        uint256 policyId;
        string reason;
        uint256 requestedAmount;
        uint256 approvedAmount;
        uint256 submissionTime;
        ClaimStatus status;
    }
    
    // Insurance token (could be a stablecoin)
    IERC20 public insuranceToken;
    
    // Governance token for possible premium discounts
    IERC20 public governanceToken;
    
    // Policy and claims data
    mapping(uint256 => Policy) public policies;
    mapping(uint256 => Claim) public claims;
    uint256 public policyCount;
    uint256 public claimCount;
    
    // Insurance fund balance
    uint256 public totalCoverageProvided;
    uint256 public totalPremiumsCollected;
    uint256 public totalClaimsPaid;
    
    // Premium rates (basis points, 100 = 1%)
    uint256 public basePremiumRate = 500; // 5% default
    
    event PolicyCreated(uint256 indexed policyId, address indexed holder, uint256 coverageAmount);
    event PolicyCancelled(uint256 indexed policyId);
    event ClaimSubmitted(uint256 indexed claimId, uint256 indexed policyId, uint256 requestedAmount);
    event ClaimProcessed(uint256 indexed claimId, ClaimStatus status, uint256 approvedAmount);
    event PremiumRateUpdated(uint256 newRate);
    
    constructor(address _insuranceToken, address _governanceToken) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CLAIM_APPROVER_ROLE, msg.sender);
        _grantRole(PREMIUM_ADJUSTER_ROLE, msg.sender);
        
        insuranceToken = IERC20(_insuranceToken);
        governanceToken = IERC20(_governanceToken);
    }
    
    /**
     * @dev Get a quote for insurance coverage
     * @param coverageAmount Amount of coverage desired
     * @param durationDays Duration of coverage in days
     */
    function getQuote(uint256 coverageAmount, uint256 durationDays) public view returns (uint256) {
        uint256 annualPremium = (coverageAmount * basePremiumRate) / 10000;
        uint256 dailyPremium = annualPremium / 365;
        
        // Apply governance token discount if applicable
        uint256 governanceBalance = governanceToken.balanceOf(msg.sender);
        uint256 discountRate = _calculateDiscountRate(governanceBalance);
        
        uint256 totalPremium = (dailyPremium * durationDays);
        if (discountRate > 0) {
            totalPremium = totalPremium * (10000 - discountRate) / 10000;
        }
        
        return totalPremium;
    }
    
    /**
     * @dev Purchase an insurance policy
     * @param coverageAmount Amount of coverage desired
     * @param durationDays Duration of coverage in days
     */
    function purchasePolicy(uint256 coverageAmount, uint256 durationDays) external nonReentrant returns (uint256) {
        require(coverageAmount > 0, "Coverage must be greater than 0");
        require(durationDays > 0 && durationDays <= 365, "Invalid duration");
        
        uint256 premium = getQuote(coverageAmount, durationDays);
        require(insuranceToken.transferFrom(msg.sender, address(this), premium), "Premium payment failed");
        
        policyCount++;
        uint256 endTime = block.timestamp + (durationDays * 1 days);
        
        policies[policyCount] = Policy({
            holder: msg.sender,
            coverageAmount: coverageAmount,
            premium: premium,
            startTime: block.timestamp,
            endTime: endTime,
            status: PolicyStatus.Active
        });
        
        totalCoverageProvided += coverageAmount;
        totalPremiumsCollected += premium;
        
        emit PolicyCreated(policyCount, msg.sender, coverageAmount);
        
        return policyCount;
    }
    
    /**
     * @dev Submit a claim on an active policy
     * @param policyId ID of the policy
     * @param amount Amount requested (must be <= coverage amount)
     * @param reason Reason for the claim
     */
    function submitClaim(uint256 policyId, uint256 amount, string calldata reason) external nonReentrant returns (uint256) {
        require(policyId <= policyCount, "Policy does not exist");
        Policy storage policy = policies[policyId];
        
        require(policy.holder == msg.sender, "Not the policy holder");
        require(policy.status == PolicyStatus.Active, "Policy not active");
        require(block.timestamp < policy.endTime, "Policy expired");
        require(amount <= policy.coverageAmount, "Amount exceeds coverage");
        
        claimCount++;
        
        claims[claimCount] = Claim({
            policyId: policyId,
            reason: reason,
            requestedAmount: amount,
            approvedAmount: 0,
            submissionTime: block.timestamp,
            status: ClaimStatus.Pending
        });
        
        emit ClaimSubmitted(claimCount, policyId, amount);
        
        return claimCount;
    }
    
    /**
     * @dev Process a pending claim (approve or reject)
     * @param claimId ID of the claim
     * @param approved Whether the claim is approved
     * @param approvedAmount Amount approved (if approved)
     */
    function processClaim(uint256 claimId, bool approved, uint256 approvedAmount) external onlyRole(CLAIM_APPROVER_ROLE) nonReentrant {
        require(claimId <= claimCount, "Claim does not exist");
        
        Claim storage claim = claims[claimId];
        Policy storage policy = policies[claim.policyId];
        
        require(claim.status == ClaimStatus.Pending, "Claim not pending");
        require(policy.status == PolicyStatus.Active, "Policy not active");
        
        if (approved) {
            require(approvedAmount <= claim.requestedAmount, "Approved amount too high");
            require(approvedAmount <= policy.coverageAmount, "Approved amount exceeds coverage");
            
            claim.status = ClaimStatus.Approved;
            claim.approvedAmount = approvedAmount;
            policy.status = PolicyStatus.Claimed;
            
            // Transfer approved amount to claimant
            require(insuranceToken.transfer(policy.holder, approvedAmount), "Claim payment failed");
            
            totalClaimsPaid += approvedAmount;
            totalCoverageProvided -= policy.coverageAmount;
        } else {
            claim.status = ClaimStatus.Rejected;
        }
        
        emit ClaimProcessed(claimId, claim.status, claim.approvedAmount);
    }
    
    /**
     * @dev Update the base premium rate
     * @param newRate New premium rate in basis points
     */
    function updatePremiumRate(uint256 newRate) external onlyRole(PREMIUM_ADJUSTER_ROLE) {
        require(newRate <= 2000, "Rate too high"); // Max 20%
        basePremiumRate = newRate;
        emit PremiumRateUpdated(newRate);
    }
    
    /**
     * @dev Calculate discount rate based on governance token holdings
     * @param governanceBalance Balance of governance tokens
     */
    function _calculateDiscountRate(uint256 governanceBalance) internal pure returns (uint256) {
        // Example tiered discount:
        // 0-999 tokens: 0% discount
        // 1000-9999 tokens: 5% discount
        // 10000+ tokens: 10% discount
        
        if (governanceBalance >= 10000 * 1e18) {
            return 1000; // 10% discount
        } else if (governanceBalance >= 1000 * 1e18) {
            return 500; // 5% discount
        } else {
            return 0; // No discount
        }
    }
    
    /**
     * @dev Get policy details
     * @param policyId ID of the policy
     */
    function getPolicyDetails(uint256 policyId) external view returns (
        address holder,
        uint256 coverageAmount,
        uint256 premium,
        uint256 startTime,
        uint256 endTime,
        PolicyStatus status
    ) {
        require(policyId <= policyCount, "Policy does not exist");
        Policy storage policy = policies[policyId];
        
        return (
            policy.holder,
            policy.coverageAmount,
            policy.premium,
            policy.startTime,
            policy.endTime,
            policy.status
        );
    }
    
    /**
     * @dev Get claim details
     * @param claimId ID of the claim
     */
    function getClaimDetails(uint256 claimId) external view returns (
        uint256 policyId,
        string memory reason,
        uint256 requestedAmount,
        uint256 approvedAmount,
        uint256 submissionTime,
        ClaimStatus status
    ) {
        require(claimId <= claimCount, "Claim does not exist");
        Claim storage claim = claims[claimId];
        
        return (
            claim.policyId,
            claim.reason,
            claim.requestedAmount,
            claim.approvedAmount,
            claim.submissionTime,
            claim.status
        );
    }
    
    /**
     * @dev Get insurance fund statistics
     */
    function getFundStatistics() external view returns (
        uint256 activeCoverage,
        uint256 premiumsCollected,
        uint256 claimsPaid,
        uint256 availableFunds
    ) {
        return (
            totalCoverageProvided,
            totalPremiumsCollected,
            totalClaimsPaid,
            insuranceToken.balanceOf(address(this))
        );
    }
}
