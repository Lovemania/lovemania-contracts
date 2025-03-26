// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract LoveMania is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    IERC20Upgradeable public feeToken;
    uint256 public postFee;
    uint256 public postCount;

    struct Post {
        uint256 id;
        address author;
        string content;
        uint256 likes;
        uint256 timestamp;
    }

    struct Comment {
        address commenter;
        string text;
        uint256 timestamp;
    }

    mapping(uint256 => Post) public posts;
    mapping(uint256 => Comment[]) public comments;
    mapping(uint256 => mapping(address => bool)) public likedPosts;
    mapping(uint256 => address[]) public likers;

    event PostCreated(uint256 indexed id, address indexed author, string content, uint256 timestamp);
    event PostLiked(uint256 indexed id, address indexed liker);
    event CommentAdded(uint256 indexed postId, address indexed commenter, string text, uint256 timestamp);
    event FeeTokenUpdated(address indexed newToken);
    event PostFeeUpdated(uint256 newFee);
    event FeesWithdrawn(address indexed to, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _feeToken, uint256 _postFee) public initializer {
        require(_feeToken != address(0), "Invalid fee token");
        require(_postFee > 0, "Post fee must be greater than zero");

        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();

        feeToken = IERC20Upgradeable(_feeToken);
        postFee = _postFee;
    }

    /*** Owner Functions ***/
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function setFeeToken(address _feeToken) external onlyOwner {
        require(_feeToken != address(0), "Invalid fee token");
        feeToken = IERC20Upgradeable(_feeToken);
        emit FeeTokenUpdated(_feeToken);
    }

    function setPostFee(uint256 _postFee) external onlyOwner {
        require(_postFee > 0, "Post fee must be greater than zero");
        postFee = _postFee;
        emit PostFeeUpdated(_postFee);
    }

    function withdrawFee(address _to) external onlyOwner {
        require(_to != address(0), "Invalid address");
        uint256 balance = feeToken.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");

        feeToken.transfer(_to, balance);
        emit FeesWithdrawn(_to, balance);
    }

    /*** User Functions ***/
    function createPost(string calldata _content) external {
        require(bytes(_content).length > 0, "Content cannot be empty");
        require(feeToken.transferFrom(msg.sender, address(this), postFee), "Fee transfer failed");

        postCount++;
        posts[postCount] = Post(postCount, msg.sender, _content, 0, block.timestamp);
        emit PostCreated(postCount, msg.sender, _content, block.timestamp);
    }

    function likePost(uint256 _postId) external {
        require(posts[_postId].id != 0, "Post does not exist");
        require(!likedPosts[_postId][msg.sender], "Already liked");

        posts[_postId].likes++;
        likedPosts[_postId][msg.sender] = true;
        likers[_postId].push(msg.sender);

        emit PostLiked(_postId, msg.sender);
    }

    function addComment(uint256 _postId, string calldata _text) external {
        require(posts[_postId].id != 0, "Post does not exist");
        require(bytes(_text).length > 0, "Comment cannot be empty");

        comments[_postId].push(Comment(msg.sender, _text, block.timestamp));
        emit CommentAdded(_postId, msg.sender, _text, block.timestamp);
    }

    /*** Getter Functions ***/
    function getComments(uint256 _postId) external view returns (Comment[] memory) {
        require(posts[_postId].id != 0, "Post does not exist");
        return comments[_postId];
    }

    function getLikers(uint256 _postId) external view returns (address[] memory) {
        require(posts[_postId].id != 0, "Post does not exist");
        return likers[_postId];
    }
}
