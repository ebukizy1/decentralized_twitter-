// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

import {LibAppStorage} from "../libraries/LibAppStorage.sol";
import "../libraries/Error.sol";



contract UserRegistrationFacet{
        LibAppStorage.Layout internal _appStorage;





    ///////// EVENT ////////////

    event ProfileSuccessful(address indexed sender,string indexed _imageUrl, bytes32 userbio);
    event RegistrationSuccessful(address indexed sender, bytes32 indexed _username, uint256 time);

    //////////////////////////////




    function createAccount(bytes32 _username, string memory _dateOfBirth) external { 
        if(_appStorage.usernameToAddress[_username] != address(0)) revert UserName_Already_Taken();
        if(_appStorage.addressToUsername[msg.sender] != bytes32(0)) revert User_Already_Register();
        _appStorage.usernameToAddress[_username] = msg.sender;
        _appStorage.addressToUsername[msg.sender] = _username;

        LibAppStorage.User storage _userDetails = _appStorage.user[msg.sender];
        _userDetails.username = _username;
        _userDetails.userAddress = msg.sender;
        _userDetails.dateOfBirth = _dateOfBirth;
        _userDetails.createdAt = block.timestamp;
        _appStorage.hasRegistered[msg.sender] = true;
        _appStorage.users.push(_userDetails);
        emit RegistrationSuccessful(msg.sender, _username, block.timestamp);
    }



    function setUpProfile(bytes32 _userBio, string calldata _imageUrl) external {
        if(!_appStorage.hasRegistered[msg.sender]) revert User_HasNot_Registered();
        if(_userBio == bytes32(0)) revert  invalid_description();
        LibAppStorage.User storage _foundUser = _appStorage.user[msg.sender];
       _foundUser.userBio  = _userBio;
       _foundUser.imageUrl = _imageUrl;
        emit ProfileSuccessful(msg.sender, _imageUrl, _userBio);
    }



    function getAllUser() external  view returns(LibAppStorage.User [] memory) {
      return  _appStorage.users;
    }


    function getUser(address _addr) external view returns(LibAppStorage.User memory _user){
        _user = _appStorage.user[_addr];
    }



}