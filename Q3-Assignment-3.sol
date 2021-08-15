//Name: Muhammad Irfan
//Roll No: PIAIC1337739
//Quarter 3 Assignment 3

pragma solidity ^0.8.0;

contract MyTokens{
    
    address Owner;
    string TokenName;
    string TokenSymbol;
    uint256 TotalSupply;
    uint TokenConversion = 100;
    
    mapping (address => uint256) MyBalance;
    mapping (address => mapping(address => uint256)) Allowance;
    
    event _Transfer (address indexed _Receipent, uint256 _Tokens);
    event _Approved (address indexed _Owner, address indexed _Receipent, uint256 _Tokens);
    
    event _ValueReceived (address indexed _From, uint256 _Value);
    event _TransferFrom(address indexed _Owner, address indexed _To, uint256 _Tokens);
    
   constructor (string memory _TokenName, string memory _TokenSymbol, uint256 _TotalSupply){
        
        bytes memory CheckTokenName = bytes(_TokenName);
        bytes memory CheckTokenSymbol = bytes(_TokenSymbol);
        
        require (CheckTokenName.length > 0, "Please enter token name");
        require (CheckTokenSymbol.length > 0, "Please enter token symbol");
        require (_TotalSupply > 1000, "Minimum total supply should be greater than 1000");
        
        Owner = msg.sender;
        TokenSymbol = _TokenName;
        TokenSymbol = _TokenSymbol;
        TotalSupply = _TotalSupply;
        MyBalance[Owner] = TotalSupply;
        
    }
    
    modifier OnlyOwner(address _Sender){
        require (Owner == _Sender);
        _;
    }
    
    function IssueToken (address _Sender, uint256 _Value ) internal {
        
        require (_Value > 0, "No ether sent");
       
        uint256 _Tokens = (_Value/(10**18)) * TokenConversion;
       
        MyBalance[_Sender] += _Tokens;
        MyBalance[Owner] -= _Tokens;
        
        emit _ValueReceived(_Sender, _Value);
    }
    
    function ChangeConversion (uint256 _Rate) public OnlyOwner(msg.sender){
       
        require(_Rate > 0, "Must enter some value");
        
        TokenConversion = _Rate;
    }
    
    function PurchaseTokens() public payable {
        
        require(msg.value > 0, "Send some ether to purchase tokens");
        
        IssueToken(msg.sender, msg.value);
    }
    
    function TransferToken(address _Receipent, uint256 _Tokens) public {
        
        require(msg.sender != address(0),"Enter valid address");
        require(MyBalance[msg.sender] >= _Tokens, "Not have sufficient tokens to transfer");
        
        MyBalance[_Receipent] += _Tokens;
        MyBalance[msg.sender] -= _Tokens;
        
        emit _Transfer(_Receipent, _Tokens);
    }
    
    function myAllowance (address _Receipent, uint256 _Tokens) public {
        
        require(_Receipent != address(0),"Enter valid address");
        require(MyBalance[msg.sender] >= _Tokens, "Not have sufficient tokens to transfer");
        
        Allowance[msg.sender][_Receipent] += _Tokens;
        
        emit _Approved(msg.sender, _Receipent, _Tokens);
    }
    
    function TransferFrom (address _Owner, address _To, uint256 _Tokens) public {
        
        require(Allowance[_Owner][msg.sender] >= _Tokens, "Not have enough approval");
        require(MyBalance[_Owner] >= _Tokens, "Not have enough tokens");
        
        MyBalance[_Owner] -= _Tokens;
        Allowance[_Owner][msg.sender] -= _Tokens;
        MyBalance[_To] += _Tokens;
        
        emit _TransferFrom(_Owner, _To, _Tokens);
    }
    
    function Balance() public view returns(uint256 _Balance){
    
        _Balance = MyBalance[msg.sender];
    
        // return _Balance;
    }
    
    //Only owner of the contract can check the ether balance
    function ethBalance() public view OnlyOwner(msg.sender) returns(uint256 _Balance){
    
        _Balance = (address(this).balance)/10**18;
    
    }
  
    function AllowanceBalance(address _Owner, address _Spender) public view returns(uint256 _Balance){
        
        _Balance = Allowance[_Owner][_Spender];
        
    }
    
    receive () external payable {
      
        emit _ValueReceived (msg.sender, msg.value);
    
    }
    
    fallback () external payable {

        IssueToken(msg.sender, msg.value);
        
    }
    
    
}