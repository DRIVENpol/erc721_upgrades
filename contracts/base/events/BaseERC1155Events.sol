// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

abstract contract BaseERC1155Events {
    // Events
    /*
     * @dev Emitted when the blocklist status of a user is updated.
     * @param user The address of the user.
     * @param isBlocked The new blocklist status of the user (true if blocked).
     */
    event BlocklistStatusUpdated(address indexed user, bool isBlocked);

    /*
     * @dev Emitted when a token is minted.
     * @param receiver The address receiving the minted token.
     * @param itemId The ID of the minted token.
     * @param quantity The quantity of the minted token.
     * @param timestamp The timestamp of the minting event.
     */
    event Minted(
        address indexed receiver,
        uint256 indexed itemId,
        uint256 quantity,
        uint64 timestamp
    );

    /*
     * @dev Emitted when tokens are batch minted.
     * @param receivers The addresses receiving the minted tokens.
     * @param itemIds The IDs of the minted tokens.
     * @param quantities The quantities of the minted tokens.
     * @param timestamp The timestamp of the batch minting event.
     */
    event BatchMinted(
        address[] receivers,
        uint256[] itemIds,
        uint256[] quantities,
        uint64 timestamp
    );

    /**
     * @dev Emitted when multiple tokens are transferred in a batch.
     * @param receivers Array of addresses receiving the transferred tokens.
     * @param tokenIds Array of IDs of the transferred tokens.
     * @param quantities The quantities of the transferred tokens.
     * @param timestamp The timestamp of the transfer.
     */
    event BatchTransferred(
        address[] receivers,
        uint256[] tokenIds,
        uint256[] quantities,
        uint64 timestamp
    );

    /**
     * @dev Emitted when nft is burned.
     * @param owner The address of the owner.
     * @param token_id The id of the token.
     * @param quantity The quantity of the token.
     * @param timestamp The timestamp of the burning.
     */
    event Burned(address indexed owner, uint256 token_id, uint256 quantity, uint64 timestamp);    
}