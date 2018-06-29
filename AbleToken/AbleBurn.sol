/**
* @title BurnABLE
* @dev ABLE burn contract.
*/
contract ABLEBurned {

    /**
    * @dev Function to contruct.
    */
    function() public payable {
    }

    /**
    * @dev Function to Selfdestruct contruct.
    */
    function burnMe() public {
        // Selfdestruct and send eth to self, 
        selfdestruct(address(this));
    }
}