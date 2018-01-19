/**
 * @title MainSale
 * @dev The main ABLE token sale contract
 * 
 * ABI
 * [{"constant": false,"inputs": [{"name": "_multisigVault","type": "address"}],"name": "setMultisigVault","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "authorizerIndex","type": "uint256"}],"name": "getAuthorizer","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "exchangeRate","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "altDeposits","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_salePeriod","type": "string"}],"name": "setSalePeriod","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "recipient","type": "address"},{"name": "tokens","type": "uint256"}],"name": "authorizedCreateTokens","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [],"name": "finishMinting","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "mintedToken","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "owner","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_exchangeRate","type": "address"}],"name": "setExchangeRate","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "salePeriod","outputs": [{"name": "","type": "string"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_token","type": "address"}],"name": "retrieveTokens","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "totalAltDeposits","type": "uint256"}],"name": "setAltDeposit","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "start","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "recipient","type": "address"}],"name": "createTokens","outputs": [],"payable": true,"stateMutability": "payable","type": "function"},{"constant": false,"inputs": [{"name": "_addr","type": "address"}],"name": "addAuthorized","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "multisigVault","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "newOwner","type": "address"}],"name": "transferOwnership","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_start","type": "uint256"}],"name": "setStart","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "hardCap","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "token","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_hardCap","type": "address"}],"name": "setHardCap","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "_addr","type": "address"}],"name": "isAuthorized","outputs": [{"name": "","type": "bool"}],"payable": false,"stateMutability": "view","type": "function"},{"payable": true,"stateMutability": "payable","type": "fallback"},{"anonymous": false,"inputs": [{"indexed": false,"name": "recipient","type": "address"},{"indexed": false,"name": "ether_amount","type": "uint256"},{"indexed": false,"name": "pay_amount","type": "uint256"},{"indexed": false,"name": "exchangerate","type": "uint256"}],"name": "TokenSold","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "recipient","type": "address"},{"indexed": false,"name": "pay_amount","type": "uint256"}],"name": "AuthorizedCreate","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "hardcap","type": "uint256[]"}],"name": "hardcapChanged","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "salePeriod","type": "uint256"}],"name": "salePreiodChanged","type": "event"},{"anonymous": false,"inputs": [],"name": "MainSaleClosed","type": "event"}]
 */
contract MainSale is Ownable, Authorizable {
  using SafeMath for uint;
  event TokenSold(address recipient, uint ether_amount, uint pay_amount, uint exchangerate);
  event AuthorizedCreate(address recipient, uint pay_amount);
  event hardcapChanged(uint[] hardcap);
  event salePreiodChanged(uint salePeriod);
  event MainSaleClosed();

  AbleToken public token = new AbleToken();

  address public multisigVault;
  
  ExchangeRate public exchangeRate;
  HardCap public hardCap;
  string public salePeriod = "";
  uint public mintedToken = 0;

  uint public altDeposits = 0;
  uint public start = 1515942000; //new Date("Jun 24 2017 11:00:00 GMT").getTime() / 1000

  /**
   * @dev modifier to allow token creation only when the sale IS ON
   */
  modifier saleIsOn() {
    require(now > start && now < start + 30 days);
    _;
  }

  /**
   * @dev modifier to allow token creation only when the hardcap has not been reached
   */
  modifier isUnderHardCap() {
    require(multisigVault.balance + altDeposits <= hardCap.getTotalHardCap());
    require(mintedToken <= hardCap.getCap(salePeriod).mul(exchangeRate.getRate(salePeriod)));
    _;
  }

  /**
   * @dev Allows anyone to create tokens by depositing ether.
   * @param recipient the recipient to receive tokens. 
   */
  function createTokens(address recipient) public isUnderHardCap saleIsOn payable {
    uint rate;
    rate = exchangeRate.getRate(salePeriod);
    uint tokens = rate.mul(msg.value);
    mintedToken = mintedToken.add(tokens);
    token.mint(recipient, tokens);
    require(multisigVault.send(msg.value));
    TokenSold(recipient, msg.value, tokens, rate);
  }


  /**
   * @dev Allows to set the toal alt deposit measured in ETH to make sure the hardcap includes other deposits
   * @param totalAltDeposits total amount ETH equivalent
   */
  function setAltDeposit(uint totalAltDeposits) public onlyOwner {
    altDeposits = totalAltDeposits;
  }

  /**
   * @dev Allows authorized acces to create tokens. This is used for Bitcoin and ERC20 deposits
   * @param recipient the recipient to receive tokens.
   * @param tokens the number of tokens to be created. 
   */
  function authorizedCreateTokens(address recipient, uint tokens) public onlyAuthorized {
    token.mint(recipient, tokens);
    AuthorizedCreate(recipient, tokens);
  }


  /**
   * @dev Allows the owner to set the starting time.
   * @param _start the new _start
   */
  function setStart(uint _start) public onlyOwner {
    start = _start;
  }

  /**
   * @dev Allows the owner to set the multisig contract.
   * @param _multisigVault the multisig contract address
   */
  function setMultisigVault(address _multisigVault) public onlyOwner {
    if (_multisigVault != address(0)) {
      multisigVault = _multisigVault;
    }
  }

  /**
   * @dev Allows the owner to set the exchangerate contract.
   * @param _exchangeRate the exchangerate address
   */
  function setExchangeRate(address _exchangeRate) public onlyOwner {
    exchangeRate = ExchangeRate(_exchangeRate);
  }
  
  /**
   * @dev Allows the owner to set the hardcap contract.
   * @param _hardCap the hardcap address
   */
  function setHardCap(address _hardCap) public onlyOwner {
    hardCap = HardCap(_hardCap);
  }
  
  /**
   * @dev Allows the owner to set the saleperiod.
   * @param _salePeriod the saleperiod
   */
  function setSalePeriod(string _salePeriod) public onlyOwner {
    salePeriod = _salePeriod;
    mintedToken = 0;
  }

  /**
   * @dev Allows the owner to finish the minting. This will create the 
   * restricted tokens and then close the minting.
   * Then the ownership of the ABLE token contract is transfered 
   * to this owner.
   */
  function finishMinting() public onlyOwner {
    token.finishMinting();
    token.transferOwnership(owner);
    MainSaleClosed();
  }

  /**
   * @dev Allows the owner to transfer ERC20 tokens to the multi sig vault
   * @param _token the contract address of the ERC20 contract
   */
  function retrieveTokens(address _token) public onlyOwner {
    ERC20 token = ERC20(_token);
    token.transfer(multisigVault, token.balanceOf(this));
  }

  /**
   * @dev Fallback function which receives ether and created the appropriate number of tokens for the 
   * msg.sender.
   */
  function() external payable {
    createTokens(msg.sender);
  }

}