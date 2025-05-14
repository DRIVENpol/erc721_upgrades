// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @dev Error thrown when a blocked address attempts to perform an action.
 * @param user The address of the user attempts to perform the action
 */
error ErrorBlockedAddress(address user);

/**
 * @dev Error thrown when two arrays have unequal lengths.
 */
error ErrorUnequalArrayLengths();

/**
 * @dev Error thrown when an operation is attempted on a token that is not active.
 * @param itemId The id of the inactive token.
 */
error ErrorTokenNotActive(uint256 itemId);

/**
 * @dev Error thrown when an attempt is made to activate a token that is already active.
 * @param itemId The id of the active token.
 */
error ErrorTokenAlreadyActive(uint256 itemId);

/**
 * @dev Error thrown when an operation requires more tokens than are available in the balance.
 * @param available The available balance of the token.
 * @param amount The amount of tokens required for the operation.
 */
error ErrorNotEnoughBalance(uint256 available, uint256 amount);

/**
 * @dev Error thrown when an operation exceeds the token cap limit.
 * @param itemId The id of the token.
 */
error ErrorTokenCapLimitExceed(uint256 itemId);

/**
 * @dev Error thrown when an operation exceeds the daily token limit.
 * @param itemId The id of the token.
 */
error ErrorTokenDailyLimitExceed(uint256 itemId);

/**
 * @dev Error thrown when a limit type applied to the token is not applicable or valid.
 * @param itemId The id of the token.
 * @param limitType The limit type applied to the token.
 */
error ErrorTokenLimitTypeNotApplicable(uint256 itemId, uint8 limitType);

/**
 * @dev Error thrown when a request to reset token count is made before the reset period is available.
 * @param itemId The id of the token.
 */
error ErrorTokenCountResetNotYetAvailable(uint256 itemId);

/**
 * @dev Error thrown when an address is address(0)
 */
error ErrorAddressZero();

/**
 * @notice Thrown when trying to change same value.
 */
error ErrorSameValue();

/**
 * @notice Thrown when array is empty.
 */
error ErrorEmptyArray();