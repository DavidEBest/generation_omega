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

pragma solidity ^0.8.4;

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

  // ** - MISC - ** //

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function getAttribute(string memory attribute, uint256 tokenId) internal pure returns (uint256) {
    uint256 rand = random(string(abi.encodePacked(attribute, toString(tokenId))));
    return rand % 7;
  }

  function getSkill(string memory val, uint256 tokenId, string memory level) internal view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(val, toString(tokenId))));
    return string(abi.encodePacked(skills[rand % skills.length], ' ',level)); 
  }

  string[] private skills = [
    "Research",
    "Investigate",
    "Resources",
    "Willpower",
    "Fight",
    "Shoot",
    "Acting",
    "Empathy",
    "Drive",
    "Athletics",
    "Making"
  ];

  function tokenURI(uint256 tokenId)
    external
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    // Attributes
    // Attributes are on a -3 to +3 scale, mapped to 0-7
    uint256 str = getAttribute('str', tokenId);
    uint256 dex = getAttribute('dex', tokenId);
    uint256 con = getAttribute('con', tokenId);
    uint256 intel = getAttribute('int', tokenId);
    uint256 wis = getAttribute('wis', tokenId);
    uint256 cha = getAttribute('cha', tokenId);

    // Skills
    string memory greatSkill = getSkill('sk1', tokenId, '(+2)');
    string memory goodSkill1 = getSkill('sk2', tokenId, '(+1)');
    string memory goodSkill2 = getSkill('sk3', tokenId, '(+1)');

    // SVG
    string[19] memory parts;
    parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
    parts[1] = string(abi.encodePacked('Generation Omega #', toString(tokenId)));
    parts[2] = '</text><text x="10" y="40" class="base">';
    parts[3] = string(abi.encodePacked('STR:', toString(str)));
    parts[4] = '</text><text x="10" y="60" class="base">';
    parts[5] = string(abi.encodePacked('DEX:', toString(dex)));
    parts[6] = '</text><text x="10" y="80" class="base">';
    parts[7] = string(abi.encodePacked('CON:', toString(con)));
    parts[8] = '</text><text x="10" y="100" class="base">';
    parts[9] = string(abi.encodePacked('INT:', toString(intel)));
    parts[10] = '</text><text x="10" y="120" class="base">';
    parts[11] = string(abi.encodePacked('WIS:', toString(wis)));
    parts[12] = '</text><text x="10" y="140" class="base">';
    parts[13] = string(abi.encodePacked('CHA:', toString(cha)));
    parts[14] = '</text><text x="10" y="160" class="base">';
    parts[15] = 'Skills';
    parts[16] = '</text><text x="10" y="180" class="base">';
    parts[17] = string(abi.encodePacked(greatSkill, ', ', goodSkill1, ', ', goodSkill2));
    parts[18] = '</text></svg>';

    string memory output = string(
      abi.encodePacked(
        parts[0],
        parts[1],
        parts[2],
        parts[3],
        parts[4],
        parts[5],
        parts[6],
        parts[7],
        parts[8]
      )
    );
    output = string(
      abi.encodePacked(
        output,
        parts[9],
        parts[10],
        parts[11],
        parts[12],
        parts[13],
        parts[14],
        parts[15],
        parts[16],
        parts[17],
        parts[18]
      )
    );
     


    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "Gen Omega #', toString(tokenId), '",',
            '"attributes":{',
            '"strength":', toString(str), ',',
            '"dexterity":', toString(dex), ',',
            '"constitution":', toString(con), ',',
            '"intelligence":', toString(intel), ',',
            '"wisdom":', toString(wis), ',',
            '"charisma":', toString(cha), '},',
            '"skills":["', 
            greatSkill, '","',
            goodSkill1, '","',
            goodSkill2, '"],',
            '"image": "data:image/svg+xml;base64,',
            Base64.encode(bytes(output)), '"'
            '}'
          )
        )
      )
    );
    output = string(abi.encodePacked("data:application/json;base64,", json));
    return output;
  }

  function toString(uint256 value) internal pure returns (string memory) {
    // Inspired by OraclizeAPI's implementation - MIT license
    // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }
}
