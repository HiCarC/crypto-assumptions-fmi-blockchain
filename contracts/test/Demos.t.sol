// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CommonBase} from "forge-std/Base.sol";
import {VmSafe} from "forge-std/Vm.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "../src/demos/Vulnerable.sol";
import {Fixture} from "./utils/Fixture.sol";
import {SettlementToken} from "../src/SettlementToken.sol";

// Failure-mode demonstrations (Component D). Local test chain only; every contract under
// attack was written for this repository. For each: what broke, whether mathematics was
// involved, the control that prevents it, and the question that would have caught it.
// The same table is in docs/demos.md.

uint256 constant SECP256K1_N = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

/// ------------------------------------------------------------------------------------
/// 1. Signature replay.  Mathematics involved: none.
///    Control: bind every signed order to chain, contract and a single-use nonce
///    (EIP-712 domain + nonce), as SettlementToken.transferWithAuthorization does.
///    Question: "What makes each signed instruction unique, and where is that enforced?"
contract Demo1_Replay is Test {
    function test_oneSignatureDrainsTheVault() public {
        (address treasurer, uint256 pk) = makeAddrAndKey("TEST KEY treasurer");
        DemoToken t = new DemoToken();
        ReplayableVault vault = new ReplayableVault(t, treasurer);
        t.mint(address(vault), 1_000);
        address payee = makeAddr("payee");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, keccak256(abi.encodePacked(payee, uint256(100))));
        bytes memory sig = abi.encodePacked(r, s, v);

        for (uint256 i = 0; i < 10; i++) {
            vault.pay(payee, 100, sig); // the treasurer approved one payment of 100
        }
        assertEq(t.balanceOf(payee), 1_000);

        // The same signature also works on a second deployment (another chain, another vault).
        ReplayableVault vault2 = new ReplayableVault(t, treasurer);
        t.mint(address(vault2), 100);
        vault2.pay(payee, 100, sig);
        assertEq(t.balanceOf(address(vault2)), 0);
    }
}

