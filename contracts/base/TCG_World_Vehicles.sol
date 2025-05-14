// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721URIStorageUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {ERC2981Upgradeable} from "@openzeppelin/contracts-upgradeable/token/common/ERC2981Upgradeable.sol";

import "./errors/ERC721Errors.sol";
import "./events/BaseERC721Events.sol";

interface ITransferValidator {
    function validateTransfer(address caller, address from, address to, uint256 tokenId) external view;
}

interface ICreatorToken {
    event TransferValidatorUpdated(address oldValidator, address newValidator);
    function getTransferValidator() external view returns (address);
    function getTransferValidationFunction() external view returns (bytes4, bool);
    function setTransferValidator(address validator) external;
}

/**
 * @title BaseERC721
 * @dev Base contract for creating and managing ERC721 tokens with additional features such as pausing, access control, and token locking.
 */
contract TCG_World_Vehicles is
    Initializable,
    ERC721URIStorageUpgradeable,
    ERC721EnumerableUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC2981Upgradeable,
    BaseERC721Events,
    ICreatorToken
{
    using Strings for uint256;

    // Role constants for access control
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    address private _transferValidator;

    // Base URI for token metadata
    string public tcgBaseURI;

    // Counter for token IDs
    uint256 private tokenIdCounter;

    // Duration in seconds for which a token is locked after transfer
    uint64 public lockDuration;

    // Mapping to check if an address is blocklisted
    mapping(address => bool) private _blocklist;

    // Mapping to check if an address is whitelisted
    mapping(address => bool) private _whitelist;

    // Mapping to record the last transfer time of a token
    mapping(uint256 => uint64) private _lastTransfer;

    // Mapping to store item ID associated with a token ID
    mapping(uint256 => uint256) private _tokenItemID;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Initializes the contract with required parameters and sets up initial roles.
     * @param _manager The address with manager role.
     * @param _pauser The address with pauser role.
     * @param _upgrader The address with upgrader role.
     * @param _name The name of the NFT.
     * @param _symbol The symbol of the NFT.
     * @param _lockDuration The duration for which tokens are locked after transfer.
     */
    function initialize(
        address _manager,
        address _pauser,
        address _upgrader,
        address _royaltyReceiver,
        address _initialValidator,
        string memory _name,
        string memory _symbol,
        uint64 _lockDuration
    ) public initializer {
        if (
            _manager == address(0) ||
            _pauser == address(0) ||
            _upgrader == address(0)
        ) {
            revert ErrorAddressZero();
        }

        __ERC721_init(_name, _symbol);
        __Pausable_init();
        __ReentrancyGuard_init();
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __AccessControl_init();
        __ERC2981_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MANAGER_ROLE, _manager);
        _grantRole(PAUSER_ROLE, _pauser);
        _grantRole(UPGRADER_ROLE, _upgrader);

        lockDuration = _lockDuration;

        _transferValidator = _initialValidator;
        _setDefaultRoyalty(_royaltyReceiver, 500);

        emit TransferValidatorUpdated(address(0), _initialValidator);
    }

    // ENFORCE ROYALTIES FUNCTIONS
    function getTransferValidator() external view override returns (address) {
        return _transferValidator;
    }

    function getTransferValidationFunction() external pure override returns (bytes4, bool) {
        return (bytes4(keccak256("validateTransfer(address,address,address,uint256)")), true);
    }

    function setTransferValidator(address validator) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        emit TransferValidatorUpdated(_transferValidator, validator);
        _transferValidator = validator;
    }

    /**
     * @notice Pauses all token transfers.
     * @dev Only callable by an address with the PAUSER_ROLE.
     */
    function pause() public virtual onlyRole(PAUSER_ROLE) {
        _pause(); // Pauses the contract
    }

    /**
     * @notice Unpauses token transfers.
     * @dev Only callable by an address with the PAUSER_ROLE.
     */
    function unpause() public virtual onlyRole(PAUSER_ROLE) {
        _unpause(); // Unpauses the contract
    }

    /**
     * @notice Updates the blocklist status of a user.
     * @param _user The address of the user to be updated.
     * @param _isBlocked Whether the user should be blocked or unblocked.
     * @dev Only callable by an address with the DEFAULT_ADMIN_ROLE.
     */
    function updateBlockListStatus(
        address _user,
        bool _isBlocked
    ) external virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        if (_isBlocked == _blocklist[_user]) {
            revert ErrorSameValue();
        }
        _blocklist[_user] = _isBlocked;

        emit BlocklistStatusUpdated(_user, _isBlocked);
    }

    /**
     * @notice Sets the base URI for token metadata.
     * @param _newURI New URI for metadata.
     * @dev Only callable by an address with the DEFAULT_ADMIN_ROLE.
     */
    function setBaseURI(
        string memory _newURI
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (Strings.equal(_newURI, tcgBaseURI)) {
            revert ErrorSameValue();
        }
        tcgBaseURI = _newURI;
    }

    /**
     * @notice Checks if an address is blocklisted.
     * @param _user The address to check.
     * @return bool Whether the address is blocklisted.
     */
    function isBlocklisted(address _user) external view virtual returns (bool) {
        return _blocklist[_user];
    }

    /**
     * @notice Checks if an address is whitelisted.
     * @param _marketplace The address to check.
     * @return bool Whether the address is whitelisted.
     */
    function isWhitelisted(
        address _marketplace
    ) external view virtual returns (bool) {
        return _whitelist[_marketplace];
    }

    /**
     * @dev Internal function to check if a token has been recently transferred.
     * @param _tokenId The ID of the token.
     * @return bool Whether the token was recently transferred.
     */
    function _isTokenRecentlyTransferred(
        uint256 _tokenId
    ) private view returns (bool) {
        uint64 lastTransfer = _lastTransfer[_tokenId];
        return
            lastTransfer != 0 &&
            lastTransfer + lockDuration > uint64(block.timestamp);
    }

    /**
     * @notice Checks if a token has been recently transferred.
     * @param _tokenId The ID of the token.
     * @return bool Whether the token was recently transferred.
     */
    function isTokenRecentlyTransferred(
        uint256 _tokenId
    ) external view virtual returns (bool) {
        return _isTokenRecentlyTransferred(_tokenId);
    }

    /**
     * @notice Updates the whitelist status of a marketplace address.
     * @param _marketplaceAddress The address of the marketplace.
     * @param _isWhitelisted Whether the marketplace should be whitelisted or not.
     * @dev Only callable by an address with the MANAGER_ROLE.
     *
     * Requirements:
     * - Caller must have the MANAGER_ROLE.
     */
    function updateWhitelist(
        address _marketplaceAddress,
        bool _isWhitelisted
    ) external virtual onlyRole(MANAGER_ROLE) {
        if (_isWhitelisted == _whitelist[_marketplaceAddress]) {
            revert ErrorSameValue();
        }
        _whitelist[_marketplaceAddress] = _isWhitelisted;
        emit MarketplaceStatusUpdate(_marketplaceAddress, _isWhitelisted);
    }

    /**
     * @notice Mints a new token and assigns it to a receiver.
     * @param _receiver The address to receive the minted token.
     * @param _itemId The associated item ID.
     * @dev Only callable by an address with the MANAGER_ROLE.
     *
     * Requirements:
     * - Caller must have the MANAGER_ROLE.
     * - The receiver must not be blocklisted.
     *
     * @return tokenId Newly minted token ID.
     */
    function mint(
        address _receiver,
        uint256 _itemId
    ) public virtual onlyRole(MANAGER_ROLE) nonReentrant returns (uint256) {
        if (_blocklist[_receiver]) {
            revert ErrorBlockedAddress();
        }
        uint256 currentId = _mint(_receiver);
        _tokenItemID[currentId] = _itemId;

        emit Minted(_receiver, currentId, _itemId, uint64(block.timestamp));

        return currentId;
    }

    /**
     * @notice Mints a new token via bridging and assigns it to a receiver.
     * @param _receiver The address to receive the minted token.
     * @param _tokenId The ID of the minted token.
     * @param _itemId The associated item ID.
     * @dev Only callable by an address with the MANAGER_ROLE.
     *
     * Requirements:
     * - Caller must have the MANAGER_ROLE.
     * - The receiver must not be blocklisted.
     */
    function bridgeMint(
        address _receiver,
        uint256 _tokenId,
        uint256 _itemId
    ) external virtual onlyRole(MANAGER_ROLE) nonReentrant {
        if (_blocklist[_receiver]) {
            revert ErrorBlockedAddress();
        }
        _mint(_receiver, _tokenId);
        _tokenItemID[_tokenId] = _itemId;

        emit Minted(_receiver, _tokenId, _itemId, uint64(block.timestamp));
    }

    /**
     * @notice Mints multiple tokens in a batch and assigns them to receivers.
     * @param _receivers Array of addresses to receive the minted tokens.
     * @param _itemIds Array of associated item IDs.
     * @dev Only callable by an address with the MANAGER_ROLE.
     *
     * Requirements:
     * - Caller must have the MANAGER_ROLE.
     */
    function batchMint(
        address[] calldata _receivers,
        uint256[] calldata _itemIds
    ) external onlyRole(MANAGER_ROLE) nonReentrant {
        uint256 receiversLength = _receivers.length;
        uint256[] memory tokenIds = new uint256[](receiversLength);
        for (uint256 i = 0; i < receiversLength; ++i) {
            if (!_blocklist[_receivers[i]]) {
                tokenIds[i] = _mint(_receivers[i]);
                _tokenItemID[tokenIds[i]] = _itemIds[i];
            } else {
                tokenIds[i] = 0;
            }
        }

        emit BatchMinted(
            _receivers,
            tokenIds,
            _itemIds,
            uint64(block.timestamp)
        );
    }

    /**
     * @notice Migrate an existing token.
     * @param _receiver Address to receive the minted token.
     * @param _itemId Associated item ID.
     * @param _userItemId Associated user item ID.
     * @dev Only callable by an address with the MANAGER_ROLE.
     *
     * Requirements:
     * - Caller must have the MANAGER_ROLE.
     */
    function migrate(
        address _receiver,
        uint256 _itemId,
        uint256 _userItemId
    ) external onlyRole(MANAGER_ROLE) nonReentrant {
        uint256 tokenId = _mint(_receiver);

        emit Migrated(
            _receiver,
            tokenId,
            _itemId,
            _userItemId,
            uint64(block.timestamp)
        );
    }

    /**
     * @notice Batch migrate existing tokens.
     * @param _receivers Array of addresses to receive the minted tokens.
     * @param _itemIds Array of associated item IDs.
     * @param _userItemIds Array of associated user item IDs.
     * @dev Only callable by an address with the MANAGER_ROLE.
     *
     * Requirements:
     * - Caller must have the MANAGER_ROLE.
     */
    function batchMigrate(
        address[] memory _receivers,
        uint256[] memory _itemIds,
        uint256[] memory _userItemIds
    ) external onlyRole(MANAGER_ROLE) nonReentrant {
        uint256 receiversLength = _receivers.length;
        uint256[] memory tokenIds = new uint256[](receiversLength);
        for (uint256 i = 0; i < receiversLength; ++i) {
            if (!_blocklist[_receivers[i]]) {
                tokenIds[i] = _mint(_receivers[i]);
                _tokenItemID[tokenIds[i]] = _itemIds[i];
            } else {
                tokenIds[i] = 0;
            }
        }

        emit BatchMigrated(
            _receivers,
            tokenIds,
            _itemIds,
            _userItemIds,
            uint64(block.timestamp)
        );
    }

    /**
     * @notice Burns a token with the specified ID.
     * @param _tokenId The ID of the token to burn.
     */
    function burn(uint256 _tokenId) public virtual nonReentrant {
        if (ownerOf(_tokenId) != msg.sender) {
            revert ErrorNotTokenOwner();
        }
        _burn(_tokenId);
        delete _lastTransfer[_tokenId];
        emit Burned(msg.sender, _tokenId, uint64(block.timestamp));
    }

    /**
     * @notice Burns a token with the specified ID.
     * @param _owner The Address of the token owner.
     * @param _tokenId The ID of the token to burn.
     */
    function burnFrom(
        address _owner,
        uint256 _tokenId
    ) public virtual onlyRole(MANAGER_ROLE) nonReentrant {
        if (ownerOf(_tokenId) != _owner) {
            revert ErrorNotTokenOwner();
        }
        _burn(_tokenId);
        delete _lastTransfer[_tokenId];
        emit Burned(_owner, _tokenId, uint64(block.timestamp));
    }

    /**
     * @notice Batch burns tokens that the sender owns.
     * @param _tokenIds An array of token IDs to burn.
     */
    function batchBurn(uint256[] memory _tokenIds) public nonReentrant {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            if (ownerOf(tokenId) != msg.sender) {
                revert ErrorNotTokenOwner();
            }
            _burn(tokenId);
            delete _lastTransfer[tokenId];
            emit Burned(msg.sender, tokenId, uint64(block.timestamp));
        }
    }

    /**
     * @notice Batch burns tokens from a specified owner.
     * @param _owner The address of the token owner.
     * @param _tokenIds An array of token IDs to burn.
     */
    function batchBurnFrom(
        address _owner,
        uint256[] memory _tokenIds
    ) public onlyRole(MANAGER_ROLE) nonReentrant {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            if (ownerOf(tokenId) != _owner) {
                revert ErrorNotTokenOwner();
            }
            _burn(tokenId);
            delete _lastTransfer[tokenId];
            emit Burned(_owner, tokenId, uint64(block.timestamp));
        }
    }

    /**
     * @notice Custom owner of without checking if nft exist
     * @param _tokenId The ID of the token.
     */
    function safeOwnerOf(uint256 _tokenId) external view returns (address) {
        return _ownerOf(_tokenId);
    }

    /**
     * @notice Returns the URI for the token metadata.
     * @param _tokenId The ID of the token.
     * @return string The URI of the token metadata.
     */
    function tokenURI(
        uint256 _tokenId
    )
        public
        view
        virtual
        override(ERC721URIStorageUpgradeable, ERC721Upgradeable)
        returns (string memory)
    {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string.concat(baseURI, _tokenId.toString(), ".json")
                : "";
    }

    /**
     * @notice Safely transfers a token to a new owner.
     * @param _receiver The address to receive the token.
     * @param _tokenId The ID of the token to transfer.
     * @dev Throws ErrorTransferLockedToken() if the token is locked.
     * Throws ErrorTokenRecentlyTransferred() if the token was recently transferred.
     *
     * Requirements:
     * - The token must not be locked.
     * - The token must not have been recently transferred.
     */
    function safeTransfer(
        address _receiver,
        uint256 _tokenId
    ) external nonReentrant {
        _safeTransfer(msg.sender, _receiver, _tokenId, "");
    }

    /**
     * @notice Safely batch transfers tokens to a new owners.
     * @param _receivers The address to receive the token.
     * @param _tokenIds The ID of the token to transfer.
     * @dev Throws ErrorTransferLockedToken() if the token is locked.
     * Throws ErrorTokenRecentlyTransferred() if the token was recently transferred.
     *
     * Requirements:
     * - The tokens must not be locked.
     * - The tokens must not have been recently transferred.
     */
    function safeBatchTransfer(
        address[] calldata _receivers,
        uint256[] calldata _tokenIds
    ) external nonReentrant {
        uint256 receiversLength = _receivers.length;
        if (receiversLength != _tokenIds.length) {
            revert ErrorUnequalArrayLengths(
                _receivers.length,
                _tokenIds.length
            );
        }
        for (uint256 i = 0; i < receiversLength; ++i) {
            _safeTransfer(msg.sender, _receivers[i], _tokenIds[i], "");
        }
        emit BatchTransferred(_receivers, _tokenIds, uint64(block.timestamp));
    }

    /**
     * @notice Returns whether the contract implements the interface defined by _interfaceId.
     * @param _interfaceId The interface ID to check.
     * @return bool Whether the contract implements the interface.
     */
    function supportsInterface(
        bytes4 _interfaceId
    )
        public
        view
        virtual
        override(
            ERC721URIStorageUpgradeable,
            AccessControlUpgradeable,
            ERC721EnumerableUpgradeable,
            ERC2981Upgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    /**
     * @dev Internal function to mint a new token.
     * @param _receiver The address to receive the minted token.
     * @return uint256 The newly minted token ID.
     */
    function _mint(address _receiver) private returns (uint256) {
        tokenIdCounter++;
        uint256 currentId = tokenIdCounter;
        super._mint(_receiver, tokenIdCounter);

        return currentId;
    }

    /**
     * @dev Internal function to return the base URI for the token metadata.
     * @return string The base URI for token metadata.
     */
    function _baseURI() internal view override returns (string memory) {
        return tcgBaseURI;
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting and burning.
     * @param _to The address of the new owner.
     * @param _tokenId The ID of the token to transfer.
     * @param _auth The batch size of the transfer.
     * @return address The previous owner of the token.
     *
     * Requirements:
     * - The token must not be blocklisted for the sender.
     * - The token must not be locked.
     * - The token must not have been recently transferred.
     */
    function _update(
        address _to,
        uint256 _tokenId,
        address _auth
    )
        internal
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        whenNotPaused
        returns (address)
    {
        address from = _ownerOf(_tokenId);
        // Block transactions from blocklisted addresses.
        if (_blocklist[from]) revert ErrorBlockedAddress();
        // Prevent recently trasferred tokens from being transferred.
        if (
            _isTokenRecentlyTransferred(_tokenId) &&
            !_whitelist[from] &&
            _to != address(0)
        ) {
            revert ErrorTokenRecentlyTransferred(
                _tokenId,
                _lastTransfer[_tokenId]
            );
        }
        address returned = super._update(_to, _tokenId, _auth);

        if (from != address(0) && !_whitelist[_to]) {
            _lastTransfer[_tokenId] = uint64(block.timestamp);
        }

        return returned;
    }

    function _increaseBalance(
        address account,
        uint128 amount
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
    {
        super._increaseBalance(account, amount);
    }

    /**
     * @dev Override for ERC721's isApprovedForAll to include blocklist check.
     * @param owner The address of the token owner.
     * @param operator The address of the operator.
     * @return bool Whether the operator is approved for all tokens of the owner.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view override(ERC721Upgradeable, IERC721) returns (bool) {
        // Whitelist Marketplace contract for easy trading.
        if (_whitelist[operator]) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    /**
     * @notice Returns the item ID associated with a token.
     * @param _tokenId The ID of the token.
     * @return uint256 The associated item ID.
     */
    function getTokenItemID(uint256 _tokenId) external view returns (uint256) {
        return _tokenItemID[_tokenId];
    }

    /**
     * @notice Sets the royalty information for all tokens.
     * @param receiver The address that will receive royalty payments.
     * @param feeNumerator The royalty fee as a fraction of 10000 (e.g., 500 for 5%).
     */
    function setRoyaltyInfo(
        address receiver,
        uint96 feeNumerator
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @notice Sets royalty information for a specific token ID.
     * @param tokenId The ID of the token.
     * @param receiver The address that will receive royalty payments.
     * @param feeNumerator The royalty fee as a fraction of 10000 (e.g., 500 for 5%).
     * @dev Only callable by an address with the DEFAULT_ADMIN_ROLE.
     */
    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    /**
     * @notice Resets royalty information for a specific token ID.
     * @param tokenId The ID of the token for which royalty is being reset.
     * @dev Only callable by an address with the DEFAULT_ADMIN_ROLE.
     */
    function resetTokenRoyalty(
        uint256 tokenId
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _resetTokenRoyalty(tokenId);
    }

    /**
     * @notice Updates lock duration
     * @param _lockDuration The new lock duration in seconds.
     * @dev Only callable by an address with the DEFAULT_ADMIN_ROLE.
     */
    function updateLockDuration(
        uint64 _lockDuration
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (lockDuration == _lockDuration) {
            revert ErrorSameValue();
        }
        lockDuration = _lockDuration;
    }
}
