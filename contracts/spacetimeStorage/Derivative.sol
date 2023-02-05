// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./DerivativeType.sol";
import "@zondax/filecoin-solidity/contracts/v0.8/cbor/BigIntCbor.sol";
import "/cbor/BigIntCbor.sol";

struct Derivative {
    DerivativeType derivativeType;
    address collection;
    uint64 size;
    uint64 client;
    uint64 provider;
    string label;
    int64 dealTermStart;
    int64 dealTermEnd;
    BigInt pricePerEpoch;
    BigInt clientCollateral;
    BigInt providerCollateral;
    bool verified;
    int64 activated;
    int64 terminated;
}