/// ------------------------------------------------------------------------------------
/// 2. ECDSA malleability and ecrecover returning the zero address.
///    Mathematics involved: a known, documented property of ECDSA (if (r, s) is valid so
///    is (r, n - s)); nothing was broken.
///    Control: a maintained library that rejects high-s and the zero address, and replay
///    tracking keyed on the message, never on signature bytes.
///    Question: "Is signature checking done by an audited library, and what is the replay key?"
contract Demo2_MalleabilityAndZeroAddress is Test {
    DemoToken t;
    MalleableClaims c;
    address payee = makeAddr("payee");

    function setUp() public {
        t = new DemoToken();
        c = new MalleableClaims(t);
        t.mint(address(c), 1_000);
    }

    function test_flippedSignaturePaysTwice() public {
        (address signer, uint256 pk) = makeAddrAndKey("TEST KEY claims signer");
        c.setSigner(signer);
        bytes32 h = keccak256(abi.encode(address(c), block.chainid, payee, uint256(100), uint256(1)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, h);

        c.claim(payee, 100, 1, v, r, s);
        c.claim(payee, 100, 1, v == 27 ? 28 : 27, r, bytes32(SECP256K1_N - uint256(s))); // same order, second encoding
        assertEq(t.balanceOf(payee), 200);

        // The maintained library refuses the flipped form outright.
        (, ECDSA.RecoverError err,) = ECDSA.tryRecover(h, v == 27 ? 28 : 27, r, bytes32(SECP256K1_N - uint256(s)));
        assertEq(uint8(err), uint8(ECDSA.RecoverError.InvalidSignatureS));
    }

    function test_garbageSignatureMatchesUnsetSigner() public {
        // signer was never set, so it is the zero address; ecrecover returns zero for nonsense input
        c.claim(payee, 1_000, 7, 99, bytes32(uint256(1)), bytes32(uint256(1)));
        assertEq(t.balanceOf(payee), 1_000);
    }
}

/// ------------------------------------------------------------------------------------
/// 3a. Bybit pattern (February 2025): the signers' screen showed a routine transfer; the
///     bytes they signed were a DELEGATECALL that replaced the wallet's implementation.
///     Mathematics involved: none. Every signature was genuine.
///     Control: independent display of what is being signed, and an on-chain guard that
///     refuses DELEGATECALL to targets not approved in advance.
///     Question: "Can your signers see, on a device the web interface does not control,
///     exactly what they are authorising? Can the wallet be made to run foreign code?"
contract Demo3a_CompromisedSigningInterface is Test {
    DemoToken t;
    MiniMultisig wallet;
    uint256[] pks;
    address attacker = makeAddr("attacker");
    ImplementationSwapper swapper = new ImplementationSwapper();
    SweepLogic sweepLogic = new SweepLogic();

    function setUp() public {
        t = new DemoToken();
        address[] memory owners = new address[](3);
        for (uint256 i = 0; i < 3; i++) {
            (address a, uint256 pk) = makeAddrAndKey(string.concat("TEST KEY owner ", vm.toString(i)));
            owners[i] = a;
            pks.push(pk);
        }
        wallet = new MiniMultisig(owners, 2);
        t.mint(address(wallet), 1_000_000);
    }

    /// The compromised web interface: displays one thing, hands the signers another.
    function _whatTheScreenShows() internal view returns (address to, bytes memory data, uint8 op) {
        return (address(t), abi.encodeCall(IERC20.transfer, (makeAddrPure("cold wallet"), 1_000)), 0);
    }

    function _whatIsActuallySigned() internal view returns (address to, bytes memory data, uint8 op) {
        return (address(swapper), abi.encodeCall(ImplementationSwapper.swap, (address(sweepLogic))), 1);
    }

    function test_genuineSignaturesOverTheWrongInstruction() public {
        (address to, bytes memory data, uint8 op) = _whatIsActuallySigned();
        bytes[] memory sigs = _ownersSign(wallet.txHash(to, data, op));

        wallet.exec(to, data, op, sigs); // 2-of-3 threshold met with real signatures
        assertEq(wallet.implementation(), address(sweepLogic), "implementation replaced");

        vm.prank(attacker);
        SweepLogic(address(wallet)).sweep(t, attacker); // no further signatures needed, ever
        assertEq(t.balanceOf(attacker), 1_000_000);
    }

    function test_guardRefusesTheDelegatecall() public {
        TransactionGuard guard = new TransactionGuard();
        vm.prank(address(wallet));
        wallet.setGuard(address(guard));

        (address to, bytes memory data, uint8 op) = _whatIsActuallySigned();
        bytes[] memory sigs = _ownersSign(wallet.txHash(to, data, op));
        vm.expectRevert("guard: delegatecall target not approved");
        wallet.exec(to, data, op, sigs);

        assertEq(t.balanceOf(address(wallet)), 1_000_000);

        (to, data, op) = _whatTheScreenShows(); // the routine transfer still goes through
        wallet.exec(to, data, op, _ownersSign(wallet.txHash(to, data, op)));
        assertEq(t.balanceOf(address(wallet)), 999_000);
    }

    function _ownersSign(bytes32 h) internal view returns (bytes[] memory sigs) {
        // two owners, ordered by address as the wallet requires
        address a0 = vm.addr(pks[0]);
        address a1 = vm.addr(pks[1]);
        (uint256 first, uint256 second) = a0 < a1 ? (pks[0], pks[1]) : (pks[1], pks[0]);
        sigs = new bytes[](2);
        sigs[0] = _sign(first, h);
        sigs[1] = _sign(second, h);
    }

    function _sign(uint256 pk, bytes32 h) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, h);
        return abi.encodePacked(r, s, v);
    }

    function makeAddrPure(string memory name) internal pure returns (address) {
        return address(uint160(uint256(keccak256(bytes(name)))));
    }
}

