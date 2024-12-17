// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PaidNFT is ERC721 {
    uint256 private _nextTokenId;
    
    IERC20 public immutable USDC;
    uint256 public constant MINT_PRICE = 1_000_000; // $1 USDC (6 decimals)
    
    constructor(address _usdc) ERC721("Dollar NFT", "DNFT") {
        USDC = IERC20(_usdc);
    }
    
    function mint() external returns (uint256) {
        // Transfer USDC first (check-effects-interactions pattern)
        require(USDC.transferFrom(msg.sender, address(this), MINT_PRICE), "USDC transfer failed");
        
        // Mint NFT
        uint256 tokenId = _nextTokenId++;
        _mint(msg.sender, tokenId);
        
        return tokenId;
    }
}