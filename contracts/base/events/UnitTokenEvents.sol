// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

abstract contract UnitTokenEvents {
   // ******************** EVENTS ********************

    /**
     * @dev Emitted when new tokens are minted.
     * @param _receiver The address receiving minted tokens.
     * @param _amount The amount of tokens minted.
     */
    event Minted(address indexed _receiver, uint256 _amount);

    /**
     * @dev Emitted when an account's blocklist status is updated.
     * @param _account The updated account.
     * @param _isBlocklisted The new blocklist status.
     */
    event BlocklistUpdated(address indexed _account, bool _isBlocklisted);

    /**
     * @dev Emitted when multiple accounts' blocklist statuses are updated in batch.
     * @param _accounts Array of updated accounts.
     * @param _isBlocklisted Array of corresponding blocklist statuses.
     */
    event BatchBlocklistUpdated(address[] _accounts, bool[] _isBlocklisted);

    /**
     * @dev Emitted when tokens are rescued from an account.
     * @param _account The address from which tokens are rescued.
     * @param _amount The amount of tokens rescued.
     */
    event RescuedAllTokens(address indexed _account, uint256 _amount);

    /**
     * @dev Emitted when an account's whitelist (tax exemption) status is updated.
     * @param _account The account that was updated.
     * @param _status The new whitelist status.
     */
    event WhitelistUpdated(address indexed _account, bool _status);

    /**
     * @dev Emitted when the buy tax is updated.
     * @param _value The new buy tax value.
     */
    event BuyTaxUpdated(uint16 _value);

    /**
     * @dev Emitted when the sell tax is updated.
     * @param _value The new sell tax value.
     */
    event SellTaxUpdated(uint16 _value);

    /**
     * @dev Emitted when the Uniswap router is updated.
     * @param _router The new Uniswap router address.
     */
    event UniSwapRouterUpdated(address _router);

    /**
     * @dev Emitted when the TreasuryManager is updated.
     * @param _treasury The new TreasuryManager address.
     */
    event TreasuryManagerUpdated(address _treasury);

    /**
     * @dev Emitted when the swap threshold is updated.
     * @param _threshold The new swap threshold value.
     */
    event SwapThresholdUpdated(uint256 _threshold);

    /**
     * @dev Emitted when tokens are confiscated from a user.
     * @param _from The address from which tokens are confiscated.
     * @param _to The address receiving the tokens (typically the admin).
     * @param _amount The amount of tokens confiscated.
     */
    event TokensConfiscated(address indexed _from, address _to, uint256 _amount);
}