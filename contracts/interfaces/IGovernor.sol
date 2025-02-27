// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.2) (governance/IGovernor.sol)

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

/**
 * @dev Interface of the {Governor} core.
 *
 * _Available since v4.3._
 */
abstract contract IGovernor is IERC165 {
  enum ProposalState {
    Pending,
    Active,
    Canceled,
    Defeated,
    Succeeded,
    Queued,
    Expired,
    Executed
  }

  /**
   * @dev Emitted when a proposal is created.
   */
  event ProposalCreated(
    uint256 proposalId,
    address proposer,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    uint256 startBlock,
    uint256 endBlock,
    string description
  );

  /**
   * @dev Emitted when a proposal is canceled.
   */
  event ProposalCanceled(uint256 proposalId);

  /**
   * @dev Emitted when a proposal is executed.
   */
  event ProposalExecuted(uint256 proposalId);

  /**
   * @dev Emitted when a vote is cast without params.
   *
   * Note: `support` values should be seen as buckets. Their interpretation depends on the voting module used.
   */
  event VoteCast(
    address indexed voter,
    uint256 proposalId,
    uint8 support,
    uint256 weight,
    string reason
  );

  /**
   * @dev Emitted when a vote is cast with params.
   *
   * Note: `support` values should be seen as buckets. Their interpretation depends on the voting module used.
   * `params` are additional encoded parameters. Their intepepretation also depends on the voting module used.
   */
  event VoteCastWithParams(
    address indexed voter,
    uint256 proposalId,
    uint8 support,
    uint256 weight,
    string reason,
    bytes params
  );

  /**
   * @notice module:core
   * @dev Name of the governor instance (used in building the ERC712 domain separator).
   */
  function name() public view virtual returns (string memory);

  /**
   * @notice module:core
   * @dev Version of the governor instance (used in building the ERC712 domain separator). Default: "1"
   */
  function version() public view virtual returns (string memory);

  /**
   * @notice module:voting
   * @dev A description of the possible `support` values for {castVote} and the way these votes are counted, meant to
   * be consumed by UIs to show correct vote options and interpret the results. The string is a URL-encoded sequence of
   * key-value pairs that each describe one aspect, for example `support=bravo&quorum=for,abstain`.
   *
   * There are 2 standard keys: `support` and `quorum`.
   *
   * - `support=bravo` refers to the vote options 0 = Against, 1 = For, 2 = Abstain, as in `GovernorBravo`.
   * - `quorum=bravo` means that only For votes are counted towards quorum.
   * - `quorum=for,abstain` means that both For and Abstain votes are counted towards quorum.
   *
   * If a counting module makes use of encoded `params`, it should  include this under a `params` key with a unique
   * name that describes the behavior. For example:
   *
   * - `params=fractional` might refer to a scheme where votes are divided fractionally between for/against/abstain.
   * - `params=erc721` might refer to a scheme where specific NFTs are delegated to vote.
   *
   * NOTE: The string can be decoded by the standard
   * https://developer.mozilla.org/en-US/docs/Web/API/URLSearchParams[`URLSearchParams`]
   * JavaScript class.
   */
  // solhint-disable-next-line func-name-mixedcase
  function COUNTING_MODE() public pure virtual returns (string memory);

  /**
   * @notice module:core
   * @dev Hashing function used to (re)build the proposal id from the proposal details..
   */
  function hashProposal(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  ) public pure virtual returns (uint256);

  /**
   * @notice module:core
   * @dev Current state of a proposal, following Compound's convention
   */
  function state(uint256 proposalId) public view virtual returns (ProposalState);

  /**
   * @notice module:core
   * @dev Block number used to retrieve user's votes and quorum. As per Compound's Comp and OpenZeppelin's
   * ERC20Votes, the snapshot is performed at the end of this block. Hence, voting for this proposal starts at the
   * beginning of the following block.
   */
  function proposalSnapshot(uint256 proposalId) public view virtual returns (uint256);

  /**
   * @notice module:core
   * @dev Block number at which votes close. Votes close at the end of this block, so it is possible to cast a vote
   * during this block.
   */
  function proposalDeadline(uint256 proposalId) public view virtual returns (uint256);

  /**
   * @notice module:user-config
   * @dev Delay, in number of block, between the proposal is created and the vote starts. This can be increassed to
   * leave time for users to buy voting power, or delegate it, before the voting of a proposal starts.
   */
  function votingDelay() public view virtual returns (uint256);

  /**
   * @notice module:user-config
   * @dev Delay, in number of blocks, between the vote start and vote ends.
   *
   * NOTE: The {votingDelay} can delay the start of the vote. This must be considered when setting the voting
   * duration compared to the voting delay.
   */
  function votingPeriod() public view virtual returns (uint256);

  /**
   * @notice module:user-config
   * @dev Minimum number of cast voted required for a proposal to be successful.
   *
   * Note: The `blockNumber` parameter corresponds to the snapshot used for counting vote. This allows to scale the
   * quorum depending on values such as the totalSupply of a token at this block (see {ERC20Votes}).
   */
  function quorum(uint256 blockNumber) public view virtual returns (uint256);

  /**
   * @notice module:reputation
   * @dev Voting power of an `account` at a specific `blockNumber`.
   *
   * Note: this can be implemented in a number of ways, for example by reading the delegated balance from one (or
   * multiple), {ERC20Votes} tokens.
   */
  function getVotes(address account, uint256 blockNumber) public view virtual returns (uint256);

  /**
   * @notice module:reputation
   * @dev Voting power of an `account` at a specific `blockNumber` given additional encoded parameters.
   */
  function getVotesWithParams(
    address account,
    uint256 blockNumber,
    bytes memory params
  ) public view virtual returns (uint256);

  /**
   * @notice module:voting
   * @dev Returns weither `account` has cast a vote on `proposalId`.
   */
  function hasVoted(uint256 proposalId, address account) public view virtual returns (bool);
}
