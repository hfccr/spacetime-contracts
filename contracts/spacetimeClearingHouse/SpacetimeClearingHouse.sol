// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./../spacetimeStorage/Derivative.sol";
import "./../spacetimeStorage/DerivativeState.sol";
import {MarketAPI} from "@zondax/filecoin-solidity/contracts/v0.8/MarketAPI.sol";
import {CommonTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/CommonTypes.sol";
import {MarketTypes} from "@zondax/filecoin-solidity/contracts/v0.8/types/MarketTypes.sol";
import {Actor} from "@zondax/filecoin-solidity/contracts/v0.8/utils/Actor.sol";
import {Misc} from "@zondax/filecoin-solidity/contracts/v0.8/utils/Misc.sol";

contract SpacetimeClearingHouse is AccessControl {
    constructor() {}

    function verifyDealData(
        DerivativeType derivativeType,
        uint64 size,
        uint64 provider,
        int64 dealTermStart,
        int64 dealTermDuration,
        uint pricePerEpoch,
        uint64 client,
        uint64 _networkDealID
    ) public returns (bool) {
        // The client of a deal proposal
        MarketTypes.GetDealClientReturn memory clientRet = MarketAPI.getDealClient(_networkDealID);
        require(clientRet.client == client, "Client does not match");
        // Data commitment and size of a deal proposal
        MarketTypes.GetDealDataCommitmentReturn memory commitmentRet = MarketAPI
            .getDealDataCommitment(_networkDealID);
        require(commitmentRet.size >= size, "Size lesser than committed");
        // The provider of a deal proposal
        MarketTypes.GetDealProviderReturn memory providerRet = MarketAPI.getDealProvider(
            _networkDealID
        );
        require(providerRet.provider == provider, "Provider does not match");
        // Start epoch and duration in epochs
        MarketTypes.GetDealTermReturn memory termRet = MarketAPI.getDealTerm(_networkDealID);
        require(termRet.start > dealTermStart, "Deal started before time");
        require(
            (termRet.end - termRet.start) > dealTermDuration,
            "Deal duration lesser than expected"
        );
        // Total price is the per epoch price
        // MarketTypes.GetDealEpochPriceReturn memory totalPriceRet = MarketAPI.getDealTotalPrice(
        //     _networkDealID
        // );
        // require(totalPriceRet.price_per_epoch <= pricePerEpoch, "Price greater than expected");
        // The client collateral required for a deal proposal
        // MarketTypes.GetDealClientCollateralReturn memory clientCollateralRet = MarketAPI
        //     .getDealClientCollateral(_networkDealID);
        // The provider collateral required for a deal proposal
        // MarketTypes.GetDealProviderCollateralReturn memory providerCollateralRet = MarketAPI
        //     .getDealProviderCollateral(_networkDealID);
        // Verified flag for a deal proposal
        // MarketTypes.GetDealVerifiedReturn memory verifiedRet = MarketAPI.getDealVerified(
        //     _networkDealID
        // );
        // Activation state for a deal
        // MarketTypes.GetDealActivationReturn memory activationRet = MarketAPI.getDealActivation(
        //     _networkDealID
        // );
        return true;
    }
}
