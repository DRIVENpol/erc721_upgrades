// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @dev Error thrown when a blocked address attempts to perform an action.
 */
error ErrorBlockedAddress();

/**
 * @dev Error thrown when a recently transferred token is attempted to be transferred again.
 * @param itemId The ID of the token.
 * @param unlockTime The timestamp when the token will be unlocked.
 */
error ErrorTokenRecentlyTransferred(uint256 itemId, uint256 unlockTime);

/**
 * @dev Error thrown when an address that does not own the token tries to perform an action.
 */
error ErrorNotTokenOwner();

/**
 * @dev Error thrown when an address is address(0)
 */
error ErrorAddressZero();

/**
 * @dev Error thrown when trying to change same value.
 */
error ErrorSameValue();

/**
 * @dev Error thrown when the lengths of two arrays do not match.
 * @param _array1Length The length of the accounts array.
 * @param _array2Length The length of the whitelist/blocklist array.
 */
error ErrorUnequalArrayLengths(uint256 _array1Length, uint256 _array2Length);

/**
 * @title BaseERC721
 * @dev Base contract for creating and managing ERC721 tokens with additional features such as pausing, access control, and token locking.
 */