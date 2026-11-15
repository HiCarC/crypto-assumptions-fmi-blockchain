// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Fixture} from "./utils/Fixture.sol";
import {SettlementToken} from "../src/SettlementToken.sol";
import {KeyRegistry} from "../src/KeyRegistry.sol";
import {DvP} from "../src/DvP.sol";
import {HybridVerifier} from "../src/verifiers/HybridVerifier.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract KeyRegistryTest is Fixture {
    uint256 internal constant MAX = type(uint256).max;
    uint256 internal aliceP256 = uint256(keccak256("TEST KEY alice p256"));

    function setUp() public {
        _deploySystem();
        _mint(cash, alice, 1_000e18);
    }

    /// The agility claim: the scheme changes, the balance does not move, the old key stops working.
    function test_rotateFromSecp256k1ToP256WithoutTouchingBalances() public {
        bytes memory newKey = _p256Key(aliceP256);
        bytes32 digest = registry.rotationDigest(alice, address(p256V), newKey, 0);
        vm.prank(relayer);
        registry.rotateKey(alice, address(p256V), newKey, _signECDSA(alicePk, digest));

        assertEq(cash.balanceOf(alice), 1_000e18);
        (address verifier,) = registry.keyOf(alice);
        assertEq(verifier, address(p256V));

        bytes32 t = cash.transferDigest(alice, bob, 10e18, 0, MAX, "n1");
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 10e18, 0, MAX, "n1", _signECDSA(alicePk, t));

        cash.transferWithAuthorization(alice, bob, 10e18, 0, MAX, "n1", _signP256(aliceP256, t));
        assertEq(cash.balanceOf(bob), 10e18);
    }

    function test_rotationSignatureCannotBeReplayed() public {
        bytes memory newKey = _p256Key(aliceP256);
        bytes memory sig = _signECDSA(alicePk, registry.rotationDigest(alice, address(p256V), newKey, 0));
        registry.rotateKey(alice, address(p256V), newKey, sig);
        vm.expectRevert(KeyRegistry.InvalidRotationSignature.selector);
        registry.rotateKey(alice, address(p256V), newKey, sig);
    }

    function test_rotationNeedsCurrentKey() public {
        bytes memory newKey = abi.encodePacked(bob);
        bytes memory sig = _signECDSA(bobPk, registry.rotationDigest(alice, address(ecdsaV), newKey, 0));
        vm.expectRevert(KeyRegistry.InvalidRotationSignature.selector);
        registry.rotateKey(alice, address(ecdsaV), newKey, sig);
    }

    function test_deprecatedSchemeStillVerifiesButAcceptsNoNewKeys() public {
        _setStatus(address(ecdsaV), KeyRegistry.VerifierStatus.Deprecated);

        cash.transferWithAuthorization(alice, bob, 1, 0, MAX, "n1", _transferSig(cash, alicePk, alice, bob, 1, "n1"));

        vm.prank(registrar);
        vm.expectRevert(abi.encodeWithSelector(KeyRegistry.VerifierNotApproved.selector, address(ecdsaV)));
        registry.registerKeyFor(makeAddr("new"), address(ecdsaV), abi.encodePacked(makeAddr("new")));

        // A participant on the deprecated scheme can still sign its own way out.
        bytes memory newKey = _p256Key(aliceP256);
        registry.rotateKey(
            alice, address(p256V), newKey, _signECDSA(alicePk, registry.rotationDigest(alice, address(p256V), newKey, 0))
        );
    }

    /// What happens to holders who never migrate: funds stay, signatures stop, the registrar is the way back.
    function test_disallowedSchemeStrandsSignaturesNotBalances() public {
        _setStatus(address(ecdsaV), KeyRegistry.VerifierStatus.Deprecated);
        _setStatus(address(ecdsaV), KeyRegistry.VerifierStatus.Disallowed);

        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 1, "n1");
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 1, 0, MAX, "n1", sig);
        assertEq(cash.balanceOf(alice), 1_000e18, "balance untouched");

        bytes memory newKey = _p256Key(aliceP256);
        bytes memory rot = _signECDSA(alicePk, registry.rotationDigest(alice, address(p256V), newKey, 0));
        vm.expectRevert(KeyRegistry.InvalidRotationSignature.selector);
        registry.rotateKey(alice, address(p256V), newKey, rot);

        vm.prank(registrar);
        registry.registerKeyFor(alice, address(p256V), newKey);
        bytes32 t = cash.transferDigest(alice, bob, 1, 0, MAX, "n2");
        cash.transferWithAuthorization(alice, bob, 1, 0, MAX, "n2", _signP256(aliceP256, t));
    }

    function test_statusOnlyMovesForward() public {
        _setStatus(address(ecdsaV), KeyRegistry.VerifierStatus.Disallowed);
        bytes memory back = abi.encodeCall(
            KeyRegistry.setVerifierStatus, (address(ecdsaV), KeyRegistry.VerifierStatus.Approved)
        );
        vm.prank(governance);
        timelock.schedule(address(registry), 0, back, bytes32(0), "s", TIMELOCK_DELAY);
        vm.warp(block.timestamp + TIMELOCK_DELAY);
        vm.prank(governance);
        vm.expectRevert(
            abi.encodeWithSelector(
                KeyRegistry.StatusMustAdvance.selector,
                KeyRegistry.VerifierStatus.Disallowed,
                KeyRegistry.VerifierStatus.Approved
            )
        );
        timelock.execute(address(registry), 0, back, bytes32(0), "s");
    }

    function test_unapprovedVerifierAndEmptyKeyRejected() public {
        vm.startPrank(registrar);
        vm.expectRevert(abi.encodeWithSelector(KeyRegistry.VerifierNotApproved.selector, address(0xBEEF)));
        registry.registerKeyFor(alice, address(0xBEEF), hex"01");
        vm.expectRevert(KeyRegistry.EmptyKey.selector);
        registry.registerKeyFor(alice, address(ecdsaV), "");
        vm.stopPrank();
    }

    function test_hybridNeedsBothSignatures() public {
        bytes memory key = abi.encode(abi.encodePacked(alice), _p256Key(aliceP256));
        vm.prank(registrar);
        registry.registerKeyFor(alice, address(hybridClassicalV), key);

        bytes32 t = cash.transferDigest(alice, bob, 5, 0, MAX, "n1");
        bytes memory good = abi.encode(_signECDSA(alicePk, t), _signP256(aliceP256, t));
        bytes memory onlyFirst = abi.encode(_signECDSA(alicePk, t), _signP256(bobPk, t));
        bytes memory onlySecond = abi.encode(_signECDSA(bobPk, t), _signP256(aliceP256, t));

        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 5, 0, MAX, "n1", onlyFirst);
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 5, 0, MAX, "n1", onlySecond);
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 5, 0, MAX, "n1", _signECDSA(alicePk, t));
        cash.transferWithAuthorization(alice, bob, 5, 0, MAX, "n1", good);
        assertEq(cash.balanceOf(bob), 5);
    }

    function test_hybridRejectsIdenticalComponents() public {
        vm.expectRevert(HybridVerifier.SameVerifier.selector);
        new HybridVerifier(ecdsaV, ecdsaV);
    }

    function test_verifiersRejectMalformedInput() public view {
        bytes32 h = keccak256("h");
        assertEq(ecdsaV.verify(hex"", h, new bytes(65)), bytes4(0xffffffff));
        assertEq(ecdsaV.verify(abi.encodePacked(alice), h, new bytes(64)), bytes4(0xffffffff));
        assertEq(ecdsaV.verify(abi.encodePacked(address(0)), h, new bytes(65)), bytes4(0xffffffff));
        assertFalse(registry.isValidSignature(alice, h, hex"deadbeef"));
    }
}

