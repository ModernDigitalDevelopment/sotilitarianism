## Social Layer Contracts (Continued)

### 1. SoGoodFeed.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title SoGoodFeed
 * @dev AI-verified social tipping feed for the SoGood Utility Governance (SUG) token.
 */
contract SoGoodFeed is AccessControl {
    using Counters for Counters.Counter;
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    Counters.Counter private _postIds;
    
    struct Post {
        uint256 id;
        address author;
        string contentHash;
        string metadata; // optional: type, category, or comment
        uint256 timestamp;
        uint256 totalTips;
    }
    
    mapping(uint256 => Post) public posts;
    mapping(uint256 => mapping(address => uint256)) public tipsByUser;
    
    event PostSubmitted(uint256 indexed id, address indexed author, string contentHash, string metadata);
    event Tipped(uint256 indexed postId, address indexed tipper, uint256 amount);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function submitPost(string calldata contentHash, string calldata metadata) external {
        _postIds.increment();
        uint256 postId = _postIds.current();
        
        posts[postId] = Post({
            id: postId,
            author: msg.sender,
            contentHash: contentHash,
            metadata: metadata,
            timestamp: block.timestamp,
            totalTips: 0
        });
        
        emit PostSubmitted(postId, msg.sender, contentHash, metadata);
    }
    
    function recordTip(uint256 postId, address tipper, uint256 amount) external onlyRole(VERIFIER_ROLE) {
        require(posts[postId].author != address(0), "Invalid post");
        
        tipsByUser[postId][tipper] += amount;
        posts[postId].totalTips += amount;
        
        emit Tipped(postId, tipper, amount);
    }
    
    function getPost(uint256 postId) external view returns (Post memory) {
        return posts[postId];
    }
    
    function totalPosts() external view returns (uint256) {
        return _postIds.current();
    }
}
```

### 2. SotilityProfileRegistry.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SotilityProfileRegistry
 * @dev Stores Sotilitarian Status and Utilitier Level ratings for SoGood ecosystem participants.
 */
contract SotilityProfileRegistry is AccessControl {
    bytes32 public constant EVALUATOR_ROLE = keccak256("EVALUATOR_ROLE");
    
    struct Profile {
        uint256 sotilitarianStatus; // long-term contribution score
        uint256 utilitierScore; // short-term activity score
        uint8 utilitierLevel; // 0 = Bronze, 1 = Silver, 2 = Gold, 3 = Platinum
        uint256 lastReset; // last Utilitier Level reset
    }
    
    mapping(address => Profile) public profiles;
    
    event SotilitarianProfileUpdated(address indexed user, uint256 statusScore, uint256 utilityScore, uint8 level);
    event UtilitierLevelReset(address indexed user, uint256 newScore, uint8 newLevel);
    
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function setProfile(address user, uint256 statusScore, uint256 utilityScore, uint8 level) external onlyRole(EVALUATOR_ROLE) {
        profiles[user].sotilitarianStatus = statusScore;
        profiles[user].utilitierScore = utilityScore;
        profiles[user].utilitierLevel = level;
        
        emit SotilitarianProfileUpdated(user, statusScore, utilityScore, level);
    }
    
    function resetUtilitierLevel(address user, uint256 newScore, uint8 newLevel) external onlyRole(EVALUATOR_ROLE) {
        profiles[user].utilitierScore = newScore;
        profiles[user].utilitierLevel = newLevel;
        profiles[user].lastReset = block.timestamp;
        
        emit UtilitierLevelReset(user, newScore, newLevel);
    }
    
    function getProfile(address user) external view returns (Profile memory) {
        return profiles[user];
    }
    
    function isEligibleForSotilitarianBoost(address user) external view returns (bool) {
        return block.timestamp >= profiles[user].lastReset + 365 days;
    }
}
```

### 3. SotilityBadgeNFT.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/**
 * @title SotilityBadgeNFT
 * @dev Soulbound NFT badges for status, impact, and tier recognition.
 */
