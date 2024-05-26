// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.9;
import {LibAppStorage} from "../libraries/LibAppStorage.sol";
import "../libraries/Error.sol";


contract SocialMediaFacet{
    LibAppStorage.Layout internal _appStorage;


  //////////EVENT ////////////////////////////////////////////////////////////////////////////////
                                                                                         ///      
    event PostCreatedSuccessful(address indexed sender,uint indexed postId,string _imageUrl);  ///
    event CommentSuccessful(address indexed _sender,uint8 indexed _postId,bytes32  _comment);  ///
    event LikePost(address indexed sender,uint indexed _postId,uint indexed numberOfLikes);    ///
    event RetweetSuccessful(address indexed retweeter, uint256 indexed postId, bytes32 text);  ///
    event UnLikePost(address indexed sender,uint indexed _postId,uint indexed numberOfLikes);  ///
    event Follow(address indexed follower, address indexed following);                     ///
    event Unfollow(address indexed follower, address indexed following);                       ///
                                                                                               ///
  /////////////////////////////////////////////////////////////////////////////////////////////////





function createPost(bytes32 _content, string memory _imageUrl) external {
       uint8 _postId = _appStorage.postId + 1;
       LibAppStorage.User storage _foundUser = _appStorage.user[msg.sender];
       LibAppStorage.Post storage _newPost = _appStorage.userPost[_postId];  

       _newPost.postId = _postId;
       _newPost.content = _content;
       _newPost.imageUrl =  _imageUrl;
       _newPost.poster = msg.sender;
       _foundUser.totalPosts = _foundUser.totalPosts + 1; 
       _foundUser.post.push(_newPost);
       _appStorage.postList.push(_newPost);
       _appStorage.postId++;
        emit PostCreatedSuccessful(msg.sender, _foundUser.totalPosts, _imageUrl);
}


function getAllUserPost(address _address)
 external view returns(LibAppStorage.Post [] memory) {
    return _appStorage.user[_address].post;
} 


// function commentOnPost(uint8 _postId, bytes32 _comment, string calldata _imageUrl)
//  external{
//         _validatePostId(_postId);
//      LibAppStorage.Post storage _foundPost = _appStorage.userPost[_postId]; 
//      LibAppStorage.Comment storage _newComment;
//      _newComment.postId = _foundPost.postId;
//      _newComment.postComment = _comment;
//      _newComment.imageUrl = _imageUrl;
//      _newComment.commenter = msg.sender;
//      _foundPost.commentCount = _foundPost.commentCount + 1;

//      _foundPost.commentedList.push(_newComment);
//     emit CommentSuccessful(msg.sender,_postId,_comment);
//  }

 
// function fetchAllPostComment(uint256 _postId) external view returns(LibAppStorage.Comment [] memory) {
//         _validatePostId(_postId);
//         LibAppStorage.Post memory _foundPost =  _appStorage.userPost[_postId];
//         uint256 _commentCount  =  _foundPost.commentedList.length;

//         LibAppStorage.Comment[] memory comments = new LibAppStorage.Comment[](_commentCount);
//         for(uint96 count; count <= _commentCount; count++){
//             comments[count] = _foundPost.commentedList[count];
//         }
//         return comments;

// }



function retweetOnPost(uint256 _postId, bytes32 _text) external {
    _validatePostId(_postId);
    LibAppStorage.Post storage _foundPost = _appStorage.userPost[_postId];
    LibAppStorage.User storage _currentUser = _appStorage.user[msg.sender];
    if(_foundPost.poster == msg.sender) revert Cant_Retweet_Your_Own_Post();

    LibAppStorage.Retweet memory _newRetweet;
    _newRetweet.retweeter = msg.sender;
    _newRetweet.postRetweeted = _foundPost;
    _newRetweet.text = _text;
    _newRetweet.retweetTime = block.timestamp;
    _foundPost.retweetCount =  _foundPost.retweetCount + 1;
    _currentUser.retweet.push(_newRetweet);

    emit RetweetSuccessful(msg.sender, _postId, _text);
}




function likePost(uint256 _postId) external {
      _validatePostId(_postId);

      LibAppStorage.Post storage _foundPost = _appStorage.userPost[_postId];
        if (!_appStorage.hasLiked[msg.sender][_postId]) {
            // like post
            _foundPost.numberOfLikes++;
              _foundPost.likersAddress.push(msg.sender);
          _appStorage.hasLiked[msg.sender][_postId] = true;
          emit LikePost(msg.sender, _postId, _foundPost.numberOfLikes);

        } else {
            // Like post
            _foundPost.numberOfLikes--;
            _removeLiker(_foundPost, msg.sender);
            _appStorage.hasLiked[msg.sender][_postId] = false;

        }
        emit UnLikePost(msg.sender, _postId, _foundPost.numberOfLikes);
    }

    function getAllPostLikes(uint256 _postId) external view returns(address [] memory) {
           _validatePostId(_postId);
        return  _appStorage.userPost[_postId].likersAddress;
    }


    
    function toggleFollowUser(address _userToToggle) external {
        _addressZeroCheck(msg.sender);
        _addressZeroCheck(_userToToggle);
        if(msg.sender == _userToToggle) revert Cannot_Follow_Unfollow_Yourself();
            // LibAppStorage.User storage _currentUser = _appStorage.user[msg.sender];

        if (_appStorage.isFollowing[msg.sender][_userToToggle]) {
            // Unfollow logic
            address[] storage _following = _appStorage.user[msg.sender].following;
            for (uint i = 0; i < _following.length; i++) {
                if (_following[i] == _userToToggle) {
                    _following[i] = _following[_following.length - 1];
                    _following.pop();
                    break;
                }
            }

            address[] storage _followers = _appStorage.user[_userToToggle].followers;
            for (uint i = 0; i < _followers.length; i++) {
                if (_followers[i] == msg.sender) {
                    _followers[i] = _followers[_followers.length - 1];
                    _followers.pop();
                    break;
                }
            }
            _appStorage.isFollowing[msg.sender][_userToToggle] = false;

            emit Unfollow(msg.sender, _userToToggle);
        } else {
            // Follow logic
            _appStorage.user[msg.sender].following.push(_userToToggle);
            _appStorage.user[_userToToggle].followers.push(msg.sender);
            _appStorage.isFollowing[msg.sender][_userToToggle] = true;

            emit Follow(msg.sender, _userToToggle);
        }
    }
  
     
    function _removeLiker(LibAppStorage.Post storage _post, address _liker) private {
            for (uint256 i = 0; i < _post.likersAddress.length; i++) {
                if (_post.likersAddress[i] == _liker) {
                    _post.likersAddress[i] = _post.likersAddress[_post.likersAddress.length - 1];
                    _post.likersAddress.pop();
                    return;
                }
            }
    }


    function _validatePostId(uint _postId) private  view{
        if(_postId < 1 || _postId > _appStorage.postId) revert Invalid_Post_ID();
    }

    function _addressZeroCheck(address _addr) private view{
        if(_appStorage.user[_addr].userAddress == address(0)) revert User_HasNot_Registered();
    }


}
