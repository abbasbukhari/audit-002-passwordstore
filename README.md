# Audit 002 — PasswordStore

A security audit of the `PasswordStore` smart contract, conducted as part of the Blokan Phase 3 practice audit series.

---

## Original Contract

**Source:** [Cyfrin / 3-passwordstore-audit](https://github.com/Cyfrin/3-passwordstore-audit)
**Author:** Patrick Collins / Cyfrin Updraft
**Course:** Cyfrin Updraft — Smart Contract Security, Section 3

The contract was created by Patrick Collins specifically for auditor training. It contains intentionally planted bugs designed to teach security researchers how to identify access control vulnerabilities and blockchain storage misconceptions.

> All credit for the original contract goes to Patrick Collins and the Cyfrin team.

---

## What This Repo Is

This repo is a hands-on security audit of `PasswordStore.sol` — a deliberately vulnerable contract used in the Cyfrin security course.

The audit covers:
- Reading the contract and forming independent observations
- Writing Foundry tests to prove or disprove suspected vulnerabilities
- Documenting findings in audit report format
- Comparing results against Patrick Collins' official audit report as a feedback loop

The goal is not to produce a production-ready audit, but to build the muscle memory of the auditing process: read → observe → test → report.

---

## The Contract

`PasswordStore` is a simple on-chain password manager. The intended behavior:

- The deployer (owner) can store a private password via `setPassword()`
- Only the owner can retrieve the password via `getPassword()`

**Contract:** [src/PasswordStore.sol](src/PasswordStore.sol)
**Solidity:** `^0.8.18`
**Complexity:** Low — short contract, subtle bugs

---

## Audit Scope

| Function | Description |
|---|---|
| `setPassword(string newPassword)` | Stores a new password on-chain |
| `getPassword()` | Returns the stored password to the caller |

---

## Test Environment

Built with [Foundry](https://book.getfoundry.sh/).

```shell
# Install dependencies
forge install

# Build
forge build

# Run tests
forge test

# Run tests with verbose output
forge test -vvv

# Gas report
forge test --gas-report

# Coverage
forge coverage
```

---

## Auditor

**Abbas Bukhari**
GitHub: [@abbasbukhari](https://github.com/abbasbukhari)
Program: Blokan — Phase 3, Practice Audits