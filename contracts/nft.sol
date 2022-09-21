pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

 // @author jamill hallak


contract nft is Ownable,ERC721 {
    struct nft {
        uint256 id;
        string title;
        string description;
        uint256 price;
        string date;
        string authorName;
        address payable author;
        address payable owner;

        // 1 means token has sale status (or still in selling) and 0 means token is already sold,
        // ownership transferred and moved to off-market gallery
        uint256 status;
        string image;
        string  _baseURIextended;

    }

    struct nftTxn {
        uint256 id;
        uint256 price;
        address seller;
        address buyer;
        uint256 txnDate;
        uint256 status;
    }

    uint256 private pendingnftCount; // gets updated during minting(creation), buying and reselling
    mapping(uint256 => nftTxn[]) private nftTxns;
    uint256 public index; // uint256 value; is cheaper than uint256 value = 0;.
    nft[] public nfts;
    mapping(uint256 => string) private _tokenURIs;

 

    

 function _TokenURI(uint256 _optionId) public view returns (string memory) {
        string memory baseURI;
        ( , , , , , , , , , , baseURI)=findnft(_optionId);
    return baseURI;
    
  } 
  function get_price(uint256 id)  public view returns(uint256) {
      uint256 x ;
    ( , , , x, , , , , , , )=findnft(id);
     return x ;
  }
  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    return _TokenURI(_tokenId);
    
  }
    


    event LognftSold(
        uint256 _tokenId,
        string _title,
        string _authorName,
        uint256 _price,
        address _author,
        address _current_owner,
        address _buyer
    );
    event LognftTokenCreate(
        uint256 _tokenId,
        string _title,
        string _category,
        string _authorName,
        uint256 _price,
        address _author,
        address _current_owner
    );
    event LognftResell(uint256 _tokenId, uint256 _status, uint256 _price);

    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    /* Create or minting the token */
    function createToken(
        string memory _title,
        string memory _description,
        string memory _date,
        string memory _authorName,
        uint256 _price,
        string memory _image,
        string memory url

    ) public {
        require(bytes(_title).length > 0, "The title cannot be empty");
        require(bytes(_date).length > 0, "The Date cannot be empty");
        require(
            bytes(_description).length > 0,
            "The description cannot be empty"
        );
        require(_price > 0, "The price cannot be empty");
        require(bytes(_image).length > 0, "The image cannot be empty");

        nft memory _nft = nft({
            id: index,
            title: _title,
            description: _description,
            price: _price,
            date: _date,
            authorName: _authorName,
            author: payable(msg.sender),
            owner: payable(msg.sender),
            status: 1,
            image: _image,
            _baseURIextended: url 
        });

        nfts.push(_nft); // push to the array
        uint256 tokenId = nfts.length - 1; // array length -1 to get the token ID = 0, 1,2 ...
        _safeMint(msg.sender, tokenId);

        emit LognftTokenCreate(
            tokenId,
            _title,
            _date,
            _authorName,
            _price,
            msg.sender,
            msg.sender
        );
        index++;
        pendingnftCount++;
    }

    /*
     *   The buynft() function verifies whether the buyer has enough balance to purchase the nft.
     *   The function also checks whether the seller and buyer both have a valid account address.
     *   The token owner's address is not the same as the buyer's address. The seller is the owner
     *   of the nft. Once all of the conditions have been verified, it will stnft the payment and
     *   nft token transfer process. _transfer transfers an nft token from the seller to the buyer's
     *   address. _current_owner.transfer will transfer the buyer's payment amount to the nft owner's
     *   account. If the seller pays extra Ether to buy the nft, that ether will be refunded to the
     *   buyer's account. Finally, the buynft() function will update nft ownership information in
     *   the blockchain. The status will change to 0, also known as the sold status. The function
     *   implementations keep records of the nft transaction in the nftTxn array.
     */
    function buynft(uint256 _tokenId) public payable {
        (
            uint256 _id,
            string memory _title,
            ,
            uint256 _price,
            uint256 _status,
            ,
            string memory _authorName,
            address _author,
            address payable _current_owner,
            ,

        ) = findnft(_tokenId);
        require(_current_owner != address(0));
        require(msg.sender != address(0));
        require(msg.sender != _current_owner);
        require(msg.value >= _price);
        require(nfts[_tokenId].owner != address(0));

        _safeTransfer(_current_owner, msg.sender, _tokenId, ""); // transfer ownership of the nft
        //return extra payment
        if (msg.value > _price)
            payable(msg.sender).transfer(msg.value - _price);
        //make a payment to the current owner
        _current_owner.transfer(_price);

        nfts[_tokenId].owner = payable(msg.sender);
        nfts[_tokenId].status = 0;

        nftTxn memory _nftTxn = nftTxn({
            id: _id,
            price: _price,
            seller: _current_owner,
            buyer: msg.sender,
            txnDate: block.timestamp,
            status: _status
        });

        nftTxns[_id].push(_nftTxn);
        pendingnftCount--;
        emit LognftSold(
            _tokenId,
            _title,
            _authorName,
            _price,
            _author,
            _current_owner,
            msg.sender
        );
    }

    /* Pass the token ID and get the nft Information */
    function findnft(uint256 _tokenId)
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            uint256,
            uint256 status,
            string memory,
            string memory,
            address,
            address payable,
            string memory,
            string memory
        )
    {
        nft memory nft = nfts[_tokenId];
        return (
            nft.id,
            nft.title,
            nft.description,
            nft.price,
            nft.status,
            nft.date,
            nft.authorName,
            nft.author,
            nft.owner,
            nft.image,
            nft._baseURIextended

        );
    }

    /*
     * The resellnft() function verifies whether the sender's address is valid and makes sure
     * that only the current nft owner is allowed to resell the nft. Then, the resellnft()
     * function updates the nft status from 0 to 1 and moves to the sale state. It also updates
     * the nft's selling price and increases the count of the current total pending nfts. emit
     * LognftResell() is used to add a log to the blockchain for the nft's status and price
     * changes.
     */
    function resellnft(uint256 _tokenId, uint256 _price) public payable {
        require(msg.sender != address(0));
        require(isOwnerOf(_tokenId, msg.sender));
        nfts[_tokenId].status = 1;
        nfts[_tokenId].price = _price;
        pendingnftCount++;
        emit LognftResell(_tokenId, 1, _price);
    }

    /* returns all the pending nfts (status =1) back to the user */
    function findAllPendingnft()
        public
        view
        returns (
            uint256[] memory,
            address[] memory,
            address[] memory,
            uint256[] memory
        )
    {
        if (pendingnftCount == 0) {
            return (
                new uint256[](0),
                new address[](0),
                new address[](0),
                new uint256[](0)
            );
        }

        uint256 arrLength = nfts.length;
        uint256[] memory ids = new uint256[](pendingnftCount);
        address[] memory authors = new address[](pendingnftCount);
        address[] memory owners = new address[](pendingnftCount);
        uint256[] memory status = new uint256[](pendingnftCount);
        uint256 idx = 0;
        for (uint256 i = 0; i < arrLength; ++i) {
            nft memory nft = nfts[i];
            if (nft.status == 1) {
                ids[idx] = nft.id;
                authors[idx] = nft.author;
                owners[idx] = nft.owner;
                status[idx] = nft.status;
                idx++;
            }
        }

        return (ids, authors, owners, status);
    }

    /* Return the token ID's that belong to the caller */
    function findMynfts()
        public
        view
        returns (uint256[] memory _mynfts, uint256 tokens)
    {
        require(msg.sender != address(0));
        uint256 numOftokens = balanceOf(msg.sender);
        if (numOftokens == 0) {
            return (new uint256[](0), 0);
        } else {
            uint256[] memory mynfts = new uint256[](numOftokens);
            uint256 idx = 0;
            uint256 arrLength = nfts.length;
            for (uint256 i = 0; i < arrLength; i++) {
                if (ownerOf(i) == msg.sender) {
                    mynfts[idx] = i;
                    idx++;
                }
            }
            return (mynfts, numOftokens);
        }
    }

    /* return true if the address is the owner of the token or else false */
    function isOwnerOf(uint256 tokenId, address account)
        public
        view
        returns (bool)
    {
        address owner = ownerOf(tokenId);
        require(owner != address(0));
        return owner == account;
    }

    function get_symbol() external view returns (string memory) {
        return symbol();
    }

    function get_name() external view returns (string memory) {
        return name();
    }
    function withdraw() public payable onlyOwner {
    
    
    // Do not remove this otherwise you will not be able to withdraw the funds.
    // =============================================================================
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    require(os,"withdraw failed");
    // =============================================================================
  }
}