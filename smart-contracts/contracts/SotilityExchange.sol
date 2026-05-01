// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SotilityExchange
 * @dev Tokenized listing and SST issuance for revenue-verified businesses.
 */

/// @dev Minimal interface for tokens that support minting (e.g. SotilityStableToken)
interface IMintable {
    function mint(address to, uint256 amount) external;
}

contract SotilityExchange is AccessControl {
    bytes32 public constant BUSINESS_ROLE = keccak256("BUSINESS_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    struct Business {
        string name;
        string description;
        string ipfsMetadata;
        address wallet;
        bool active;
    }

    struct RevenueProof {
        string ipfsHash;
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Business) public businesses;
    mapping(address => RevenueProof[]) public revenueProofs;

    IERC20 public stableToken; // e.g. SST
    address public treasury;

    event BusinessRegistered(address indexed wallet, string name);
    event RevenueSubmitted(address indexed business, uint256 amount, string ipfsHash);
    event SSTIssued(address indexed to, uint256 amount);

    constructor(address _stableToken, address _treasury) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        stableToken = IERC20(_stableToken);
        treasury = _treasury;
    }

    function registerBusiness(
        address wallet,
        string calldata name,
        string calldata description,
        string calldata ipfsMetadata
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(!businesses[wallet].active, "Already registered");

        businesses[wallet] = Business({
            name: name,
            description: description,
            ipfsMetadata: ipfsMetadata,
            wallet: wallet,
            active: true
        });

        _grantRole(BUSINESS_ROLE, wallet);

        emit BusinessRegistered(wallet, name);
    }

    function submitRevenueProof(address business, uint256 amount, string calldata ipfsHash)
        external onlyRole(VERIFIER_ROLE)
    {
        require(businesses[business].active, "Business not registered");

        revenueProofs[business].push(RevenueProof({
            ipfsHash: ipfsHash,
            amount: amount,
            timestamp: block.timestamp
        }));

        // Mint SST to the business proportional to verified revenue
        IMintable(address(stableToken)).mint(business, amount);

        emit RevenueSubmitted(business, amount, ipfsHash);
        emit SSTIssued(business, amount);
    }

    function getRevenueHistory(address business) external view returns (RevenueProof[] memory) {
        return revenueProofs[business];
    }

    function deactivateBusiness(address business) external onlyRole(DEFAULT_ADMIN_ROLE) {
        businesses[business].active = false;
    }

    function updateTreasury(address newTreasury) external onlyRole(DEFAULT_ADMIN_ROLE) {
        treasury = newTreasury;
    }
}
