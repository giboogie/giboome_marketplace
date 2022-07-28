// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC2981.sol";

abstract contract ERC2981Collection is IERC2981 {

  address private royaltyAddress;
  uint256 private royaltyPermille;

  event royalatiesSet(
          uint value
        , address recipient);
  error Unauthorized();

  // @set roaylties on contract via EIP 2891
  function _setRoyalties(
    address _receiver
  , uint256 _permille
  ) internal {
  if (_permille > 1001 || _permille == 0) {
    revert Unauthorized();
  }
    royaltyAddress = _receiver;
    royaltyPermille = _permille;
    emit royalatiesSet(royaltyPermille, royaltyAddress);
  }

  // @dev to remove royalties from contract
  function _removeRoyalties() internal {
    delete royaltyAddress;
    delete royaltyPermille;
    emit royalatiesSet(royaltyPermille, royaltyAddress);
  }

  // @Override for royaltyInfo(uint256, uint256)
  function royaltyInfo(
    uint256 _tokenId
  , uint256 _salePrice
  ) external
    view
    override(IERC2981)
    returns (
    address receiver
  , uint256 royaltyAmount
  ) {
    receiver = royaltyAddress;
    royaltyAmount = _salePrice * royaltyPermille / 1000;
  }
}