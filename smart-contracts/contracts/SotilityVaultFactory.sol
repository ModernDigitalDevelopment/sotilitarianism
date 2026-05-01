// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./SotilityYieldEngine.sol";

/**
 * @title SotilityVaultFactory
 * @dev Deploys isolated yield engines for each verified project or business.
 */
contract SotilityVaultFactory is AccessControl {
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    
    struct VaultRecord {
        address creator;
        address vaultAddress;
        address token;
        address rewardDistributor;
        string ipfsMetadata;
        uint256 timestamp;
    }
    
    VaultRecord[] public deployedVaults;
    
    event VaultDeployed(address indexed vault, address token, address distributor, string ipfsMetadata);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEPLOYER_ROLE, msg.sender);
    }
    
    function deployVault(
        address stableToken,
        address rewardDistributor,
        string calldata ipfsMetadata
    ) external onlyRole(DEPLOYER_ROLE) returns (address) {
        SotilityYieldEngine vault = new SotilityYieldEngine(stableToken, rewardDistributor);
        
        deployedVaults.push(VaultRecord({
            creator: msg.sender,
            vaultAddress: address(vault),
            token: stableToken,
            rewardDistributor: rewardDistributor,
            ipfsMetadata: ipfsMetadata,
            timestamp: block.timestamp
        }));
        
        emit VaultDeployed(address(vault), stableToken, rewardDistributor, ipfsMetadata);
        return address(vault);
    }
    
    function getAllVaults() external view returns (VaultRecord[] memory) {
        return deployedVaults;
    }
}
