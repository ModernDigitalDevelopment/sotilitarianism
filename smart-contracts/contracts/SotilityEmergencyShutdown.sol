// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SotilityEmergencyShutdown
 * @dev Circuit breaker pattern for Sotility ecosystem in case of attacks
 */
contract SotilityEmergencyShutdown is AccessControl {
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");
    bytes32 public constant RECOVERY_ROLE = keccak256("RECOVERY_ROLE");
    
    mapping(address => bool) public pausedContracts;
    bool public systemWideEmergency;
    uint256 public emergencyTimelock;
    uint256 public constant EMERGENCY_DELAY = 24 hours;
    
    event ContractPaused(address indexed contractAddress);
    event ContractUnpaused(address indexed contractAddress);
    event SystemWideEmergencyActivated();
    event SystemWideEmergencyDeactivated();
    event EmergencyTimelockInitiated(uint256 activationTime);
    
    constructor(address[] memory guardians, address[] memory recoveryTeam) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        
        for (uint i = 0; i < guardians.length; i++) {
            _grantRole(GUARDIAN_ROLE, guardians[i]);
        }
        
        for (uint i = 0; i < recoveryTeam.length; i++) {
            _grantRole(RECOVERY_ROLE, recoveryTeam[i]);
        }
    }
    
    function initiateEmergencyTimelock() external onlyRole(GUARDIAN_ROLE) {
        require(emergencyTimelock == 0, "Timelock already initiated");
        emergencyTimelock = block.timestamp + EMERGENCY_DELAY;
        emit EmergencyTimelockInitiated(emergencyTimelock);
    }
    
    function activateSystemWideEmergency() external onlyRole(GUARDIAN_ROLE) {
        require(block.timestamp >= emergencyTimelock, "Emergency timelock not expired");
        systemWideEmergency = true;
        emit SystemWideEmergencyActivated();
    }
    
    function deactivateSystemWideEmergency() external onlyRole(RECOVERY_ROLE) {
        systemWideEmergency = false;
        emergencyTimelock = 0;
        emit SystemWideEmergencyDeactivated();
    }
    
    function pauseContract(address contractAddress) external onlyRole(GUARDIAN_ROLE) {
        pausedContracts[contractAddress] = true;
        emit ContractPaused(contractAddress);
    }
    
    function unpauseContract(address contractAddress) external onlyRole(RECOVERY_ROLE) {
        pausedContracts[contractAddress] = false;
        emit ContractUnpaused(contractAddress);
    }
    
    function isContractPaused(address contractAddress) external view returns (bool) {
        return pausedContracts[contractAddress] || systemWideEmergency;
    }
}
