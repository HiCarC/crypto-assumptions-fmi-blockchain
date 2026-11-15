// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {IERC7913SignatureVerifier} from "@openzeppelin/contracts/interfaces/IERC7913.sol";

/// @title Participant signing keys, kept apart from balances.
/// @notice Every participant has one signing key: a (verifier contract, key bytes) pair.
///         Tokens and the DvP contract ask this registry whether a signature is valid, so
///         the signature scheme can change without touching a single balance.
///
///         Who holds which power (all through the AccessManager):
///           - which schemes exist and their life cycle  -> `setVerifierStatus` (cryptographic governance)
///           - first key and emergency replacement       -> `registerKeyFor`   (registrar)
///           - routine rotation, including to a new scheme -> the participant, by signing with the current key
///
/// @dev Life cycle mirrors NIST IR 8547's vocabulary: Approved -> Deprecated -> Disallowed.
///      Deprecated keys still verify but cannot be newly registered; Disallowed keys verify
///      nothing. Status only moves forward, so a disallowed scheme cannot be quietly revived.
contract KeyRegistry is AccessManaged, EIP712 {
    enum VerifierStatus {
        Unknown,
        Approved,
        Deprecated,
        Disallowed
    }

    struct SigningKey {
        address verifier;
        bytes key;
    }

    bytes32 public constant ROTATE_TYPEHASH =
        keccak256("RotateKey(address account,address newVerifier,bytes32 newKeyHash,uint256 nonce)");

    mapping(address verifier => VerifierStatus) public verifierStatus;
    mapping(address account => SigningKey) private _keys;
    mapping(address account => uint256) public rotationNonce;

    event VerifierStatusChanged(address indexed verifier, VerifierStatus status);
    event KeyRegistered(address indexed account, address indexed verifier, bytes32 keyHash, bool byRegistrar);

    error StatusMustAdvance(VerifierStatus current, VerifierStatus requested);
    error VerifierNotApproved(address verifier);
    error EmptyKey();
    error InvalidRotationSignature();

    constructor(address authority_) AccessManaged(authority_) EIP712("KeyRegistry", "1") {}

    // ---------------------------------------------------------------- governance

    function setVerifierStatus(address verifier, VerifierStatus status) external restricted {
        VerifierStatus current = verifierStatus[verifier];
        if (uint8(status) <= uint8(current)) revert StatusMustAdvance(current, status);
        verifierStatus[verifier] = status;
        emit VerifierStatusChanged(verifier, status);
    }

    /// @notice Onboarding and emergency path: the registrar sets a participant's key directly.
    ///         This is the remedy when a scheme is broken and the current key can no longer
    ///         be trusted to authorise its own replacement.
    function registerKeyFor(address account, address verifier, bytes calldata key) external restricted {
        _setKey(account, verifier, key, true);
    }

    // ---------------------------------------------------------------- participants

    /// @notice Routine rotation, callable by anyone carrying a signature from the current key.
    function rotateKey(address account, address newVerifier, bytes calldata newKey, bytes calldata signature)
        external
    {
        bytes32 digest = rotationDigest(account, newVerifier, newKey, rotationNonce[account]);
        if (!isValidSignature(account, digest, signature)) revert InvalidRotationSignature();
        rotationNonce[account]++;
        _setKey(account, newVerifier, newKey, false);
    }

    function rotationDigest(address account, address newVerifier, bytes calldata newKey, uint256 nonce)
        public
        view
        returns (bytes32)
    {
        return _hashTypedDataV4(keccak256(abi.encode(ROTATE_TYPEHASH, account, newVerifier, keccak256(newKey), nonce)));
    }

    // ---------------------------------------------------------------- verification

    function keyOf(address account) external view returns (address verifier, bytes memory key) {
        SigningKey storage k = _keys[account];
        return (k.verifier, k.key);
    }

    /// @notice True iff `signature` is a valid signature of `hash` under the account's
    ///         registered key and that key's scheme has not been disallowed.
    function isValidSignature(address account, bytes32 hash, bytes calldata signature) public view returns (bool) {
        SigningKey storage k = _keys[account];
        address verifier = k.verifier;
        if (verifier == address(0)) return false;
        VerifierStatus status = verifierStatus[verifier];
        if (status != VerifierStatus.Approved && status != VerifierStatus.Deprecated) return false;
        try IERC7913SignatureVerifier(verifier).verify(k.key, hash, signature) returns (bytes4 magic) {
            return magic == IERC7913SignatureVerifier.verify.selector;
        } catch {
            return false;
        }
    }

    function _setKey(address account, address verifier, bytes calldata key, bool byRegistrar) private {
        if (verifierStatus[verifier] != VerifierStatus.Approved) revert VerifierNotApproved(verifier);
        if (key.length == 0) revert EmptyKey();
        _keys[account] = SigningKey(verifier, key);
        emit KeyRegistered(account, verifier, keccak256(key), byRegistrar);
    }
}
