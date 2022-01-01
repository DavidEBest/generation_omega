// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * Generation Omega
 *
 * Generation Omega is a near future, post-apocalyptic
 * setting for an RPG. The mintable tokens are randomized
 * characters with attributes and skills.
 *
 * Developed by @scrimmage_us, based on contract
 * breakdowns by @marcelc63.
 */

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./library/ERC721B.sol";
import "./library/Base64.sol";
import "./interfaces/IGenerationOmegaRenderer.sol";

contract GenerationOmega is Ownable, ERC721B {
  using Strings for uint256;
  using ECDSA for bytes32;

  uint256 public constant GO_PUBLIC = 4500;
  uint256 public constant GO_MAX = 5000;
  uint256 public constant GO_GIFT = 500;
  uint256 public constant GO_PRICE = 0.02 ether;
  uint256 public constant GO_PER_MINT = 4;
  uint256 public giftedAmount;

  address public rendererContractAddress;

  bool public saleLive;

  constructor() ERC721B("Generation Omega", "GO") payable {}

  // ** - CORE - ** //

  function ownerClaim(uint256 tokenId) public onlyOwner {
    require(tokenId < GO_MAX, "Token ID invalid");
    _safeMint(owner(), tokenId);
  }

  function buy(
    uint256 tokenQuantity
  ) external payable {
    require(saleLive, "SALE_CLOSED");
    require(tokenQuantity <= GO_PER_MINT, "EXCEED_GO_PER_MINT");
    require(GO_PRICE * tokenQuantity <= msg.value, "INSUFFICIENT_ETH");

    uint256 supply = _owners.length;
    require(supply + tokenQuantity <= GO_PUBLIC, "EXCEED_MAX_SALE_SUPPLY");
    for (uint256 i = 0; i < tokenQuantity; i++) {
      _mint(msg.sender, supply++);
    }
  }

  // ** - ADMIN - ** //

  function withdraw() external onlyOwner {
    payable(owner()).transfer(address(this).balance);
  }

  function gift(address[] calldata receivers) external onlyOwner {
    uint256 supply = _owners.length;

    require(supply + receivers.length <= GO_MAX, "MAX_MINT");
    require(giftedAmount + receivers.length <= GO_GIFT, "NO_GIFTS");

    for (uint256 i = 0; i < receivers.length; i++) {
      giftedAmount++;
      _safeMint(receivers[i], supply++);
    }
  }

  function toggleSaleStatus() external onlyOwner {
    saleLive = !saleLive;
  }

  function setRendererContractAddress(address _rendererContractAddress)
    public
    onlyOwner
  {
    rendererContractAddress = _rendererContractAddress;
  }

  // ** - Rendering - ** //

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    if (rendererContractAddress == address(0)) {
      return "";
    }

    IGenerationOmegaRenderer renderer = IGenerationOmegaRenderer(rendererContractAddress);
    return renderer.tokenURI(tokenId);
  }
}
