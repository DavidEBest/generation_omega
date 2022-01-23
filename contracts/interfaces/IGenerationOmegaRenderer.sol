// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../GenerationOmegaTypes.sol";

interface IGenerationOmegaRenderer {
  function tokenURI(
    uint256 tokenId,
    GenerationOmegaTypes.GenOmega memory omegaData
  ) external view returns (string memory);
}
