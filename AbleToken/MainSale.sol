pragma solidity ^0.4.19;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./Authorizable.sol";
import "./AbleToken.sol";
import "./Authorizable.sol";
import "./Authorizable.sol";

/**
 * @title MainSale
 * @dev The main ABLE token sale contract
 * 
 * ABI
 * [{"constant": false,"inputs": [{"name": "_multisigVault","type": "address"}],"name": "setMultisigVault","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [],"name": "startTrading","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "authorizerIndex","type": "uint256"}],"name": "getAuthorizer","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "exchangeRate","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "altDeposits","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_salePeriod","type": "string"}],"name": "setSalePeriod","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "recipient","type": "address"},{"name": "tokens","type": "uint256"}],"name": "authorizedCreateTokens","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "ethDeposits","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [],"name": "stopTrading","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [],"name": "finishMinting","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "owner","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_exchangeRate","type": "address"}],"name": "setExchangeRate","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "salePeriod","outputs": [{"name": "","type": "string"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_token","type": "address"}],"name": "retrieveTokens","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "totalAltDeposits","type": "uint256"}],"name": "setAltDeposit","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "start","outputs": [{"name": "","type": "uint256"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "recipient","type": "address"}],"name": "createTokens","outputs": [],"payable": true,"stateMutability": "payable","type": "function"},{"constant": false,"inputs": [{"name": "_addr","type": "address"}],"name": "addAuthorized","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "multisigVault","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "newOwner","type": "address"}],"name": "transferOwnership","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": false,"inputs": [{"name": "_start","type": "uint256"}],"name": "setStart","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [],"name": "hardCap","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": true,"inputs": [],"name": "token","outputs": [{"name": "","type": "address"}],"payable": false,"stateMutability": "view","type": "function"},{"constant": false,"inputs": [{"name": "_hardCap","type": "address"}],"name": "setHardCap","outputs": [],"payable": false,"stateMutability": "nonpayable","type": "function"},{"constant": true,"inputs": [{"name": "_addr","type": "address"}],"name": "isAuthorized","outputs": [{"name": "","type": "bool"}],"payable": false,"stateMutability": "view","type": "function"},{"payable": true,"stateMutability": "payable","type": "fallback"},{"anonymous": false,"inputs": [{"indexed": false,"name": "recipient","type": "address"},{"indexed": false,"name": "ether_amount","type": "uint256"},{"indexed": false,"name": "pay_amount","type": "uint256"},{"indexed": false,"name": "exchangerate","type": "uint256"}],"name": "TokenSold","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "recipient","type": "address"},{"indexed": false,"name": "pay_amount","type": "uint256"}],"name": "AuthorizedCreate","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "hardcap","type": "uint256[]"}],"name": "hardcapChanged","type": "event"},{"anonymous": false,"inputs": [{"indexed": false,"name": "salePeriod","type": "uint256"}],"name": "salePreiodChanged","type": "event"},{"anonymous": false,"inputs": [],"name": "MainSaleClosed","type": "event"}]
 */
contract MainSale is Ownable, Authorizable {
  using SafeMath for uint;
  event TokenSold(address recipient, uint ether_amount, uint pay_amount, uint exchangerate);
  event AuthorizedCreate(address recipient, uint pay_amount);
  event hardcapChanged(uint[] hardcap);
  event salePreiodChanged(uint salePeriod);
  event MainSaleClosed();

  AbleToken public token = new AbleToken();
  //AbleToken public token = 0x3AA6eaa1127063A3700EFdd589eB75fF1b5907b3;

  address public multisigVault;
  
  ExchangeRate public exchangeRate;
  HardCap public hardCap;
  string public salePeriod = "";
  uint public ethDeposits = 0;
  uint public altDeposits = 0;
  uint public start = 1522119600; // Web 27 March 2018 12:00:00 GMT+09:00
  //uint public personalHarcap = 2500000000000000000;

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
    require(ethDeposits + altDeposits <= hardCap.getCap(salePeriod));
    _;
  }

  /**
   * @dev Allows anyone to create tokens by depositing ether.
   * @param recipient the recipient to receive tokens. 
   */
  function createTokens(address recipient) public isUnderHardCap saleIsOn payable {
    uint rate;
    rate = exchangeRate.getRate(salePeriod);
    /*
    if ((msg.value > personalHarcap) &&(token.balanceOf(recipient) > personalHarcap * rate)) {
      revert();
    }
    */
    uint tokens = rate.mul(msg.value);
    ethDeposits = ethDeposits.add(msg.value);
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
    ethDeposits = 0;
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
   * @dev Allows the owner to start the trading ABLE tokens. 
   */
  function startTrading() public onlyOwner {
    token.startTrading();
  }
  
  /**
   * @dev Allows the owner to stop the trading ABLE tokens. 
   */
  function stopTrading() public onlyOwner {
    token.stopTrading();
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