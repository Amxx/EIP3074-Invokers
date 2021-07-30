// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library Nonces {
    struct SimpleNonces {
        mapping(address => uint256) _data;
    }

    function getNonce(SimpleNonces storage nonces, address from) internal view returns (uint256) {
        return nonces._data[from];
    }

    function _verifyAndConsumeNonce(SimpleNonces storage nonces, address owner, uint256 idx) internal returns (bool) {
        return idx == nonces._data[owner]++;
    }

    struct MultiNonces {
        mapping(address => mapping(uint256 => uint256)) _data;
    }

    function getNonce(MultiNonces storage nonces, address from) internal view returns (uint256) {
        return nonces._data[from][0];
    }

    function getNonce(MultiNonces storage nonces, address from, uint256 timeline) internal view returns (uint256) {
        return nonces._data[from][timeline];
    }

    function _verifyAndConsumeNonce(MultiNonces storage nonces, address owner, uint256 idx) internal returns (bool) {
        return idx % (1 << 128) == nonces._data[owner][idx >> 128]++;
    }
}
