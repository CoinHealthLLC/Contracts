pragma solidity ^0.4.16;
/**
 * @title Shareable Ownership
 * @author RHendricks
 * @dev Modification of the standard Ownable contract to allow
 * a patient owner to assign a physician owner to share contract.
 */


contract ShareableOwnership {

	address public patientOwner;    // address of Patient
	address public physicianOwner;  // address of Physician
	address public pendingOwner;    // address of Pending Physician
    
    // @dev creator of contract is Patient
	function Ownable() {
        patientOwner = msg.sender;
    }
	
    // @dev only the patient owner or physician owner can modify
	modifier onlyOwner(){
		if (msg.sender == patientOwner || msg.sender == physicianOwner) {
			_;
		}
	}

    // @dev Allows current physician or patient to change Physician ownership
    // @param _pendingOwner Address of physician for transfer of shared ownership
    // @return whether the modification was successful
    function editPhysician(address _pendingOwner) onlyOwner() returns(bool) {
        if (_pendingOwner == 0x0) {
            return false;
        }
	    pendingOwner = _pendingOwner;
        return true;
    }

    // @dev pending Physician owner must claim ownership to complete transfer
    // @returns whether the claim was successful
	function claimOwnPhysician() returns(bool) {
		if (pendingOwner != msg.sender) {
            return false;
        }

        physicianOwner = pendingOwner;
        delete pendingOwner;

        return true;
    }

    // @dev function to destroy contract during development 
    // @dev this helps minimize garbage on the network
	function destroy() onlyOwner {
        selfdestruct(patientOwner);
    }
}