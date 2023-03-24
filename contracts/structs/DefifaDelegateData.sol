// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@jbx-protocol/juice-721-delegate/contracts/structs/JB721TierParams.sol';
import '@jbx-protocol/juice-721-delegate/contracts/interfaces/IJBTiered721DelegateStore.sol';

/**
  @member name The name of the token.
  @member symbol The symbol that the token should be represented by.
  @member baseUri A URI to use as a base for full token URIs.
  @member contractUri A URI where contract metadata can be found. 
  @member tiers The tiers to set.
  @member tierNames The names of the tiers.
  @member store The store contract to use.
*/
struct DefifaDelegateData {
  string name;
  string symbol;
  string baseUri;
  string contractUri;
  JB721TierParams[] tiers;
  string[] tierNames;
  IJBTiered721DelegateStore store;
}
