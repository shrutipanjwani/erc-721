// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AtomicSwap {
    struct SwapDetails {
        address nftContract;
        uint256 tokenId;
        uint256 price;
        address seller;
        bool isActive;
    }
    
    mapping(bytes32 => SwapDetails) public swaps;
    IERC20 public immutable USDC;
    
    constructor(address _usdc) {
        USDC = IERC20(_usdc);
    }
    
    // Creates a swap offer - called by seller (Bob)
    function createSwap(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        require(price > 0, "Price must be positive");
        
        // Check if seller owns and has approved this contract
        IERC721 nft = IERC721(nftContract);
        require(nft.ownerOf(tokenId) == msg.sender, "Not owner of NFT");
        require(nft.getApproved(tokenId) == address(this), "NFT not approved");
        
        bytes32 swapId = getSwapId(nftContract, tokenId, price, msg.sender);
        swaps[swapId] = SwapDetails({
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            seller: msg.sender,
            isActive: true
        });
    }
    
    // Execute the swap - called by buyer (Alice)
    function executeSwap(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address seller
    ) external {
        bytes32 swapId = getSwapId(nftContract, tokenId, price, seller);
        SwapDetails memory swap = swaps[swapId];
        
        require(swap.isActive, "Swap not active");
        require(swap.price == price, "Price mismatch");
        require(swap.seller == seller, "Seller mismatch");
        
        // Deactivate swap first (check-effects-interactions)
        swaps[swapId].isActive = false;
        
        // Transfer USDC from buyer to seller
        require(USDC.transferFrom(msg.sender, seller, price), "USDC transfer failed");
        
        // Transfer NFT from seller to buyer
        IERC721(nftContract).transferFrom(seller, msg.sender, tokenId);
    }
    
    // Cancel a swap - called by seller
    function cancelSwap(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) external {
        bytes32 swapId = getSwapId(nftContract, tokenId, price, msg.sender);
        SwapDetails memory swap = swaps[swapId];
        
        require(swap.isActive, "Swap not active");
        require(swap.seller == msg.sender, "Not the seller");
        
        swaps[swapId].isActive = false;
    }
    
    // Helper function to generate unique swap ID
    function getSwapId(
        address nftContract,
        uint256 tokenId,
        uint256 price,
        address seller
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(nftContract, tokenId, price, seller));
    }
}