// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {KeyRegistry} from "./KeyRegistry.sol";
import {SettlementToken} from "./SettlementToken.sol";

/// @title Delivery versus payment between two settlement tokens.
/// @notice Seller and buyer each sign the same order. `settle` checks both signatures
///         through {KeyRegistry} and moves both legs in one transaction: either both
///         legs settle or neither does.
/// @dev The contract holds the settlement-operator role on both tokens and never holds
///      balances. Reference code for research; not for production use.
contract DvP is EIP712 {
    struct Order {
        address seller;
        address buyer;
        SettlementToken assetToken;
        uint256 assetAmount;
        SettlementToken cashToken;
        uint256 cashAmount;
        uint256 deadline;
        bytes32 nonce;
    }

    bytes32 public constant ORDER_TYPEHASH = keccak256(
        "Order(address seller,address buyer,address assetToken,uint256 assetAmount,address cashToken,uint256 cashAmount,uint256 deadline,bytes32 nonce)"
    );

    KeyRegistry public immutable REGISTRY;
    mapping(bytes32 orderHash => bool) public settled;

    event Settled(bytes32 indexed orderHash, address indexed seller, address indexed buyer);

    error OrderExpired();
    error OrderAlreadySettled();
    error InvalidSellerSignature();
    error InvalidBuyerSignature();
    error SameParty();

    constructor(KeyRegistry registry_) EIP712("DvP", "1") {
        REGISTRY = registry_;
    }

    function orderDigest(Order calldata o) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(
                abi.encode(
                    ORDER_TYPEHASH,
                    o.seller,
                    o.buyer,
                    o.assetToken,
                    o.assetAmount,
                    o.cashToken,
                    o.cashAmount,
                    o.deadline,
                    o.nonce
                )
            )
        );
    }

    function settle(Order calldata o, bytes calldata sellerSig, bytes calldata buyerSig) external {
        if (block.timestamp > o.deadline) revert OrderExpired();
        if (o.seller == o.buyer) revert SameParty();
        bytes32 digest = orderDigest(o);
        if (settled[digest]) revert OrderAlreadySettled();
        if (!REGISTRY.isValidSignature(o.seller, digest, sellerSig)) revert InvalidSellerSignature();
        if (!REGISTRY.isValidSignature(o.buyer, digest, buyerSig)) revert InvalidBuyerSignature();

        settled[digest] = true;
        emit Settled(digest, o.seller, o.buyer);

        o.assetToken.settlementTransfer(o.seller, o.buyer, o.assetAmount);
        o.cashToken.settlementTransfer(o.buyer, o.seller, o.cashAmount);
    }
}
