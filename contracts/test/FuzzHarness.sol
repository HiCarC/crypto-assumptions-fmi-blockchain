// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.24;

import {Handler} from "./Invariants.t.sol";

/// @notice Entry point for Echidna and Medusa. Reuses the invariant handler: the fuzzers
///         call its honest and hostile actions in random sequences, then check these
///         properties after every call. See audit/echidna.yaml and audit/medusa.json.
contract FuzzHarness is Handler {
    bytes32 private constant IMPL_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    function echidna_nothing_impossible_happened() public view returns (bool) {
        return bytes(violation).length == 0;
    }

    function echidna_supply_conserved() public view returns (bool) {
        return cash.totalSupply() == mintedCash - burnedCash && asset.totalSupply() == mintedAsset - burnedAsset
            && cash.balanceOf(alice) + cash.balanceOf(bob) == cash.totalSupply()
            && asset.balanceOf(alice) + asset.balanceOf(bob) == asset.totalSupply();
    }

    function echidna_implementation_unchanged() public view returns (bool) {
        return address(uint160(uint256(vm.load(address(cash), IMPL_SLOT)))) == address(tokenImpl)
            && address(uint160(uint256(vm.load(address(asset), IMPL_SLOT)))) == address(tokenImpl);
    }
}
