// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library ReplayProtection {
    struct Nonces {
        mapping(address => uint256) _data;
    }

    function getNonce(Nonces storage nonces, address from) internal view returns (uint256) {
        return nonces._data[from];
    }

    function verifyAndConsumeNonce(Nonces storage nonces, address owner, uint256 idx) internal returns (bool) {
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

    function verifyAndConsumeNonce(MultiNonces storage nonces, address owner, uint256 idx) internal returns (bool) {
        return idx % (1 << 128) == nonces._data[owner][idx >> 128]++;
    }
}
