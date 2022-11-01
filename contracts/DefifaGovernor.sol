// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import '@paulrberg/contracts/math/PRBMath.sol';
import '@jbx-protocol/juice-721-delegate/contracts/JBTiered721Delegate.sol';
import '@jbx-protocol/juice-721-delegate/contracts/JB721TieredGovernance.sol';
import '@openzeppelin/contracts/governance/Governor.sol';
import '@openzeppelin/contracts/governance/extensions/GovernorSettings.sol';
import '@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol';
import '@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol';

contract DefifaGovernor is Governor, GovernorSettings, GovernorCountingSimple {
  error INCORRECT_TIER_ORDER(uint256, uint256[]);
  error PROPOSAL_CREATION_THRESHOLD_NOT_REACHED_YET();

  // The max voting power 1 tier has if everyone votes
  uint256 public constant MAX_VOTING_POWER_TIER = 1_000_000_000;
  // How many seconds does 1 block take
  uint256 internal constant BLOCKTIME_SECONDS = 12;
  // The votingDelay that is set after the contract gets deployed
  uint256 public constant INITIAL_VOTING_DELAY_AFTER_DEPLOYMENT = 1 weeks;
  // After the `INITIAL_VOTING_DELAY_AFTER_DEPLOYMENT` has expired, how long should the delay be then
  uint256 public constant VOTING_DELAY = 1 days;

  uint256 internal immutable DEPLOYED_AT;

  // The datasource for votingpower
  IJB721TieredGovernance public immutable jbTieredGovernance;

  // proposal creation threshold time
  uint256 public immutable proposalCreationThreshold;

  constructor(
    IJB721TieredGovernance _jbTieredGovernance,
    uint256 _proposalCreationThreshold
  )
    Governor('DefifaGovernor')
    GovernorSettings(
      1, /* 1 block */
      45818, /* 1 week */
      0
    )
  {
    DEPLOYED_AT = block.timestamp;
    jbTieredGovernance = _jbTieredGovernance;
    proposalCreationThreshold = _proposalCreationThreshold;
  }

  /**
   * Get the voting weights for specific tiers
   */
  function _getVotes(
    address account,
    uint256 blockNumber,
    bytes memory params
  ) internal view virtual override(Governor) returns (uint256 votingPower) {
    // Decode the bytes into the tier_ids
    uint256[] memory _tiers = abi.decode(params, (uint256[]));
    uint256 _tiers_length = _tiers.length;

    // Loop over all tiers gathering the voting share of the user
    uint256 _prevTier;
    for (uint256 _i; _i < _tiers_length; ) {
      // Enforce the tiers to be in ascending order, reverts if
      // there are any duplicates or the tiers are incorrecly sorted
      if (_tiers[_i] <= _prevTier) revert INCORRECT_TIER_ORDER(_i, _tiers);
      _prevTier = _tiers[_i];

      uint256 _tierVotingPower = jbTieredGovernance.getPastTierVotes(
        account,
        _tiers[_i],
        blockNumber
      );

      unchecked {
        if (_tierVotingPower != 0) {
          votingPower += PRBMath.mulDiv(
            _tierVotingPower,
            MAX_VOTING_POWER_TIER,
            jbTieredGovernance.getPastTierTotalVotes(_tiers[_i], blockNumber)
          );
        }

        ++_i;
      }
    }
  }

  /**
   * @dev Default additional encoded parameters used by castVote methods that don't include them
   */
  function _defaultParams() internal view virtual override returns (bytes memory) {
    // TODO: should we do this on every time or should we just store this, what is cheaper...
    uint256 _count = jbTieredGovernance.store().maxTierIdOf(address(jbTieredGovernance));
    uint256[] memory _ids = new uint256[](_count);

    // Add all tiers to the array
    for (uint256 _i; _i < _count; ) {
      // Tiers start counting from 1
      _ids[_i] = _i + 1;

      unchecked {
        ++_i;
      }
    }

    return abi.encode(_ids);
  }

  // Overrides we have to do

  function votingDelay() public view override(IGovernor, GovernorSettings) returns (uint256) {
    // After the contract initially deploys there is a long delay, once this long delay has passed we use `VOTING_DELAY`
    if (DEPLOYED_AT + INITIAL_VOTING_DELAY_AFTER_DEPLOYMENT - VOTING_DELAY > block.timestamp) {
      return
        ((DEPLOYED_AT + INITIAL_VOTING_DELAY_AFTER_DEPLOYMENT) - block.timestamp) /
        BLOCKTIME_SECONDS;
    }

    return VOTING_DELAY / BLOCKTIME_SECONDS;
  }

  function votingPeriod() public view override(IGovernor, GovernorSettings) returns (uint256) {
    return super.votingPeriod();
  }

  function quorum(uint256 blockNumber) public pure override(IGovernor) returns (uint256) {
    blockNumber;
    // TODO: I just picked some random value for now, decide what a appropriate quarum should be
    return 2 * MAX_VOTING_POWER_TIER;
  }

  function state(uint256 proposalId) public view override(Governor) returns (ProposalState) {
    return super.state(proposalId);
  }

  function propose(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    string memory description
  ) public override(Governor) returns (uint256) {
    if (block.timestamp <= proposalCreationThreshold) {
      revert PROPOSAL_CREATION_THRESHOLD_NOT_REACHED_YET();
    }
    return super.propose(targets, values, calldatas, description);
  }

  function proposalThreshold() public view override(Governor, GovernorSettings) returns (uint256) {
    return super.proposalThreshold();
  }

  function _execute(
    uint256 proposalId,
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  ) internal override(Governor) {
    super._execute(proposalId, targets, values, calldatas, descriptionHash);
  }

  function _cancel(
    address[] memory targets,
    uint256[] memory values,
    bytes[] memory calldatas,
    bytes32 descriptionHash
  ) internal override(Governor) returns (uint256) {
    return super._cancel(targets, values, calldatas, descriptionHash);
  }

  function _executor() internal view override(Governor) returns (address) {
    return super._executor();
  }

  function supportsInterface(bytes4 interfaceId) public view override(Governor) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}