pragma solidity ^0.4.16;
/**
 * @title Shareable Ownership
 * @dev Modification of the standard Ownable contract to allow
 * a patient owner to assign a physician owner to share contract.
 */

contract ShareableOwnership {

    address public patientOwner;    // address of Patient
    address public physicianOwner;  // address of Physician
    address public pendingSharedOwner;    // address of Pending Physician
    
    // @dev creator of contract is Patient
    function Ownable() internal {
        patientOwner = msg.sender;
    }

    // @dev only the patient owner or physician owner can modify
    modifier onlySharedOwner() {
        if (msg.sender == patientOwner || msg.sender == physicianOwner) {
            _;
        } else {
            revert();
        }
    }

    // @dev Allows current physician or patient to change Physician ownership
    // @param _pendingOwner Address of physician for transfer of shared ownership
    // @return whether the modification was successful
    function editPhysician(address _pendingSharedOwner) onlySharedOwner() returns(bool) {
        if (_pendingSharedOwner == 0x0) {
            return false;
        }
        pendingSharedOwner = _pendingSharedOwner;
        return true;
    }

    // @dev pending Physician owner must claim ownership to complete transfer
    // @returns whether the claim was successful
    function acceptSharedOwnership() returns(bool) {
        if (pendingSharedOwner != msg.sender) {
            return false;
        }
        physicianOwner = pendingSharedOwner;
        delete pendingSharedOwner;
        return true;
    }

    // @dev function to destroy contract during development 
    // @dev this helps minimize garbage on the network
    function destroy() public onlySharedOwner {
        selfdestruct(patientOwner);
    }
}
