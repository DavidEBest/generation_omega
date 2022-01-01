// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * Solidity Contract Template based on
 * Source: https://etherscan.io/address/
 *
 * Add Introduction Here
 *
 * Add Summary Here
 *
 * Curated by @marcelc63 - marcelchristianis.com
 * Each functions have been annotated based on my own research.
 *
 * Feel free to use and modify as you see appropriate
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

  address private _vaultAddress = 0x699cF25b70821ecD6430506314b4272cB4Fddd68;

  address public rendererContractAddress;

  bool public saleLive;

  event CharacterMinted(address sender, uint256 tokenId);

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
      _mint(msg.sender, supply);
      emit CharacterMinted(msg.sender, supply++);
    }
  }

  function remainingTokens() public view returns (uint256) {
    return GO_MAX - _owners.length;
  }

  // ** - ADMIN - ** //

  function withdraw() external onlyOwner {
    payable(_vaultAddress).transfer(address(this).balance);
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

  // NOTE: The team can call this function to update the renderer address to point to a new upgraded renderer.
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
