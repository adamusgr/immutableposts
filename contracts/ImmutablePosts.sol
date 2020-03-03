pragma solidity >= 0.5.0 < 0.7.0;
//pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/ownership/Ownable.sol";

/// @title Immutable Post Contract
/// @author Seb @Increaseo on the concept idea of Troy @Increaseo
/// @notice For now, this contract create a post, category have a fee split.

contract ImmutablePosts is Ownable {
    
    // The Post
    struct Post {
        string title;
        string description;
        string category;
    }

    //Category 
    struct Category {
        string name;
    }
    uint nbarticles = 0;

    // Beneficiary Wallet address this is setup in the plugin
   
    //Our Wallet
    address payable walletaddress = 0x6711be7371C275F62Ee7F69e4Cb7C09ACEd852cC; // Account 3 in Ganache

    //Post to Owner
    mapping (uint => address) public postToOwner;
    // Owner to Post
    mapping (address => uint) ownerToPost;
    //Post Count per Owner
    mapping (address => uint) ownerPostCount;
    
    mapping (address => uint) balances;

    // New Post created
    event newPost(uint id, string title, string description, string category);
    // New Category created
    event newCategory(uint id, string categoryname);

    // ARRAY METHOD for Posts and Categories
    Post[] public posts;
    Category[] public categories;

    // Fee to post a Post approx 20USD
    uint postFee = 87200000000000000 wei;

    //Percentage share
    uint commissionPercentage = 5;
    
    //Create a new post
    function createPostandPay(string memory _title, string memory _description, string memory _category, address payable _pluginbeneficiary) public payable{
          require(msg.value == postFee);
          uint id = posts.push(Post(_title,_description,_category)) - 1;
          postToOwner[id] = msg.sender;
          ownerToPost[msg.sender] = id;
          ownerPostCount[msg.sender]++;
          emit newPost(id, _title, _description,_category);
          nbarticles ++;
          //Pay and Split the Fee
          payAndSplitFee(postFee, _pluginbeneficiary);
        
          
    }
    //Split fee for the post between Beneficiary and Us
    function payAndSplitFee(uint _fullfee, address payable _pluginbeneficiary) public payable {
          

          uint postFeeBeneficiary = _fullfee * commissionPercentage / 100;
          _pluginbeneficiary.transfer(postFeeBeneficiary);
          uint postFeeUs = _fullfee - postFeeBeneficiary;
          walletaddress.transfer(postFeeUs);
    }

    //Create new category
    function createCategory (string memory _categoryname) public {
         uint id = categories.push(Category(_categoryname)) - 1;
         emit newCategory(id, _categoryname);
    }
    

    // Experimental so removed
    // function getPosts() public view returns (Post[] memory){
    //   Post[] memory id = new Post[](nbarticles);
    //   for (uint i = 0; i < nbarticles; i++) {
    //       Post storage post = posts[i];
    //       id[i] = post;
    //   }
    //   return id;
    //  }
     
    //  function getPostbyAccount(address _myAddress) public view returns (uint) {
    //     return ownerToPost[_myAddress];
    //   }

     //Get Post per Account
     function getPostbyAccount(address _owner) external view returns(uint[] memory) {
        uint[] memory result = new uint[](ownerPostCount[_owner]);
        uint counter = 0;
        for (uint i = 0; i < posts.length; i++) {
          if (postToOwner[i] == _owner) {
            result[counter] = i;
            counter++;
          }
        }
        return result;
      }
     
      // Get All Numbers of Posts
      function getNbArticles() public view returns (uint _nbarticle){
         uint counter = 0;
        for (uint i = 0; i < posts.length; i++) {
            counter++;
        }
        return counter;
      }

     // Get Post by Id Array
      function getPostbyId(uint pos) public view returns(string memory title, string memory description, string memory category){ 
        Post storage postss = posts[pos];
        return (postss.title, postss.description, postss.category);
     } 

     // For Admin of the contract to control the fee
     function setFee(uint _fee) external onlyOwner {
        _fee = _fee * 10**18;
        postFee = _fee;
     }
      function getFee() public view returns (uint)   {
        return postFee;
     }
     
      // For Admin of the contract to control the percentage
     function setPercentage(uint _percent) external onlyOwner {
        _percent = _percent;
        commissionPercentage = _percent;
     }


     // Setup Beneficiary wallet adddress
   //  function setUpBeneficiary(address payable _newbeneficiary) public {
   //     pluginbeneficiary = _newbeneficiary;
   //  }
   //   function getNewBenef() public view returns (address payable)   {
   //      return  pluginbeneficiary;
   //   } 
    // Update our Wallet address Admin only 
     function setUpOurWallerAddress(address payable _ourwallet) public onlyOwner {
       walletaddress = _ourwallet;
    }

    //Balance 
  //  function getBalanceInEth(address addr) public view returns(uint) {
  //       return ConvertLib.convert(getBalance(addr),2);
  //   }

    // function getBalance(address addr) public view returns(uint) {
    //     return balances[addr];
    // }


}