contract SotilityBadgeNFT is ERC721URIStorage, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _tokenIds;
    mapping(uint256 => bool) public soulbound;
    
    event BadgeMinted(address indexed to, uint256 tokenId, string uri);
    event BadgeRevoked(uint256 tokenId);
    
    constructor() ERC721("Sotility Badge NFT", "SBNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    function mint(address to, string calldata uri, bool isSoulbound) external onlyRole(MINTER_ROLE) returns (uint256) {
        _tokenIds++;
        uint256 newId = _tokenIds;
        
        _mint(to, newId);
        _setTokenURI(newId, uri);
        soulbound[newId] = isSoulbound;
        
        emit BadgeMinted(to, newId, uri);
        return newId;
    }
    
    function revoke(uint256 tokenId) external onlyRole(MINTER_ROLE) {
        _burn(tokenId);
        emit BadgeRevoked(tokenId);
    }
    
    // Override to disable soulbound transfer
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
        require(from == address(0) || !soulbound[tokenId], "Soulbound: Non-transferable");
    }
    
    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
```

### 4. SotilityContentGovernance.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SotilityContentGovernance
 * @dev Implements decentralized content moderation with economic incentives
 */
contract SotilityContentGovernance is AccessControl {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    
    enum ContentStatus { Active, UnderReview, Removed, Restored }
    enum ModeratorAction { Flag, Approve, Remove, Restore }
    
    struct Content {
        uint256 id;
        address author;
        string contentHash;
        ContentStatus status;
        uint256 flagCount;
        uint256 approvalCount;
        uint256 lastDecisionTime;
        address[] moderatorsVoted;
    }
    
    struct ModeratorStats {
        uint256 totalVotes;
        uint256 alignedVotes;  // Votes that aligned with final decision
        uint256 stakeAmount;
        uint256 rewardsClaimed;
    }
    
    // Content registry
    mapping(uint256 => Content) public contentRegistry;
    uint256 public contentCount;
    
    // Moderator statistics
    mapping(address => ModeratorStats) public moderatorStats;
    mapping(uint256 => mapping(address => ModeratorAction)) public moderatorVotes;
    
    // Economic parameters
    uint256 public requiredStake;          // Stake required to be a moderator
    uint256 public flagThreshold;          // Number of flags to trigger review
    uint256 public moderatorRewardPool;    // Total rewards available for distribution
    uint256 public rewardPerAlignedVote;   // Reward per vote that aligns with consensus
    uint256 public slashingPercentage;     // Percentage of stake slashed for misalignment
    
    // Events
    event ContentRegistered(uint256 indexed contentId, address indexed author, string contentHash);
    event ContentFlagged(uint256 indexed contentId, address indexed moderator);
    event ContentStatusUpdated(uint256 indexed contentId, ContentStatus newStatus);
    event ModeratorVoted(uint256 indexed contentId, address indexed moderator, ModeratorAction action);
    event ModeratorRewarded(address indexed moderator, uint256 amount);
    event ModeratorSlashed(address indexed moderator, uint256 amount);
    
    constructor(
        uint256 _requiredStake,
        uint256 _flagThreshold,
        uint256 _rewardPerAlignedVote,
        uint256 _slashingPercentage
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        
        requiredStake = _requiredStake;
        flagThreshold = _flagThreshold;
        rewardPerAlignedVote = _rewardPerAlignedVote;
        slashingPercentage = _slashingPercentage;
    }
    
    /**
     * @dev Register as a moderator by staking tokens
     */
    function registerAsModerator() external payable {
        require(msg.value >= requiredStake, "Insufficient stake");
        require(!hasRole(MODERATOR_ROLE, msg.sender), "Already a moderator");
        
        _grantRole(MODERATOR_ROLE, msg.sender);
        
        ModeratorStats storage stats = moderatorStats[msg.sender];
        stats.stakeAmount = msg.value;
    }
    
    /**
     * @dev Unregister as a moderator and withdraw stake
     */
    function unregisterAsModerator() external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "Not a moderator");
        
        ModeratorStats storage stats = moderatorStats[msg.sender];
        uint256 stakeToReturn = stats.stakeAmount;
        
        _revokeRole(MODERATOR_ROLE, msg.sender);
        stats.stakeAmount = 0;
        
        payable(msg.sender).transfer(stakeToReturn);
    }
    
    /**
     * @dev Register new content
     * @param contentHash IPFS hash of the content
     */
    function registerContent(string calldata contentHash) external returns (uint256) {
        contentCount++;
        
        contentRegistry[contentCount] = Content({
            id: contentCount,
            author: msg.sender,
            contentHash: contentHash,
            status: ContentStatus.Active,
            flagCount: 0,
            approvalCount: 0,
            lastDecisionTime: block.timestamp,
            moderatorsVoted: new address[](0)
        });
        
        emit ContentRegistered(contentCount, msg.sender, contentHash);
        return contentCount;
    }
    
    /**
     * @dev Cast a moderation vote on content
     * @param contentId ID of the content
     * @param action Moderation action to take
     */
    function moderateContent(uint256 contentId, ModeratorAction action) external onlyRole(MODERATOR_ROLE) {
        require(contentId <= contentCount, "Content does not exist");
        Content storage content = contentRegistry[contentId];
        
        // Check if moderator has already voted
        bool alreadyVoted = false;
        for (uint i = 0; i < content.moderatorsVoted.length; i++) {
            if (content.moderatorsVoted[i] == msg.sender) {
                alreadyVoted = true;
                break;
            }
        }
        require(!alreadyVoted, "Already voted on this content");
        
        // Record vote
        moderatorVotes[contentId][msg.sender] = action;
        content.moderatorsVoted.push(msg.sender);
        moderatorStats[msg.sender].totalVotes++;
        
        // Update content status based on action
        if (action == ModeratorAction.Flag) {
            content.flagCount++;
            if (content.flagCount >= flagThreshold && content.status == ContentStatus.Active) {
                content.status = ContentStatus.UnderReview;
                emit ContentStatusUpdated(contentId, ContentStatus.UnderReview);
            }
        } else if (action == ModeratorAction.Approve) {
            content.approvalCount++;
        } else if (action == ModeratorAction.Remove && hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            // Only admins can directly remove content
            content.status = ContentStatus.Removed;
            _processModerationOutcome(contentId, ContentStatus.Removed);
            emit ContentStatusUpdated(contentId, ContentStatus.Removed);
        } else if (action == ModeratorAction.Restore && hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            // Only admins can directly restore content
            content.status = ContentStatus.Restored;
            _processModerationOutcome(contentId, ContentStatus.Restored);
            emit ContentStatusUpdated(contentId, ContentStatus.Restored);
        }
        
        emit ModeratorVoted(contentId, msg.sender, action);
        
        // Check for moderation consensus
        _checkModerationConsensus(contentId);
    }
    
    /**
     * @dev Check if consensus has been reached on content moderation
     * @param contentId ID of the content
     */
    function _checkModerationConsensus(uint256 contentId) internal {
        Content storage content = contentRegistry[contentId];
        
        // Only process if under review
        if (content.status != ContentStatus.UnderReview) {
            return;
        }
        
        uint256 totalVotes = content.moderatorsVoted.length;
        if (totalVotes < 3) {
            return; // Need at least 3 votes for consensus
        }
        
        // Determine outcome based on votes
        if (content.flagCount > totalVotes / 2) {
            content.status = ContentStatus.Removed;
            _processModerationOutcome(contentId, ContentStatus.Removed);
            emit ContentStatusUpdated(contentId, ContentStatus.Removed);
        } else if (content.approvalCount > totalVotes / 2) {
            content.status = ContentStatus.Active;
            _processModerationOutcome(contentId, ContentStatus.Active);
            emit ContentStatusUpdated(contentId, ContentStatus.Active);
        }
        
        content.lastDecisionTime = block.timestamp;
    }
    
    /**
     * @dev Process rewards and slashing based on moderation outcome
     * @param contentId ID of the content
     * @param finalStatus Final status of the content
     */
    function _processModerationOutcome(uint256 contentId, ContentStatus finalStatus) internal {
        Content storage content = contentRegistry[contentId];
        
        for (uint i = 0; i < content.moderatorsVoted.length; i++) {
            address moderator = content.moderatorsVoted[i];
            ModeratorAction vote = moderatorVotes[contentId][moderator];
            
            bool aligned = (
                (finalStatus == ContentStatus.Removed && vote == ModeratorAction.Flag) ||
                (finalStatus == ContentStatus.Active && vote == ModeratorAction.Approve) ||
                (finalStatus == ContentStatus.Restored && vote == ModeratorAction.Restore)
            );
            
            if (aligned) {
                // Reward aligned votes
                moderatorStats[moderator].alignedVotes++;
                _rewardModerator(moderator, rewardPerAlignedVote);
            } else {
                // Slash for misaligned votes
                _slashModerator(moderator);
            }
        }
    }
    
    /**
     * @dev Reward a moderator for aligned votes
     * @param moderator Address of the moderator
     * @param amount Amount to reward
     */
    function _rewardModerator(address moderator, uint256 amount) internal {
        require(moderatorRewardPool >= amount, "Insufficient reward pool");
        
        moderatorRewardPool -= amount;
        moderatorStats[moderator].rewardsClaimed += amount;
        
        emit ModeratorRewarded(moderator, amount);
    }
    
    /**
     * @dev Slash a moderator for misaligned votes
     * @param moderator Address of the moderator
     */
    function _slashModerator(address moderator) internal {
        ModeratorStats storage stats = moderatorStats[moderator];
        uint256 slashAmount = (stats.stakeAmount * slashingPercentage) / 10000;
        
        if (slashAmount > 0) {
            stats.stakeAmount -= slashAmount;
            moderatorRewardPool += slashAmount; // Add slashed amount to reward pool
            
            emit ModeratorSlashed(moderator, slashAmount);
        }
    }
    
    /**
     * @dev Claim accumulated rewards
     */
    function claimRewards() external {
        require(hasRole(MODERATOR_ROLE, msg.sender), "Not a moderator");
        
        ModeratorStats storage stats = moderatorStats[msg.sender];
        uint256 amount = stats.rewardsClaimed;
        require(amount > 0, "No rewards to claim");
        
        stats.rewardsClaimed = 0;
        
        payable(msg.sender).transfer(amount);
    }
    
    /**
     * @dev Add funds to the moderator reward pool
     */
    function addToRewardPool() external payable {
        moderatorRewardPool += msg.value;
    }
}
```

