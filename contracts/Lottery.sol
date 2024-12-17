// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


//1234567891234567891234567891234
enum YieldMode {
    AUTOMATIC,
    VOID,
    CLAIMABLE
}

enum GasMode {
    VOID,
    CLAIMABLE 
}

interface IBlast{
    // configure
    function configureContract(address contractAddress, YieldMode _yield, GasMode gasMode, address governor) external;
    function configure(YieldMode _yield, GasMode gasMode, address governor) external;

    // base configuration options
    function configureClaimableYield() external;
    function configureClaimableYieldOnBehalf(address contractAddress) external;
    function configureAutomaticYield() external;
    function configureAutomaticYieldOnBehalf(address contractAddress) external;
    function configureVoidYield() external;
    function configureVoidYieldOnBehalf(address contractAddress) external;
    function configureClaimableGas() external;
    function configureClaimableGasOnBehalf(address contractAddress) external;
    function configureVoidGas() external;
    function configureVoidGasOnBehalf(address contractAddress) external;
    function configureGovernor(address _governor) external;
    function configureGovernorOnBehalf(address _newGovernor, address contractAddress) external;

    // claim yield
    function claimYield(address contractAddress, address recipientOfYield, uint256 amount) external returns (uint256);
    function claimAllYield(address contractAddress, address recipientOfYield) external returns (uint256);

    // claim gas
    function claimAllGas(address contractAddress, address recipientOfGas) external returns (uint256);
    function claimGasAtMinClaimRate(address contractAddress, address recipientOfGas, uint256 minClaimRateBips) external returns (uint256);
    function claimMaxGas(address contractAddress, address recipientOfGas) external returns (uint256);
    function claimGas(address contractAddress, address recipientOfGas, uint256 gasToClaim, uint256 gasSecondsToConsume) external returns (uint256);

    // read functions
    function readClaimableYield(address contractAddress) external view returns (uint256);
    function readYieldConfiguration(address contractAddress) external view returns (uint8);
    function readGasParams(address contractAddress) external view returns (uint256 etherSeconds, uint256 etherBalance, uint256 lastUpdated, GasMode);
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint);
}


interface IBlastPoints {
	
   function configurePointsOperator(address operator) external;
}

