// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Nonced {
    mapping(address => mapping(uint256 => uint256)) private _nonces;

    function nonce(address from) public view virtual returns (uint256) {
        return uint256(_nonces[from][0]);
    }

    function nonce(address from, uint256 timeline) public view virtual returns (uint256) {
        return _nonces[from][timeline];
    }

    function _verifyNonce(address owner, uint256 idx) internal virtual returns (bool) {
        return idx % (1 << 128) == _nonces[owner][idx >> 128]++;
    }
}
