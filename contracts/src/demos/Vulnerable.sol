// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

// =====================================================================================
//  DELIBERATELY VULNERABLE CONTRACTS. Written for this repository to reproduce known
//  failure patterns on a local test chain. Never deploy any of this.
//  Each has a fixed counterpart: either in this file or in the reference system (src/).
// =====================================================================================

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract DemoToken is ERC20 {
    constructor() ERC20("Demo", "DEMO") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

// ------------------------------------------------------------------ 1. signature replay

/// Signed payment orders with no nonce, no chain id and no contract address in the hash.
contract ReplayableVault {
    IERC20 public immutable TOKEN;
    address public immutable TREASURER;

    constructor(IERC20 token, address treasurer) {
        TOKEN = token;
        TREASURER = treasurer;
    }

    function pay(address to, uint256 amount, bytes calldata sig) external {
        bytes32 h = keccak256(abi.encodePacked(to, amount)); // BUG: nothing makes this order unique
        require(ECDSA.recover(h, sig) == TREASURER, "bad sig");
        TOKEN.transfer(to, amount);
    }
}

// ------------------------------------------------------------------ 2. malleability and ecrecover(0)

/// Uses raw `ecrecover`, tracks spent orders by signature bytes, and can be left with an
/// unset signer.
contract MalleableClaims {
    IERC20 public immutable TOKEN;
    address public signer; // BUG: zero until someone remembers to set it
    mapping(bytes32 => bool) public usedSignature;

    constructor(IERC20 token) {
        TOKEN = token;
    }

    function setSigner(address s) external {
        require(signer == address(0), "already set");
        signer = s;
    }

    function claim(address to, uint256 amount, uint256 id, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 h = keccak256(abi.encode(address(this), block.chainid, to, amount, id));
        bytes32 sigId = keccak256(abi.encodePacked(r, s, v));
        require(!usedSignature[sigId], "used"); // BUG: the same order has two valid encodings
        usedSignature[sigId] = true;
        require(ecrecover(h, v, r, s) == signer, "bad sig"); // BUG: ecrecover returns 0 on garbage
        TOKEN.transfer(to, amount);
    }
}

// ------------------------------------------------------------------ 3a. multisig that will delegatecall anything (Bybit pattern)

/// A minimal proxy-based multisig. Slot 0 holds the implementation, as in the wallet
/// involved in the February 2025 theft. Owners sign (to, data, operation); operation 1
/// is DELEGATECALL, which runs foreign code against this wallet's own storage.
contract MiniMultisig {
    address public implementation; // slot 0 (unused by this demo's logic, but it is what the attacker overwrites)
    address[] public owners;
    uint256 public threshold;
    uint256 public nonce;
    address public guard; // optional policy check, unset in the vulnerable configuration

    constructor(address[] memory owners_, uint256 threshold_) {
        owners = owners_;
        threshold = threshold_;
        implementation = address(this);
    }

    function setGuard(address g) external {
        require(msg.sender == address(this), "only self");
        guard = g;
    }

    function txHash(address to, bytes calldata data, uint8 operation) public view returns (bytes32) {
        return keccak256(abi.encode(address(this), block.chainid, to, keccak256(data), operation, nonce));
    }

    function exec(address to, bytes calldata data, uint8 operation, bytes[] calldata sigs) external {
        bytes32 h = txHash(to, data, operation);
        require(sigs.length >= threshold, "threshold");
        address last;
        for (uint256 i = 0; i < threshold; i++) {
            address a = ECDSA.recover(h, sigs[i]);
            require(a > last && _isOwner(a), "bad owner");
            last = a;
        }
        nonce++;
        if (guard != address(0)) TransactionGuard(guard).check(to, operation);
        bool ok;
        if (operation == 1) (ok,) = to.delegatecall(data);
        else (ok,) = to.call(data);
        require(ok, "exec failed");
    }

    /// After a hijack, the wallet forwards everything to whatever sits in slot 0.
    fallback() external {
        address impl = implementation;
        if (impl == address(this)) revert("no such function");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let r := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch r
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _isOwner(address a) private view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == a) return true;
        }
        return false;
    }
}

/// The control: an on-chain policy that refuses DELEGATECALL to anything not pre-approved.
contract TransactionGuard {
    mapping(address => bool) public delegatecallAllowed;

    function check(address to, uint8 operation) external view {
        require(operation != 1 || delegatecallAllowed[to], "guard: delegatecall target not approved");
    }
}

/// What the signers were tricked into authorising: one storage write, then a sweep.
contract ImplementationSwapper {
    function swap(address newImpl) external {
        assembly {
            sstore(0, newImpl)
        }
    }
}

contract SweepLogic {
    function sweep(IERC20 token, address to) external {
        token.transfer(to, token.balanceOf(address(this)));
    }
}

// ------------------------------------------------------------------ 4. bridges that accept unproven messages

/// Nomad pattern (August 2022): an upgrade initialised the "confirmed roots" table so
/// that the zero root counted as confirmed, and an unproven message has root zero.
contract ZeroRootBridge {
    IERC20 public immutable TOKEN;
    mapping(bytes32 root => uint256 confirmedAt) public confirmAt;
    mapping(bytes32 message => bytes32 root) public provenUnder;
    mapping(bytes32 => bool) public processed;

    constructor(IERC20 token, bytes32 initialRoot) {
        TOKEN = token;
        confirmAt[initialRoot] = 1; // BUG when initialRoot == 0
    }

    function process(address to, uint256 amount, uint256 id) external {
        bytes32 m = keccak256(abi.encode(to, amount, id));
        require(!processed[m], "done");
        require(confirmAt[provenUnder[m]] != 0, "not proven"); // unproven => root 0 => "confirmed"
        processed[m] = true;
        TOKEN.transfer(to, amount);
    }
}

/// Wormhole pattern (February 2022): the code that checks guardian signatures is taken
/// from the caller's input instead of from a fixed, trusted address.
interface IAttestationChecker {
    function attested(bytes32 message) external view returns (bool);
}

contract CallerChosenVerifierBridge {
    IERC20 public immutable TOKEN;
    mapping(bytes32 => bool) public processed;

    constructor(IERC20 token) {
        TOKEN = token;
    }

    function redeem(address to, uint256 amount, uint256 id, IAttestationChecker checker) external {
        bytes32 m = keccak256(abi.encode(to, amount, id));
        require(!processed[m], "done");
        require(checker.attested(m), "not attested"); // BUG: who is `checker`?
        processed[m] = true;
        TOKEN.transfer(to, amount);
    }
}

contract AlwaysYes is IAttestationChecker {
    function attested(bytes32) external pure returns (bool) {
        return true;
    }
}

// ------------------------------------------------------------------ 3b. hot wallet drained through a delegation it signed (Binance pattern)

/// Code the attacker wants the hot wallet's address to run.
contract Drainer {
    function drain(IERC20 token, address to) external {
        token.transfer(to, token.balanceOf(address(this)));
    }
}
