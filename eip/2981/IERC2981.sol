// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

///
/// @dev Interface for the NFT Royalty Standard
///

interface IERC2981 is IERC165 {

  function royaltyInfo(
    uint256 _tokenId
  , uint256 _salePrice
  ) external
    view
    returns (
    address receiver
  , uint256 royaltyAmount
  );
}