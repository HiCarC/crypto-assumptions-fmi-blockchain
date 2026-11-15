// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {AccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC7913SignatureVerifier} from "@openzeppelin/contracts/interfaces/IERC7913.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {KeyRegistry} from "../src/KeyRegistry.sol";
import {SettlementToken} from "../src/SettlementToken.sol";
import {DvP} from "../src/DvP.sol";

/// @dev Stands in for the cryptography: a signature is "valid" iff it is exactly the
///      bytes this verifier was told to accept for that key. Symbolic execution cannot
///      reason about real elliptic-curve arithmetic, and the properties below are about
///      what the contracts do with the verifier's answer, not about the curve.
contract OracleVerifier is IERC7913SignatureVerifier {
    function verify(bytes calldata key, bytes32, bytes calldata signature) external pure returns (bytes4) {
        return keccak256(key) == keccak256(signature) ? IERC7913SignatureVerifier.verify.selector : bytes4(0xffffffff);
    }
}

/// @notice Symbolic checks (run with `halmos`; functions are prefixed `check_`).
///         Each holds for ALL values of its parameters within the stated bounds, not for
///         sampled values as in fuzzing.
contract HalmosChecks is Test {
    bytes32 internal constant IMPL_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    AccessManager internal manager;
    KeyRegistry internal registry;
    SettlementToken internal cash;
    SettlementToken internal asset;
    SettlementToken internal impl;
    DvP internal dvp;
    OracleVerifier internal verifier;

    address internal constant ALICE = address(0xA11CE);
    address internal constant BOB = address(0xB0B);
    address internal constant ISSUER = address(0x1551);
    bytes internal constant ALICE_SIG = hex"a11ce0";
    bytes internal constant BOB_SIG = hex"b0b000";

    function setUp() public {
        manager = new AccessManager(address(this));
        registry = new KeyRegistry(address(manager));
        impl = new SettlementToken();
        cash = _token("cash");
        asset = _token("asset");
        dvp = new DvP(registry);
        verifier = new OracleVerifier();

        _role(address(cash), SettlementToken.mint.selector, 1);
        _role(address(asset), SettlementToken.mint.selector, 1);
        _role(address(cash), SettlementToken.settlementTransfer.selector, 4);
        _role(address(asset), SettlementToken.settlementTransfer.selector, 4);
        manager.grantRole(1, ISSUER, 0);
        manager.grantRole(4, address(dvp), 0);
        // every other restricted function stays admin-only; this contract is the admin

        registry.setVerifierStatus(address(verifier), KeyRegistry.VerifierStatus.Approved);
        registry.registerKeyFor(ALICE, address(verifier), ALICE_SIG);
        registry.registerKeyFor(BOB, address(verifier), BOB_SIG);
        for (uint256 i = 0; i < 2; i++) {
            SettlementToken t = i == 0 ? cash : asset;
            t.setAllowed(ALICE, true);
            t.setAllowed(BOB, true);
        }
        vm.startPrank(ISSUER);
        cash.mint(ALICE, 1_000);
        cash.mint(BOB, 1_000);
        asset.mint(ALICE, 1_000);
        vm.stopPrank();
    }

    function _token(string memory n) private returns (SettlementToken) {
        return SettlementToken(
            address(new ERC1967Proxy(address(impl), abi.encodeCall(SettlementToken.initialize, (n, n, address(manager), registry))))
        );
    }

    function _role(address target, bytes4 sel, uint64 role) private {
        bytes4[] memory s = new bytes4[](1);
        s[0] = sel;
        manager.setTargetFunctionRole(target, s, role);
    }

    /// P1. No valid signature, no movement: an authorisation carrying anything other than
    ///     the signer's valid signature never changes a balance.
    function check_noValidSignatureNoTransfer(
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        bytes3 sig
    ) public {
        vm.assume(keccak256(abi.encodePacked(sig)) != keccak256(ALICE_SIG));
        uint256 before = cash.balanceOf(ALICE);
        (bool ok,) = address(cash).call(
            abi.encodeCall(
                SettlementToken.transferWithAuthorization,
                (ALICE, to, value, validAfter, validBefore, nonce, abi.encodePacked(sig))
            )
        );
        assert(!ok);
        assert(cash.balanceOf(ALICE) == before);
    }

    /// P2. An authorisation is single-use: once (from, nonce) has been accepted, no second
    ///     call with that pair succeeds, whatever its other fields.
    function check_nonceIsSingleUse(address to1, uint256 v1, address to2, uint256 v2, uint256 vb2, bytes32 nonce)
        public
    {
        (bool first,) = address(cash).call(
            abi.encodeCall(
                SettlementToken.transferWithAuthorization, (ALICE, to1, v1, 0, type(uint256).max, nonce, ALICE_SIG)
            )
        );
        vm.assume(first);
        (bool second,) = address(cash).call(
            abi.encodeCall(SettlementToken.transferWithAuthorization, (ALICE, to2, v2, 0, vb2, nonce, ALICE_SIG))
        );
        assert(!second);
    }

    /// P3. Delivery versus payment is atomic: for all amounts, deadlines and signatures,
    ///     settlement either moves exactly both legs or changes nothing.
    function check_dvpIsAtomic(uint256 assetAmount, uint256 cashAmount, uint256 deadline, bytes32 nonce, bytes3 sSig, bytes3 bSig)
        public
    {
        DvP.Order memory o = DvP.Order(ALICE, BOB, asset, assetAmount, cash, cashAmount, deadline, nonce);
        uint256 aA = asset.balanceOf(ALICE);
        uint256 aB = asset.balanceOf(BOB);
        uint256 cA = cash.balanceOf(ALICE);
        uint256 cB = cash.balanceOf(BOB);
        (bool ok,) =
            address(dvp).call(abi.encodeCall(DvP.settle, (o, abi.encodePacked(sSig), abi.encodePacked(bSig))));
        if (ok) {
            assert(keccak256(abi.encodePacked(sSig)) == keccak256(ALICE_SIG));
            assert(keccak256(abi.encodePacked(bSig)) == keccak256(BOB_SIG));
            assert(asset.balanceOf(ALICE) == aA - assetAmount && asset.balanceOf(BOB) == aB + assetAmount);
            assert(cash.balanceOf(BOB) == cB - cashAmount && cash.balanceOf(ALICE) == cA + cashAmount);
        } else {
            assert(asset.balanceOf(ALICE) == aA && asset.balanceOf(BOB) == aB);
            assert(cash.balanceOf(ALICE) == cA && cash.balanceOf(BOB) == cB);
        }
        assert(asset.totalSupply() == 1_000 && cash.totalSupply() == 2_000);
    }

    /// P4. An outsider cannot use any privileged entry point: for every caller holding no
    ///     role, mint, burn, freeze, pause, operator transfer and upgrade all revert.
    function check_outsiderHasNoPrivilegedPower(address outsider, address a, uint256 n, bool flag) public {
        vm.assume(outsider != address(this) && outsider != ISSUER && outsider != address(dvp));
        vm.startPrank(outsider);
        bool ok;
        (ok,) = address(cash).call(abi.encodeCall(SettlementToken.mint, (a, n)));
        assert(!ok);
        (ok,) = address(cash).call(abi.encodeCall(SettlementToken.burn, (a, n)));
        assert(!ok);
        (ok,) = address(cash).call(abi.encodeCall(SettlementToken.setFrozen, (a, flag)));
        assert(!ok);
        (ok,) = address(cash).call(abi.encodeCall(SettlementToken.setAllowed, (a, flag)));
        assert(!ok);
        (ok,) = address(cash).call(abi.encodeCall(SettlementToken.pause, ()));
        assert(!ok);
        (ok,) = address(cash).call(abi.encodeCall(SettlementToken.settlementTransfer, (ALICE, a, n)));
        assert(!ok);
        (ok,) = address(cash).call(abi.encodeCall(UUPSUpgradeable.upgradeToAndCall, (a, "")));
        assert(!ok);
        vm.stopPrank();
        assert(address(uint160(uint256(vm.load(address(cash), IMPL_SLOT)))) == address(impl));
        assert(cash.totalSupply() == 2_000);
    }
}

/// @notice Vacuity controls. Each asserts the OPPOSITE of what the checks above rely on,
///         so Halmos MUST report a counterexample for every function here. If one of these
///         "passes", the corresponding property above was proved over an empty set of cases.
contract HalmosVacuity is HalmosChecks {
    function check_EXPECT_FAIL_validTransferIsReachable(uint256 v, bytes32 nonce) public {
        (bool ok,) = address(cash).call(
            abi.encodeCall(SettlementToken.transferWithAuthorization, (ALICE, BOB, v, 0, type(uint256).max, nonce, ALICE_SIG))
        );
        assert(!ok); // must fail: a correctly signed transfer does succeed
    }

    function check_EXPECT_FAIL_settlementIsReachable(uint256 a, uint256 c, uint256 deadline, bytes32 nonce) public {
        DvP.Order memory o = DvP.Order(ALICE, BOB, asset, a, cash, c, deadline, nonce);
        (bool ok,) = address(dvp).call(abi.encodeCall(DvP.settle, (o, ALICE_SIG, BOB_SIG)));
        assert(!ok); // must fail: a correctly signed order does settle
    }
}
