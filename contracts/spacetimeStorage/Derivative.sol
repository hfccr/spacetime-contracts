// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./DerivativeType.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
import "./DerivativeState.sol";

struct Derivative {
    DerivativeType derivativeType;
    DerivativeState derivativeState;
    uint64 size;
    uint64 client;
    address clientEthAddress;
    uint64 provider;
    address providerEthAddress;
    int64 dealTermStart;
    int64 dealTermDuration;
    uint pricePerEpoch;
    // Client can trade derivative up for sale
    bool onSale;
    // The sale price the client has put up this derivative for
    uint256 salePrice;
}