contract Lottery {



uint startTimeCompetition;

uint endTimeCompetition;

address owner;

address governor;

uint totalPoints;

uint256 totalAvgPoints;



mapping(address => uint256) private _balances;

mapping(address => uint256) private _balancesTop;

mapping(address => bool) private _balancesReward;

bool internal locked;

uint numberOfTop;

address[] allAddresses;

uint256 yieldAll;
struct Weightedaverage{
        uint256 start;
        uint256 end;
        uint256 amount;

    }
mapping(address => Weightedaverage[]) weightedaverage;

struct Struct{
        address adr;
        uint256 amount;

}

struct Ticket{
        address adr;
        uint256[] numbers;

}
struct Tickets{
        Ticket[] ticket;
    

}

struct Winner{
       address adr;
       uint256 numberofright;
    

}

struct Winners{
        Winner[] winner;
    

}

struct Win{
        uint256 winner4;
        uint256 winner5;
        uint256 winner6;
    

}

struct paid{
        address adr;
        bool paid;
    

}

struct Paids{
        paid[] paid;
    

}


mapping(uint256 => Tickets)  _Lottery;

mapping(uint256 => uint256[])  Lots;

mapping(uint256 => Winners)  Lotwinners;
mapping(uint256 => Win)  Winall;
mapping(uint256 => uint256)  winmoney;
mapping(uint256 => Paids)  winmoneypaid;

mapping(address => bool)  api;

uint256 std;
uint256 Lotsdone;
uint256 Lotsdone1;
uint256 Lotsdone2;

uint256 commision;

uint256 randNo ;

address private wethTokenAddress = 0xd2f510928c29Da4f5b4E0737126bb7a4206Eb60d;

uint256 private numberofttokensfor = 900000000000000000;

bool loterrystoped;

uint256 _numberofweeks;  

uint256 jackpot;
    




error Unauthorized();

constructor(address gov, address ownerCompetition) {
		IBlast(0x4300000000000000000000000000000000000002).configureClaimableYield();
        IBlast(0x4300000000000000000000000000000000000002).configureClaimableGas();
		IBlast(0x4300000000000000000000000000000000000002).configureGovernor(gov); //only this address can claim yield
        governor = gov;
        owner = ownerCompetition;
        std = 1709463600;
        _numberofweeks = 3;
        IBlastPoints(0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800).configurePointsOperator(gov);
	}
   


 function readClaimableYield(address contractAddress) external view returns (uint256){

    return IBlast(0x4300000000000000000000000000000000000002).readClaimableYield(contractAddress);

   }
 function readYieldConfiguration(address contractAddress) external view returns (uint8){

        return  IBlast(0x4300000000000000000000000000000000000002).readYieldConfiguration(contractAddress);

    }

    
   modifier noReentrant() {
     require(!locked);
     locked = true;
      _;
     locked = false;
  }


function setNFTContract(address ct) external  {

     require(msg.sender == owner, "ERC20: not owner");
    wethTokenAddress = ct; 

  }

    function setTokensNumberEligible(uint256 toknumber) external  {

     require(msg.sender == owner, "ERC20: not owner");
    numberofttokensfor = toknumber; 

  }

  function setLotteryStop(bool stop) external  {

     require(msg.sender == owner, "ERC20: not owner");
    loterrystoped = stop; 

  }

function setStartDate(uint256 strdate) external  {

   require(msg.sender == owner, "ERC20: not owner");
    std = strdate; 

  }


 function setWeeks(uint256 numberofweeks) external  {

     require(msg.sender == owner, "ERC20: not owner");
    _numberofweeks = numberofweeks; 

  }

    function buyTicket(uint[] calldata numbers ) public payable {

    require(msg.value >= 0.001 ether, "ERC20: Not Ticket Price.");
    require(!loterrystoped, "ERC20: Loterry stopped.");
    uint startDate = std; 
    uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;

    commision += msg.value/10;

    //loterrynumber

    winmoney[loterrynumber] += msg.value -msg.value/10;
    
    _Lottery[loterrynumber].ticket.push(Ticket(msg.sender,numbers));
    api[msg.sender] = true;


    }

 function buyTickets(uint[] calldata numbers ) public payable 
    {

      require(msg.value >= 0.002 ether, "ERC20: Not Ticket Price.");
      require(numbers.length == 18, "wrong lenght");
      require(!loterrystoped, "ERC20: Loterry stopped.");
      uint wethBalance = IERC20(wethTokenAddress).balanceOf(msg.sender);
      require(wethBalance >= numberofttokensfor, "ERC20: Not allowed to buy.");
       uint startDate = std; 
   uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;

    commision += msg.value/10;

    //loterrynumber

    winmoney[loterrynumber] += msg.value -msg.value/10;

    uint[] memory balance = new uint[](6);

   balance[0] = numbers[0];
   balance[1] = numbers[1];
   balance[2] = numbers[2];
   balance[3] = numbers[3];
   balance[4] = numbers[4];
   balance[5] = numbers[5];

   uint[] memory balance1 = new uint[](6);

   balance1[0] = numbers[6];
   balance1[1] = numbers[7];
   balance1[2] = numbers[8];
   balance1[3] = numbers[9];
   balance1[4] = numbers[10];
   balance1[5] = numbers[11];

   uint[] memory balance2 = new uint[](6);

   balance2[0] = numbers[12];
   balance2[1] = numbers[13];
   balance2[2] = numbers[14];
   balance2[3] = numbers[15];
   balance2[4] = numbers[16];
   balance2[5] = numbers[17];

    //uint[] memory a = new [numbers[0], numbers[1],numbers[2],numbers[3],numbers[4],numbers[5]](6);
    //uint[] memory b = [numbers[6], numbers[7],numbers[8],numbers[9],numbers[10],numbers[11]];
    //uint[] memory c = [numbers[12], numbers[13],numbers[14],numbers[15],numbers[16],numbers[17]];

    uint[][] memory d = new uint[][](3);
    d[0] = balance;
    d[1] = balance1;
    d[2] = balance2;
    
    for (uint p = 0; p < 3; p++)
    {
     _Lottery[loterrynumber].ticket.push(Ticket(msg.sender,d[p]));
    }
    
    api[msg.sender] = true;


    }


 function getAPI(address adr) public view returns (bool) {
      
        if(api[adr])
        {
return true;
        }
        else{
return false;
        }      
        
    }

   function getCommission() public view returns (uint) {
      require(msg.sender == owner, "ERC20: not owner");
        return commision;
    }

      function getAmountofLottery(uint256 Lotterynumber) public view returns (uint) {
      //require(msg.sender == owner, "ERC20: not owner");
        return  winmoney[Lotterynumber];
    }

     function getLottery() public view returns (uint) {
        uint256 startDate = std; 
        uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
        return loterrynumber;
    }





   function getAllLotteryTickets(uint256 Lotterynumber) public view returns (Ticket[] memory) {
      require(msg.sender == owner, "ERC20: not owner");
      
      Ticket[] memory tickets = _Lottery[Lotterynumber].ticket;

      return tickets;
    }



function getLotteryTickets(uint256 Lotterynumber) public view returns (Ticket[] memory) {
      Ticket[] memory tickets = _Lottery[Lotterynumber].ticket;
      uint k = 0;
      for (uint p = 0; p < tickets.length; p++) {
        //uint j = 0;
        if(tickets[p].adr == msg.sender )
        {
            

           
          k += 1;
        }

       

      }
      
      Ticket[] memory numbertickets = new Ticket[](k);
      uint j = 0;
      for (uint u = 0; u < tickets.length; u++) {
        
        if(tickets[u].adr == msg.sender )
        {
            
         numbertickets[j] = tickets[u];
           
          j += 1;
        }

       

      }



        return numbertickets;
    }







function setLotteryResults(uint256 Lotterynumber) external  {
        require(msg.sender == owner, "ERC20: not owner");
       uint256[] memory numbertickets = new uint256[](6);
       uint256 startDate = std; 
        uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
       require(loterrynumber > Lotterynumber, "Lottery not ended yet");
        if(Lotterynumber > Lotsdone)
        {
        for (uint p = Lotsdone+1; p <= Lotterynumber; p++) {
        randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        numbertickets[0] =   randNo;

      do {                   // do while loop	
        randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        numbertickets[1] = randNo;
      }
      while (numbertickets[1] == numbertickets[0]);

        do {                   // do while loop	
        randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        numbertickets[2] = randNo;
      }
      while (numbertickets[2] == numbertickets[0] || numbertickets[2] == numbertickets[1]);

       do {                   // do while loop	
        randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        numbertickets[3] = randNo;
      }
      while (numbertickets[3] == numbertickets[0] || numbertickets[3] == numbertickets[1] || numbertickets[3] == numbertickets[2]);


      
       do {                   // do while loop	
        randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        numbertickets[4] = randNo;
      }
      while (numbertickets[4] == numbertickets[0] || numbertickets[4] == numbertickets[1] || numbertickets[4] == numbertickets[2] || numbertickets[4] == numbertickets[3]);


        do {                   // do while loop	
        randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        numbertickets[5] = randNo;
      }
      while (numbertickets[5] == numbertickets[0] || numbertickets[5] == numbertickets[1] || numbertickets[5] == numbertickets[2] || numbertickets[5] == numbertickets[3]  || numbertickets[5] == numbertickets[4]);
    
        // randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        //numbertickets[2] = randNo;
         //randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        //numbertickets[3] = randNo;
         //randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        //numbertickets[4] = randNo;
        //randNo = uint256 (keccak256(abi.encodePacked (msg.sender, block.timestamp, randNo)))%48 + 1;
        //numbertickets[5] = randNo;
       
       
        Lots[p] = numbertickets;
        Lotsdone = p;




      
        }
        
 
        }
  
        
    

     }


     
     
     




 function setLotteryWinners(uint256 Lotterynumber) external  {
        require(msg.sender == owner, "ERC20: not owner");
       uint256[] memory numbertickets = new uint256[](6);
       uint256 startDate = std; 
    uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
        require(loterrynumber > Lotterynumber, "Lottery not ended yet");
if(Lotterynumber > Lotsdone1)
        {
for (uint p = Lotsdone1; p <= Lotterynumber; p++) {

        numbertickets =  Lots[p] ;
        Lotsdone1 = p;
 for (uint k = 0; k < _Lottery[p].ticket.length; k++) {

    uint256[] memory walletnumbers = _Lottery[p].ticket[k].numbers; 
    address walletwinner = _Lottery[p].ticket[k].adr; 
    uint256 numberofwinnings = 0;

 
 
 
 for (uint g = 0; g < numbertickets.length; g++) {

     for (uint h = 0; h < walletnumbers.length; h++) {
      if(numbertickets[g]  == walletnumbers[h])
      {
         numberofwinnings += 1;
      }
       

     }
      
 }

 if(numberofwinnings > 3)
 {

    Lotwinners[p].winner.push(Winner(walletwinner,numberofwinnings));
 }



  }



        }
        
    
        }


     }   









   function getLotteryWinnersall(uint256 Lotterynumber) public view returns (Winner[] memory) {

        Winner[] memory numbertickets = new Winner[](Lotwinners[Lotterynumber].winner.length);
        uint256 startDate = std; 
        uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
        require(loterrynumber > Lotterynumber, "Lottery not started yet");
        require(Lotterynumber <= Lotsdone1, "Lottery not set yet");
        numbertickets = Lotwinners[Lotterynumber].winner;
        return numbertickets;
    }









function setLotteryWinnersAmount(uint256 Lotterynumber) external  {
        require(msg.sender == owner, "ERC20: not owner");
       uint256[] memory numbertickets = new uint256[](6);
       uint256 startDate = std; 
        uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
        require(loterrynumber > Lotterynumber, "Lottery not ended yet");
        if(Lotterynumber > Lotsdone2)
        {
for (uint p = Lotsdone2; p <= Lotterynumber; p++) {

        numbertickets =  Lots[p] ;
        Lotsdone2 = p;




   uint256 all = winmoney[p] + jackpot;

   uint256 all4 = all/5;
   uint256 all5 = all/2 - all4;
   uint256 all6 = all - all4 - all5;

   uint256 numberall4 = 0;
   uint256 numberall5 = 0;
   uint256 numberall6 = 0;

for (uint z = 0; z < Lotwinners[p].winner.length; z++) {
  
 if( Lotwinners[p].winner[z].numberofright == 4)
 {
    numberall4 +=1;
 }

 else if( Lotwinners[p].winner[z].numberofright == 5)
 {
    numberall5 +=1;
 }
 else if( Lotwinners[p].winner[z].numberofright == 6)
 {
    numberall6 +=1;
 }
 
 



}

uint256 result4 = 0;
uint256 result5 = 0;
uint256 result6 = 0;

uint256 jacky = all;

if(numberall4 != 0)
{

   result4 = all4/numberall4;

   jacky -= all4;

}

if(numberall5 != 0)
{

   result5 = all5/numberall5;

   jacky -= all5;

}

if(numberall6 != 0)
{

   result6 = all6/numberall6;

   jacky -= all6;

}


Winall[p] = Win(result4,result5,result6);
jackpot = jacky;


        }
        
       
        }
    

     }     
     
     
     
     
     
     
    
    
 function getLotteryResultsAmonts(uint256 Lotterynumber) public view returns (Win memory) {

        Win memory numbertickets;
        uint256 startDate = std; 
      uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
        require(loterrynumber > Lotterynumber, "Lottery not started yet");
       require(Lotterynumber <= Lotsdone, "Lottery not set yet");
        numbertickets = Winall[Lotterynumber];
        return numbertickets;
    }
    
    
    
    
    
    
    
    
     function getLotteryResults(uint256 Lotterynumber) public view returns (uint256[] memory) {

        uint256[] memory numbertickets = new uint256[](6);
        uint256 startDate = std; 
        uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
        require(loterrynumber > Lotterynumber, "Lottery not started yet");
        require(Lotterynumber <= Lotsdone, "Lottery not set yet");
        numbertickets = Lots[Lotterynumber];
        return numbertickets;
    }


     
     
     
function PayOutCommision()  public payable noReentrant{
   require(msg.sender == owner, "ERC20: not owner");
   require(commision > 0, "ERC20: Not enough funds.");
   address _to = msg.sender;
   (bool sent, bytes memory data) =_to.call{value: commision}("");
   require(sent, "Failed to send Ether");
   commision = 0;

  }   
     
     
     
     
     
function PayOutWinners(uint256 Lotterynumber)  public payable noReentrant{

        uint256[] memory numbertickets = new uint256[](6);
        uint256 startDate = std; 
        uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
        require(loterrynumber > Lotterynumber, "Lottery not started yet");
        require(Lotterynumber <= Lotsdone, "Lottery not set yet");
        numbertickets = Lots[Lotterynumber];
 
    




uint256 amount = 0;

for (uint z = 0; z < Lotwinners[Lotterynumber].winner.length; z++) {
  
 if( Lotwinners[Lotterynumber].winner[z].adr == msg.sender)
 {
 if( Lotwinners[Lotterynumber].winner[z].numberofright == 4)
 {
    amount += Winall[Lotterynumber].winner4;
 }

 else if( Lotwinners[Lotterynumber].winner[z].numberofright == 5)
 {
    amount += Winall[Lotterynumber].winner5;
 }
 else if( Lotwinners[Lotterynumber].winner[z].numberofright == 6)
 {
    amount += Winall[Lotterynumber].winner6;
 }
 
 
 }


 



}

    bool paid1 = false;
    for (uint q = 0; q < winmoneypaid[Lotterynumber].paid.length; q++) {

       if( winmoneypaid[Lotterynumber].paid[q].adr == msg.sender)
       {

        if(winmoneypaid[Lotterynumber].paid[q].paid)
        {paid1 = winmoneypaid[Lotterynumber].paid[q].paid;}

       }

    
    }

    require(!paid1, "ERC20: already paid out");
    address _to = msg.sender;
    require(_to != address(0), "ERC20: transfer to the zero address");
    require(amount > 0, "ERC20: Not enough funds.");
   
   (bool sent, bytes memory data) =_to.call{value: amount}("");
   require(sent, "Failed to send Ether");  
   winmoneypaid[Lotterynumber].paid.push( paid(_to, true));     
        
    }





function PayOut(uint256 _amount)  public payable noReentrant{

   require(msg.sender == owner, "ERC20: not owner");
  
   address _to = msg.sender;
   (bool sent, bytes memory data) =_to.call{value: _amount}("");
   require(sent, "Failed to send Ether");
  

}











// Function to receive Ether. msg.data must be empty
    receive() external payable {
   

   if(msg.sender == owner)
   {
    uint startDate = std; 
    uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
    winmoney[loterrynumber] += msg.value;

   }
     
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {

      
   if(msg.sender == owner)
   {
    uint startDate = std; 
    uint256 loterrynumber = (block.timestamp - startDate)/((1 weeks)*_numberofweeks) + 1;
    winmoney[loterrynumber] += msg.value;

   }

    }

 function getBalance() public view returns (uint) {
        return address(this).balance;
    }

}