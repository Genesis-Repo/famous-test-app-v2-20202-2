// SPDX-License-Identifier: MIT

// The SPDX-License-Identifier specifies the license under which the contract is released.
// Using MIT license in this case.

// This line specifies the version of Solidity that the contract is written in.
// The caret (^) symbol indicates that the compiler should use any version of Solidity greater than 0.8.0.
pragma solidity ^0.8.0;

// Import statements are used to bring code from other Solidity files into the current contract.
// In this contract, we are importing three different contracts from the OpenZeppelin library.

// The ERC721 contract is a standard for non-fungible tokens (NFTs) on the Ethereum blockchain.
// It provides functionalities for creating unique tokens that are not interchangeable.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// The ERC20 contract is a standard for fungible tokens on the Ethereum blockchain.
// It provides functionalities for creating tokens that are interchangeable.
// This contract is usually used for creating normal tokens like cryptocurrencies.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// The Ownable contract is also part of the OpenZeppelin library.
// It provides basic authorization control functions, simplifying the implementation of access control in contracts.
import "@openzeppelin/contracts/access/Ownable.sol";

// The LoyaltyApp contract inherits from ERC721 and Ownable.
// It means that LoyaltyApp has access to the functions and variables defined in ERC721 and Ownable.
contract LoyaltyApp is ERC721, Ownable {
    // Token ID counter to keep track of the next token ID to be minted.
    uint256 private tokenIdCounter;

    // Mapping to keep track of token burn status. 
    // It stores whether a specific token ID has been burnt or not.
    mapping(uint256 => bool) private isTokenBurnt;

    // Flag to determine if token is transferable.
    // This flag indicates whether the tokens can be transferred or not.
    bool private isTokenTransferable;

    // Event emitted when a new token is minted.
    event TokenMinted(address indexed user, uint256 indexed tokenId);

    // Event emitted when a token is burned.
    event TokenBurned(address indexed user, uint256 indexed tokenId);

    // Modifier to check if token is transferable before executing a function.
    modifier onlyTransferable() {
        require(isTokenTransferable, "Token is not transferable");
        _;
    }

    // Constructor function is called only once when the contract is deployed.
    constructor() ERC721("Loyalty Token", "LOYALTY") {
        tokenIdCounter = 1; // Start token IDs from 1
        isTokenBurnt[0] = true; // Reserved token ID 0 to represent a burnt token
        isTokenTransferable = false; // Token is not transferable by default
    }

    /**
     * @dev Mint a new token for the user.
     * Only the contract owner can call this function.
     * This function creates a new token and assigns it to the given user address.
     */
    function mintToken(address user) external onlyOwner returns (uint256) {
        require(user != address(0), "Invalid user address");

        uint256 newTokenId = tokenIdCounter; // Get the next token ID
        tokenIdCounter++; // Increment the token ID counter

        // Mint a new token with the given ID and assign it to the user
        _safeMint(user, newTokenId);

        emit TokenMinted(user, newTokenId); // Emit an event indicating the token minting

        return newTokenId; // Return the ID of the minted token
    }

    /**
     * @dev Burn a token.
     * The caller must be the owner of the token or the contract owner.
     * This function burns a specific token, removing it from circulation.
     */
    function burnToken(uint256 tokenId) external {
        // Check if the caller is the owner of the token or the contract owner
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Caller is not the owner nor approved");
        require(!isTokenBurnt[tokenId], "Token is already burnt"); // Check if the token is not already burnt

        isTokenBurnt[tokenId] = true; // Mark the token as burnt
        _burn(tokenId); // Burn the token from the user's possession

        emit TokenBurned(_msgSender(), tokenId); // Emit an event indicating the token burn
    }

    /**
     * @dev Set whether the token is transferable or not.
     * Only the contract owner can call this function.
     * This function allows the contract owner to enable or disable token transferability.
     */
    function setTokenTransferability(bool transferable) external onlyOwner {
        isTokenTransferable = transferable; // Update the transferability flag
    }

    /**
     * @dev Check if a token is burnt.
     * This function allows users to check whether a specific token has been burnt.
     */
    function isTokenBurned(uint256 tokenId) external view returns (bool) {
        return isTokenBurnt[tokenId]; // Return the burn status of the token
    }

    /**
     * @dev Check if the token is transferable.
     * This function allows users to check the current transferability status of the token.
     */
    function getTransferability() external view returns (bool) {
        return isTokenTransferable; // Return the transferability flag
    }
}