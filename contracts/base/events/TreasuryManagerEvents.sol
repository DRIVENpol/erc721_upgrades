// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

abstract contract TreasuryManagerEvents {
    /** 
     * ******************** EVENTS ********************
     */

    /** 
     * Emitted when the router address is updated.
     */
    event RouterUpdated(address newRouter);
    /** 
     * Emitted when the UNIT/WETH pair is created.
     */
    event PairCreated(address pair);
    /** 
     * Emitted when the marketplace contract address is updated.
     */
    event MarketplaceContractUpdated(address newMarketplaceContract);
    /** 
     * Emitted when tokens are swapped for ETH.
     */
    event TokensSwapped(uint256 amountIn, uint256 amountOut, address recipient);
}