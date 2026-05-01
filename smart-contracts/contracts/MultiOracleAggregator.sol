// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title MultiOracleAggregator
 * @dev Aggregates data from multiple AI oracles to prevent oracle manipulation
 */
contract MultiOracleAggregator is AccessControl {
    bytes32 public constant ORACLE_ADMIN_ROLE = keccak256("ORACLE_ADMIN_ROLE");
    
    struct OracleData {
        uint256 score;
        uint256 timestamp;
        bool submitted;
    }
    
    struct ContentScore {
        mapping(address => OracleData) oracleScores;
        address[] oracles;
        uint256 finalScore;
        bool finalized;
    }
    
    mapping(uint256 => ContentScore) public contentScores;
    mapping(address => bool) public authorizedOracles;
    uint256 public minimumOracleResponses;
    uint256 public scoreDeviationThreshold; // in basis points (e.g., 1000 = 10%)
    
    event OracleAuthorized(address indexed oracle);
    event OracleDeauthorized(address indexed oracle);
    event ScoreSubmitted(uint256 indexed contentId, address indexed oracle, uint256 score);
    event ScoreFinalized(uint256 indexed contentId, uint256 finalScore);
    
    constructor(uint256 _minimumOracleResponses, uint256 _scoreDeviationThreshold) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ORACLE_ADMIN_ROLE, msg.sender);
        minimumOracleResponses = _minimumOracleResponses;
        scoreDeviationThreshold = _scoreDeviationThreshold;
    }
    
    function authorizeOracle(address oracle) external onlyRole(ORACLE_ADMIN_ROLE) {
        authorizedOracles[oracle] = true;
        emit OracleAuthorized(oracle);
    }
    
    function deauthorizeOracle(address oracle) external onlyRole(ORACLE_ADMIN_ROLE) {
        authorizedOracles[oracle] = false;
        emit OracleDeauthorized(oracle);
    }
    
    function submitScore(uint256 contentId, uint256 score) external {
        require(authorizedOracles[msg.sender], "Not an authorized oracle");
        require(score <= 100, "Score must be between 0-100");
        require(!contentScores[contentId].finalized, "Score already finalized");
        require(!contentScores[contentId].oracleScores[msg.sender].submitted, "Oracle already submitted");
        
        ContentScore storage content = contentScores[contentId];
        content.oracleScores[msg.sender] = OracleData({
            score: score,
            timestamp: block.timestamp,
            submitted: true
        });
        content.oracles.push(msg.sender);
        
        emit ScoreSubmitted(contentId, msg.sender, score);
        
        if (content.oracles.length >= minimumOracleResponses) {
            _attemptFinalization(contentId);
        }
    }
    
    function _attemptFinalization(uint256 contentId) internal {
        ContentScore storage content = contentScores[contentId];
        
        // Calculate average score
        uint256 totalScore;
        for (uint i = 0; i < content.oracles.length; i++) {
            totalScore += content.oracleScores[content.oracles[i]].score;
        }
        uint256 averageScore = totalScore / content.oracles.length;
        
        // Check for large deviations
        bool hasLargeDeviation = false;
        for (uint i = 0; i < content.oracles.length; i++) {
            uint256 oracleScore = content.oracleScores[content.oracles[i]].score;
            uint256 deviation;
            
            if (oracleScore > averageScore) {
                deviation = ((oracleScore - averageScore) * 10000) / averageScore;
            } else {
                deviation = ((averageScore - oracleScore) * 10000) / averageScore;
            }
            
            if (deviation > scoreDeviationThreshold) {
                hasLargeDeviation = true;
                break;
            }
        }
        
        if (!hasLargeDeviation) {
            content.finalScore = averageScore;
            content.finalized = true;
            emit ScoreFinalized(contentId, averageScore);
        }
    }
    
    function getScoreStatus(uint256 contentId) external view returns (
        uint256 oracleCount,
        bool isFinalized,
        uint256 finalScore
    ) {
        ContentScore storage content = contentScores[contentId];
        return (
            content.oracles.length,
            content.finalized,
            content.finalScore
        );
    }
    
    function forceFinalize(uint256 contentId) external onlyRole(ORACLE_ADMIN_ROLE) {
        ContentScore storage content = contentScores[contentId];
        require(!content.finalized, "Already finalized");
        require(content.oracles.length >= minimumOracleResponses, "Not enough oracles");
        
        uint256 totalScore;
        for (uint i = 0; i < content.oracles.length; i++) {
            totalScore += content.oracleScores[content.oracles[i]].score;
        }
        uint256 averageScore = totalScore / content.oracles.length;
        
        content.finalScore = averageScore;
        content.finalized = true;
        
        emit ScoreFinalized(contentId, averageScore);
    }
}