contract DvPTest is Fixture {
    function setUp() public {
        _deploySystem();
        _mint(asset, alice, 100e18);
        _mint(cash, bob, 5_000e18);
    }

    function _sigs(DvP.Order memory o) internal view returns (bytes memory s, bytes memory b) {
        bytes32 d = dvp.orderDigest(o);
        return (_signECDSA(alicePk, d), _signECDSA(bobPk, d));
    }

    function test_settleMovesBothLegs() public {
        DvP.Order memory o = _order(10e18, 1_000e18, "o1");
        (bytes memory s, bytes memory b) = _sigs(o);
        vm.prank(relayer);
        dvp.settle(o, s, b);
        assertEq(asset.balanceOf(bob), 10e18);
        assertEq(asset.balanceOf(alice), 90e18);
        assertEq(cash.balanceOf(alice), 1_000e18);
        assertEq(cash.balanceOf(bob), 4_000e18);
    }

    function test_cashLegFailureUnwindsAssetLeg() public {
        DvP.Order memory o = _order(10e18, 6_000e18, "o1"); // buyer holds only 5,000
        (bytes memory s, bytes memory b) = _sigs(o);
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, bob, 5_000e18, 6_000e18)
        );
        dvp.settle(o, s, b);
        assertEq(asset.balanceOf(alice), 100e18);
        assertEq(asset.balanceOf(bob), 0);
    }

    function test_frozenBuyerBlocksWholeSettlement() public {
        DvP.Order memory o = _order(10e18, 1_000e18, "o1");
        (bytes memory s, bytes memory b) = _sigs(o);
        vm.prank(compliance);
        cash.setFrozen(bob, true);
        vm.expectRevert(abi.encodeWithSelector(SettlementToken.AccountFrozen.selector, bob));
        dvp.settle(o, s, b);
        assertEq(asset.balanceOf(alice), 100e18);
    }

    function test_replayReverts() public {
        DvP.Order memory o = _order(10e18, 1_000e18, "o1");
        (bytes memory s, bytes memory b) = _sigs(o);
        dvp.settle(o, s, b);
        vm.expectRevert(DvP.OrderAlreadySettled.selector);
        dvp.settle(o, s, b);
    }

    function test_signaturesAreNotInterchangeable() public {
        DvP.Order memory o = _order(10e18, 1_000e18, "o1");
        (bytes memory s, bytes memory b) = _sigs(o);
        vm.expectRevert(DvP.InvalidSellerSignature.selector);
        dvp.settle(o, b, b);
        vm.expectRevert(DvP.InvalidBuyerSignature.selector);
        dvp.settle(o, s, s);
    }

    function test_alteredTermsRevert() public {
        DvP.Order memory o = _order(10e18, 1_000e18, "o1");
        (bytes memory s, bytes memory b) = _sigs(o);
        o.cashAmount = 1;
        vm.expectRevert(DvP.InvalidSellerSignature.selector);
        dvp.settle(o, s, b);
    }

    function test_expiredAndSelfDealingOrdersRevert() public {
        DvP.Order memory o = _order(10e18, 1_000e18, "o1");
        (bytes memory s, bytes memory b) = _sigs(o);
        vm.warp(o.deadline + 1);
        vm.expectRevert(DvP.OrderExpired.selector);
        dvp.settle(o, s, b);

        vm.warp(o.deadline);
        o.buyer = alice;
        vm.expectRevert(DvP.SameParty.selector);
        dvp.settle(o, s, s);
    }

    function test_partiesMayUseDifferentSchemes() public {
        uint256 bobP256 = uint256(keccak256("TEST KEY bob p256"));
        vm.prank(registrar);
        registry.registerKeyFor(bob, address(p256V), _p256Key(bobP256));
        DvP.Order memory o = _order(10e18, 1_000e18, "o1");
        bytes32 d = dvp.orderDigest(o);
        dvp.settle(o, _signECDSA(alicePk, d), _signP256(bobP256, d));
        assertEq(asset.balanceOf(bob), 10e18);
    }

    function test_pausedTokenBlocksSettlement() public {
        DvP.Order memory o = _order(10e18, 1_000e18, "o1");
        (bytes memory s, bytes memory b) = _sigs(o);
        vm.prank(pauser);
        cash.pause();
        vm.expectRevert();
        dvp.settle(o, s, b);
        assertEq(asset.balanceOf(alice), 100e18);
    }

    function testFuzz_settlementConservesSupplyAndIsAtomic(uint256 a, uint256 c, bytes32 nonce) public {
        a = bound(a, 0, 200e18);
        c = bound(c, 0, 10_000e18);
        DvP.Order memory o = _order(a, c, nonce);
        (bytes memory s, bytes memory b) = _sigs(o);
        bool shouldSettle = a <= 100e18 && c <= 5_000e18;
        if (!shouldSettle) vm.expectRevert();
        dvp.settle(o, s, b);
        assertEq(asset.balanceOf(bob), shouldSettle ? a : 0);
        assertEq(cash.balanceOf(alice), shouldSettle ? c : 0);
        assertEq(asset.totalSupply(), 100e18);
        assertEq(cash.totalSupply(), 5_000e18);
    }
}
