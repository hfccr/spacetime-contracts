// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import {Actor} from "@zondax/filecoin-solidity/contracts/v0.8/utils/Actor.sol";
import {Misc} from "@zondax/filecoin-solidity/contracts/v0.8/utils/Misc.sol";

contract SpacetimeClearingHouse is AccessControl {
    constructor() {}

    function verifyDealData(
        uint64 _networkDealID,
        bytes memory _cidraw,
        uint64 _provider,
        uint64 _client,
        uint _size
    ) public returns (bool) {
        // Data commitment and size of a deal proposal
        MarketTypes.GetDealDataCommitmentReturn memory commitmentRet = MarketAPI
            .getDealDataCommitment(_networkDealID);
        // The client of a deal proposal
        MarketTypes.GetDealClientReturn memory clientRet = MarketAPI.getDealClient(_networkDealID);
        // The provider of a deal proposal
        MarketTypes.GetDealProviderReturn memory providerRet = MarketAPI.getDealProvider(
            _networkDealID
        );
        // Label of the deal proposal
        MarketTypes.GetDealLabelReturn memory labelRet = MarketAPI.getDealLabel(_networkDealID);
        // Start epoch and duration in epochs
        MarketTypes.GetDealTermReturn memory termRet = MarketAPI.getDealTerm(_networkDealID);
        // Total price is the per epoch price
        MarketTypes.GetDealEpochPriceReturn memory totalPriceRet = MarketAPI.getDealTotalPrice(
            _networkDealID
        );
        // The client collateral required for a deal proposal
        // MarketTypes.GetDealClientCollateralReturn memory clientCollateralRet = MarketAPI
        //     .getDealClientCollateral(_networkDealID);
        // The provider collateral required for a deal proposal
        // MarketTypes.GetDealProviderCollateralReturn memory providerCollateralRet = MarketAPI
        //     .getDealProviderCollateral(_networkDealID);
        // Verified flag for a deal proposal
        MarketTypes.GetDealVerifiedReturn memory verifiedRet = MarketAPI.getDealVerified(
            _networkDealID
        );
        // Activation state for a deal
        MarketTypes.GetDealActivationReturn memory activationRet = MarketAPI.getDealActivation(
            _networkDealID
        );
        return true;
    }
}
