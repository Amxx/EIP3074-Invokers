// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Nonces.sol";

abstract contract WithNonce {
    using Nonces for Nonces.MultiNonces;

    Nonces.MultiNonces private _nonces;

    function nonce(address from) public view virtual returns (uint256) {
        return _nonces.getNonce(from);
    }

    function nonce(address from, uint256 timeline) public view virtual returns (uint256) {
        return _nonces.getNonce(from, timeline);
    }

    function _verifyAndConsumeNonce(address owner, uint256 idx) internal virtual returns (bool) {
        return _nonces._verifyAndConsumeNonce(owner, idx);
    }
}
