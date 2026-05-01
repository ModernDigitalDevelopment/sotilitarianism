// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SotilityLiquidStaking
 * @dev Allows users to stake SOT while receiving liquid staked tokens (lstSOT)
 */
contract SotilityLiquidStaking is ERC20, AccessControl {
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant FEE_COLLECTOR_ROLE = keccak256("FEE_COLLECTOR_ROLE");
    
    address public immutable stakingToken; // SOT
    address public feeCollectorAddress;
    
    uint256 public protocolFee; // Basis points (100 = 1%)
    uint256 public totalStaked;
    uint256 public totalRewards;
    uint256 public constant FEE_DENOMINATOR = 10000;
    
    event Staked(address indexed user, uint256 amount, uint256 lstAmount);
    event Unstaked(address indexed user, uint256 lstAmount, uint256 sotAmount);
    event RewardsAdded(uint256 amount);
    event ProtocolFeeUpdated(uint256 newFee);
    
    constructor(address _stakingToken, uint256 _initialFee) ERC20("Liquid Staked SOT", "lstSOT") {
        stakingToken = _stakingToken;
        protocolFee = _initialFee;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VALIDATOR_ROLE, msg.sender);
        _grantRole(FEE_COLLECTOR_ROLE, msg.sender);
        feeCollectorAddress = msg.sender;
    }
    
    /**
     * @dev Stake SOT tokens and receive lstSOT in return
     * @param amount Amount of SOT to stake
     */
    function stake(uint256 amount) external {
        require(amount > 0, "Cannot stake 0");
        
        // Transfer SOT from user
        IERC20(stakingToken).transferFrom(msg.sender, address(this), amount);
        
        // Calculate lstSOT to mint based on current exchange rate
        uint256 lstAmount = (amount * 1e18) / exchangeRate();
        
        // Mint lstSOT to user
        _mint(msg.sender, lstAmount);
        
        // Update total staked
        totalStaked += amount;
        
        emit Staked(msg.sender, amount, lstAmount);
    }
    
    /**
     * @dev Unstake SOT by burning lstSOT
     * @param lstAmount Amount of lstSOT to burn
     */
    function unstake(uint256 lstAmount) external {
        require(lstAmount > 0, "Cannot unstake 0");
        require(balanceOf(msg.sender) >= lstAmount, "Insufficient lstSOT balance");
        
        // Calculate SOT amount based on current exchange rate
        uint256 sotAmount = (lstAmount * exchangeRate()) / 1e18;
        
        // Burn lstSOT
        _burn(msg.sender, lstAmount);
        
        // Calculate protocol fee
        uint256 feeAmount = (sotAmount * protocolFee) / FEE_DENOMINATOR;
        uint256 sotToReturn = sotAmount - feeAmount;
        
        // Transfer SOT back to user
        IERC20(stakingToken).transfer(msg.sender, sotToReturn);
        
        // Transfer fee to fee collector
        if (feeAmount > 0) {
            address feeCollector = feeCollectorAddress != address(0) ? feeCollectorAddress : msg.sender;
            IERC20(stakingToken).transfer(feeCollector, feeAmount);
        }
        
        // Update total staked
        totalStaked -= sotAmount;
        
        emit Unstaked(msg.sender, lstAmount, sotToReturn);
    }
    
    /**
     * @dev Add staking rewards
     * @param amount Amount of SOT to add as rewards
     */
    function addRewards(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        // Transfer SOT from sender
        IERC20(stakingToken).transferFrom(msg.sender, address(this), amount);
        
        // Update total rewards
        totalRewards += amount;
        
        emit RewardsAdded(amount);
    }
    
    /**
     * @dev Update protocol fee
     * @param newFee New fee in basis points
     */
    function updateProtocolFee(uint256 newFee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(newFee <= 1000, "Fee too high"); // Max 10%
        protocolFee = newFee;
        emit ProtocolFeeUpdated(newFee);
    }
    
    /**
     * @dev Calculate current exchange rate (SOT per lstSOT)
     * @return Exchange rate with 18 decimals
     */
    function exchangeRate() public view returns (uint256) {
        uint256 totalSupply = totalSupply();
        if (totalSupply == 0) {
            return 1e18; // Initial exchange rate: 1:1
        }
        
        // Exchange rate increases as rewards accumulate
        return ((totalStaked + totalRewards) * 1e18) / totalSupply;
    }
    
    /**
     * @dev Get SOT equivalent for a given lstSOT amount
     * @param lstAmount Amount of lstSOT
     * @return Equivalent SOT amount
     */
    function sotEquivalent(uint256 lstAmount) external view returns (uint256) {
        return (lstAmount * exchangeRate()) / 1e18;
    }
}
