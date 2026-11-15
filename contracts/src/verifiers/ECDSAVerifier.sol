// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {IERC7913SignatureVerifier} from "@openzeppelin/contracts/interfaces/IERC7913.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title ECDSA secp256k1 verifier behind the ERC-7913 interface.
/// @notice `key` is the 20-byte Ethereum address derived from the public key;
///         `signature` is the 65-byte (r, s, v) encoding.
/// @dev OpenZeppelin's ECDSA rejects high-s signatures and the zero address, which closes
///      the malleability and `ecrecover == address(0)` pitfalls shown in src/demos.
contract ECDSAVerifier is IERC7913SignatureVerifier {
    function verify(bytes calldata key, bytes32 hash, bytes calldata signature) external pure returns (bytes4) {
        if (key.length != 20 || signature.length != 65) return 0xffffffff;
        (address recovered, ECDSA.RecoverError err,) = ECDSA.tryRecoverCalldata(hash, signature);
        if (err != ECDSA.RecoverError.NoError || recovered != address(bytes20(key))) return 0xffffffff;
        return IERC7913SignatureVerifier.verify.selector;
    }
}
