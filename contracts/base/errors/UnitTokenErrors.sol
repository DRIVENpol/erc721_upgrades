// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @dev Custom error indicating that a minting request would exceed the maximum total supply.
 * @param _requestedAmount The amount requested for minting.
 * @param _maxTotalSupply The maximum allowed total supply.
 */
error ErrorMaxTotalSupplyExceeded(uint256 _requestedAmount, uint256 _maxTotalSupply);

/**
 * @dev Custom error indicating that either the sender or recipient of a transfer is blacklisted.
 * @param _sender The address of the sender.
 * @param _recipient The address of the recipient.
 */
error ErrorBlacklisted(address _sender, address _recipient);

/**
 * @dev Custom error indicating mismatched lengths of provided arrays (e.g., for batch operations).
 * @param _array1Length Length of the first array.
 * @param _array2Length Length of the second array.
 */
error ErrorUnequalArrayLengths(uint256 _array1Length, uint256 _array2Length);

/**
 * @dev Custom error indicating insufficient token balance for a requested operation.
 * @param _token The address of the token.
 * @param _requestedAmount The requested token amount.
 * @param _availableAmount The available token amount.
 */
error ErrorNotEnoughToken(address _token, uint256 _requestedAmount, uint256 _availableAmount);

/**
 * @dev Custom error indicating insufficient native token balance for a requested operation.
 * @param _requestedAmount The requested amount.
 * @param _availableAmount The available native balance.
 */
error ErrorNotEnoughBalance(uint256 _requestedAmount, uint256 _availableAmount);

/**
 * @dev Custom error indicating a failed token transfer.
 */
error ErrorTransferFailed();

/**
 * @dev Custom error indicating an invalid amount (typically zero).
 */
error ErrorInvalidAmount();

/**
 * @dev Custom error thrown when an address is the zero address.
 */
error ErrorAddressZero();

/**
 * @dev Custom error thrown when attempting to transfer tokens to the zero address.
 */
error ErrorTransferToAddressZero();

/**
 * @dev Custom error thrown when attempting to update a value to the same existing value.
 */
error ErrorSameValue();