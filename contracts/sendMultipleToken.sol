pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
         public view returns (uint256);

    function transferFrom(address from, address to, uint256 value)
         public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title sendMultipleABLX
 * @dev send multiple ABLX
 */
contract sendMultipleABLX {
    // ERC20 basic token contract being sent
    ERC20 public token;
    
    constructor(ERC20 _token) public {
        // Set ABLX token address
        token = _token;
    }
    
    /**
     * @dev Function to send ABLX multiply
     * @param _to the array of address for sending.
     * @param _value the uint for amount of sending.
     * @return boolean flag if send is success.
     */
	function sendMulABLX(address[] _to, uint256[] _value) public returns (bool _success) {
		require(_to.length==_value.length);
		require(_to.length<=255);

		// loop through to addresses and send value
		for (uint8 i = 0; i < _to.length; i++) {
		    require(token.transferFrom(msg.sender, _to[i], _value[i]));
		}
		
		return true;
	}

}
