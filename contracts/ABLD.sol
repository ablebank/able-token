pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/StandardBurnableToken.sol";
import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";

/**
 * @title ABLE Dollar token
 *
 * @dev Implementation of the 
 */
contract AbleDollarToken is Ownable, StandardBurnableToken, MintableToken {

    string public name = "ABLE Dollar X Token";
    string public symbol = "ABLD";
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 1000000000000000000000000000;

    bool public released = false;
    mapping (address => bool) public frozenAccount;

    event Release(bool released);
    event Freeze(address target, bool freezed);

    /**
     * @dev Modifier for release
     */
    modifier onlyReleased() {
        require(released);
        _;
    }

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    /**
     * @dev Function to release tokens
     * @param _release The boolean that is released or unReleased.
     */
    function release(bool _release) onlyOwner public {
        require(released != _release);
        released = _release;
        emit Release(released);
    }

    /**
     * @dev Function to freeze address
     * @param _target The address that will be freezed.
     * @param _freeze The boolean that is freezed or unfreezed.
     */
    function freezeAccount(address _target, bool _freeze) onlyOwner public {
        require(frozenAccount[_target] != _freeze);
        frozenAccount[_target] = _freeze;
        emit Freeze(_target, frozenAccount[_target]);
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) onlyReleased public returns (bool) {
        require(!frozenAccount[msg.sender]);        // Check if sender is frozen
        require(!frozenAccount[_to]);               // Check if recipient is frozen
        super.transfer(_to,_value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) onlyReleased public returns (bool) {
        require(!frozenAccount[msg.sender]);        // Check if approved is frozen
        require(!frozenAccount[_from]);             // Check if sender is frozen
        require(!frozenAccount[_to]);               // Check if recipient is frozen
        super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) onlyReleased public returns (bool) {
        super.approve(_spender, _value);
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint256 _addedValue) onlyReleased public returns (bool) {
        super.increaseApproval(_spender, _addedValue);
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint256 _subtractedValue) onlyReleased public returns (bool) {
        super.decreaseApproval(_spender, _subtractedValue);
    }
}