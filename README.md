##  HODLBOX: Decentralized Time-Locked Asset Management

**HODLBOX** is a Clarity smart contract enabling secure, time-locked asset management of STX tokens on the Stacks blockchain. Users can lock STX tokens in a vault that becomes accessible only after a specified block height. Optional beneficiary access allows for secure, emergency fund retrieval.

---

###  Features

* **Time-Locked Deposits**: Lock STX tokens until a specified block height.
* **Incremental Deposits**: Add to an existing vault while maintaining or extending the lock duration.
* **Secure Withdrawals**: Only possible after the lock period expires.
* **Beneficiary Access**: Assign an optional trusted party to withdraw if the owner is unavailable.
* **Full Ownership Control**: Only the vault creator or the assigned beneficiary can access the vault.
* **Read-Only Insight**: Check vault status, balance, and contract holdings without executing state changes.

---

###  Functions

#### Vault Management

* `deposit(amount, unlock-height)`
  Create a new vault or deposit into an existing one. The vault remains locked until `unlock-height`.

* `withdraw(amount)`
  Withdraw STX tokens once the vault is unlocked.

* `set-beneficiary(beneficiary-address)`
  Assign a trusted address as a fallback to retrieve funds if needed.

* `beneficiary-withdraw(vault-owner)`
  Allows the beneficiary to withdraw funds after unlock height is reached.

#### 🔍 Read-Only Utilities

* `get-vault(owner)`
  View the details of a specific user's vault.

* `vault-exists(owner)`
  Check if a vault exists for a specific principal.

* `is-vault-unlocked(owner)`
  Returns true if the vault is unlocked based on current block height.

* `get-contract-balance()`
  Returns the STX balance held by the contract (useful for auditing and testing).

---

### 🛠️ Error Codes

| Code | Description                 |
| ---- | --------------------------- |
| 100  | Unauthorized access         |
| 101  | No vault exists             |
| 102  | Vault is still locked       |
| 103  | Invalid unlock time         |
| 104  | Deposit amount is zero      |
| 105  | Insufficient funds in vault |
| 106  | Beneficiary already set     |
| 107  | Invalid beneficiary address |

---

### 🔄 Contract Logic Overview

Vaults are stored in a map keyed by owner principal. Each vault contains:

* `balance`: STX locked
* `unlock-height`: Block height at which vault unlocks
* `beneficiary`: Optional fallback address

STX tokens are held by the contract and transferred back only upon a valid withdrawal request, either by the owner or a designated beneficiary after the lock period ends.

---

### ✅ Example Workflow

1. **Alice** deposits 100 STX into a vault, locked until block 10000.
2. She assigns **Bob** as a beneficiary.
3. If Alice is unavailable, **Bob** can withdraw after block 10000.
4. If the full balance is withdrawn, the vault is automatically deleted.

---

### 📜 Requirements

* **Clarity language** on the **Stacks blockchain**
* Compatible development environment (e.g., Clarinet)

---