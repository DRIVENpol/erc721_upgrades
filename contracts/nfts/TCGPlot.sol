// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {BaseERC721} from "../base/BaseERC721.sol";

// error ErrorMergingPlotAlreadyEnabled();
// error ErrorMergingPlotAlreadyDisabled();
// error ErrorMergingPlotIsNotEnabled();
// error ErrorNotOwner(address user, uint256 tokenId);

contract TCGPlot is BaseERC721 {
    // bool public mergingPlotEnabled;

    // event MergingLandPlotStatusUpdate(bool indexed _status, uint64 _timestamp);
    // event MergedLandPlots(uint256 indexed newPlotId, uint256[] landIds);

    // mapping(uint256 => uint256[]) private _mergedLandPlots; // new plot id => [array of merged plot ids]

    // function mergeLandPlot(
    //     address receiver,
    //     uint256[] calldata landIds
    // ) external nonReentrant onlyRole(MANAGER_ROLE) returns (uint256) {
    //     if (!mergingPlotEnabled) {
    //         revert ErrorMergingPlotIsNotEnabled();
    //     }
    //     for (uint256 i = 0; i < landIds.length; ++i) {
    //         if (ownerOf(landIds[i]) != receiver) {
    //             revert ErrorNotOwner(receiver, landIds[i]);
    //         }
    //     }
    //     uint256 newLandId = _mint(receiver);
    //     _mergedLandPlots[newLandId] = landIds;
    //     emit MergedLandPlots(newLandId, landIds);
    //     return newLandId;
    // }

    // function updateMergingLandPlot(
    //     bool _status
    // ) external nonReentrant onlyRole(MANAGER_ROLE) {
    //     if (mergingPlotEnabled == _status) {
    //         if (_status) {
    //             revert ErrorMergingPlotAlreadyEnabled();
    //         } else {
    //             revert ErrorMergingPlotAlreadyDisabled();
    //         }
    //     }
    //     mergingPlotEnabled = _status;
    //     emit MergingLandPlotStatusUpdate(_status, uint64(block.timestamp));
    // }
}
