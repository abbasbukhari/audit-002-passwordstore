# Security Audit Report — PasswordStore

**Auditor:** Abbas Bukhari
**Date:** March 12, 2026
**Contract:** PasswordStore
**Source:** https://github.com/Cyfrin/3-passwordstore-audit
**Audit Repo:** https://github.com/abbasbukhari/audit-002-passwordstore

---

## Summary

| Finding | Severity | Status |
|---|---|---|
| [F-01] Missing access control on `setPassword()` | High | Confirmed |
| [F-02] `s_password` readable on-chain despite `private` keyword | High | Confirmed |

---

## Scope

| File | Lines |
|---|---|
| `src/PasswordStore.sol` | 49 |

**In scope:**
- `setPassword(string newPassword)`
- `getPassword()`
- `s_password` storage variable
- `s_owner` storage variable

---

## F-01 — Missing Access Control on `setPassword()`

**Severity:** High

**Location:** [src/PasswordStore.sol:32](src/PasswordStore.sol#L32)

**Description:**

The `setPassword()` function is documented as owner-only in its NatSpec comment, but contains no access control in its implementation. There is no `require`, `if/revert`, or modifier checking that `msg.sender == s_owner`. Any address can call it freely and overwrite the stored password.

**Impact:**

Any attacker can call `setPassword()` with any value and permanently overwrite the owner's password. The owner loses control of their own data. The entire premise of the contract — that only the owner can manage the password — is broken.

**Proof of Concept:**

Test `test_setPassword_NotOwnerCanSet` in [test/PasswordStoreTest.t.sol](test/PasswordStoreTest.t.sol) proves this. A `nonOwner` address calls `setPassword("hacked")` — it succeeds without reverting. The owner then calls `getPassword()` and receives `"hacked"`, confirming the attacker overwrote the stored value.

```solidity
vm.prank(nonOwner);
passwordStore.setPassword("hacked");
vm.prank(owner);
string memory stored = passwordStore.getPassword();
assertEq(stored, "hacked"); // passes — bug confirmed
```

**Recommended Fix:**

Add an access control check at the top of `setPassword()` matching the pattern already used in `getPassword()`:

```solidity
function setPassword(string memory newPassword) external {
    if (msg.sender != s_owner) {
        revert PasswordStore__NotOwner();
    }
    s_password = newPassword;
    emit SetNewPassword();
}
```

---

## F-02 — Password Stored On-Chain Is Not Private

**Severity:** High

**Location:** [src/PasswordStore.sol:16](src/PasswordStore.sol#L16)

**Description:**

`s_password` is declared as `private`, but `private` in Solidity only prevents other contracts from reading the variable directly through the ABI. It does not encrypt the data or hide it from the public blockchain. All contract storage is permanently visible on-chain. Anyone can read any storage slot using tools like `cast storage` or `vm.load` — no ABI or getter function required.

**Impact:**

Any person who knows the contract address can read the stored password directly from the blockchain. The contract's core promise — "store a private password that others won't be able to see" — is false. The password is exposed to everyone from the moment it is stored.

**Proof of Concept:**

A storage slot read bypasses `getPassword()` entirely:

```bash
cast storage <contract_address> 1
```

Or in a Foundry test using `vm.load`:

```solidity
bytes32 rawPassword = vm.load(address(passwordStore), bytes32(uint256(1)));
```

This returns the raw value of `s_password` from storage slot 1 without calling any function or being the owner.

**Recommended Fix:**

There is no safe way to store a secret on a public blockchain. The fundamental architecture of this contract is flawed. Sensitive data must never be stored in plaintext on-chain, regardless of visibility modifiers. If a password system is required, consider storing only a hash of the password on-chain and keeping the plaintext off-chain, or using encryption before storing.

---

## Test Coverage

| Test | Pattern | Status |
|---|---|---|
| `test_setPassword_UpdatesPassword` | Pattern A | [x] Passing |
| `test_setPassword_NotOwnerCanSet` | Pattern E | [x] Passing |
| `test_getPassword_ownerCanRead` | Pattern B | [ ] |
| `test_getPassword_nonOwnerReverts` | Pattern E | [ ] |
| `test_passwordReadableViaStorageSlot` | vm.load | [ ] |

---

## Conclusion

<!-- Write after all tests are complete. -->

---

*This audit was conducted as part of Blokan Phase 3 — Practice Audits. Findings are compared against Patrick Collins' official audit report after submission.*