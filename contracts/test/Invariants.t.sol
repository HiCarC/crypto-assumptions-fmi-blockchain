// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Fixture} from "./utils/Fixture.sol";
import {SettlementToken} from "../src/SettlementToken.sol";
import {DvP} from "../src/DvP.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

/// @notice Drives the system with random sequences of honest and hostile actions and
///         records any outcome that should be impossible.
contract Handler is Fixture {
    uint256 public mintedCash;
    uint256 public burnedCash;
    uint256 public mintedAsset;
    uint256 public burnedAsset;
    string public violation; // empty unless something impossible happened
    uint256 public settlements;
    uint256 public signedTransfers;
    uint256 public replaysTried;

    struct UsedAuth {
        address from;
        address to;
        uint256 value;
        bytes32 nonce;
        bytes sig;
    }

    UsedAuth[] internal usedAuths;
    DvP.Order[] internal usedOrders;
    bytes[2][] internal usedOrderSigs;
    uint256 internal nonceCounter;
    address[] internal actors;
    address internal eve = makeAddr("eve");

    constructor() {
        _deploySystem();
        actors.push(alice);
        actors.push(bob);
    }

    function expose() external view returns (SettlementToken, SettlementToken, address, address, address) {
        return (cash, asset, alice, bob, address(tokenImpl));
    }

    function _pk(address a) internal view returns (uint256) {
        return a == alice ? alicePk : bobPk;
    }

    function _flag(string memory what) internal {
        if (bytes(violation).length == 0) violation = what;
    }

    // ---------------------------------------------------------------- honest actions

    function mint(bool isCash, uint256 actorSeed, uint256 amount) external {
        amount = bound(amount, 0, 1e24);
        SettlementToken t = isCash ? cash : asset;
        address to = actors[actorSeed % 2];
        bool paused = t.paused();
        vm.prank(issuer);
        try t.mint(to, amount) {
            if (paused) _flag("mint succeeded while paused");
            if (isCash) mintedCash += amount;
            else mintedAsset += amount;
        } catch {}
    }

    function burn(bool isCash, uint256 actorSeed, uint256 amount) external {
        SettlementToken t = isCash ? cash : asset;
        address from = actors[actorSeed % 2];
        amount = bound(amount, 0, t.balanceOf(from));
        bool paused = t.paused();
        vm.prank(issuer);
        try t.burn(from, amount) {
            if (paused) _flag("burn succeeded while paused");
            if (isCash) burnedCash += amount;
            else burnedAsset += amount;
        } catch {}
    }

    function signedTransfer(bool isCash, uint256 actorSeed, uint256 amount) external {
        SettlementToken t = isCash ? cash : asset;
        address from = actors[actorSeed % 2];
        address to = actors[((actorSeed % 2) + 1) % 2];
        amount = bound(amount, 0, t.balanceOf(from));
        bytes32 nonce = bytes32(++nonceCounter);
        bytes memory sig = _transferSig(t, _pk(from), from, to, amount, nonce);
        bool blocked = t.paused() || t.isFrozen(from) || t.isFrozen(to);
        try t.transferWithAuthorization(from, to, amount, 0, type(uint256).max, nonce, sig) {
            if (blocked) _flag("signed transfer succeeded while paused or frozen");
            signedTransfers++;
            if (isCash) usedAuths.push(UsedAuth(from, to, amount, nonce, sig));
        } catch {}
    }

    function settle(uint256 assetAmount, uint256 cashAmount) external {
        assetAmount = bound(assetAmount, 0, asset.balanceOf(alice));
        cashAmount = bound(cashAmount, 0, cash.balanceOf(bob));
        DvP.Order memory o = _order(assetAmount, cashAmount, bytes32(++nonceCounter));
        bytes32 d = dvp.orderDigest(o);
        bytes memory s = _signECDSA(alicePk, d);
        bytes memory b = _signECDSA(bobPk, d);
        uint256[4] memory pre = [asset.balanceOf(alice), asset.balanceOf(bob), cash.balanceOf(alice), cash.balanceOf(bob)];
        bool blocked = cash.paused() || asset.paused();
        try dvp.settle(o, s, b) {
            if (blocked) _flag("settlement succeeded while a token was paused");
            if (asset.balanceOf(bob) != pre[1] + assetAmount || cash.balanceOf(alice) != pre[2] + cashAmount) {
                _flag("settlement moved the wrong amounts");
            }
            settlements++;
            usedOrders.push(o);
            usedOrderSigs.push([s, b]);
        } catch {
            if (
                asset.balanceOf(alice) != pre[0] || asset.balanceOf(bob) != pre[1] || cash.balanceOf(alice) != pre[2]
                    || cash.balanceOf(bob) != pre[3]
            ) _flag("failed settlement left one leg moved");
        }
    }

    function toggleFreeze(bool isCash, uint256 actorSeed, bool frozen) external {
        vm.prank(compliance);
        (isCash ? cash : asset).setFrozen(actors[actorSeed % 2], frozen);
    }

    function togglePause(bool isCash, bool pause_) external {
        SettlementToken t = isCash ? cash : asset;
        vm.prank(pauser);
        if (pause_) try t.pause() {} catch {}
        else try t.unpause() {} catch {}
    }

    function warp(uint256 secs) external {
        vm.warp(block.timestamp + bound(secs, 0, 30 minutes));
    }

    // ---------------------------------------------------------------- hostile actions

    function replayTransfer(uint256 i) external {
        if (usedAuths.length == 0) return;
        UsedAuth memory u = usedAuths[i % usedAuths.length];
        replaysTried++;
        try cash.transferWithAuthorization(u.from, u.to, u.value, 0, type(uint256).max, u.nonce, u.sig) {
            _flag("a used authorisation was accepted twice");
        } catch {}
        vm.chainId(block.chainid + 1); // same signature on another chain id
        try cash.transferWithAuthorization(u.from, u.to, u.value, 0, type(uint256).max, bytes32(++nonceCounter), u.sig) {
            _flag("an authorisation was accepted on another chain or nonce");
        } catch {}
        vm.chainId(block.chainid - 1);
        try asset.transferWithAuthorization(u.from, u.to, u.value, 0, type(uint256).max, u.nonce, u.sig) {
            _flag("an authorisation for one token was accepted by another");
        } catch {}
    }

    function replaySettlement(uint256 i) external {
        if (usedOrders.length == 0) return;
        uint256 k = i % usedOrders.length;
        try dvp.settle(usedOrders[k], usedOrderSigs[k][0], usedOrderSigs[k][1]) {
            _flag("an order settled twice");
        } catch {}
    }

    function outsiderTriesEverything(uint256 amount, address newImpl) external {
        vm.startPrank(eve);
        try cash.mint(eve, amount) {
            _flag("outsider minted");
        } catch {}
        try cash.settlementTransfer(alice, eve, amount) {
            _flag("outsider used the settlement operator path");
        } catch {}
        try cash.setFrozen(alice, true) {
            _flag("outsider froze an account");
        } catch {}
        try cash.upgradeToAndCall(newImpl, "") {
            _flag("outsider upgraded the token");
        } catch {}
        vm.stopPrank();
        vm.prank(governance); // the governance multisig acting directly, without the timelock
        try cash.upgradeToAndCall(newImpl, "") {
            _flag("upgrade bypassed the timelock");
        } catch {}
    }

    function forgedTransfer(uint256 amount, uint256 fakeKey) external {
        fakeKey = bound(fakeKey, 1, type(uint128).max);
        if (fakeKey == alicePk) return;
        amount = bound(amount, 1, 1e24);
        bytes32 nonce = bytes32(++nonceCounter);
        bytes memory sig = _transferSig(cash, fakeKey, alice, bob, amount, nonce);
        try cash.transferWithAuthorization(alice, bob, amount, 0, type(uint256).max, nonce, sig) {
            _flag("a signature from the wrong key moved funds");
        } catch {}
    }
}

