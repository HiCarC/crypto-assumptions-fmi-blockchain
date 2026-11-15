// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20PausableUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {AccessManagedUpgradeable} from
    "@openzeppelin/contracts-upgradeable/access/manager/AccessManagedUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {KeyRegistry} from "./KeyRegistry.sol";

/// @title Wholesale settlement token (tokenised deposit / tokenised security), reference model.
/// @notice A permissioned ERC-20 whose signed authorisations are verified through
///         {KeyRegistry}, so the signature scheme is replaceable without migrating balances.
///
///         Powers, each a separate AccessManager role:
///           issue / redeem        mint, burn
///           freeze / allow-list   setFrozen, setAllowed          (the "freeze key")
///           pause everything      pause, unpause
///           settlement operator   settlementTransfer             (granted to the DvP contract)
///           change the code       upgradeToAndCall               (timelocked governance only)
/// @dev Reference code for research. Not audited by a third party. Not for production use.
contract SettlementToken is
    ERC20Upgradeable,
    ERC20PausableUpgradeable,
    AccessManagedUpgradeable,
    EIP712Upgradeable,
    UUPSUpgradeable
{
    bytes32 public constant TRANSFER_TYPEHASH = keccak256(
        "TransferWithAuthorization(address from,address to,uint256 value,uint256 validAfter,uint256 validBefore,bytes32 nonce)"
    );

    /// @custom:storage-location erc7201:fmi.storage.SettlementToken
    struct TokenStorage {
        KeyRegistry registry;
        mapping(address => bool) allowed;
        mapping(address => bool) frozen;
        mapping(address => mapping(bytes32 => bool)) authorizationUsed;
    }

    // keccak256(abi.encode(uint256(keccak256("fmi.storage.SettlementToken")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant STORAGE_SLOT = 0x49a8334351c162a1162b84b3cccd21e628bd5d9ce2095dc2b2b2eaebc49cb100;

    event AllowedSet(address indexed account, bool allowed);
    event FrozenSet(address indexed account, bool frozen);
    event AuthorizationUsed(address indexed from, bytes32 indexed nonce);

    error NotAllowed(address account);
    error AccountFrozen(address account);
    error AuthorizationNotYetValid();
    error AuthorizationExpired();
    error AuthorizationAlreadyUsed();
    error InvalidAuthorization();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(string memory name_, string memory symbol_, address authority_, KeyRegistry registry_)
        external
        initializer
    {
        __ERC20_init(name_, symbol_);
        __ERC20Pausable_init();
        __AccessManaged_init(authority_);
        __EIP712_init(name_, "1");
        _s().registry = registry_;
    }

    // ---------------------------------------------------------------- views

    function registry() external view returns (KeyRegistry) {
        return _s().registry;
    }

    function isAllowed(address account) external view returns (bool) {
        return _s().allowed[account];
    }

    function isFrozen(address account) external view returns (bool) {
        return _s().frozen[account];
    }

    function authorizationState(address from, bytes32 nonce) external view returns (bool) {
        return _s().authorizationUsed[from][nonce];
    }

    function transferDigest(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(keccak256(abi.encode(TRANSFER_TYPEHASH, from, to, value, validAfter, validBefore, nonce)));
    }

    // ---------------------------------------------------------------- restricted powers

    function mint(address to, uint256 amount) external restricted {
        _mint(to, amount);
    }

    /// @notice Redemption, and also the claw-back path: burning ignores the frozen flag.
    function burn(address from, uint256 amount) external restricted {
        _burn(from, amount);
    }

    function setAllowed(address account, bool allowed_) external restricted {
        _s().allowed[account] = allowed_;
        emit AllowedSet(account, allowed_);
    }

    function setFrozen(address account, bool frozen_) external restricted {
        _s().frozen[account] = frozen_;
        emit FrozenSet(account, frozen_);
    }

    function pause() external restricted {
        _pause();
    }

    function unpause() external restricted {
        _unpause();
    }

    /// @notice Operator leg used by the DvP contract after it has checked both signatures.
    function settlementTransfer(address from, address to, uint256 amount) external restricted {
        _transfer(from, to, amount);
    }

    function _authorizeUpgrade(address) internal override restricted {}

    // ---------------------------------------------------------------- signed transfers

    /// @notice Moves `value` on the strength of a signature by `from`'s registered key.
    ///         Anyone may relay it; the signer needs no account-level key on the ledger.
    /// @dev Replay protection: the digest binds chain id and this contract's address
    ///      (EIP-712 domain), and each (from, nonce) pair is single-use.
    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes calldata signature
    ) external {
        TokenStorage storage $ = _s();
        if (block.timestamp <= validAfter) revert AuthorizationNotYetValid();
        if (block.timestamp >= validBefore) revert AuthorizationExpired();
        if ($.authorizationUsed[from][nonce]) revert AuthorizationAlreadyUsed();
        bytes32 digest = transferDigest(from, to, value, validAfter, validBefore, nonce);
        if (!$.registry.isValidSignature(from, digest, signature)) revert InvalidAuthorization();
        $.authorizationUsed[from][nonce] = true;
        emit AuthorizationUsed(from, nonce);
        _transfer(from, to, value);
    }

    // ---------------------------------------------------------------- transfer rules

    /// @dev Pause blocks every movement including mint and burn. Transfers and mints need
    ///      allow-listed, unfrozen parties. Burns are exempt so the issuer can redeem or
    ///      claw back from a frozen or de-listed account.
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        TokenStorage storage $ = _s();
        if (to != address(0)) {
            if (from != address(0)) {
                if (!$.allowed[from]) revert NotAllowed(from);
                if ($.frozen[from]) revert AccountFrozen(from);
            }
            if (!$.allowed[to]) revert NotAllowed(to);
            if ($.frozen[to]) revert AccountFrozen(to);
        }
        super._update(from, to, value);
    }

    function _s() private pure returns (TokenStorage storage $) {
        assembly {
            $.slot := STORAGE_SLOT
        }
    }
}
