// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {ERC7913P256Verifier} from "@openzeppelin/contracts/utils/cryptography/verifiers/ERC7913P256Verifier.sol";
import {IERC7913SignatureVerifier} from "@openzeppelin/contracts/interfaces/IERC7913.sol";
import {KeyRegistry} from "../../src/KeyRegistry.sol";
import {SettlementToken} from "../../src/SettlementToken.sol";
import {DvP} from "../../src/DvP.sol";
import {ECDSAVerifier} from "../../src/verifiers/ECDSAVerifier.sol";
import {HybridVerifier} from "../../src/verifiers/HybridVerifier.sol";

/// @notice Deploys the reference system the way the README describes it. All keys here are
///         TEST KEYS derived from public labels.
abstract contract Fixture is Test {
    uint64 internal constant ISSUER = 1;
    uint64 internal constant COMPLIANCE = 2;
    uint64 internal constant PAUSER = 3;
    uint64 internal constant SETTLEMENT = 4;
    uint64 internal constant UPGRADER = 5;
    uint64 internal constant REGISTRAR = 6;
    uint64 internal constant CRYPTO_GOV = 7;
    uint256 internal constant TIMELOCK_DELAY = 2 days;
    uint256 internal constant P256_N = 0xFFFFFFFF00000000FFFFFFFFFFFFFFFFBCE6FAADA7179E84F3B9CAC2FC632551;

    AccessManager internal manager;
    TimelockController internal timelock;
    KeyRegistry internal registry;
    SettlementToken internal cash;
    SettlementToken internal asset;
    SettlementToken internal tokenImpl;
    DvP internal dvp;
    ECDSAVerifier internal ecdsaV;
    ERC7913P256Verifier internal p256V;
    HybridVerifier internal hybridClassicalV; // ECDSA + P-256, used where no PQ fixture is needed

    address internal governance = makeAddr("governance-multisig");
    address internal issuer = makeAddr("issuer");
    address internal compliance = makeAddr("compliance");
    address internal pauser = makeAddr("pauser");
    address internal registrar = makeAddr("registrar");
    address internal relayer = makeAddr("relayer");

    uint256 internal alicePk = uint256(keccak256("TEST KEY alice"));
    uint256 internal bobPk = uint256(keccak256("TEST KEY bob"));
    address internal alice;
    address internal bob;

    function _deploySystem() internal {
        alice = vm.addr(alicePk);
        bob = vm.addr(bobPk);

        manager = new AccessManager(address(this));
        address[] memory gov = new address[](1);
        gov[0] = governance;
        timelock = new TimelockController(TIMELOCK_DELAY, gov, gov, address(0));

        registry = new KeyRegistry(address(manager));
        tokenImpl = new SettlementToken();
        cash = _newToken("Tokenised Deposit EUR", "tdEUR");
        asset = _newToken("Tokenised Bond", "tBOND");
        dvp = new DvP(registry);

        ecdsaV = new ECDSAVerifier();
        p256V = new ERC7913P256Verifier();
        hybridClassicalV = new HybridVerifier(ecdsaV, p256V);

        _wire(address(cash));
        _wire(address(asset));
        _restrict(address(registry), KeyRegistry.setVerifierStatus.selector, CRYPTO_GOV);
        _restrict(address(registry), KeyRegistry.registerKeyFor.selector, REGISTRAR);

        manager.grantRole(ISSUER, issuer, 0);
        manager.grantRole(COMPLIANCE, compliance, 0);
        manager.grantRole(PAUSER, pauser, 0);
        manager.grantRole(SETTLEMENT, address(dvp), 0);
        manager.grantRole(REGISTRAR, registrar, 0);
        manager.grantRole(UPGRADER, address(timelock), 0);
        manager.grantRole(CRYPTO_GOV, address(timelock), 0);

        // Hand the manager itself to the timelock; the deployer keeps nothing.
        manager.grantRole(manager.ADMIN_ROLE(), address(timelock), 0);
        manager.renounceRole(manager.ADMIN_ROLE(), address(this));

        _approveVerifier(address(ecdsaV));
        _approveVerifier(address(p256V));
        _approveVerifier(address(hybridClassicalV));

        _onboard(alice, address(ecdsaV), abi.encodePacked(alice));
        _onboard(bob, address(ecdsaV), abi.encodePacked(bob));
    }

    function _newToken(string memory name, string memory symbol) internal returns (SettlementToken) {
        bytes memory init = abi.encodeCall(SettlementToken.initialize, (name, symbol, address(manager), registry));
        return SettlementToken(address(new ERC1967Proxy(address(tokenImpl), init)));
    }

    function _wire(address token) private {
        _restrict(token, SettlementToken.mint.selector, ISSUER);
        _restrict(token, SettlementToken.burn.selector, ISSUER);
        _restrict(token, SettlementToken.setAllowed.selector, COMPLIANCE);
        _restrict(token, SettlementToken.setFrozen.selector, COMPLIANCE);
        _restrict(token, SettlementToken.pause.selector, PAUSER);
        _restrict(token, SettlementToken.unpause.selector, PAUSER);
        _restrict(token, SettlementToken.settlementTransfer.selector, SETTLEMENT);
        _restrict(token, UUPSUpgradeable.upgradeToAndCall.selector, UPGRADER);
    }

    function _restrict(address target, bytes4 selector, uint64 role) private {
        bytes4[] memory s = new bytes4[](1);
        s[0] = selector;
        manager.setTargetFunctionRole(target, s, role);
    }

    // ------------------------------------------------------------ governance helpers

    /// @dev Runs `data` on `target` through the timelock: schedule, wait the full delay, execute.
    function _viaTimelock(address target, bytes memory data) internal {
        bytes32 salt = keccak256(abi.encode(target, data, block.timestamp));
        vm.prank(governance);
        timelock.schedule(target, 0, data, bytes32(0), salt, TIMELOCK_DELAY);
        vm.warp(block.timestamp + TIMELOCK_DELAY);
        vm.prank(governance);
        timelock.execute(target, 0, data, bytes32(0), salt);
    }

    function _approveVerifier(address verifier) internal {
        _setStatus(verifier, KeyRegistry.VerifierStatus.Approved);
    }

    function _setStatus(address verifier, KeyRegistry.VerifierStatus status) internal {
        _viaTimelock(address(registry), abi.encodeCall(KeyRegistry.setVerifierStatus, (verifier, status)));
    }

    function _onboard(address account, address verifier, bytes memory key) internal {
        vm.prank(registrar);
        registry.registerKeyFor(account, verifier, key);
        vm.startPrank(compliance);
        cash.setAllowed(account, true);
        asset.setAllowed(account, true);
        vm.stopPrank();
    }

    function _mint(SettlementToken token, address to, uint256 amount) internal {
        vm.prank(issuer);
        token.mint(to, amount);
    }

    // ------------------------------------------------------------ signing helpers

    function _signECDSA(uint256 pk, bytes32 digest) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function _p256Key(uint256 pk) internal pure returns (bytes memory) {
        (uint256 x, uint256 y) = vm.publicKeyP256(pk);
        return abi.encodePacked(x, y);
    }

    /// @dev Normalises to low-s, which OpenZeppelin's P256 library requires.
    function _signP256(uint256 pk, bytes32 digest) internal pure returns (bytes memory) {
        (bytes32 r, bytes32 s) = vm.signP256(pk, digest);
        if (uint256(s) > P256_N / 2) s = bytes32(P256_N - uint256(s));
        return abi.encodePacked(r, s);
    }

    function _transferSig(SettlementToken token, uint256 pk, address from, address to, uint256 value, bytes32 nonce)
        internal
        view
        returns (bytes memory)
    {
        return _signECDSA(pk, token.transferDigest(from, to, value, 0, type(uint256).max, nonce));
    }

    function _order(uint256 assetAmount, uint256 cashAmount, bytes32 nonce) internal view returns (DvP.Order memory) {
        return DvP.Order(alice, bob, asset, assetAmount, cash, cashAmount, block.timestamp + 1 hours, nonce);
    }
}
