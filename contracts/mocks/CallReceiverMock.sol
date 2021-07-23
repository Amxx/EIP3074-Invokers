// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CallReceiverMock {
    event Received(address sender, uint256 value, bytes data);

    fallback() external payable {
        emit Received(msg.sender, msg.value, msg.data);
    }

    function fail() external payable {
        revert("CallReceiverMock revert");
    }
}
