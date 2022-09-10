// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract DPetitioner{
    string public name;
    address public owner;
    enum Gender {Male, Female, Other}
    uint256 nextProposal;
    //Stores info about accountholders
    struct AccountInfo{
        address account;
        string firstName;
        string lastName;
        Gender gender;
    }

    mapping(address => AccountInfo) public voters;
    
    struct proposal{
        uint256 id;
        address creator;
        bool exists;
        string title;
        string description;
        uint deadline;
        uint upvotes;
        uint downvotes;
        bool passed;
        mapping(address => bool) voted;
    }
    mapping(uint256 => proposal) public Proposals;


    constructor(){
        name = "DPetitioner";
        owner = msg.sender;
        nextProposal = 1;
    }
    function addVoter(address _newVoter, string memory _fname, string memory _lname, Gender _gender) public{
        // require(msg.sender == owner);
        require(_newVoter != address(0));
        require(_gender <= Gender.Other);
        require(voters[_newVoter].account == address(0));
        AccountInfo storage acc = voters[_newVoter];
        acc.account = _newVoter;
        acc.firstName = _fname;
        acc.lastName = _lname;
        acc.gender = _gender;
    }
    function addProposal(string memory _title, string memory _desc, uint _deadline) public returns(uint256){
        require(voters[msg.sender].account != address(0));
        proposal storage newProposal = Proposals[nextProposal];
        newProposal.id = nextProposal;
        newProposal.creator = msg.sender;
        newProposal.exists = true;
        newProposal.title = _title;
        newProposal.description = _desc;
        newProposal.deadline = _deadline;
        newProposal.upvotes = 0;
        newProposal.downvotes = 0;
        newProposal.passed = false;
        
        nextProposal++;
        return (nextProposal -1);
    }
    function hasVoted(uint256 _id, address sender) public view returns(bool){
        require(_id < nextProposal && _id>0);
        if(Proposals[_id].voted[sender]){
            return true;
        }else{
            return false;
        }
    }
    function castVote(uint256 _id, bool upvote) public{
        require(_id<nextProposal && _id>0);
        require(Proposals[_id].exists);
        require(!(hasVoted(_id, msg.sender)));
        require(voters[msg.sender].account != address(0));
        Proposals[_id].voted[msg.sender] = true;
        if(upvote){
            Proposals[_id].upvotes += 1;
        }else{
            Proposals[_id].downvotes += 1;
        }
    }
    function calculatePetitionResult(uint256 _id) public returns(bool){
        require(_id>0 && _id<nextProposal);
        require(Proposals[_id].exists);
        if(Proposals[_id].upvotes > Proposals[_id].downvotes){
            Proposals[_id].passed = true;
        }else{
            Proposals[_id].passed = false;
        }
        Proposals[_id].exists = false;
        return Proposals[_id].passed;
    }
    function checkResultById(uint _id) public view returns(bool){
        require(_id>0 && _id<nextProposal);
        return Proposals[_id].passed;
    }
}