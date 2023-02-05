// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISpacetimeClearingHouse {
    // Verify that a deal happened between a client and a provider
    function verifyDeal() external;
    // Verify that data selection has happened from the client to the provider
    function verifyDataTransfer() external;
}