## Financial Infrastructure Contracts

### 1. SotilityExchange.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/**
 * @title SotilityExchange
 * @dev Tokenized listing and SST issuance for revenue-verified businesses.
 */
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
        
        ERC20Burnable(address(stableToken)).mint(business, amount); // Assume minting rights exist
        
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
```

### 2. SotilityTreasuryRouter.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title SotilityTreasuryRouter
 * @dev Routes protocol revenue to SOT dividends, SST mint vaults, and SUG campaigns.
 */
contract SotilityTreasuryRouter is AccessControl {
    bytes32 public constant ROUTER_ROLE = keccak256("ROUTER_ROLE");
    
    address public dividendPool;
    address public stableVault;
    address public campaignPool;
    
    uint256 public splitToDividends = 4000; // 40%
    uint256 public splitToStable = 4000;    // 40%
    uint256 public splitToCampaigns = 2000; // 20%
    
    event RevenueReceived(address indexed sender, uint256 amount);
    event RevenueSplit(uint256 toDividends, uint256 toVault, uint256 toCampaigns);
    event DestinationsUpdated(address dividendPool, address stableVault, address campaignPool);
    event SplitsUpdated(uint256 toDividends, uint256 toVault, uint256 toCampaigns);
    
    constructor(address _dividendPool, address _stableVault, address _campaignPool) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        dividendPool = _dividendPool;
        stableVault = _stableVault;
        campaignPool = _campaignPool;
    }
    
    receive() external payable {
        emit RevenueReceived(msg.sender, msg.value);
        _split(msg.value);
    }
    
    function _split(uint256 amount) internal {
        uint256 toDividends = (amount * splitToDividends) / 10000;
        uint256 toVault = (amount * splitToStable) / 10000;
        uint256 toCampaigns = amount - toDividends - toVault;
        
        payable(dividendPool).transfer(toDividends);
        payable(stableVault).transfer(toVault);
        payable(campaignPool).transfer(toCampaigns);
        
        emit RevenueSplit(toDividends, toVault, toCampaigns);
    }
    
    function updateDestinations(address _dividend, address _vault, address _campaign)
        external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        dividendPool = _dividend;
        stableVault = _vault;
        campaignPool = _campaign;
        
        emit DestinationsUpdated(_dividend, _vault, _campaign);
    }
    
    function updateSplits(uint256 toDiv, uint256 toVault, uint256 toCamp)
        external onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(toDiv + toVault + toCamp == 10000, "Invalid split sum");
        
        splitToDividends = toDiv;
        splitToStable = toVault;
        splitToCampaigns = toCamp;
        
        emit SplitsUpdated(toDiv, toVault, toCamp);
    }
}
```

