# STACKDELEGATE - Identity Delegation Smart Contract
A Clarity smart contract for identity delegation on the Stacks blockchain.  
Allows users (owners) to securely delegate permission to another wallet (delegate) for a specified duration (in blocks).

## Features

- **Delegate identity** to another principal for a set duration
- **Revoke delegation** at any time
- **Query delegation status** and expiration
- **Helper functions** for delegation info and expiration checks

## Contract Overview

- `create-delegation`: Delegate to another principal for a given duration
- `revoke-delegation`: Remove delegation for the sender
- `is-valid-delegate`: Check if a principal is a valid delegate for an owner
- `get-delegation`: Get current delegate and expiration for an owner
- `get-delegation-info`: Get delegate, expiration, and active status
- `is-delegation-expired`: Check if a delegation is expired

## Data Structures

- `delegation-map`: Maps owner principal to delegate principal and expiration block

## Usage

Deploy the contract using [Clarinet](https://github.com/clarinet/clarinet) or the Stacks CLI.

### Example

```clarity
;; Delegate to another principal for 100 blocks
(create-delegation 'SP123... 100)

;; Revoke delegation
(revoke-delegation)
```
