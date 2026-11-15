// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {IERC7913SignatureVerifier} from "@openzeppelin/contracts/interfaces/IERC7913.sol";

/// @title Hybrid verifier: a signature is valid only if BOTH component schemes accept it.
/// @notice Intended pairing: one classical scheme and one post-quantum scheme, so that a
///         break of either alone does not forge an authorisation.
///         `key` = abi.encode(bytes classicalKey, bytes pqKey)
///         `signature` = abi.encode(bytes classicalSig, bytes pqSig)
/// @dev The two component verifiers are fixed at construction, so governance approves one
///      specific combination when it approves this contract.
contract HybridVerifier is IERC7913SignatureVerifier {
    IERC7913SignatureVerifier public immutable CLASSICAL;
    IERC7913SignatureVerifier public immutable POST_QUANTUM;

    error SameVerifier();

    constructor(IERC7913SignatureVerifier classical, IERC7913SignatureVerifier postQuantum) {
        if (address(classical) == address(postQuantum)) revert SameVerifier();
        CLASSICAL = classical;
        POST_QUANTUM = postQuantum;
    }

    function verify(bytes calldata key, bytes32 hash, bytes calldata signature) external view returns (bytes4) {
        (bytes memory keyA, bytes memory keyB) = abi.decode(key, (bytes, bytes));
        (bytes memory sigA, bytes memory sigB) = abi.decode(signature, (bytes, bytes));
        if (CLASSICAL.verify(keyA, hash, sigA) != IERC7913SignatureVerifier.verify.selector) return 0xffffffff;
        if (POST_QUANTUM.verify(keyB, hash, sigB) != IERC7913SignatureVerifier.verify.selector) return 0xffffffff;
        return IERC7913SignatureVerifier.verify.selector;
    }
}
