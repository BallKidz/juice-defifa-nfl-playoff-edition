// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './IDefifaDelegate.sol';

interface IDefifaTokenUriResolver {
  function codeOrigin() external view returns (address);

  function delegate() external view returns (IDefifaDelegate);

  function initialize(IDefifaDelegate _delegate) external;
}
