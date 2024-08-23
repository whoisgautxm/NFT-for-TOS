
// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@4.5.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.5.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.5.0/security/Pausable.sol";
import "@openzeppelin/contracts@4.5.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.5.0/utils/Counters.sol";

contract HappyMonkey is ERC721, ERC721Enumerable, Pausable, Ownable {

    // ===== 1. Property Variables ===== //

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    uint256 public MINT_PRICE = 0.05 ether;
    uint public MAX_SUPPLY = 100;

    // Mapping to store the message for each token
    mapping(uint256 => string) private _tokenMessages;

    // ===== 2. Lifecycle Methods ===== //

    constructor() ERC721("HappyMonkey", "HM") {
        // Start token ID at 1. By default is starts at 0.
        _tokenIdCounter.increment();
    }

    function withdraw() public onlyOwner() {
        require(address(this).balance > 0, "Balance is zero");
        payable(owner()).transfer(address(this).balance);
    }

    // ===== 3. Pausable Functions ===== //

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // ===== 4. Minting Functions ===== //

    // Use 'calldata' for the message parameter to reduce gas costs
    function safeMint(address to, string calldata message) public payable {
        // ❌ Check that totalSupply is less than MAX_SUPPLY
        require(totalSupply() < MAX_SUPPLY, "Can't mint anymore tokens.");

        // ❌ Check if ether value is correct
        require(msg.value >= MINT_PRICE, "Not enough ether sent.");
        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        
        // Mint the NFT
        _safeMint(to, tokenId);
        
        // Store the message associated with the token ID
        _tokenMessages[tokenId] = message;
    }

    // ===== 5. Retrieve Message Function ===== //

    // Function to retrieve the message for a given tokenId
    function tokenMessage(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token does not exist.");
        return _tokenMessages[tokenId];
    }

    // ===== 6. Other Functions ===== //

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://happyMonkeyBaseURI/";
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
