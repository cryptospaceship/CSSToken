pragma solidity ^0.4.23;

import "./SpaceShipGameplay.sol";
import "./erc721.sol";
import "./SafeMath.sol";
import "./AddressUtils.sol";

contract SpaceShipOwnership is SpaceShipGameplay, ERC721 {

    using AddressUtils for address;

    mapping(uint => address) shipApprovals;
    
      // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) internal operatorApprovals;

    string tokenName = "Crypto Space Ship";
    string tokenSymbol = "CSS";
    bytes4 ERC721_RECEIVED =  0xf0b9e5ba;

    event Transfer(address indexed _from, address indexed _to, uint256 _shipId);

    event Approval(address indexed _owner, address indexed _approved, uint256 _shipId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /**
     *  TODO: To be compliance with the standard, see: 
     *   https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
     */

    function name()
        external
        view
        returns(string)
    {
        return tokenName;
    }

    function symbol() 
        external 
        view 
        returns(string) 
    {
        return tokenSymbol;
    }

    function balanceOf(address _owner)
        external
        view
        returns(uint256)
    {
        require(_owner != address(0));
        return ownerShipCount[_owner];
    }

    function ownerOf(uint256 _shipId)
        external
        view
        returns(address)
    {
        return shipToOwner[_shipId];
    }

    function _ownerOf(uint256 _shipId) 
        internal
        view
        returns(address)
    {
        address _owner = shipToOwner[_shipId];
        require(_owner != address(0));
        return _owner;
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * @dev The zero address indicates there is no approved address.
     * @dev There can only be one approved address per token at a given time.
     * @dev Can only be called by the token owner or an approved operator.
     * @param _to address to be approved for the given token ID
     * @param _shipId uint256 ID of the token to be approved
     */
    function approve(address _to, uint256 _shipId)
        external
        payable
    {
        address owner = _ownerOf(_shipId);
        require(_to != owner);
        require(msg.sender == owner || _isApprovedForAll(owner, msg.sender));

        if (_getApproved(_shipId) != address(0) || _to != address(0)) {
            shipApprovals[_shipId] = _to;
            emit Approval(owner, _to, _shipId);
        }
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * @param _shipId uint256 ID of the token to query the approval of
     * @return address currently approved for a the given token ID
     */
    function _getApproved(uint256 _shipId)
        internal
        view 
        returns(address) 
    {
        return shipApprovals[_shipId];
    }
    
    function getApproved(uint256 _shipId)
        external
        view
        returns(address)
    {
        return _getApproved(_shipId);        
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * @dev An operator is allowed to transfer all tokens of the sender on their behalf
     * @param _to operator address to set the approval
     * @param _approved representing the status of the approval to be set
     */
    function setApprovalForAll(address _to, bool _approved) 
        external
    {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param _spender address of the spender to query
     * @param _shipId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *  is an operator of the owner, or is the owner of the token
     */
    function isApprovedOrOwner(address _spender, uint256 _shipId)
        internal 
        view 
        returns (bool) 
    {
        address owner = _ownerOf(_shipId);
        return _spender == owner || _getApproved(_shipId) == _spender || _isApprovedForAll(owner, _spender);
    }


    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param _owner owner address which you want to query the approval of
     * @param _operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function _isApprovedForAll(address _owner, address _operator) 
        internal 
        view 
        returns(bool) 
    {
        return operatorApprovals[_owner][_operator];
    }
    
    function isApprovedForAll(address _owner, address _operator) 
        external 
        view 
        returns(bool) 
    {
        return _isApprovedForAll(_owner,_operator);    
    }

    function transferFrom(address _from, address _to, uint256 _shipId)
        external
        payable
    {
        require(isApprovedOrOwner(msg.sender,_shipId));
        _transfer(_from,_to,_shipId);
    }

    function _safeTransferFrom(address _from, address _to, uint256 _shipId, bytes _data)
        internal
    {
        require(isApprovedOrOwner(msg.sender,_shipId));
        _transfer(_from,_to,_shipId);
        require(checkAndCallSafeTransfer(_from,_to,_shipId,_data));
    }

    function safeTransferFrom(address _from, address _to, uint256 _shipId)
        external
        payable
    {
        _safeTransferFrom(_from,_to,_shipId,"");    
    }

    function safeTransferFrom(address _from, address _to, uint256 _shipId, bytes _data)
        external
        payable
    {
        _safeTransferFrom(_from,_to,_shipId,_data);
    }

    function checkAndCallSafeTransfer(
        address _from,
        address _to,
        uint256 _shipId,
        bytes _data
    )
        internal
        returns (bool)
    {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _shipId, _data);
        return (retval == ERC721_RECEIVED);
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address
     * @param _to address representing the new owner of the given token ID
     * @param _shipId uint256 ID of the token to be added to the tokens list of the given address
     */
    function addTokenTo(address _to, uint256 _shipId)
        internal 
    {
        require(shipToOwner[_shipId] == address(0));
        shipToOwner[_shipId] = _to;
        ownerShipCount[_to] = ownerShipCount[_to].add(1);
    }

    /**
     * @dev Internal function to remove a token ID from the list of a given address
     * @param _from address representing the previous owner of the given token ID
     * @param _shipId uint256 ID of the token to be removed from the tokens list of the given address
    */
    function removeTokenFrom(address _from, uint256 _shipId) 
        internal 
    {
        require(_ownerOf(_shipId) == _from);
        ownerShipCount[_from] = ownerShipCount[_from].sub(1);
        shipToOwner[_shipId] = address(0);
    }

    /**
     * @dev Internal function to clear current approval of a given token ID
     * @dev Reverts if the given address is not indeed the owner of the token
     * @param _owner owner of the token
     * @param _shipId uint256 ID of the token to be transferred
     */
    function clearApproval(address _owner, uint256 _shipId) 
        internal 
    {
        require(_ownerOf(_shipId) == _owner);
        if (shipApprovals[_shipId] != address(0)) {
            shipApprovals[_shipId] = address(0);
            emit Approval(_owner, address(0), _shipId);
        }   
    }

    function _transfer(address _from, address _to, uint256 _shipId)
        internal
    {
        require(_from != address(0));
        require(_to != address(0));
        clearApproval(_from, _shipId);
        removeTokenFrom(_from, _shipId);
        addTokenTo(_to, _shipId);
        emit Transfer(_from, _to, _shipId);
    }
} 