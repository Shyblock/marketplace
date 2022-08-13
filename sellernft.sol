/*create a simple marketplace where user can sell their erc721 nfts for erc20 tokens , 
so the seller will set the price of their nft and if the buyer is interested in that nft,
then they can buy that nft with their erc20 tokens */

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
contract Nft is ERC721{
    address public nftCreator;
    constructor() ERC721("MyNft", "NFT"){
        nftCreator = msg.sender;
    }
    function mintNft(address to, uint256 id) public {
        _mint(to, id);
    }
}
contract token is ERC20{
    constructor() ERC20("token", "tk"){
        _mint(msg.sender, 1000*10**18);
    }
}
contract nftMarketplace{
    IERC721 public nftContract;
    IERC20 public tokenContract;
    address public nftCreator;
    struct nft{
        uint256 tokenId;
        uint256 price;
        address seller;
    }
    mapping (uint256 => nft) public nftMap;
     constructor(address _tokenContract, address _nftContract, address _nftCreator) {
        tokenContract = IERC20(_tokenContract);
        nftContract = IERC721(_nftContract);
        nftCreator = _nftCreator;
    }
    function createSale(uint256 tokenId, uint256 price) public {
        nftMap[tokenId] = nft(tokenId, price, msg.sender);
        nftContract.safeTransferFrom(msg.sender, address(this), tokenId);
    }
    function BuyNFT(uint256 tokenId, uint256 nftPrice) public {
        require(nftMap[tokenId].price == nftPrice,"nftPrice must equal to decided price by seller");
        uint sentCreator = (nftPrice / 100) * 10;   //10% sent to creator
        uint sentSeller = (nftPrice / 100) * 90;      //90% sent to nft Seller
        tokenContract.transferFrom(msg.sender, nftCreator, sentCreator);  //token send to creator
        tokenContract.transferFrom(msg.sender, nftMap[tokenId].seller, sentSeller);  //token send to seller
        nftContract.safeTransferFrom(address(this), msg.sender, tokenId);   //nft transfer
    }
}