### 3. SotilityYieldEngine.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SotilityYieldEngine
 * @notice AI-managed, cross-chain, laddered-leverage staking vault for stablecoins.
 */
contract SotilityYieldEngine is Ownable {
    struct Strategy {
        string name;
        address targetProtocol;
        uint256 allocationBps; // Allocation in basis points (1% = 100)
        uint256 leverageRatio; // Multiplier, e.g., 2 = 2x
        uint256 lockTime;      // Lock duration in seconds
    }
    
    IERC20 public stableToken;
    address public rewardDistributor;
    Strategy[] public strategies;
    
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public entryTimestamps;
    
    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event StrategyAdded(string name);
    
    constructor(address _stableToken, address _rewardDistributor) {
        stableToken = IERC20(_stableToken);
        rewardDistributor = _rewardDistributor;
    }
    
    function deposit(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        stableToken.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
        entryTimestamps[msg.sender] = block.timestamp;
        
        emit Deposited(msg.sender, amount);
    }
    
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        
        deposits[msg.sender] -= amount;
        stableToken.transfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }
    
    function addStrategy(
        string calldata name,
        address targetProtocol,
        uint256 allocationBps,
        uint256 leverageRatio,
        uint256 lockTime
    ) external onlyOwner {
        strategies.push(Strategy({
            name: name,
            targetProtocol: targetProtocol,
            allocationBps: allocationBps,
            leverageRatio: leverageRatio,
            lockTime: lockTime
        }));
        
        emit StrategyAdded(name);
    }
    
    function rebalanceYieldStrategies() external onlyOwner {
        // Placeholder for AI strategy engine:
        // Fetch APYs, risk scores, reallocate across strategies
        // Could use Chainlink Functions, Gelato, or custom oracle
    }
    
    function getUserStakeDetails(address user) external view returns (uint256 staked, uint256 duration) {
        return (deposits[user], block.timestamp - entryTimestamps[user]);
    }
    
    function getStrategies() external view returns (Strategy[] memory) {
        return strategies;
    }
    
    function setRewardDistributor(address _distributor) external onlyOwner {
        rewardDistributor = _distributor;
    }
}
```

### 4. SotilityVaultFactory.sol

```solidity
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
```

### 5. SotilityBri