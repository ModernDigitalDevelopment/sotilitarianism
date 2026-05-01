// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SotilityVeToken
 * @dev Vote-escrowed token model for longer-term governance commitment
 */
contract SotilityVeToken is AccessControl {
    bytes32 public constant TOKEN_MANAGER_ROLE = keccak256("TOKEN_MANAGER_ROLE");
    
    struct LockPosition {
        uint256 amount;
        uint256 lockEnd;
        uint256 veAmount;
    }
    
    // Token being locked
    address public immutable baseToken;
    
    // Maximum lock time (4 years)
    uint256 public constant MAX_LOCK_TIME = 4 * 365 days;
    
    // User balances
    mapping(address => LockPosition) public lockPositions;
    
    // Total veToken supply
    uint256 public totalVeSupply;
    
    event TokensLocked(address indexed user, uint256 amount, uint256 lockEnd, uint256 veAmount);
    event LockIncreased(address indexed user, uint256 newAmount, uint256 newLockEnd, uint256 newVeAmount);
    event TokensUnlocked(address indexed user, uint256 amount);
    
    constructor(address _baseToken) {
        baseToken = _baseToken;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(TOKEN_MANAGER_ROLE, msg.sender);
    }
    
    /**
     * @dev Lock tokens for a period of time to receive veTokens
     * @param amount Amount of base tokens to lock
     * @param lockDuration Duration to lock tokens in seconds (up to MAX_LOCK_TIME)
     */
    function lockTokens(uint256 amount, uint256 lockDuration) external {
        require(amount > 0, "Amount must be greater than 0");
        require(lockDuration > 0 && lockDuration <= MAX_LOCK_TIME, "Invalid lock duration");
        
        IERC20(baseToken).transferFrom(msg.sender, address(this), amount);
        
        uint256 lockEnd = block.timestamp + lockDuration;
        uint256 veAmount = calculateVeAmount(amount, lockDuration);
        
        LockPosition storage position = lockPositions[msg.sender];
        
        if (position.amount > 0) {
            // User already has a lock position, merge them
            position.amount += amount;
            position.lockEnd = lockEnd > position.lockEnd ? lockEnd : position.lockEnd;
            
            // Recalculate veAmount based on new values
            uint256 remainingDuration = position.lockEnd - block.timestamp;
            position.veAmount = calculateVeAmount(position.amount, remainingDuration);
        } else {
            // New lock position
            position.amount = amount;
            position.lockEnd = lockEnd;
            position.veAmount = veAmount;
        }
        
        totalVeSupply += veAmount;
        
        emit TokensLocked(msg.sender, amount, lockEnd, veAmount);
    }
    
    /**
     * @dev Extend lock duration to get more veTokens
     * @param newDuration New lock duration in seconds from now
     */
    function extendLock(uint256 newDuration) external {
        LockPosition storage position = lockPositions[msg.sender];
        require(position.amount > 0, "No existing lock");
        require(position.lockEnd > block.timestamp, "Lock expired");
        require(newDuration > 0, "Duration must be greater than 0");
        
        uint256 newLockEnd = block.timestamp + newDuration;
        require(newLockEnd > position.lockEnd, "New lock end must be later than current");
        require(newLockEnd <= block.timestamp + MAX_LOCK_TIME, "Lock too long");
        
        // Remove old veTokens from total supply
        totalVeSupply -= position.veAmount;
        
        // Update lock position
        position.lockEnd = newLockEnd;
        position.veAmount = calculateVeAmount(position.amount, newDuration);
        
        // Add new veTokens to total supply
        totalVeSupply += position.veAmount;
        
        emit LockIncreased(msg.sender, position.amount, newLockEnd, position.veAmount);
    }
    
    /**
     * @dev Unlock tokens after lock period ends
     */
    function unlock() external {
        LockPosition storage position = lockPositions[msg.sender];
        require(position.amount > 0, "No existing lock");
        require(block.timestamp >= position.lockEnd, "Lock not expired yet");
        
        uint256 amount = position.amount;
        
        // Remove veTokens from total supply
        totalVeSupply -= position.veAmount;
        
        // Clear lock position
        position.amount = 0;
        position.lockEnd = 0;
        position.veAmount = 0;
        
        // Return tokens to user
        IERC20(baseToken).transfer(msg.sender, amount);
        
        emit TokensUnlocked(msg.sender, amount);
    }
    
    /**
     * @dev Calculate veToken amount based on lock duration
     * @param amount Base token amount
     * @param duration Lock duration in seconds
     */
    function calculateVeAmount(uint256 amount, uint256 duration) public pure returns (uint256) {
        // Linear scaling: 1 year = 0.25x, 2 years = 0.5x, 3 years = 0.75x, 4 years = 1x
        return (amount * duration) / MAX_LOCK_TIME;
    }
    
    /**
     * @dev Get current veToken balance for an account
     * @param account Address to check
     */
    function balanceOf(address account) external view returns (uint256) {
        LockPosition storage position = lockPositions[account];
        
        if (position.lockEnd <= block.timestamp) {
            return 0; // Lock expired, no voting power
        }
        
        return position.veAmount;
    }
    
    /**
     * @dev Get detailed lock position info
     */
    function getLockPosition(address account) external view returns (
        uint256 amount,
        uint256 lockEnd,
        uint256 veAmount,
        uint256 remainingTime
    ) {
        LockPosition storage position = lockPositions[account];
        uint256 remaining = position.lockEnd > block.timestamp ? position.lockEnd - block.timestamp : 0;
        
        return (
            position.amount,
            position.lockEnd,
            position.veAmount,
            remaining
        );
    }
}
