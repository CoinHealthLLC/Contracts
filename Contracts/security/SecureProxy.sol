pragma solidity ^0.4.19;


contract iRecordStorageProxy { //The patients proxy needs to be reengineered 
    function createNewRecord(string name, string dob, string publicId, string privateId);
    function getExistingRecord(string patientPubId) returns (bytes32, bytes32, bytes32);
}


contract iRecordAccessProxy {
    function addToRecord(string privId, string labResultsRecord);
    function updateRecord(string privId, string labResultsRecord);
    function retrieveFromRecord(string privId) returns (bytes32);
}


/**
 * @title SecureProxy contract provides a degree of separation from secure records
 * @author RH
 * @dev version 1.618
 */

contract SecureProxy {

    function AddRecord(string privateId, string patientLabResults) {
        labResults.AddToStore(privateId, patientLabResults);
    }

    //Update a patient's lab results on the blockchain, only to be called when updating the ;ab results of an existing patient
    //Lab results will be sent to and stored on the blockchain unencrypted
    function UpdatePatientLabResults(string privateId, string updatedPatientLabResults) {
        labResults.UpdateStore(privateId, updatedPatientLabResults);
    }

    //Get a patient's lab results from the blockchain
    //Lab results will reach the front end unencrypted
    function GetPatientLabResults(string privateId) returns (string) {
        return bytes32ToString(labResults.RetrieveFromStore(privateId));
    }



    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}


contract Prescriptions {    
    mapping(string => string) dataStore;

    function AddToStore(string privId, string prescriptionRecord) {
        if(keccak256(dataStore[privId]) != keccak256("")){
            revert();
        } else {
            dataStore[privId] = prescriptionRecord;
        }
    }

    function UpdateStore(string privId, string prescriptionRecord) {
        if(keccak256(dataStore[privId]) == keccak256("")){
            revert();
        } else {
            dataStore[privId] = prescriptionRecord;
        }
    }

    function RetrieveFromStore(string privId) returns (bytes32) {
        return stringToBytes32(dataStore[privId]);
    }

    function stringToBytes32(string memory source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
}



contract StorageProxy {
    function createNewStorage(string name, string id, string publicId, string secureID);
    function getStorage(string patientPubId) returns (bytes32, bytes32, bytes32);
}

contract RecordProxy {
    function addToRecord(string secureID, string streetAddress);
    function updateRecord(string secureID, string streetAddress);
    function retrieveFromRecord(string secureID) returns (bytes32);
}

contract HealthDB {
    PatientsProxy patients = StorageProxy(); //address of storage which holds multiple records
    AddressesProxy addresses = RecordProxy(); //address of record 
    
    function createNewPatientAccount(string name, string dob, string publicId, string secureID) {
        patients.createNewPatient(name, dob, publicId, secureID);
    }

    function GetPatientAccount(string publicId) returns (string, string, string) {
        var (x, y, z) = patients.GetPatient(publicId);
        return (bytes32ToString(x), bytes32ToString(y), bytes32ToString(z));
    }


    //Add a patient address to the blockchain, only to be called when adding a patient's address for the first time 
    //Address should be encrypted on the front end and should not exist unencrypted in any form on the blockchain
    function AddPatientAddress(string secureID, string patientAddress) {
        addresses.AddToStore(secureID, patientAddress);
    }

    //Update a patient address on the blockchain, only to be called when updating the address of an existing patient
    //Address should be encrypted on the front end and should not exist unencrypted in any form on the blockchain
    function UpdatePatientAddress(string secureID, string updatedPatientAddress) {
        addresses.UpdateStore(secureID, updatedPatientAddress);
    }

    //Get a patient's address from the blockchain
    //Address must be unencrypted with the patient's passphrase once it reaches the front end
    function GetPatientAddress(string secureID) returns (string) {
        return bytes32ToString(addresses.RetrieveFromStore(secureID));
    }


    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
}


contract Addresses {

    mapping(string => string) dataStore;

    function addToRecord(string secureID, string _data) {
        if (keccak256(dataStore[secureID]) != keccak256("")){
            revert();
        } else {
            dataStore[secureID] = _data;
        }
    }

    function updateRecord(string secureID, string _data) {
        if (keccak256(dataStore[secureID]) == keccak256("")) {
            revert();
        } else {
            dataStore[secureID] = _data;
        }
    }

    function retrieveFromRecord(string secureID) returns (bytes32) {
        return stringToBytes32(dataStore[secureID]);
    }


    function stringToBytes32(string memory source) returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }
}