// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Vote {
    // first entity
    struct Voter {
        string name;
        uint256 age;
        uint256 voterId;
        Gender gender;
        uint256 voteCandidateId; // candidate id to whom the voter has voted
        address voterAddress; // EOA of the voter
    }

    // second entity
    struct Candidate {
        string name;
        string party;
        uint256 age;
        Gender gender;
        uint256 candidateId;
        address candidateAddress; // candidate EOA
        uint256 votes; // number of votes
    }

    // third entity
    address public electionCommission;
    address public winner;
    uint256 nextVoterId = 1;
    uint256 nextCandidateId = 1;

    // voting period
    uint256 public startTime;
    uint256 public endTime;
    bool public stopVoting;

    mapping(uint256 => Voter) public voterDetails;
    mapping(uint256 => Candidate) public candidateDetails;

    enum VotingStatus {
        NotStarted,
        InProgress,
        Ended
    }
    enum Gender {
        NotSpecified,
        Male,
        Female,
        Other
    }

    event VoterRegistered(uint256 voterId, address voterAddress);
    event CandidateRegistered(uint256 candidateId, address candidateAddress);
    event VoteCast(uint256 voterId, uint256 candidateId);
    event VotingResultAnnounced(address winner);
    event VotingPeriodSet(uint256 startTime, uint256 endTime);
    event VotingStopped();

    constructor() {
        electionCommission = msg.sender; // msg.sender is a global variable
    }

    modifier isVotingOver() {
        require(
            block.timestamp <= endTime && stopVoting == false,
            "Voting time is over"
        );
        _;
    }

    modifier onlyCommissioner() {
        require(msg.sender == electionCommission, "Not authorized");
        _;
    }

    modifier isValidAge(uint256 _age) {
        require(_age >= 18, "Not eligible for voting");
        _;
    }

    modifier isValidCandidate(uint256 _candidateId) {
        require(
            candidateDetails[_candidateId].candidateId == _candidateId,
            "Invalid candidate"
        );
        _;
    }

    function registerCandidate(
        string calldata _name,
        string calldata _party,
        uint256 _age,
        Gender _gender
    ) external isValidAge(_age) {
        require(
            isCandidateNotRegistered(msg.sender),
            "You are already registered"
        );
        require(
            msg.sender != electionCommission,
            "Election Commission not allowed to register"
        );

        candidateDetails[nextCandidateId] = Candidate({
            name: _name,
            party: _party,
            gender: _gender,
            age: _age,
            candidateId: nextCandidateId,
            candidateAddress: msg.sender,
            votes: 0
        });
        emit CandidateRegistered(nextCandidateId, msg.sender);
        nextCandidateId++;
    }

    function isCandidateNotRegistered(address _person)
        private
        view
        returns (bool)
    {
        for (uint256 i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].candidateAddress == _person) {
                return false;
            }
        }
        return true;
    }

    function getCandidateList() public view returns (Candidate[] memory) {
        Candidate[] memory candidateList = new Candidate[](nextCandidateId - 1); // initialize an empty array of length = `nextCandidateId - 1`
        for (uint256 i = 0; i < candidateList.length; i++) {
            candidateList[i] = candidateDetails[i + 1];
        }
        return candidateList;
    }

    function isVoterNotRegistered(address _person) private view returns (bool) {
        for (uint256 i = 1; i < nextVoterId; i++) {
            if (voterDetails[i].voterAddress == _person) {
                return false;
            }
        }
        return true;
    }

    function registerVoter(
        string calldata _name,
        uint256 _age,
        Gender _gender
    ) external isValidAge(_age) {
        require(isVoterNotRegistered(msg.sender), "You are already registered");

        voterDetails[nextVoterId] = Voter({
            name: _name,
            age: _age,
            voterId: nextVoterId,
            gender: _gender,
            voteCandidateId: 0,
            voterAddress: msg.sender
        });
        emit VoterRegistered(nextVoterId, msg.sender);
        nextVoterId++;
    }

    function getVoterList() public view returns (Voter[] memory) {
        uint256 lengthArr = nextVoterId - 1;
        Voter[] memory voterList = new Voter[](lengthArr);
        for (uint256 i = 0; i < voterList.length; i++) {
            voterList[i] = voterDetails[i + 1];
        }
        return voterList;
    }

    function castVote(uint256 _voterId, uint256 _candidateId)
        external
        isVotingOver
        isValidCandidate(_candidateId)
    {
        require(block.timestamp >= startTime, "Voting has not started yet");
        require(
            voterDetails[_voterId].voteCandidateId == 0,
            "You have already voted"
        );
        require(
            voterDetails[_voterId].voterAddress == msg.sender,
            "You are not authorized"
        );

        voterDetails[_voterId].voteCandidateId = _candidateId; // voting to _candidateId
        candidateDetails[_candidateId].votes++; // increment _candidateId votes
        emit VoteCast(_voterId, _candidateId);
    }

    function setVotingPeriod(
        uint256 _startTimeDuration,
        uint256 _endTimeDuration
    ) external onlyCommissioner {
        require(
            _endTimeDuration > 3600,
            "_endTimeDuration must be greater than 1 hour"
        );
        startTime = block.timestamp + _startTimeDuration;
        endTime = startTime + _endTimeDuration;
        emit VotingPeriodSet(startTime, endTime);
    }

    function getVotingStatus() public view returns (VotingStatus) {
        if (startTime == 0) {
            return VotingStatus.NotStarted;
        } else if (endTime > block.timestamp && stopVoting == false) {
            return VotingStatus.InProgress;
        } else {
            return VotingStatus.Ended;
        }
    }

    function announceVotingResult() external onlyCommissioner {
        uint256 max = 0;
        for (uint256 i = 1; i < nextCandidateId; i++) {
            if (candidateDetails[i].votes > max) {
                max = candidateDetails[i].votes;
                winner = candidateDetails[i].candidateAddress;
            }
        }
        emit VotingResultAnnounced(winner);
    }

    function emergencyStopVoting() public onlyCommissioner {
        stopVoting = true;
        emit VotingStopped();
    }

    function getVotingResults() public view returns (Candidate[] memory) {
        Candidate[] memory candidateList = new Candidate[](nextCandidateId - 1);
        for (uint256 i = 0; i < candidateList.length; i++) {
            candidateList[i] = candidateDetails[i + 1];
        }
        return candidateList;
    }
}