contract InvariantsTest is Fixture {
    bytes32 internal constant IMPL_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    Handler internal h;
    SettlementToken internal c;
    SettlementToken internal a;
    address internal p1;
    address internal p2;
    address internal impl;

    function setUp() public {
        h = new Handler();
        (c, a, p1, p2, impl) = h.expose();
        targetContract(address(h));
    }

    /// Supply conservation: tokens exist only by mint and vanish only by burn.
    function invariant_supplyConservation() public view {
        assertEq(c.totalSupply(), h.mintedCash() - h.burnedCash());
        assertEq(a.totalSupply(), h.mintedAsset() - h.burnedAsset());
        assertEq(c.balanceOf(p1) + c.balanceOf(p2), c.totalSupply());
        assertEq(a.balanceOf(p1) + a.balanceOf(p2), a.totalSupply());
    }

    /// Covers: DvP atomicity, pause stops all movement, freeze holds, no replay across
    /// nonces/chains/tokens, no forged signature, no unauthorised privileged call.
    function invariant_nothingImpossibleHappened() public view {
        assertEq(h.violation(), "");
    }

    /// Only timelocked governance can change the code: no handler action has that power,
    /// so the implementation must never move.
    function invariant_implementationUnchanged() public view {
        assertEq(address(uint160(uint256(vm.load(address(c), IMPL_SLOT)))), impl);
        assertEq(address(uint160(uint256(vm.load(address(a), IMPL_SLOT)))), impl);
    }

    function afterInvariant() public view {
        // surfaced with -vv so a reader can see the run exercised real activity
        h.settlements();
    }
}
