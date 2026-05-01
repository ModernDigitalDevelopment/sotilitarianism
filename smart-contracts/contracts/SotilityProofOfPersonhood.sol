// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SotilityProofOfPersonhood
 * @dev Sybil-resistant identity verification without revealing personal data
 */
contract SotilityProofOfPersonhood is AccessControl {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant REVOKER_ROLE = keccak256("REVOKER_ROLE");
    
    enum VerificationStatus { None, Pending, Verified, Revoked }
    
    struct PersonhoodCredential {
        VerificationStatus status;
        uint256 verifiedAt;
        uint256 expiresAt;
        bytes32 credentialHash;
    }
    
    // Mapping of addresses to their personhood status
    mapping(address => PersonhoodCredential) public credentials;
    
    // Total verified accounts
    uint256 public totalVerified;
    
    // Events
    event VerificationRequested(address indexed user, bytes32 requestId);
    event VerificationCompleted(address indexed user);
    event VerificationRevoked(address indexed user, string reason);
    event CredentialRenewed(address indexed user, uint256 newExpiry);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VERIFIER_ROLE, msg.sender);
        _grantRole(REVOKER_ROLE, msg.sender);
    }
    
    /**
     * @dev Request verification of personhood
     * @param credentialHash Hash of the verification credential (implementation-specific)
     */
    function requestVerification(bytes32 credentialHash) external {
        require(credentials[msg.sender].status == VerificationStatus.None, "Verification already exists");
        
        credentials[msg.sender] = PersonhoodCredential({
            status: VerificationStatus.Pending,
            verifiedAt: 0,
            expiresAt: 0,
            credentialHash: credentialHash
        });
        
        emit VerificationRequested(msg.sender, credentialHash);
    }
    
    /**
     * @dev Complete verification process (by authorized verifier)
     * @param user Address of the user to verify
     * @param expiryDuration How long the verification remains valid (in seconds)
     */
    function completeVerification(address user, uint256 expiryDuration) external onlyRole(VERIFIER_ROLE) {
        require(credentials[user].status == VerificationStatus.Pending, "Invalid verification status");
        
        uint256 expiryTime = block.timestamp + expiryDuration;
        
        credentials[user].status = VerificationStatus.Verified;
        credentials[user].verifiedAt = block.timestamp;
        credentials[user].expiresAt = expiryTime;
        
        totalVerified++;
        
        emit VerificationCompleted(user);
    }
    
    /**
     * @dev Revoke verification (by authorized revoker)
     * @param user Address of the user to revoke
     * @param reason Reason for revocation
     */
    function revokeVerification(address user, string calldata reason) external onlyRole(REVOKER_ROLE) {
        require(credentials[user].status == VerificationStatus.Verified, "Not verified");
        
        credentials[user].status = VerificationStatus.Revoked;
        
        if (totalVerified > 0) {
            totalVerified--;
        }
        
        emit VerificationRevoked(user, reason);
    }
    
    /**
     * @dev Renew verification before expiry
     * @param expiryDuration New duration to add to current timestamp
     */
    function renewVerification(uint256 expiryDuration) external {
        require(credentials[msg.sender].status == VerificationStatus.Verified, "Not verified");
        require(block.timestamp <= credentials[msg.sender].expiresAt, "Verification expired");
        
        uint256 newExpiry = block.timestamp + expiryDuration;
        credentials[msg.sender].expiresAt = newExpiry;
        
        emit CredentialRenewed(msg.sender, newExpiry);
    }
    
    /**
     * @dev Check if an address is a verified person
     * @param user Address to check
     */
    function isVerifiedPerson(address user) external view returns (bool) {
        return (
            credentials[user].status == VerificationStatus.Verified &&
            block.timestamp <= credentials[user].expiresAt
        );
    }
    
    /**
     * @dev Get verification details
     * @param user Address to check
     */
    function getVerificationDetails(address user) external view returns (
        VerificationStatus status,
        uint256 verifiedAt,
        uint256 expiresAt,
        bool isValid
    ) {
        PersonhoodCredential memory cred = credentials[user];
        
        bool valid = (
            cred.status == VerificationStatus.Verified &&
            block.timestamp <= cred.expiresAt
        );
        
        return (
            cred.status,
            cred.verifiedAt,
            cred.expiresAt,
            valid
        );
    }
}
