// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SotilityCrossChainIdentity
 * @dev Aggregates reputation and identity information across multiple blockchains
 */
contract SotilityCrossChainIdentity is AccessControl {
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    
    struct ChainIdentity {
        uint256 chainId;
        address identityContract;
        bytes32 identityId;
        uint256 reputationScore;
        uint256 lastUpdated;
        bool verified;
    }
    
    // User's identity across multiple chains
    mapping(address => mapping(uint256 => ChainIdentity)) public chainIdentities;
    mapping(address => uint256[]) public userChains;
    
    // Aggregated reputation score across all chains
    mapping(address => uint256) public aggregatedReputation;
    
    event IdentityLinked(address indexed user, uint256 chainId, bytes32 identityId);
    event ReputationUpdated(address indexed user, uint256 chainId, uint256 newScore);
    event AggregatedScoreUpdated(address indexed user, uint256 newScore);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    /**
     * @dev Link an identity from another chain to this user
     * @param user Address of the user
     * @param chainId ID of the blockchain (e.g., Ethereum = 1, Polygon = 137)
     * @param identityContract Address of the identity contract on that chain
     * @param identityId Unique identifier of the user on that chain
     * @param initialScore Initial reputation score from that chain
     */
    function linkChainIdentity(
        address user,
        uint256 chainId,
        address identityContract,
        bytes32 identityId,
        uint256 initialScore
    ) external onlyRole(BRIDGE_ROLE) {
        require(chainIdentities[user][chainId].lastUpdated == 0, "Chain identity already linked");
        
        chainIdentities[user][chainId] = ChainIdentity({
            chainId: chainId,
            identityContract: identityContract,
            identityId: identityId,
            reputationScore: initialScore,
            lastUpdated: block.timestamp,
            verified: false
        });
        
        userChains[user].push(chainId);
        
        emit IdentityLinked(user, chainId, identityId);
        
        _updateAggregatedScore(user);
    }
    
    /**
     * @dev Update reputation score from another chain
     * @param user Address of the user
     * @param chainId ID of the blockchain
     * @param newScore Updated reputation score
     */
    function updateReputationScore(
        address user,
        uint256 chainId,
        uint256 newScore
    ) external onlyRole(BRIDGE_ROLE) {
        require(chainIdentities[user][chainId].lastUpdated > 0, "Chain identity not linked");
        
        chainIdentities[user][chainId].reputationScore = newScore;
        chainIdentities[user][chainId].lastUpdated = block.timestamp;
        
        emit ReputationUpdated(user, chainId, newScore);
        
        _updateAggregatedScore(user);
    }
    
    /**
     * @dev Verify an identity on another chain
     * @param user Address of the user
     * @param chainId ID of the blockchain
     */
    function verifyChainIdentity(address user, uint256 chainId) external onlyRole(VERIFIER_ROLE) {
        require(chainIdentities[user][chainId].lastUpdated > 0, "Chain identity not linked");
        
        chainIdentities[user][chainId].verified = true;
        
        _updateAggregatedScore(user);
    }
    
    /**
     * @dev Calculate and update the aggregated reputation score
     * @param user Address of the user
     */
    function _updateAggregatedScore(address user) internal {
        uint256[] memory chains = userChains[user];
        uint256 totalScore;
        uint256 verifiedChains;
        
        for (uint i = 0; i < chains.length; i++) {
            ChainIdentity storage identity = chainIdentities[user][chains[i]];
            
            if (identity.verified) {
                totalScore += identity.reputationScore;
                verifiedChains++;
            }
        }
        
        // Calculate weighted average of verified chain scores
        if (verifiedChains > 0) {
            aggregatedReputation[user] = totalScore / verifiedChains;
        } else {
            aggregatedReputation[user] = 0;
        }
        
        emit AggregatedScoreUpdated(user, aggregatedReputation[user]);
    }
    
    /**
     * @dev Get all chains a user has linked identities on
     * @param user Address of the user
     */
    function getUserChains(address user) external view returns (uint256[] memory) {
        return userChains[user];
    }
    
    /**
     * @dev Get a user's aggregated reputation score
     * @param user Address of the user
     */
    function getAggregatedReputation(address user) external view returns (uint256) {
        return aggregatedReputation[user];
    }
}
