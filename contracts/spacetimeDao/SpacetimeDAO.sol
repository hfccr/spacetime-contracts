// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./../spacetimeToken/SpacetimeToken.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract SpacetimeDAO is Context, AccessControlEnumerable {
    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant MEMBER = keccak256("MEMBER");
    bytes32 public constant DEAL_PROPOSAL_VALIDATOR = keccak256("DEAL_PROPOSAL_VALIDATOR");
    SpacetimeToken _spacetimeToken;

    constructor(address spacetimeToken) {
        _spacetimeToken = SpacetimeToken(spacetimeToken);
    }

    function getTokenAddress() public view returns (address) {
        return address(_spacetimeToken);
    }

    function join() public {
        require(!hasRole(MEMBER, _msgSender()), "User is already a member");
        _setupRole(MEMBER, _msgSender());
        _spacetimeToken.mint(_msgSender(), 100);
    }

    function quit() public {
        require(hasRole(MEMBER, _msgSender()), "User is not a member");
        _revokeRole(MEMBER, _msgSender());
    }

    function validateDealProposal() public {}

    function addFuture() public {}

    function addOption() public {}

    function addPerpetual() public {}
}
