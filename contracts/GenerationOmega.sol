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
import "./GenerationOmegaTypes.sol";
import "./interfaces/IGenerationOmegaRenderer.sol";

import "hardhat/console.sol";

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

  mapping(uint256 => GenerationOmegaTypes.GenOmega) characters;

  event CharacterMinted(address sender, uint256 tokenId);
  event CharacterInjured(address sender, uint256 hpRemaining);
  event CharacterHealed(address sender, uint256 hpRemaining);
  event CharacterXpEarned(address sender, uint256 xpTotal);

  constructor() ERC721B("Generation Omega", "GO") payable {}

  // ** - CORE - ** //

  function ownerClaim(uint256 tokenId) public onlyOwner {
    require(tokenId < GO_MAX, "Token ID invalid");

    GenerationOmegaTypes.GenOmega memory character;
    character.maxHp = 100;
    character.hp = 100;
    character.xp = 0;
    characters[tokenId] = character;

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
      GenerationOmegaTypes.GenOmega memory character;
      character.maxHp = 100;
      character.hp = 100;
      character.xp = 0;
      characters[supply] = character;
      emit CharacterMinted(msg.sender, supply++);
    }
  }

  function remainingTokens() public view returns (uint256) {
    return GO_MAX - _owners.length;
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
      GenerationOmegaTypes.GenOmega memory character;
      character.maxHp = 100;
      character.hp = 100;
      character.xp = 0;
      characters[supply] = character;
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
    return renderer.tokenURI(tokenId, characters[tokenId]);
  }

  // ** - Attribute Updates - ** //
  function injure(uint256 tokenId, uint256 damageAmount) public {
    require(tokenId < GO_MAX, "Token ID invalid");
    require(damageAmount > 0, "No damage value");

    GenerationOmegaTypes.GenOmega storage character = characters[tokenId];
    
    if (character.hp > damageAmount) {
      character.hp = character.hp - damageAmount;
    } else {
      character.hp = 0;
    } 
    emit CharacterInjured(msg.sender, character.hp);
  }

  function heal(uint256 tokenId, uint256 healAmount) public {
    require(tokenId < GO_MAX, "Token ID invalid");
    require(healAmount > 0, "No heal value");

    GenerationOmegaTypes.GenOmega storage character = characters[tokenId];
    
    if (character.maxHp < character.hp + healAmount) {
      character.hp = character.maxHp;
    } else {
      character.hp = character.hp + healAmount;
    } 
    emit CharacterHealed(msg.sender, character.hp);
  }

  function earnXp(uint256 tokenId, uint256 xpAmount) public {
    require(tokenId < GO_MAX, "Token ID invalid");
    require(xpAmount > 0, "No xp value");

    GenerationOmegaTypes.GenOmega storage character = characters[tokenId];
    
    character.xp = character.xp + xpAmount;
    emit CharacterXpEarned(msg.sender, character.xp);
  }

  function getRoll(string memory dieNumber, uint256 tokenId) internal view returns (string memory) {
    uint256 rand = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, tokenId, dieNumber)));

    rand = rand % 3;
    if (rand == 0) return "-1";
    if (rand == 1) return "0";
    else return "1";
  }

  function diceRoll(uint256 tokenId) public view returns (string memory) {
    require(tokenId < GO_MAX, "Token ID invalid");
    return string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          bytes(
            string(
              abi.encodePacked(
                '[',
                getRoll('FIRST', tokenId),',',
                getRoll('SECOND', tokenId),',',
                getRoll('THIRD', tokenId),',',
                getRoll('FOURTH', tokenId),
                ']'
              )
            )
          )
        )
      )
    );
  }
}
