pragma solidity 0.4.16;


import ".././base/Ownable.sol";

/**
 * @title SecureTransferProxy
 * @author RH
 * @dev Version 1.618
 */

contract SecureTransferProxy is Ownable {

    /**
     * @dev onlyAuthorized senders can initiate a transfer
     * @notice this is not necesarily the contract owner!
     */
    modifier onlyAuthorized {
        require(authorized[msg.sender]);
        _;
    }

    /**
     * @param target is the target address required to be authorized
     * @dev requires that the target address is authorized
     */
    modifier targetAuthorized(address target) {
        require(authorized[target]);
        _;
    }

    /**
     * @param target is the target address required to be authorized
     * @param proxy is the proxy address from which authorized is transferring on behalf
     * @dev both sides of transfer are authorized in order for transfer
     */
    modifier channelSecure(address target, address proxy) {
        require(authorized[target] && authorized[proxy]);
        _;
    }

    /**
     * @param target is the target address required to NOT be authorized
     * @dev requires that the target address is NOT authorized
     * @notice ensures a target address has successfully been deauthorized
     */
    modifier targetNotAuthorized(address target) {
        require(!authorized[target]);
        _;
    }

    // mapping authorization to address as boolean
    mapping (address => bool) public authorized;

    // array of authorized addresses
    address[] public authorities;

    // logging authorization and de-authorization of addresses
    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);
    event LogAuthorizedAddressRemoved(address indexed target, address indexed caller);

    /**
     * @dev addAuthorizedAddress only when target address currently un-authorized
     * @param _target is the address to be authorized
     * @notice authorizes an address when called by owner
     */
    function addAuthorizedAddress(address _target)
        public
        onlyOwner
        targetNotAuthorized(_target)
    {
        authorized[_target] = true;
        authorities.push(_target);
        LogAuthorizedAddressAdded(_target, msg.sender);
    }

    /**
     * @dev removeAuthorizedAddress only when target address currently authorized
     * @param _target is the address to be de-authorized
     * @notice de-authorizes an address when called by owner
     */
    function removeAuthorizedAddress(address _target)
        public
        onlyOwner
        targetAuthorized(_target)
    {
        delete authorized[_target];
        for (uint i = 0; i < authorities.length; i++) {
            if (authorities[i] == _target) {
                authorities[i] = authorities[authorities.length - 1];
                authorities.length -= 1;
                break;
            }
        }
        LogAuthorizedAddressRemoved(_target, msg.sender);
    }

    /**
     * @dev secureTransfer can only be initiated by an authorized address
     * @dev secureTransfer only possible between two authorized addresses
     * @param data is the data to be Securely Transferred
     * @param proxy is the authorized proxy address
     * @param target is the authorized target
     * @param value is the value of transfer if given value
     */
    function transferFrom(
        bytes32 data, //inherited or defined externally
        address proxy,
        address target,
        uint value)
        public
        onlyAuthorized
        channelSecure(proxy, target)
        returns (bool)
    {
        return; // (data).transferFrom(proxy, target, value);
    }

    /**
     * @dev returns array with all authorized addresses
     */
    function getAuthorizedAddresses()
        public
        constant
        returns (address[])
    {
        return authorities;
    }
}
