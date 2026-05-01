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
    
    // OZ v5: use _update hook instead of _beforeTokenTransfer
    function _update(address to, uint256 tokenId, address auth)
        internal override(ERC721)
        returns (address)
    {
        address from = _ownerOf(tokenId);
        require(from == address(0) || !soulbound[tokenId], "Soulbound: Non-transferable");
        return super._update(to, tokenId, auth);
    }

    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721URIStorage, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
