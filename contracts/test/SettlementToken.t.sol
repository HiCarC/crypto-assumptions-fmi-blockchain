// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Fixture} from "./utils/Fixture.sol";
import {SettlementToken} from "../src/SettlementToken.sol";
import {KeyRegistry} from "../src/KeyRegistry.sol";
import {IAccessManaged} from "@openzeppelin/contracts/access/manager/IAccessManaged.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract SettlementTokenV2 is SettlementToken {
    function version() external pure returns (uint256) {
        return 2;
    }
}

contract SettlementTokenTest is Fixture {
    uint256 internal constant MAX = type(uint256).max;

    function setUp() public {
        _deploySystem();
        _mint(cash, alice, 1_000e18);
    }

    // ------------------------------------------------------------ signed transfers

    function test_transferWithAuthorization() public {
        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 100e18, "n1");
        vm.prank(relayer);
        cash.transferWithAuthorization(alice, bob, 100e18, 0, MAX, "n1", sig);
        assertEq(cash.balanceOf(bob), 100e18);
        assertEq(cash.balanceOf(alice), 900e18);
        assertTrue(cash.authorizationState(alice, "n1"));
    }

    function test_replaySameNonceReverts() public {
        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 100e18, "n1");
        cash.transferWithAuthorization(alice, bob, 100e18, 0, MAX, "n1", sig);
        vm.expectRevert(SettlementToken.AuthorizationAlreadyUsed.selector);
        cash.transferWithAuthorization(alice, bob, 100e18, 0, MAX, "n1", sig);
    }

    function test_replayOnOtherChainReverts() public {
        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 100e18, "n1");
        vm.chainId(block.chainid + 1);
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 100e18, 0, MAX, "n1", sig);
    }

    function test_replayOnOtherTokenReverts() public {
        _mint(asset, alice, 1_000e18);
        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 100e18, "n1");
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        asset.transferWithAuthorization(alice, bob, 100e18, 0, MAX, "n1", sig);
    }

    function test_wrongSignerReverts() public {
        bytes memory sig = _transferSig(cash, bobPk, alice, bob, 100e18, "n1");
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 100e18, 0, MAX, "n1", sig);
    }

    function test_alteredAmountReverts() public {
        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 100e18, "n1");
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 101e18, 0, MAX, "n1", sig);
    }

    function test_validityWindow() public {
        vm.warp(1_000_000);
        bytes memory sig = _signECDSA(alicePk, cash.transferDigest(alice, bob, 1, 2_000_000, 3_000_000, "n"));
        vm.expectRevert(SettlementToken.AuthorizationNotYetValid.selector);
        cash.transferWithAuthorization(alice, bob, 1, 2_000_000, 3_000_000, "n", sig);
        vm.warp(3_000_000);
        vm.expectRevert(SettlementToken.AuthorizationExpired.selector);
        cash.transferWithAuthorization(alice, bob, 1, 2_000_000, 3_000_000, "n", sig);
        vm.warp(2_500_000);
        cash.transferWithAuthorization(alice, bob, 1, 2_000_000, 3_000_000, "n", sig);
    }

    function test_unregisteredAccountCannotAuthorize() public {
        uint256 pk = uint256(keccak256("TEST KEY stranger"));
        address stranger = vm.addr(pk);
        bytes memory sig = _transferSig(cash, pk, stranger, bob, 0, "n");
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(stranger, bob, 0, 0, MAX, "n", sig);
    }

    function testFuzz_authorizedTransfer(uint256 amount, bytes32 nonce) public {
        amount = bound(amount, 0, 1_000e18);
        bytes memory sig = _transferSig(cash, alicePk, alice, bob, amount, nonce);
        cash.transferWithAuthorization(alice, bob, amount, 0, MAX, nonce, sig);
        assertEq(cash.balanceOf(bob), amount);
        assertEq(cash.totalSupply(), 1_000e18);
    }

    function testFuzz_corruptedSignatureRejected(uint8 index, uint8 flip) public {
        vm.assume(flip != 0);
        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 1e18, "n1");
        sig[index % sig.length] = bytes1(uint8(sig[index % sig.length]) ^ flip);
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 1e18, 0, MAX, "n1", sig);
    }

    // ------------------------------------------------------------ freeze, allow-list, pause

    function test_freezeBlocksBothDirectionsAndBurnClawsBack() public {
        vm.prank(compliance);
        cash.setFrozen(alice, true);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(SettlementToken.AccountFrozen.selector, alice));
        cash.transfer(bob, 1);

        _mint(cash, bob, 5);
        vm.prank(bob);
        vm.expectRevert(abi.encodeWithSelector(SettlementToken.AccountFrozen.selector, alice));
        cash.transfer(alice, 1);

        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 1, "n");
        vm.expectRevert(abi.encodeWithSelector(SettlementToken.AccountFrozen.selector, alice));
        cash.transferWithAuthorization(alice, bob, 1, 0, MAX, "n", sig);

        vm.prank(issuer);
        cash.burn(alice, 1_000e18); // claw-back path
        assertEq(cash.balanceOf(alice), 0);
    }

    /// Added after mutation testing: a freeze must be reversible by the same role.
    function test_unfreezeRestoresTransfers() public {
        vm.startPrank(compliance);
        cash.setFrozen(alice, true);
        cash.setFrozen(alice, false);
        vm.stopPrank();
        assertFalse(cash.isFrozen(alice));
        vm.prank(alice);
        cash.transfer(bob, 1);
        assertEq(cash.balanceOf(bob), 1);
    }

    /// Added after mutation testing: metadata is part of the EIP-712 domain participants sign.
    function test_metadataAndSigningDomain() public view {
        assertEq(cash.name(), "Tokenised Deposit EUR");
        assertEq(cash.symbol(), "tdEUR");
        (, string memory domainName,, uint256 chainId, address verifying,,) = cash.eip712Domain();
        assertEq(domainName, "Tokenised Deposit EUR");
        assertEq(chainId, block.chainid);
        assertEq(verifying, address(cash));
    }

    function test_onlyAllowListedPartiesCanHold() public {
        address outsider = makeAddr("outsider");
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(SettlementToken.NotAllowed.selector, outsider));
        cash.transfer(outsider, 1);
        vm.prank(issuer);
        vm.expectRevert(abi.encodeWithSelector(SettlementToken.NotAllowed.selector, outsider));
        cash.mint(outsider, 1);
    }

    function test_delistedSenderCannotMoveButIssuerCanRedeem() public {
        assertEq(address(cash.registry()), address(registry));
        vm.prank(compliance);
        cash.setAllowed(alice, false);
        assertFalse(cash.isAllowed(alice));
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(SettlementToken.NotAllowed.selector, alice));
        cash.transfer(bob, 1);
        vm.prank(issuer);
        cash.burn(alice, 1_000e18);
        assertEq(cash.totalSupply(), 0);
    }

    function test_pauseStopsEveryMovement() public {
        vm.prank(pauser);
        cash.pause();
        bytes4 paused = PausableUpgradeable.EnforcedPause.selector;

        vm.prank(alice);
        vm.expectRevert(paused);
        cash.transfer(bob, 1);

        bytes memory sig = _transferSig(cash, alicePk, alice, bob, 1, "n");
        vm.expectRevert(paused);
        cash.transferWithAuthorization(alice, bob, 1, 0, MAX, "n", sig);

        vm.startPrank(issuer);
        vm.expectRevert(paused);
        cash.mint(alice, 1);
        vm.expectRevert(paused);
        cash.burn(alice, 1);
        vm.stopPrank();

        vm.prank(address(dvp));
        vm.expectRevert(paused);
        cash.settlementTransfer(alice, bob, 1);

        vm.prank(pauser);
        cash.unpause();
        vm.prank(alice);
        cash.transfer(bob, 1);
    }

    // ------------------------------------------------------------ access control

    function test_restrictedFunctionsRejectOutsiders() public {
        address eve = makeAddr("eve");
        bytes memory unauthorized = abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, eve);
        vm.startPrank(eve);
        vm.expectRevert(unauthorized);
        cash.mint(eve, 1);
        vm.expectRevert(unauthorized);
        cash.burn(alice, 1);
        vm.expectRevert(unauthorized);
        cash.setFrozen(alice, true);
        vm.expectRevert(unauthorized);
        cash.setAllowed(eve, true);
        vm.expectRevert(unauthorized);
        cash.pause();
        vm.expectRevert(unauthorized);
        cash.settlementTransfer(alice, eve, 1);
        vm.expectRevert(unauthorized);
        cash.upgradeToAndCall(address(1), "");
        vm.expectRevert(unauthorized);
        registry.setVerifierStatus(address(ecdsaV), KeyRegistry.VerifierStatus.Disallowed);
        vm.expectRevert(unauthorized);
        registry.registerKeyFor(alice, address(ecdsaV), abi.encodePacked(eve));
        vm.stopPrank();
    }

    function test_rolesDoNotLeakAcrossPowers() public {
        // The freeze key cannot mint; the issuer cannot freeze; neither can upgrade.
        vm.prank(compliance);
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, compliance));
        cash.mint(alice, 1);
        vm.prank(issuer);
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, issuer));
        cash.setFrozen(alice, true);
        vm.prank(governance); // even the governance multisig must go through the timelock
        vm.expectRevert(abi.encodeWithSelector(IAccessManaged.AccessManagedUnauthorized.selector, governance));
        cash.upgradeToAndCall(address(1), "");
    }

    // ------------------------------------------------------------ upgrades

    function test_upgradeOnlyThroughTimelockAfterDelay() public {
        address v2 = address(new SettlementTokenV2());
        bytes memory data = abi.encodeCall(UUPSUpgradeable.upgradeToAndCall, (v2, ""));

        vm.prank(governance);
        timelock.schedule(address(cash), 0, data, bytes32(0), "salt", TIMELOCK_DELAY);

        vm.warp(block.timestamp + TIMELOCK_DELAY - 1);
        vm.prank(governance);
        vm.expectRevert(); // TimelockUnexpectedOperationState: not ready yet
        timelock.execute(address(cash), 0, data, bytes32(0), "salt");

        vm.warp(block.timestamp + 1);
        vm.prank(governance);
        timelock.execute(address(cash), 0, data, bytes32(0), "salt");

        assertEq(SettlementTokenV2(address(cash)).version(), 2);
        assertEq(cash.balanceOf(alice), 1_000e18, "balances survive the upgrade");
        assertTrue(cash.isAllowed(alice), "allow-list survives the upgrade");
    }

    function test_timelockRejectsShortDelayAndStrangers() public {
        bytes memory data = abi.encodeCall(UUPSUpgradeable.upgradeToAndCall, (address(1), ""));
        vm.prank(governance);
        vm.expectRevert(); // TimelockInsufficientDelay
        timelock.schedule(address(cash), 0, data, bytes32(0), "salt", TIMELOCK_DELAY - 1);
        vm.prank(makeAddr("eve"));
        vm.expectRevert(); // missing PROPOSER_ROLE
        timelock.schedule(address(cash), 0, data, bytes32(0), "salt", TIMELOCK_DELAY);
    }

    function test_implementationAndProxyCannotBeReinitialised() public {
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        tokenImpl.initialize("x", "x", address(manager), registry);
        vm.expectRevert(Initializable.InvalidInitialization.selector);
        cash.initialize("x", "x", address(manager), registry);
    }

    function test_deployerKeepsNoPower() public view {
        (bool isAdmin,) = manager.hasRole(manager.ADMIN_ROLE(), address(this));
        assertFalse(isAdmin);
        (bool timelockIsAdmin,) = manager.hasRole(manager.ADMIN_ROLE(), address(timelock));
        assertTrue(timelockIsAdmin);
    }
}
