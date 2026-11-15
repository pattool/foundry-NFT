// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    /*--------------------------------------------------------------------
                              ERRORS
    ---------------------------------------------------------------------*/
    error MoodNft__CantFlipMoodIfNotOwnerOrApproved();

    /*--------------------------------------------------------------------
                        STORAGE VARIABLES
    ---------------------------------------------------------------------*/
    uint256 private sTokenCounter;
    string private sSadSvgImageUri;
    string private sHappySvgImageUri;

    enum Mood {
        SAD,
        HAPPY
    }

    mapping(uint256 => Mood) private sTokenIdToMood;

    /*--------------------------------------------------------------------
                           CONSTRUCTOR
    ---------------------------------------------------------------------*/
    constructor(string memory sadSvgImageUri, string memory happySvgImageUri) ERC721("Mood NFT", "MN") {
        sTokenCounter = 0;
        sSadSvgImageUri = sadSvgImageUri;
        sHappySvgImageUri = happySvgImageUri;
    }

    /*--------------------------------------------------------------------
                           FUNCTIONS
    ---------------------------------------------------------------------*/
    function mintNft() public {
        _safeMint(msg.sender, sTokenCounter);
        sTokenIdToMood[sTokenCounter] = Mood.HAPPY;
        sTokenCounter++;
    }

    function flipMood(uint256 tokenId) public {
        if (getApproved(tokenId) != msg.sender && ownerOf(tokenId) != msg.sender) {
            revert MoodNft__CantFlipMoodIfNotOwnerOrApproved();
        }

        if (sTokenIdToMood[tokenId] == Mood.HAPPY) {
            sTokenIdToMood[tokenId] = Mood.SAD;
        } else {
            sTokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        string memory imageURI;
        if (sTokenIdToMood[tokenId] == Mood.HAPPY) {
            imageURI = sHappySvgImageUri;
        } else {
            imageURI = sSadSvgImageUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            name(),
                            '", "description": "An NFT that reflects the owners mood.", "attributes": [{"trait_type": "moodiness", "value": 100}], "image": "',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }
}

