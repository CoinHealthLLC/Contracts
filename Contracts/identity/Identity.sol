pragma solidity ^0.4.17;

contract ERC725 {

    uint256 constant MANAGEMENT_KEY = 1;
    uint256 constant ACTION_KEY = 2;
    uint256 constant CLAIM_SIGNER_KEY = 3;
    uint256 constant ENCRYPTION_KEY = 4;

    event KeyAdded(address indexed key, uint256 indexed keyType);
    event KeyRemoved(address indexed key, uint256 indexed keyType);
    event KeyReplaced(address indexed oldKey, address indexed newKey, uint256 indexed keyType);
    event ExecutionRequested(bytes32 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Executed(bytes32 indexed executionId, address indexed to, uint256 indexed value, bytes data);
    event Approved(bytes32 indexed executionId, bool approved);

    function getKeyType(address _key) public constant returns(uint256 keyType);
    function getKeysByType(uint256 _type) public constant returns(address[]);
    function addKey(address _key, uint256 _type) public returns (bool success);
    function removeKey(address _key) public returns (bool success);
    function replaceKey(address _oldKey, address _newKey) public returns (bool success);
    function execute(address _to, uint256 _value, bytes _data) public returns (bytes32 executionId);
    function approve(bytes32 _id, bool _approve) public returns (bool success);
}

contract ERC735 {

    event ClaimRequested(bytes32 indexed claimId, uint256 indexed claimType, address indexed issuer, uint256 signatureType, bytes signature, bytes claim, string uri);
    event ClaimAdded(bytes32 indexed claimId, uint256 indexed claimType, address indexed issuer, uint256 signatureType, bytes signature, bytes claim, string uri);
    event ClaimRemoved(bytes32 indexed claimId, uint256 indexed claimType,  address indexed issuer, uint256 signatureType, bytes signature, bytes claim, string uri);
    event ClaimChanged(bytes32 indexed claimId, uint256 indexed claimType,  address indexed issuer, uint256 signatureType, bytes signature, bytes claim, string uri);

    struct Claim {
        uint256 claimType;
        address issuer; // msg.sender
        uint256 signatureType; // The type of signature
        bytes signature; // this.address + claimType + claim
        bytes claim;
        string uri;
    }

    function getClaim(bytes32 _claimId) public constant returns(uint256 claimType, address issuer, uint256 signatureType, bytes signature, bytes claim, string uri);
    function getClaimsIdByType(uint256 _claimType) public constant returns(bytes32[]);
    function addClaim(uint256 _claimType, address issuer, uint256 signatureType, bytes _signature, bytes _claim, string _uri) public returns (bytes32 claimId);
    function removeClaim(bytes32 _claimId) public returns (bool success);
}

contract Identity is ERC725, ERC735 {

        mapping (address => uint256) keys;
        mapping (bytes32 => Claim) claims;
        mapping (uint256 => address[]) keysByType;
        mapping (uint256 => bytes32[]) claimsByType;
        mapping (bytes32 => uint256) indexes;
        mapping (bytes32 => Transaction) txx;

        uint nonce = 0;

        struct Transaction {
            address to;
            uint value;
            bytes data;
            uint nonce;
        }


        modifier managerOnly {
            require(keys[msg.sender] == MANAGEMENT_KEY);
            _;
        }

        modifier managerOrSelf {
            require(keys[msg.sender] == MANAGEMENT_KEY || msg.sender == address(this));
            _;
        }

        modifier actorOnly {
            require(keys[msg.sender] == ACTION_KEY);
            _;
        }

        modifier claimSignerOnly {
            require(keys[msg.sender] == CLAIM_SIGNER_KEY);
            _;
        }


        function Identity() public {
            _addKey(msg.sender, MANAGEMENT_KEY);
        }


        function addKey(address _key, uint256 _type) public managerOrSelf returns (bool success) {
            _addKey(_key, _type);
        }


        function removeKey(address _key) public managerOrSelf returns (bool success) {
            _removeKey(_key);
        }


        function replaceKey(address _oldKey, address _newKey) public managerOrSelf returns (bool success) {
            _addKey(_newKey, getKeyType(_oldKey));
            _removeKey(_oldKey);
            return true;
        }



        function execute(
            address _to,
            uint256 _value,
            bytes _data
        ) 
            public 
            returns (bytes32 executionId) 
        {
            uint256 senderKey = keys[msg.sender];
            require(senderKey == MANAGEMENT_KEY || senderKey == ACTION_KEY);
            executionId = keccak256(_to, _value, _data, nonce);
            ExecutionRequested(executionId, _to, _value, _data);
            txx[executionId] = Transaction (
                {
                    to: _to,
                    value: _value,
                    data: _data,
                    nonce: nonce
                });
            if (senderKey == MANAGEMENT_KEY) {
                approve(executionId, true);
            }
        }

        function approve(
            bytes32 _id,
            bool _approve
        ) 
            public
            managerOnly
            returns (bool success)
        {
            require(txx[_id].nonce == nonce);
            nonce++;
            if (_approve) {
                success = txx[_id].to.call.value(txx[_id].value)(txx[_id].data);
            } 
        }


        function addClaim(
            uint256 _claimType,
            address _issuer,
            uint256 _signatureType,
            bytes _signature,
            bytes _claim,
            string _uri
        ) 
            public 
            claimSignerOnly 
            returns (bytes32 claimId) 
        {
            claimId = keccak256(_issuer, _claimType);
            claims[claimId] = Claim(
                {
                    claimType: _claimType,
                    issuer: _issuer,
                    signatureType: _signatureType,
                    signature: _signature,
                    claim: _claim,
                    uri: _uri
                }
            );
            indexes[keccak256(_issuer, _claimType)] = claimsByType[_claimType].length;
            claimsByType[_claimType].push(claimId);
        }


        function removeClaim(bytes32 _claimId) public returns (bool success) {
            Claim memory c = claims[_claimId];
            require(msg.sender == c.issuer || keys[msg.sender] == MANAGEMENT_KEY || msg.sender == address(this));
            uint claimIdTypePos = indexes[_claimId];
            delete indexes[_claimId];
            bytes32[] storage claimsTypeArr = claimsByType[c.claimType];
            bytes32 replacer = claimsTypeArr[claimsTypeArr.length-1];
            claimsTypeArr[claimIdTypePos] = replacer;
            indexes[replacer] = claimIdTypePos;
            delete claims[_claimId];
            claimsTypeArr.length--;
            return true;
        }


        function _addKey(address _key, uint256 _type) private {
            require(keys[_key] == 0);
            KeyAdded(_key, _type);
            keys[_key] = _type;
            indexes[keccak256(_key, _type)] = keysByType[_type].length;
            keysByType[_type].push(_key);
        }


        function _removeKey(address _key) private {
            uint256 kType = keys[_key];
            KeyRemoved(_key, kType);
            address[] storage keyArr = keysByType[kType];
            if (msg.sender != address(this) && kType == MANAGEMENT_KEY && keyArr.length == 1) {
                revert();
            }
            bytes32 oldIndex = keccak256(_key, kType);
            uint index = indexes[oldIndex];
            delete indexes[oldIndex];
            address replacer = keyArr[keyArr.length-1];
            keyArr[index] = replacer;
            indexes[keccak256(replacer, keys[replacer])] = index;
            keyArr.length--;
            delete keys[_key];
        }


        function getKeyType(address _key) public constant returns(uint256 keyType) {
            return keys[_key];
        }


        function getKeysByType(uint256 _type) public constant returns(address[]) {
            return keysByType[_type];
        }


        function getClaim(
            bytes32 _claimId
        )
            public 
            constant 
            returns
                (uint256 claimType,
                address issuer,
                uint256 signatureType,
                bytes signature,
                bytes claim,
                string uri)
        {
            Claim memory _claim = claims[_claimId];
            return (_claim.claimType, _claim.issuer, _claim.signatureType, _claim.signature, _claim.claim, _claim.uri);
        }


        function getClaimsIdByType(uint256 _claimType) public constant returns(bytes32[]) {
            return claimsByType[_claimType];
        }


    }