// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./eip/2981/ERC2981Collection.sol";

contract NFTCollection is ERC721, Ownable, ERC721Burnable, ERC721Enumerable, ERC2981Collection {
  using Strings for uint256;
 mapping(uint256 => string) private _tokenURIs;
 
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  address private marketplaceAddress;
  mapping(uint256 => address) private _creators;

  event TokenMinted(uint256 indexed tokenId, string tokenURI, address marketplaceAddress);
  bool public paused = true;

  event UpdatedRoyalties(address newRoyaltyAddress, uint256 newPercentage);
  
  constructor(address _marketplaceAddress) ERC721(" ", " ") {
      marketplaceAddress = _marketplaceAddress;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
     super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, IERC165) returns(bool) {
     return super.supportsInterface(interfaceId);
  }
  
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
     if (_exists(tokenId) == true) {      
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return super.tokenURI(tokenId);
     } else {
        return "https://ipfs.io/ipfs/QmURKtTWiiPbtoboZ1ymMsgnqN863Nf2tERDdBGBKdMNNP"; 
     }    
  }
      
  function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

  function mintToken(string memory _tokenURI) public returns (uint256) {
     _tokenIds.increment();
     uint256 newItemId = _tokenIds.current();

     _mint(msg.sender, newItemId);
     _creators[newItemId] = msg.sender;
     _setTokenURI(newItemId, _tokenURI);

     setApprovalForAll(marketplaceAddress, true);
     emit TokenMinted(newItemId, _tokenURI, marketplaceAddress);
     return newItemId;
 }

 function getTokensList() public view returns (uint256[] memory) {
     uint256 numberOfExistingTokens = _tokenIds.current();     
     uint256[] memory allTokenIds = new uint256[](numberOfExistingTokens);
     uint256 currentIndex = 0;
     for (uint256 i = 0; i < numberOfExistingTokens; i++) {
         uint256 tokenId = i + 1;         
         allTokenIds[currentIndex] = tokenId;
         currentIndex += 1;
     }
     return allTokenIds;
 }

 function getTokensOwnedByMe() public view returns (uint256[] memory) {
     uint256 numberOfExistingTokens = _tokenIds.current();
     uint256 numberOfTokensOwned = balanceOf(msg.sender);
     uint256[] memory ownedTokenIds = new uint256[](numberOfTokensOwned);
     uint256 currentIndex = 0;
     
     for (uint256 i = 0; i < numberOfExistingTokens; i++) {
         uint256 tokenId = i + 1;
         if(_exists(tokenId) == true) {
            if (ownerOf(tokenId) != msg.sender) continue;
                ownedTokenIds[currentIndex] = tokenId;
                currentIndex += 1;
         }
     }
     return ownedTokenIds;
 }

  function getTokenCreatorById(uint256 tokenId) public view returns (address) {
      return _creators[tokenId];
  }

  function getTokensCreatedByMe() public view returns (uint256[] memory) {
      uint256 numberOfExistingTokens = _tokenIds.current();
      uint256 numberOfTokensCreated = 0;

      for (uint256 i = 0; i < numberOfExistingTokens; i++) {
          uint256 tokenId = i + 1;
          if (_creators[tokenId] != msg.sender) continue;
          numberOfTokensCreated += 1;
      }

      uint256[] memory createdTokenIds = new uint256[](numberOfTokensCreated);
      uint256 currentIndex = 0;

      for (uint256 i = 0; i < numberOfExistingTokens; i++) {
          uint256 tokenId = i + 1;
          if (_creators[tokenId] != msg.sender) continue;
          createdTokenIds[currentIndex] = tokenId;
          currentIndex += 1;
      }
      return createdTokenIds;
  }

  function getTokensCreatedByAddress(address account) public view returns (uint256[] memory) {
      uint256 numberOfExistingTokens = _tokenIds.current();
      uint256 numberOfTokensCreated = 0;

      for (uint256 i = 0; i < numberOfExistingTokens; i++) {
          uint256 tokenId = i + 1;
          if (_creators[tokenId] != account) continue;
          numberOfTokensCreated += 1;
      }

      uint256[] memory createdTokenIds = new uint256[](numberOfTokensCreated);
      uint256 currentIndex = 0;

      for (uint256 i = 0; i < numberOfExistingTokens; i++) {
          uint256 tokenId = i + 1;
          if (_creators[tokenId] != account) continue;
          createdTokenIds[currentIndex] = tokenId;
          currentIndex += 1;
      }
      return createdTokenIds;
  }
  
    function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setRoyaltyInfo (address _royaltyAddress, uint256 _percentage) public onlyOwner {
    _setRoyalties(_royaltyAddress, _percentage);
    emit UpdatedRoyalties(_royaltyAddress, _percentage);
  }

 }
