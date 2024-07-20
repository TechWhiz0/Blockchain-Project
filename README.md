# Blockchain Voting System
This Solidity smart contract implements a blockchain-based voting system. It allows for the registration of candidates and voters, casting votes, and announcing the results. The contract ensures secure and transparent voting by utilizing Ethereum's blockchain technology.

Features
1- Candidate Registration: Candidates can register with their name, party, age, and gender.
2- Voter Registration: Voters can register with their name, age, and gender.
3- Vote Casting: Registered voters can cast their vote for a registered candidate.
4- Voting Period: The election commissioner can set the voting start and end times.
5- Voting Status: The contract provides real-time updates on the voting status (Not Started, In Progress, Ended).
6- Voting Results: The election commissioner can announce the voting results, and the results can be viewed by anyone.
7- Emergency Stop: The election commissioner can stop the voting process in case of an emergency.
8- Event Logging: Significant actions such as voter registration, candidate registration, vote casting, and result announcements are logged as events.

# Prerequisites
Solidity ^0.8.2

# Getting Started
You can run this contract in the Remix IDE, an online Solidity editor.

# Steps to Run in Remix IDE
Open Remix IDE: Go to Remix IDE.

Create a New File: Click on the "+" button in the file explorer panel to create a new file and name it Vote.sol.

Copy and Paste the Contract Code: Copy the Solidity contract code from this repository and paste it into the newly created file in Remix IDE.

Compile the Contract:

Go to the "Solidity Compiler" tab.
Ensure the compiler version is set to 0.8.2.
Click on the "Compile Vote.sol" button.
Deploy the Contract:

Go to the "Deploy & Run Transactions" tab.
Select "JavaScript VM" as the environment.
Click on the "Deploy" button.
Interact with the Contract:

After deployment, you can interact with the contract using the Remix interface.
Use the provided functions to register candidates and voters, cast votes, set voting periods, and announce results.

# Example Usage

Register Candidates:

Call registerCandidate(string _name, string _party, uint256 _age, Gender _gender).
Register Voters:

Call registerVoter(string _name, uint256 _age, Gender _gender).
Set Voting Period:

Call setVotingPeriod(uint256 _startTimeDuration, uint256 _endTimeDuration) as the election commissioner.
Cast Votes:

Call castVote(uint256 _voterId, uint256 _candidateId) to cast a vote.
Announce Results:

Call announceVotingResult() to announce the results as the election commissioner.
Emergency Stop Voting:

Call emergencyStopVoting() to stop voting in case of an emergency.
