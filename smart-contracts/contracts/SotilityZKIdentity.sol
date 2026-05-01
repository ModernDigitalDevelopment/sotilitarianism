// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SotilityZKIdentity
 * @dev Enables zero-knowledge proofs of reputation without revealing specific data
 */
contract SotilityZKIdentity is AccessControl {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");
    
    struct ZKProof {
        bytes32 proofHash;
        uint256 timestamp;
        bool verified;
    }
    
    // Mapping of unique identifiers to their ZK proofs
    mapping(bytes32 => ZKProof) public proofs;
    
    // Mapping of user addresses to their proof identifiers
    mapping(address => bytes32[]) public userProofs;
    
    event ProofIssued(address indexed user, bytes32 indexed proofId);
    event ProofVerified(bytes32 indexed proofId, bool success);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /**
     * @dev Issue a new ZK proof for a user
     * @param user Address of the user
     * @param proofId Unique identifier for the proof
     * @param proofHash Hash of the ZK proof data
     */
    function issueProof(address user, bytes32 proofId, bytes32 proofHash) external onlyRole(ISSUER_ROLE) {
        require(proofs[proofId].timestamp == 0, "Proof ID already exists");
        
        proofs[proofId] = ZKProof({
            proofHash: proofHash,
            timestamp: block.timestamp,
            verified: false
        });
        
        userProofs[user].push(proofId);
        
        emit ProofIssued(user, proofId);
    }
    
    /**
     * @dev Verify a ZK proof
     * @param proofId Identifier of the proof to verify
     * @param proof ZK proof data to validate
     */
    function verifyProof(bytes32 proofId, bytes calldata proof) external onlyRole(VERIFIER_ROLE) returns (bool) {
        require(proofs[proofId].timestamp > 0, "Proof does not exist");
        
        // In a real implementation, this would involve complex ZK proof verification
        // For this example, we're using a simplified placeholder
        bool success = keccak256(proof) == proofs[proofId].proofHash;
        
        if (success) {
            proofs[proofId].verified = true;
        }
        
        emit ProofVerified(proofId, success);
        return success;
    }
    
    /**
     * @dev Check if a user has a verified proof without revealing the proof data
     * @param user Address of the user
     * @param proofCategory Category of proof to check (e.g., "AGE_OVER_18", "CREDIT_SCORE_ABOVE_700")
     */
    function hasVerifiedProof(address user, string calldata proofCategory) external view returns (bool) {
        bytes32 categoryHash = keccak256(abi.encodePacked(proofCategory));
        
        bytes32[] memory userProofIds = userProofs[user];
        for (uint i = 0; i < userProofIds.length; i++) {
            bytes32 proofId = userProofIds[i];
            
            // Check if this proof is of the requested category and is verified
            if (proofId & categoryHash == categoryHash && proofs[proofId].verified) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * @dev Get all proof IDs for a user
     * @param user Address of the user
     */
    function getUserProofIds(address user) external view returns (bytes32[] memory) {
        return userProofs[user];
    }
}
