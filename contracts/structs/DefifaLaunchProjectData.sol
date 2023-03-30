// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@jbx-protocol/juice-721-delegate/contracts/interfaces/IJBTiered721DelegateStore.sol';
import '@jbx-protocol/juice-contracts-v3/contracts/interfaces/IJBPaymentTerminal.sol';
import '@jbx-protocol/juice-contracts-v3/contracts/structs/JBProjectMetadata.sol';
import '@jbx-protocol/juice-contracts-v3/contracts/structs/JBSplit.sol';
import './DefifaTierParams.sol';
import './DefifaTimeData.sol';

/**
  @member projectMetadata Metadata to associate with the project within a particular domain. This can be updated any time by the owner of the project.
  @member token The token the game is played with.
  @member mintDuration The duration of the game's first phase.
  @member refundPeriodDuration The time between the mint period and the start time where mint's are no longer open but refunds are still allowed.
  @member start The timestamp at which the game should start.
  @member end The timestamp at which the game should end.
  @member splits Splits to distribute funds between during the game's second phase.
  @member distributionLimit The amount of funds to distribute from the pot during the game's second phase.
  @member ballkidzFeeProjectTokenAccount The address that should be sent Defifa Ballkidz tokens that are minted from paying the fee.
  @member votingPeriod The time the vote will be active for once it has started, measured in blocks.
  @member terminal A payment terminal to add for the project.
  @member store A contract to store standard 721 data in.
*/
struct DefifaLaunchProjectData {
  string name;
  JBProjectMetadata projectMetadata;
  string contractUri;
  string baseUri;
  DefifaTierParams[] tiers;
  address token;
  uint48 mintDuration;
  uint48 refundPeriodDuration;
  uint48 start;
  uint48 end;
  JBSplit[] splits;
  uint88 distributionLimit;
  address payable ballkidzFeeProjectTokenAccount;
  uint256 votingPeriod;
  IJBPaymentTerminal terminal;
  IJBTiered721DelegateStore store;
}
