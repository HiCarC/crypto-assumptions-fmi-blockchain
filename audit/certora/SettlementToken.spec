// Certora Prover specification for SettlementToken.
// The prover starts from an ARBITRARY storage state, so these rules hold for every reachable
// (and unreachable) state of the implementation, not only states our tests happened to visit.
// Two external dependencies are abstracted:
//   - KeyRegistry.isValidSignature  -> an uninterpreted predicate sigValid(account, digest)
//   - AccessManager.canCall (via AuthorityUtils.canCallWithDelay) -> an uninterpreted permission table allowed[caller][selector]
// The rules are therefore about what the token does with those answers.

methods {
    function totalSupply() external returns (uint256) envfree;
    function balanceOf(address) external returns (uint256) envfree;
    function paused() external returns (bool) envfree;
    function authorizationState(address, bytes32) external returns (bool) envfree;

    function _.isValidSignature(address account, bytes32 hash, bytes signature) external
        => sigValid(account, hash) expect bool;
    // OpenZeppelin queries the access manager through a low-level staticcall inside this
    // library function, so the summary is attached here rather than on canCall itself.
    function AuthorityUtils.canCallWithDelay(address authority, address caller, address target, bytes4 selector)
        internal returns (bool, uint32) => canCallSummary(caller, selector);
}

ghost sigValid(address, bytes32) returns bool;
ghost mapping(address => mapping(bytes4 => bool)) allowed;

function canCallSummary(address caller, bytes4 selector) returns (bool, uint32) {
    return (allowed[caller][selector], 0);
}

definition isUpgrade(method f) returns bool =
    f.selector == sig:upgradeToAndCall(address, bytes).selector;

/// R1. Without a valid signature from the payer, a signed transfer always reverts.
rule invalidSignatureCannotTransfer(
    env e, address from, address to, uint256 value, uint256 validAfter, uint256 validBefore, bytes32 nonce, bytes signature
) {
    bytes32 digest = transferDigest(e, from, to, value, validAfter, validBefore, nonce);
    require !sigValid(from, digest);
    transferWithAuthorization@withrevert(e, from, to, value, validAfter, validBefore, nonce, signature);
    assert lastReverted;
}

/// R2. An authorisation nonce is single-use, whatever else changes in the second call.
rule nonceIsSingleUse(
    env e1, env e2, address from, bytes32 nonce,
    address to1, uint256 v1, uint256 a1, uint256 b1, bytes s1,
    address to2, uint256 v2, uint256 a2, uint256 b2, bytes s2
) {
    transferWithAuthorization(e1, from, to1, v1, a1, b1, nonce, s1);
    assert authorizationState(from, nonce);
    transferWithAuthorization@withrevert(e2, from, to2, v2, a2, b2, nonce, s2);
    assert lastReverted;
}

/// R3. Supply conservation: only mint and burn can change total supply.
rule supplyChangesOnlyByMintOrBurn(method f, env e, calldataarg args)
    filtered { f -> !f.isView && !isUpgrade(f) }
{
    uint256 before = totalSupply();
    f(e, args);
    assert totalSupply() != before =>
        f.selector == sig:mint(address, uint256).selector || f.selector == sig:burn(address, uint256).selector;
}

/// R4. Pause stops all value movement: while paused, no function changes any balance.
rule pausedMeansNoBalanceChange(method f, env e, calldataarg args, address who)
    filtered { f -> !f.isView && !isUpgrade(f) }
{
    require paused();
    uint256 before = balanceOf(who);
    f@withrevert(e, args); // reverted or not, the balance must be the same
    assert balanceOf(who) == before;
}

/// R5. Privileged entry points revert for callers the access manager does not authorise,
///     including the upgrade entry point (so only governance holding that permission can upgrade).
rule privilegedFunctionsNeedPermission(env e, address a, uint256 n, bool flag, bytes data) {
    bytes4 mintSel = to_bytes4(sig:mint(address, uint256).selector);
    bytes4 burnSel = to_bytes4(sig:burn(address, uint256).selector);
    bytes4 frzSel = to_bytes4(sig:setFrozen(address, bool).selector);
    bytes4 opSel = to_bytes4(sig:settlementTransfer(address, address, uint256).selector);
    bytes4 upSel = to_bytes4(sig:upgradeToAndCall(address, bytes).selector);
    require !allowed[e.msg.sender][mintSel] && !allowed[e.msg.sender][burnSel] && !allowed[e.msg.sender][frzSel]
        && !allowed[e.msg.sender][opSel] && !allowed[e.msg.sender][upSel];

    mint@withrevert(e, a, n);
    assert lastReverted;
    burn@withrevert(e, a, n);
    assert lastReverted;
    setFrozen@withrevert(e, a, flag);
    assert lastReverted;
    settlementTransfer@withrevert(e, a, a, n);
    assert lastReverted;
    upgradeToAndCall@withrevert(e, a, data);
    assert lastReverted;
}
