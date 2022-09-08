//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract LotusNFT is ERC721, Ownable {
    string private a; //gas control
    using Strings for uint256;
    uint256 public supplyMinted = 0;
    string public baseURI = "https://ipfs.io/ipfs/xxxxxxxxxxxxxxxxxxxxxxxx/";

    mapping(uint256 => uint256) tokentype;
    mapping(uint256 => uint256) tokenbiome;

    mapping(uint256 => uint256) tokenmintedblock;

    constructor() ERC721("LotusNFT", "PLANT") {}

    function mint() external payable {
        require(msg.value >= .01 ether);
        require(tx.origin == msg.sender, "CANNOT MINT THROUGH A CONTRACT");
        uint256 id = supplyMinted+1;

        uint256 seedtype = random();
        tokentype[id] = seedtype;
        tokenbiome[id] = 0;

        tokenmintedblock[id] = block.number;

        _safeMint(msg.sender, id);
        supplyMinted++;
    }

    function water(uint256 tokenId) external {
        require(msg.sender == ownerOf(tokenId));
        require(tokenbiome[tokenId] == 0);

        if (block.number > (tokenmintedblock[tokenId] + 1000)) {
            //Desert biome
            tokenbiome[tokenId] = 2;
        }
        else {
            //Wild biome
            tokenbiome[tokenId] = 1;  
        }

    }

    //View
    function random() private view returns (uint) {
        // 0 - 19 value
        uint randomHash = uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender)));
        return randomHash % 20;
    } 

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    //0-4 biome
    //0-19 type
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId),"ERC721Metadata: URI query for nonexistant token");
        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenbiome[tokenId], tokentype[tokenId], ".json")): "";
    }
  
    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

}