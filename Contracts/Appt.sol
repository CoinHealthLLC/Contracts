pragma solidity ^0.4.16;


contract AppointmentSch {

    enum Status {
        NeedsConfirmation,
        Confirmed,
        Cancelled,
        Arrived,
        InProgress,
        Complete,
        Rescheduled,
        NoShow
    }

    Appointment[] public Appointments;

    struct Appointment {
        string apptId;       // EHR ID
        string patientId;       // Patient ID
        string providerId;      // Provider ID
        string reason;          // Reason
        string scheduledDate;   // Date of appointment
        string minutesDur;      // Appointment Duration
        string apptProfile;     // Appointment Profile

    }

    function addNewAppt (
        string _apptId,
        string _patientId,
        string _providerId,
        string _reason,
        string _scheduledDate,
        string _minutesDur,
        string _apptProfile
    ) returns (bool addNewApptStatus){
        Appointment memory newSchAppt;
    
        newSchAppt.apptId = _apptId;
        newSchAppt.patientId = _patientId;
        newSchAppt.providerId = _providerId;
        newSchAppt.reason = _reason;
        newSchAppt.scheduledDate = _scheduledDate;
        newSchAppt.minutesDur = _minutesDur;
        newSchAppt.apptProfile = _apptProfile;


        Appointments.push(newSchAppt);

        return true;
    }
        
    
/*
    function getApptDetails() constant returns (bytes32[], bytes32[], bytes32[], uint[], uint[]){
        uint length = Appointments.length;
        bytes32[] memory firstNames = new bytes32[](length);
        bytes32[] memory lastNames = new bytes32[](length);
        uint[] memory DBAccountNos = new uint[](length);
        bytes32[] memory userIDs = new bytes32[](length);
        uint[] memory mobiles = new uint[](length);    
        for (var i = 0; i < length; i++) {
            User memory currentUser;
            currentUser = Users[i];
            firstNames[i] = currentUser.firstName;
            lastNames[i] = currentUser.lastName;
            DBAccountNos[i] = currentUser.DBAccountNo;
            userIDs[i] = currentUser.userID;
            mobiles[i] = currentUser.mobile;
        }
        return(firstNames, lastNames, userIDs, DBAccountNos, mobiles);
    }
*/
}