/// ------------------------------------------------------------------------------------
/// 3b. Binance pattern (October 2026, as described in Binance's 3 November report): the
///     attacker never held a key. An internal signing service signed what it was sent,
///     including an EIP-7702 authorisation, a message type added to Ethereum in May 2025
///     that makes an ordinary account run code of the signer's choosing.
///     Mathematics involved: none. The signature is valid and the ledger behaves as specified.
///     Control: a signing policy that only accepts typed, structured requests it
///     understands (transfer of asset X to allow-listed address Y under limit Z), has no
///     raw-digest endpoint, and is reviewed whenever the ledger adds a message type.
///     Question: "List every message type your signer will sign. Who updated that list
///     after the last protocol upgrade?"
contract NaiveSigningService is CommonBase {
    uint256 private immutable KEY; // stands in for an HSM/MPC-held key: callers never see it
    mapping(address => bool) public authenticated;

    constructor(uint256 key, address client) {
        KEY = key;
        authenticated[client] = true;
    }

    /// "Sign this digest": the policy checks who is asking, not what is being signed.
    function sign(bytes32 digest) external view returns (uint8 v, bytes32 r, bytes32 s) {
        require(authenticated[msg.sender], "unauthenticated");
        return vm.sign(KEY, digest);
    }
}

contract PolicySigningService is CommonBase {
    uint256 private immutable KEY;
    mapping(address => bool) public authenticated;
    mapping(address => bool) public allowedDestination;
    uint256 public immutable PER_TRANSFER_LIMIT;

    constructor(uint256 key, address client, address destination, uint256 limit) {
        KEY = key;
        authenticated[client] = true;
        allowedDestination[destination] = true;
        PER_TRANSFER_LIMIT = limit;
    }

    /// The only thing this service signs: a transfer it has rebuilt itself from typed fields.
    function signTransfer(bytes32 domainSeparator, address token, address to, uint256 amount, uint256 nonce)
        external
        view
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(authenticated[msg.sender], "unauthenticated");
        require(allowedDestination[to], "policy: destination not allow-listed");
        require(amount <= PER_TRANSFER_LIMIT, "policy: over limit");
        bytes32 structHash = keccak256(abi.encode(keccak256("Transfer(address token,address to,uint256 amount,uint256 nonce)"), token, to, amount, nonce));
        return vm.sign(KEY, keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash)));
    }
    // There is deliberately no function that accepts a raw digest or an EIP-7702 authorisation.
}

contract Demo3b_SignerPolicyNeverAnticipatedDelegation is Test {
    DemoToken t;
    uint256 hotWalletKey = uint256(keccak256("TEST KEY exchange hot wallet"));
    address hotWallet;
    address attacker = makeAddr("attacker on a compromised engineer laptop");
    Drainer drainer;

    function setUp() public {
        t = new DemoToken();
        hotWallet = vm.addr(hotWalletKey);
        t.mint(hotWallet, 6_300_000);
        drainer = new Drainer();
    }

    /// keccak256(0x05 || rlp([chain_id, address, nonce])) as specified by EIP-7702.
    function _authorizationDigest(address implementation) internal view returns (bytes32) {
        require(block.chainid == 31337 && vm.getNonce(hotWallet) == 0, "demo assumes local chain, fresh account");
        bytes memory rlp = abi.encodePacked(hex"d9", hex"827a69", hex"94", implementation, hex"80");
        return keccak256(abi.encodePacked(hex"05", rlp));
    }

    function test_validSignatureWrongInstruction() public {
        NaiveSigningService service = new NaiveSigningService(hotWalletKey, attacker);

        // 1. From inside the network, the attacker asks the service to sign 32 bytes.
        vm.prank(attacker);
        (uint8 v, bytes32 r, bytes32 s) = service.sign(_authorizationDigest(address(drainer)));
        assertEq(ecrecover(_authorizationDigest(address(drainer)), v, r, s), hotWallet, "a perfectly valid signature");

        // 2. Those 32 bytes were an EIP-7702 authorisation. Anyone can now submit it.
        vm.attachDelegation(VmSafe.SignedDelegation({v: v - 27, r: r, s: s, nonce: 0, implementation: address(drainer)}));
        vm.prank(attacker);
        Drainer(hotWallet).drain(t, attacker);

        assertEq(t.balanceOf(attacker), 6_300_000);
        assertEq(t.balanceOf(hotWallet), 0);
        assertEq(hotWallet.code, abi.encodePacked(hex"ef0100", address(drainer)), "the account now runs attacker code");
        // The private key never left the service. Rotating it would not undo the delegation.
    }

    function test_typedPolicyHasNothingToAbuse() public {
        address treasury = makeAddr("treasury cold wallet");
        PolicySigningService service = new PolicySigningService(hotWalletKey, attacker, treasury, 10_000);

        // The attacker is fully authenticated, and still:
        vm.startPrank(attacker);
        vm.expectRevert("policy: destination not allow-listed");
        service.signTransfer(bytes32(0), address(t), attacker, 1, 0);
        vm.expectRevert("policy: over limit");
        service.signTransfer(bytes32(0), address(t), treasury, 10_001, 0);
        // No raw-digest endpoint exists, so the authorisation digest cannot be submitted at all.
        (bool ok,) = address(service).call(abi.encodeWithSignature("sign(bytes32)", _authorizationDigest(address(drainer))));
        assertFalse(ok);
        vm.stopPrank();
        assertEq(t.balanceOf(hotWallet), 6_300_000);
    }
}

