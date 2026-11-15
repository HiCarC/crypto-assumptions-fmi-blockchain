// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Fixture} from "./utils/Fixture.sol";
import {SettlementToken} from "../src/SettlementToken.sol";
import {HybridVerifier} from "../src/verifiers/HybridVerifier.sol";
import {IERC7913SignatureVerifier} from "@openzeppelin/contracts/interfaces/IERC7913.sol";
import {P256} from "@openzeppelin/contracts/utils/cryptography/P256.sol";
import {ZKNOX_dilithium} from "ETHDILITHIUM/ZKNOX_dilithium.sol";

/// @dev P-256 verified in plain Solidity, to show the cost on a chain without the precompile.
contract P256SolidityVerifier is IERC7913SignatureVerifier {
    function verify(bytes calldata key, bytes32 hash, bytes calldata sig) external view returns (bytes4) {
        if (key.length != 64 || sig.length != 64) return 0xffffffff;
        return P256.verifySolidity(hash, bytes32(sig[0:32]), bytes32(sig[32:64]), bytes32(key[0:32]), bytes32(key[32:64]))
            ? IERC7913SignatureVerifier.verify.selector
            : bytes4(0xffffffff);
    }
}

/// @notice ML-DSA-44 (FIPS 204) and hybrid ECDSA + ML-DSA authorisations, plus the cost table.
///
///         ML-DSA signatures cannot be produced inside the EVM test runner, so they come from
///         a fixture file. Two-step flow (`make pq-fixtures`):
///           1. `test_emitDigests` writes the digests this suite needs to results/pq-digests.json
///           2. tools/mldsa.py signs them into test/fixtures/mldsa44.json
///         Every test checks that the fixture was made for exactly the digest it computes and
///         fails with a clear message otherwise.
///
///         The verifier is ZKNoxHQ/ETHDILITHIUM (pinned commit), which its authors label
///         experimental and unaudited. It is used here to measure, not to recommend.
contract PostQuantumTest is Fixture {
    uint256 internal constant MAX = type(uint256).max;
    string internal constant SEED = "464d49206368617074657220322054455354204b4559206f6e6c792121212121"; // "FMI chapter 2 TEST KEY only!!!!!"
    string internal constant FIXTURE = "test/fixtures/mldsa44.json";
    bytes32 internal constant BENCH = keccak256("fmi-chapter2 benchmark digest");

    ZKNOX_dilithium internal mldsaV;
    HybridVerifier internal hybridPqV;
    P256SolidityVerifier internal p256SolV;
    address internal carol = makeAddr("carol (ML-DSA only)");
    uint256 internal davePk = uint256(keccak256("TEST KEY dave"));
    address internal dave;
    uint256 internal p256Pk = uint256(keccak256("TEST KEY p256 bench"));

    bool internal haveFixture;
    string internal fx;
    bytes internal mldsaKey; // 20-byte pointer to the expanded public key
    uint256 internal setKeyGas;

    function setUp() public {
        _deploySystem();
        dave = vm.addr(davePk);
        mldsaV = new ZKNOX_dilithium();
        hybridPqV = new HybridVerifier(ecdsaV, IERC7913SignatureVerifier(address(mldsaV)));
        p256SolV = new P256SolidityVerifier();
        _approveVerifier(address(mldsaV));
        _approveVerifier(address(hybridPqV));
        _mint(cash, alice, 1_000e18);

        try vm.readFile(FIXTURE) returns (string memory json) {
            fx = json;
            haveFixture = true;
            uint256 g = gasleft();
            mldsaKey = mldsaV.setKey(vm.parseJsonBytes(fx, ".pk"));
            setKeyGas = g - gasleft();
            _onboard(carol, address(mldsaV), mldsaKey);
            _onboard(dave, address(hybridPqV), abi.encode(abi.encodePacked(dave), mldsaKey));
            _mint(cash, carol, 100e18);
            _mint(cash, dave, 100e18);
        } catch {}
    }

    // ------------------------------------------------------------ digests and fixture plumbing

    function _carolDigest() internal view returns (bytes32) {
        return cash.transferDigest(carol, bob, 1e18, 0, MAX, "pq-carol");
    }

    function _daveDigest() internal view returns (bytes32) {
        return cash.transferDigest(dave, bob, 1e18, 0, MAX, "pq-dave");
    }

    function test_emitDigests() public {
        string memory d = "digests";
        vm.serializeBytes32(d, "bench", BENCH);
        vm.serializeBytes32(d, "carol", _carolDigest());
        string memory digests = vm.serializeBytes32(d, "dave", _daveDigest());
        string memory root = "root";
        vm.serializeString(root, "seed", SEED);
        vm.writeJson(vm.serializeString(root, "digests", digests), "../results/pq-digests.json");
    }

    function _sig(string memory name, bytes32 expectedDigest) internal view returns (bytes memory) {
        assertEq(
            vm.parseJsonBytes32(fx, string.concat(".digests.", name)),
            expectedDigest,
            "stale ML-DSA fixture: run `make pq-fixtures`"
        );
        return vm.parseJsonBytes(fx, string.concat(".sigs.", name));
    }

    modifier needsFixture() {
        if (!haveFixture) {
            vm.skip(true, "ML-DSA fixture missing: run `make pq-fixtures`");
        }
        _;
    }

    // ------------------------------------------------------------ behaviour

    function test_mldsaOnlyAccountTransfers() public needsFixture {
        bytes memory sig = _sig("carol", _carolDigest());
        assertEq(sig.length, 2420);
        vm.prank(relayer);
        cash.transferWithAuthorization(carol, bob, 1e18, 0, MAX, "pq-carol", sig);
        assertEq(cash.balanceOf(bob), 1e18);
        vm.expectRevert(SettlementToken.AuthorizationAlreadyUsed.selector);
        cash.transferWithAuthorization(carol, bob, 1e18, 0, MAX, "pq-carol", sig);
    }

    function test_mldsaRejectsTamperedSignatureAndWrongMessage() public needsFixture {
        bytes memory sig = _sig("carol", _carolDigest());
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(carol, bob, 2e18, 0, MAX, "pq-carol", sig); // different message
        sig[100] = bytes1(uint8(sig[100]) ^ 0x01);
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(carol, bob, 1e18, 0, MAX, "pq-carol", sig);
    }

    function test_hybridEcdsaPlusMldsa() public needsFixture {
        bytes32 d = _daveDigest();
        bytes memory pq = _sig("dave", d);
        bytes memory classical = _signECDSA(davePk, d);

        vm.expectRevert(SettlementToken.InvalidAuthorization.selector); // classical alone
        cash.transferWithAuthorization(dave, bob, 1e18, 0, MAX, "pq-dave", classical);

        vm.expectRevert(SettlementToken.InvalidAuthorization.selector); // PQ half valid, classical half forged
        cash.transferWithAuthorization(dave, bob, 1e18, 0, MAX, "pq-dave", abi.encode(_signECDSA(alicePk, d), pq));

        bytes memory badPq = bytes.concat(pq);
        badPq[7] = bytes1(uint8(badPq[7]) ^ 0x80);
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector); // classical half valid, PQ half forged
        cash.transferWithAuthorization(dave, bob, 1e18, 0, MAX, "pq-dave", abi.encode(classical, badPq));

        cash.transferWithAuthorization(dave, bob, 1e18, 0, MAX, "pq-dave", abi.encode(classical, pq));
        assertEq(cash.balanceOf(bob), 1e18);
    }

    /// Migration in one signed step: alice moves from ECDSA to hybrid, balance untouched.
    function test_migrateClassicalAccountToHybrid() public needsFixture {
        bytes memory newKey = abi.encode(abi.encodePacked(alice), mldsaKey);
        bytes32 d = registry.rotationDigest(alice, address(hybridPqV), newKey, 0);
        registry.rotateKey(alice, address(hybridPqV), newKey, _signECDSA(alicePk, d));
        assertEq(cash.balanceOf(alice), 1_000e18);
        bytes memory oldStyle = _transferSig(cash, alicePk, alice, bob, 1, "n");
        vm.expectRevert(SettlementToken.InvalidAuthorization.selector);
        cash.transferWithAuthorization(alice, bob, 1, 0, MAX, "n", oldStyle);
    }

    // ------------------------------------------------------------ cost table

    struct Row {
        string name;
        uint256 keyBytes;
        uint256 sigBytes;
        uint256 verifyGas;
        uint256 transferGas;
        uint256 calldataBytes;
        uint256 calldataZeroBytes;
    }

    /// @dev Writes results/gas.json. `verifyGas` is one external call to the verifier;
    ///      `transferGas` is the execution gas of a complete transferWithAuthorization
    ///      (excluding the 21,000 base and calldata charges, which scripts/gas_table.py adds).
    function test_writeGasTable() public needsFixture {
        Row[] memory rows = new Row[](6);
        bytes memory k256 = _p256Key(p256Pk);
        address erin = vm.addr(uint256(keccak256("TEST KEY erin")));

        rows[0] = _measure("ecdsa-secp256k1", address(ecdsaV), abi.encodePacked(erin), 20, _signECDSA(uint256(keccak256("TEST KEY erin")), BENCH));
        rows[1] = _measure("p256-precompile", address(p256V), k256, 64, _signP256(p256Pk, BENCH));
        rows[2] = _measure("p256-solidity", address(p256SolV), k256, 64, _signP256(p256Pk, BENCH));
        rows[3] = _measure("mldsa44", address(mldsaV), mldsaKey, 1312, _sig("bench", BENCH));
        rows[4] = _measure(
            "hybrid-ecdsa+p256",
            address(hybridClassicalV),
            abi.encode(abi.encodePacked(erin), k256),
            84,
            abi.encode(_signECDSA(uint256(keccak256("TEST KEY erin")), BENCH), _signP256(p256Pk, BENCH))
        );
        rows[5] = _measure(
            "hybrid-ecdsa+mldsa44",
            address(hybridPqV),
            abi.encode(abi.encodePacked(erin), mldsaKey),
            1332,
            abi.encode(_signECDSA(uint256(keccak256("TEST KEY erin")), BENCH), _sig("bench", BENCH))
        );

        // End-to-end transfers for the three account types that exist in this suite.
        rows[0].transferGas = _e2e(alice, "g-a", _transferSig(cash, alicePk, alice, bob, 1e18, "g-a"), rows[0]);
        rows[3].transferGas = _e2e(carol, "pq-carol", _sig("carol", _carolDigest()), rows[3]);
        bytes32 dd = _daveDigest();
        rows[5].transferGas = _e2e(dave, "pq-dave", abi.encode(_signECDSA(davePk, dd), _sig("dave", dd)), rows[5]);

        string memory root = "gas";
        string memory out;
        for (uint256 i = 0; i < rows.length; i++) {
            string memory o = rows[i].name;
            vm.serializeUint(o, "keyBytes", rows[i].keyBytes);
            vm.serializeUint(o, "sigBytes", rows[i].sigBytes);
            vm.serializeUint(o, "verifyGas", rows[i].verifyGas);
            vm.serializeUint(o, "transferExecutionGas", rows[i].transferGas);
            vm.serializeUint(o, "transferCalldataBytes", rows[i].calldataBytes);
            out = vm.serializeString(
                root, o, vm.serializeUint(o, "transferCalldataZeroBytes", rows[i].calldataZeroBytes)
            );
        }
        vm.serializeUint(root, "mldsa44KeyRegistrationGas", setKeyGas);
        out = vm.serializeUint(root, "mldsa44ExpandedKeyBytes", vm.parseJsonBytes(fx, ".pk").length);
        vm.writeJson(out, "../results/gas.json");

        assertLt(rows[0].verifyGas, rows[3].verifyGas, "sanity: ML-DSA costs more than ECDSA");
    }

    function _measure(string memory name, address verifier, bytes memory key, uint256 rawKeyBytes, bytes memory sig)
        internal
        view
        returns (Row memory r)
    {
        r.name = name;
        r.keyBytes = rawKeyBytes;
        r.sigBytes = sig.length;
        uint256 g = gasleft();
        bytes4 magic = IERC7913SignatureVerifier(verifier).verify(key, BENCH, sig);
        r.verifyGas = g - gasleft();
        assertEq(magic, IERC7913SignatureVerifier.verify.selector, name);
    }

    function _e2e(address from, bytes32 nonce, bytes memory sig, Row memory r) internal returns (uint256) {
        bytes memory data =
            abi.encodeCall(SettlementToken.transferWithAuthorization, (from, bob, 1e18, 0, MAX, nonce, sig));
        r.calldataBytes = data.length;
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i] == 0) r.calldataZeroBytes++;
        }
        vm.prank(relayer);
        (bool ok,) = address(cash).call(data);
        assertTrue(ok, "transfer failed");
        return vm.lastCallGas().gasTotalUsed;
    }
}
