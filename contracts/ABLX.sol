pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/PausableToken.sol";

/**
 * @title ABLE token
 *
 * @dev Implementation of the ABLE token 
 */
contract AbleToken is Ownable, StandardBurnableToken, MintableToken, PausableToken {

    string public name = "ABLE X Token";
    string public symbol = "ABLX";
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 25000000000000000000000000000;

    mapping (address => bool) public frozenAccount;

    event Freeze(address target, bool freezed);

    /**
     * @dev constructor for AbleToken
     */
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     */
    function () external payable {
        revert();
    }

    /**
     * @dev Function to freeze address
     * @param _target The address that will be freezed.
     * @param _freeze The boolean that is freezed or unfreezed.
     */
    function freezeAccount(address _target, bool _freeze) onlyOwner public {
        require(_target != address(0));
        require(frozenAccount[_target] != _freeze);
        frozenAccount[_target] = _freeze;
        emit Freeze(_target, frozenAccount[_target]);
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!frozenAccount[msg.sender]);        // Check if sender is frozen
        require(!frozenAccount[_to]);               // Check if recipient is frozen
        return super.transfer(_to,_value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(!frozenAccount[msg.sender]);        // Check if approved is frozen
        require(!frozenAccount[_from]);             // Check if sender is frozen
        require(!frozenAccount[_to]);               // Check if recipient is frozen
        return super.transferFrom(_from, _to, _value);
    }
}