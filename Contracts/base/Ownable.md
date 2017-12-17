* [Ownable](#ownable)
  * [changeOwnership](#function-changeownership)
  * [claimOwnership](#function-claimownership)
  * [destroy](#function-destroy)
  * [owner](#function-owner)
  * [pendingOwner](#function-pendingowner)

# Ownable


## *function* changeOwnership

Ownable.changeOwnership(_to) `nonpayable` `2af4c31e`

**Prepares ownership pass. Can only be called by current owner.**


Inputs

| | | |
|-|-|-|
| *address* | _to | address of the next owner. 0x0 is not allowed. |

Outputs

| | | |
|-|-|-|
| *bool* |  | undefined |

## *function* claimOwnership

Ownable.claimOwnership() `nonpayable` `4e71e0c8`

**Finalize ownership pass.     * Can only be called by pending owner.**




Outputs

| | | |
|-|-|-|
| *bool* |  | undefined |

## *function* destroy

Ownable.destroy() `nonpayable` `83197ef0`

**Only owner can call it**

> Destroy contract and scrub a data




## *function* owner

Ownable.owner() `view` `8da5cb5b`





## *function* pendingOwner

Ownable.pendingOwner() `view` `e30c3978`






---