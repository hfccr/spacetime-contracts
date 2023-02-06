// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./../spacetimeToken/SpacetimeToken.sol";
import "./../spacetimeERC721/SpacetimeERC721.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./../spacetimeStorage/Derivative.sol";
import "./../spacetimeStorage/DerivativeState.sol";

contract SpacetimeDAO is Context, AccessControlEnumerable {
    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32 public constant MEMBER = keccak256("MEMBER");
    bytes32 public constant DEAL_PROPOSAL_VALIDATOR = keccak256("DEAL_PROPOSAL_VALIDATOR");
    SpacetimeToken _spacetimeToken;
    SpacetimeERC721 _spacetimeERC721;

    constructor(address spacetimeToken, address spacetimeERC721) {
        _spacetimeToken = SpacetimeToken(spacetimeToken);
        _spacetimeERC721 = SpacetimeERC721(spacetimeERC721);
    }

    function getTokenAddress() public view returns (address) {
        return address(_spacetimeToken);
    }

    function join() public {
        require(!hasRole(MEMBER, _msgSender()), "User is already a member");
        _setupRole(MEMBER, _msgSender());
        _spacetimeToken.mint(_msgSender(), 10000);
    }

    function quit() public {
        require(hasRole(MEMBER, _msgSender()), "User is not a member");
        _revokeRole(MEMBER, _msgSender());
    }

    function isMember(address participant) public view returns (bool) {
        return hasRole(MEMBER, participant);
    }

    function validateDealProposal(uint256 tokenId) public {
        _spacetimeERC721.submitDealProposal(tokenId);
    }

    function createDerivative(
        DerivativeType derivativeType,
        uint64 size,
        uint64 provider,
        int64 dealTermStart,
        int64 dealTermDuration,
        uint pricePerEpoch
    ) public {
        require(hasRole(MEMBER, _msgSender()), "User is not a member");
        _spacetimeERC721.mintDerivative(
            derivativeType,
            size,
            provider,
            dealTermStart,
            dealTermDuration,
            pricePerEpoch,
            msg.sender
        );
    }

    function transferDeal(uint256 tokenId) public {}

    function faucet() public {
        _spacetimeToken.mint(_msgSender(), 10000);
    }

    function getAllDerivatives() public view returns (Derivative[] memory) {
        Derivative[] memory derivativesList = new Derivative[](_spacetimeERC721.getCount());
        for (uint i = 0; i < _spacetimeERC721.getCount(); i++) {
            Derivative memory derivative = _spacetimeERC721.getDerivative(i);
            derivativesList[i] = derivative;
        }
        return derivativesList;
    }
}
