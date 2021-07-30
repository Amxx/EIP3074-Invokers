// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/ReplayProtection.sol";

abstract contract WithNonce {
    using ReplayProtection for ReplayProtection.MultiNonces;

    ReplayProtection.MultiNonces private _nonces;

    function nonce(address from) public view virtual returns (uint256) {
        return _nonces.getNonce(from);
    }

    function nonce(address from, uint256 timeline) public view virtual returns (uint256) {
        return _nonces.getNonce(from, timeline);
    }

    function _verifyAndConsumeNonce(address owner, uint256 idx) internal virtual returns (bool) {
        return _nonces.verifyAndConsumeNonce(owner, idx);
    }
}
