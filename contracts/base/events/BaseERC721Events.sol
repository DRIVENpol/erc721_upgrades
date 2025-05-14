// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

abstract contract BaseERC721Events {
    /**
     * @dev Emitted when the blocklist status of a user is updated.
     * @param user The address of the user whose blocklist status is updated.
     * @param isBlocked The new blocklist status of the user.
     */
    event BlocklistStatusUpdated(address indexed user, bool isBlocked);

    /**
     * @dev Emitted when a token is minted.
     * @param receiver The address receiving the minted token.
     * @param tokenId The ID of the minted token.
     * @param itemId The associated item ID.
     * @param timestamp The timestamp of the minting.
     */
    event Minted(
        address indexed receiver, // Address receiving the minted token
        uint256 indexed tokenId, // ID of the minted token
        uint256 indexed itemId, // Associated item ID
        uint64 timestamp // Timestamp of the minting
    );

    /**
     * @dev Emitted when multiple tokens are minted in a batch.
     * @param receivers Array of addresses receiving the minted tokens.
     * @param tokenIds Array of IDs of the minted tokens.
     * @param itemIds Array of associated item IDs.
     * @param timestamp The timestamp of the minting.
     */
    event BatchMinted(
        address[] receivers, // Addresses receiving the minted tokens
        uint256[] tokenIds, // IDs of the minted tokens
        uint256[] itemIds, // Associated item IDs
        uint64 timestamp // Timestamp of the minting
    );

    /**
     * @dev Emitted when a token is migrated.
     * @param receiver Address receiving the migrated token.
     * @param tokenId ID of the migrated token.
     * @param itemId Associated item ID.
     * @param userItemId Associated user item ID.
     * @param timestamp The timestamp of the migration.
     */
    event Migrated(
        address receiver, // Address receiving the minted token
        uint256 tokenId, // ID of the minted token
        uint256 itemId, // Associated item IDs
        uint256 userItemId, // Associated user item ID
        uint64 timestamp // Timestamp of the migration
    );

    /**
     * @dev Emitted when multiple tokens are minted in a batch.
     * @param receivers Array of addresses receiving the minted tokens.
     * @param tokenIds Array of IDs of the minted tokens.
     * @param itemIds Array of associated item IDs.
     * @param userItemIds Array of associated user item IDs.
     * @param timestamp The timestamp of the migration.
     */
    event BatchMigrated(
        address[] receivers, // Addresses receiving the minted tokens
        uint256[] tokenIds, // IDs of the minted tokens
        uint256[] itemIds, // Associated item IDs
        uint256[] userItemIds, // Associated user item IDs
        uint64 timestamp // Timestamp of the migration
    );

    /**
     * @dev Emitted when multiple tokens are transferred in a batch.
     * @param receivers Array of addresses receiving the transferred tokens.
     * @param tokenIds Array of IDs of the transferred tokens.
     * @param timestamp The timestamp of the transfer.
     */
    event BatchTransferred(
        address[] receivers, // Addresses receiving the transferred tokens
        uint256[] tokenIds, // IDs of the transferred tokens
        uint64 timestamp // Timestamp of the transfer
    );

    /**
     * @dev Emitted when the whitelist status of a marketplace is updated.
     * @param marketplaceAddress The address of the marketplace.
     * @param status The new whitelist status of the marketplace.
     */
    event MarketplaceStatusUpdate(
        address indexed marketplaceAddress,
        bool status
    );

    /**
     * @dev Emitted when nft is burned.
     * @param owner The address of the owner.
     * @param token_id The token id of the nft.
     * @param timestamp The timestamp of the burning.
     */
    event Burned(address indexed owner, uint256 token_id, uint64 timestamp);
}