pragma solidity ^0.4.11;

/**
 * @title Owned contract with safe ownership pass.
 *
 * Note: all the non constant functions return false instead of throwing in case if state change
 * didn't happen yet.
 */


contract Ownable {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * Contract owner address
     */
    address public pendingOwner;

    function Ownable() {
        owner = msg.sender;
    }

    /**
    * @dev Owner check modifier
    */
    modifier onlyOwner() {
        if (owner == msg.sender) {
            _;
        }
    }

    /**
     * @dev Destroy contract and scrub a data
     * @notice Only owner can call it
     */
    function destroy() onlyOwner {
        suicide(msg.sender);
    }

    /**
     * Prepares ownership pass.
     * Can only be called by current owner.
     * @param _to address of the next owner. 0x0 is not allowed.
     * @return success.
     */
    function changeOwnership(address _to) onlyOwner() returns(bool) {
        if (_to == 0x0) {
            return false;
        }

        pendingOwner = _to;
        return true;
    }

    /**
     * Finalize ownership pass.
     *
     * Can only be called by pending owner.
     *
     * @return success.
     */
    function claimOwnership() returns(bool) {
        if (pendingOwner != msg.sender) {
            return false;
        }

        owner = pendingOwner;
        delete pendingOwner;

        return true;
    }
}
