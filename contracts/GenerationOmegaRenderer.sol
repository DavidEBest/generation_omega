// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
 * Generation Omega Renderer
 *
 * Generation Omega is a near future, post-apocalyptic
 * setting for an RPG. The mintable tokens are randomized
 * characters with attributes and skills.
 *
 * This contract packages up the rendering functions
 * for the Generation Omega NFT project.
 * 
 * Developed by @scrimmage_us, based on contract
 * breakdowns by @marcelc63.
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "./library/Base64.sol";
import "./GenerationOmegaTypes.sol";

contract GenerationOmegaRenderer is Ownable {

  // ** - RENDERING - ** //

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  function getAttribute(string memory attribute, uint256 tokenId) internal pure returns (uint256) {
    uint256 rand = random(string(abi.encodePacked(attribute, toString(tokenId))));
    return rand % 7;
  }

  function getSkill(string memory val, uint256 tokenId, string memory level) internal view returns (string memory) {
    uint256 rand = random(string(abi.encodePacked(val, level, toString(tokenId))));
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

  struct Attributes {
    string str;
    string dex;
    string con;
    string intel;
    string wis;
    string cha;
    string greatSkill;
    string goodSkill1;
    string goodSkill2;
  }

  function getAttributeJson(
    string memory traitName,
    string memory traitValue
  ) internal pure returns (string memory) {
    return string(abi.encodePacked('{"trait_type": "', traitName, '", "max_value": 7, "value": ', traitValue, '},'));
  }

  function getAllAttributesJson(
    Attributes memory attr
  ) internal pure returns (string memory) {
    return string(
      abi.encodePacked(
        getAttributeJson('Strength', attr.str),
        getAttributeJson('Dexterity', attr.dex),
        getAttributeJson('Constitution', attr.con),
        getAttributeJson('Intelligence', attr.intel),
        getAttributeJson('Wisdom', attr.wis),
        getAttributeJson('Charisma', attr.cha)
      )
    );
  }

  function getSkillJson(
    string memory skillValue 
  ) internal pure returns (string memory) {
    return string(abi.encodePacked('{"trait_type": "Skill", "value": "', skillValue, '"},'));
  }

  function getJsonString(
    uint256 tokenId,
    Attributes memory attr,
    GenerationOmegaTypes.GenOmega memory omegaData,
    string memory svgOutput
  ) internal pure returns (string memory) {
    return Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "Generation Omega #', toString(tokenId), '",',
            '"image": "data:image/svg+xml;base64,', Base64.encode(bytes(svgOutput)), '",',
            '"attributes":[',
              getAllAttributesJson(attr),
              getSkillJson(attr.greatSkill),
              getSkillJson(attr.goodSkill1),
              getSkillJson(attr.goodSkill2),
              '{"trait_type": "Hit Points", "value": ', toString(omegaData.hp), ', "max_value":', toString(omegaData.maxHp), '},',
              '{"trait_type": "Experience Points", "value": ', toString(omegaData.xp), '}',
            ']}'
          )
        )
      )
    );
  }

  function tokenURI(
    uint256 tokenId,
    GenerationOmegaTypes.GenOmega memory omegaData
  ) public view returns (string memory) {
    // Attributes
    Attributes memory attr;
    // Attributes are on a -3 to +3 scale, mapped to 0-7
    attr.str = toString(getAttribute('str', tokenId));
    attr.dex = toString(getAttribute('dex', tokenId));
    attr.con = toString(getAttribute('con', tokenId));
    attr.intel = toString(getAttribute('int', tokenId));
    attr.wis = toString(getAttribute('wis', tokenId));
    attr.cha = toString(getAttribute('cha', tokenId));

    // Skills
    attr.greatSkill = getSkill('sk1', tokenId, '(+2)');
    attr.goodSkill1 = getSkill('sk2', tokenId, '(+1)');
    attr.goodSkill2 = getSkill('sk3', tokenId, '(+1)');

    // SVG
    string[21] memory parts;
    parts[0] = '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350"><style>.base { fill: white; font-family: serif; font-size: 14px; }</style><rect width="100%" height="100%" fill="black" /><text x="10" y="20" class="base">';
    parts[1] = string(abi.encodePacked('Generation Omega #', toString(tokenId)));
    parts[2] = '</text><text x="10" y="40" class="base">';
    parts[3] = string(abi.encodePacked('STR:', attr.str));
    parts[4] = '</text><text x="10" y="60" class="base">';
    parts[5] = string(abi.encodePacked('DEX:', attr.dex));
    parts[6] = '</text><text x="10" y="80" class="base">';
    parts[7] = string(abi.encodePacked('CON:', attr.con));
    parts[8] = '</text><text x="10" y="100" class="base">';
    parts[9] = string(abi.encodePacked('INT:', attr.intel));
    parts[10] = '</text><text x="10" y="120" class="base">';
    parts[11] = string(abi.encodePacked('WIS:', attr.wis));
    parts[12] = '</text><text x="10" y="140" class="base">';
    parts[13] = string(abi.encodePacked('CHA:', attr.cha));
    parts[14] = '</text><text x="10" y="160" class="base">';
    parts[15] = 'Skills';
    parts[16] = '</text><text x="10" y="180" class="base">';
    parts[17] = string(abi.encodePacked(attr.greatSkill, ', ', attr.goodSkill1, ', ', attr.goodSkill2));
    parts[18] = '</text><text x="10" y="200" class="base">';
    parts[19] = string(abi.encodePacked('HP: ', toString(omegaData.hp), '/', toString(omegaData.maxHp), '  XP: ', toString(omegaData.xp)));
    parts[20] = '</text></svg>';

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

    output = string(
      abi.encodePacked(
        output,
        parts[19],
        parts[20]
      )
    );
    return string(abi.encodePacked("data:application/json;base64,", getJsonString(tokenId, attr, omegaData, output)));
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
