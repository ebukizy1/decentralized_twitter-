// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;

library LibAppStorage {



struct Post{
    uint8 postId;
    bytes32 content;
    string imageUrl;
    uint numberOfLikes;
    // Comment [] commentedList;
    address [] likersAddress;
    address poster;
    uint256 retweetCount;
    uint256 commentCount;

}


// struct Comment {
//     uint8 postId;
//     string imageUrl;
//     bytes32 postComment;
//     address commenter;
//     }






    struct User {
        bytes32 username;
        address userAddress;
        bytes32 userBio;
        address [] followers;
        address [] following;
        uint256 createdAt;
        Post [] post;
        Retweet [] retweet;
        uint256 totalPosts;
        string imageUrl;
        string dateOfBirth;
    }

    struct Retweet{
        address retweeter;
        Post postRetweeted;
        bytes32 text;
        uint256 retweetTime;
    }
    
    struct Layout{
        mapping(address =>User) user;
        mapping(bytes32 => address) usernameToAddress;
        mapping(address => bytes32) addressToUsername;
        mapping(address => bool) hasRegistered;
        mapping(uint256 =>Post) userPost;
        mapping(address user => mapping(uint postId => bool)) hasLiked;
        mapping(address => mapping(address => bool))  isFollowing; // Tracks if a user is following another user
        Post [] postList;
        User [] users;
        uint8 postId;



        


    }
    
}