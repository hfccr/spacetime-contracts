// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "./../spacetimeStorage/Derivative.sol";
import "./../spacetimeStorage/DerivativeState.sol";
import "./../spacetimeToken/SpacetimeToken.sol";
import "./../spacetimeClearingHouse/SpacetimeClearingHouse.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract SpacetimeERC721 is ERC721PresetMinterPauserAutoId {
    uint256 private _count;
    mapping(uint256 => Derivative) derivatives;
    mapping(address => uint256) clientCount;
    mapping(address => uint256) providerCount;
    SpacetimeToken _spacetimeToken;
    SpacetimeClearingHouse _spacetimeClearingHouse;

    constructor(
        address spacetimeToken,
        address spacetimeClearingHouse
    ) ERC721PresetMinterPauserAutoId("Spacetime Derivatives", "SPDX", "") {
        _spacetimeToken = SpacetimeToken(spacetimeToken);
        _spacetimeClearingHouse = SpacetimeClearingHouse(spacetimeClearingHouse);
    }

    function getCount() public view returns (uint256) {
        return _count;
    }

    function getDerivative(uint256 tokenId) public view returns (Derivative memory) {
        Derivative memory derivative = derivatives[tokenId];
        return derivative;
    }

    function mintDerivative(
        DerivativeType derivativeType,
        uint64 size,
        uint64 provider,
        int64 dealTermStart,
        int64 dealTermDuration,
        uint pricePerEpoch,
        address providerEthAddress
    ) public {
        require(hasRole(MINTER_ROLE, msg.sender), "User is not a minter");
        Derivative memory derivative;
        derivative.derivativeType = derivativeType;
        derivative.derivativeState = DerivativeState.Open;
        derivative.size = size;
        derivative.provider = provider;
        derivative.providerEthAddress = providerEthAddress;
        derivative.dealTermStart = dealTermStart;
        derivative.dealTermDuration = dealTermDuration;
        derivative.pricePerEpoch = pricePerEpoch;

        _mint(msg.sender, _count);
        derivatives[_count] = derivative;
        providerCount[providerEthAddress]++;
        _count++;
    }

    // Buy a deal from another client in case the client has set a price for the deal
    function purchase(uint256 tokenId, uint64 client) public {
        require(derivatives[tokenId].derivativeState == DerivativeState.ClientSet);
        require(derivatives[tokenId].onSale == true);
        require(derivatives[tokenId].salePrice > 0);
        clientCount[derivatives[tokenId].clientEthAddress]--;
        _spacetimeToken.permissionlessTransferFrom(
            msg.sender,
            derivatives[tokenId].clientEthAddress,
            derivatives[tokenId].salePrice
        );
        clientCount[msg.sender]++;
        derivatives[tokenId].client = client;
        derivatives[tokenId].clientEthAddress = msg.sender;
        derivatives[tokenId].onSale = false;
        derivatives[tokenId].salePrice = 0;
    }

    // Set the deal up for sale
    function setPrice(uint256 tokenId, uint256 price) public {
        require(
            derivatives[tokenId].derivativeState == DerivativeState.ClientSet,
            "Cannot sell this"
        );
        require(msg.sender == derivatives[tokenId].clientEthAddress);
        _spacetimeToken.permissionlessTransferFrom(
            msg.sender,
            derivatives[tokenId].clientEthAddress,
            1000
        );
        derivatives[tokenId].salePrice = price;
        derivatives[tokenId].onSale = true;
    }

    function setClient(uint256 tokenId, uint64 client) public {
        require(derivatives[tokenId].derivativeState == DerivativeState.Open);
        // accept payment
        _spacetimeToken.permissionlessTransferFrom(
            msg.sender,
            derivatives[tokenId].providerEthAddress,
            1000
        );
        derivatives[tokenId].clientEthAddress = msg.sender;
        derivatives[tokenId].client = client;
        clientCount[msg.sender]++;
    }

    // Client records sending a deal proposal
    function submitDealProposal(uint256 tokenId) public {
        require(hasRole(MINTER_ROLE, _msgSender()));
        require(derivatives[tokenId].derivativeState == DerivativeState.Open);
        derivatives[tokenId].derivativeState = DerivativeState.DealProposalSubmitted;
    }

    // // Client failed to send proposal
    // function expireDeal(uint256 tokenId) public {
    //     require(
    //         (derivatives[tokenId].derivativeState == DerivativeState.Open ||
    //             derivatives[tokenId].derivativeState == DerivativeState.DealProposalSubmitted),
    //         "Deal is not possible to expire"
    //     );
    //     derivatives[tokenId].derivativeState = DerivativeState.DealExpired;
    // }

    // // SP failed to act
    // function failByProvider(uint256 tokenId) public {
    //     require(derivatives[tokenId].derivativeState == DerivativeState.DealProposalSubmitted);
    //     // TODO: add time check
    //     derivatives[tokenId].derivativeState = DerivativeState.DealFailedByProvider;
    // }

    // SP completed the deal. Check market API to close the deal.
    // function completeDeal(uint256 tokenId, uint64 _networkDealID) public {
    //     require(
    //         (derivatives[tokenId].derivativeState == DerivativeState.Open ||
    //             derivatives[tokenId].derivativeState == DerivativeState.DealProposalSubmitted),
    //         "Deal is not possible to complete"
    //     );
    //     _spacetimeClearingHouse.verifyDealData(
    //         derivatives[tokenId].derivativeType,
    //         derivatives[tokenId].size,
    //         derivatives[tokenId].provider,
    //         derivatives[tokenId].dealTermStart,
    //         derivatives[tokenId].dealTermDuration,
    //         derivatives[tokenId].pricePerEpoch,
    //         derivatives[tokenId].client,
    //         _networkDealID
    //     );
    //     derivatives[tokenId].derivativeState = DerivativeState.DealCompleted;
    // }

    function completeDealManual(uint256 tokenId) public {
        require(
            (derivatives[tokenId].derivativeState == DerivativeState.Open ||
                derivatives[tokenId].derivativeState == DerivativeState.DealProposalSubmitted)
        );
        derivatives[tokenId].derivativeState = DerivativeState.DealCompleted;
    }

    // // SP no longer wants to do the deal. Works only if the deal hasn't been taken up by any client yet
    // function withdrawDeal(uint256 tokenId) public {
    //     require(
    //         msg.sender == derivatives[tokenId].providerEthAddress,
    //         "You need to be the provider of this deal to withdraw it"
    //     );
    //     require(
    //         derivatives[tokenId].derivativeState == DerivativeState.Open,
    //         "The deal needs to be in the open state to withdraw it"
    //     );
    //     derivatives[tokenId].derivativeState = DerivativeState.Withdrawn;
    // }

    // function getAllDerivatives() public view returns (Derivative[] memory) {
    //     Derivative[] memory derivativesListSend = derivativesList;
    //     return derivativesListSend;
    // }

    // function getAllDerivativesForProvider(
    //     address target
    // ) public view returns (Derivative[] memory) {
    //     Derivative[] memory derivativesList = new Derivative[](providerCount[target]);
    //     uint256 index = 0;
    //     for (uint i = 0; i < _count; i++) {
    //         if (derivatives[i].providerEthAddress == target) {
    //             Derivative storage derivative = derivatives[i];
    //             derivativesList[index] = derivative;
    //             index++;
    //         }
    //     }
    //     return derivativesList;
    // }

    // function getAllDerivativesForClient(address target) public view returns (Derivative[] memory) {
    //     Derivative[] memory derivativesList = new Derivative[](clientCount[target]);
    //     uint256 index = 0;
    //     for (uint i = 0; i < _count; i++) {
    //         if (derivatives[i].clientEthAddress == target) {
    //             Derivative storage derivative = derivatives[i];
    //             derivativesList[index] = derivative;
    //             index++;
    //         }
    //     }
    //     return derivativesList;
    // }
}
