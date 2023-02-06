// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

enum DerivativeState {
    Open, // Deal has been created
    ClientSet, // One or more client has bought the derivative
    DealProposalSubmitted, // Deal proposal submitted by client
    DealCompleted, // SP has stored the deal proposal
    DealFailedByProvider, // SP failed to store deal proposal in valid time
    DealExpired, // Future/Option expired
    Withdrawn // The SP has chosen to close an Open deal
}