/// ------------------------------------------------------------------------------------
/// 4. Bridges that pay out on messages nobody proved (Nomad and Wormhole patterns, 2022).
///    Mathematics involved: none. The proof check was satisfiable without a proof.
///    Control: test the negative case ("an unproven message must fail") after every
///    upgrade; fix the verifier's identity in code, never take it from the caller.
///    Question: "After your last upgrade, which test shows that a message with no valid
///    attestation is rejected?"
contract Demo4_BridgeVerification is Test {
    DemoToken t = new DemoToken();
    address attacker = makeAddr("attacker");

    function test_zeroRootCountsAsConfirmed() public {
        ZeroRootBridge bad = new ZeroRootBridge(t, bytes32(0)); // the faulty initialisation
        t.mint(address(bad), 190);
        vm.prank(attacker);
        bad.process(attacker, 190, 1); // message was never proven
        assertEq(t.balanceOf(attacker), 190);

        ZeroRootBridge good = new ZeroRootBridge(t, keccak256("a real root"));
        t.mint(address(good), 190);
        vm.expectRevert("not proven");
        good.process(attacker, 190, 2);
    }

    function test_callerSuppliesItsOwnVerifier() public {
        CallerChosenVerifierBridge bad = new CallerChosenVerifierBridge(t);
        t.mint(address(bad), 325);
        AlwaysYes fake = new AlwaysYes();
        vm.prank(attacker);
        bad.redeem(attacker, 325, 1, fake);
        assertEq(t.balanceOf(attacker), 325);
    }
}

/// ------------------------------------------------------------------------------------
/// 5. Weak key generation (Profanity pattern, 2022): the key came from a seed far smaller
///    than the key. Demonstrated on a deliberately tiny 16-bit seed space; the real tool
///    used 32 bits, which was enough to be searched on rented hardware.
///    Mathematics involved: the curve was not attacked. The search space was 2^16, not 2^256.
///    Control: keys generated inside certified hardware or by audited libraries from a
///    proper entropy source; no vanity-address tools for institutional keys.
///    Question: "Where was each signing key generated, by what software, from what entropy?"
contract Demo5_WeakKeyGeneration is Fixture {
    function _weakKey(uint16 seed) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked("vanity-generator", seed)));
    }

    function test_addressAloneRevealsTheKey() public {
        _deploySystem();
        uint256 victimKey = _weakKey(40_321); // the victim believes this is a 256-bit secret
        address victim = vm.addr(victimKey);
        _onboard(victim, address(ecdsaV), abi.encodePacked(victim));
        _mint(cash, victim, 160e18);

        // The attacker sees only the public address and enumerates the generator's seeds.
        uint256 recovered;
        for (uint256 seed = 0; seed < 65_536; seed++) {
            uint256 k = _weakKey(uint16(seed));
            if (vm.addr(k) == victim) {
                recovered = k;
                break;
            }
        }
        assertEq(recovered, victimKey);

        // With the key, the attacker produces an authorisation the system must accept.
        bytes memory sig = _transferSig(cash, recovered, victim, bob, 160e18, "stolen");
        cash.transferWithAuthorization(victim, bob, 160e18, 0, type(uint256).max, "stolen", sig);
        assertEq(cash.balanceOf(victim), 0);
    }
}
