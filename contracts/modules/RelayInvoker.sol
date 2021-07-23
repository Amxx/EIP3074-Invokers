// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../utils/EIP3074.sol";
import "../utils/Nonced.sol";

contract RelayInvoker is Nonced {
    function relay(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[]   calldata calldatas,
        uint256            deadline,
        uint256            nonce,
        bytes     calldata authsig)
    public payable
    {
        address signer = EIP3074.auth(keccak256(abi.encode(targets, values, calldatas, deadline, nonce)), authsig);

        require(block.timestamp <= deadline, "Deadline reached");
        require(_verifyNonce(signer, nonce), "Invalid nonce");

        uint256 left = msg.value;
        for (uint256 i = 0; i < targets.length; ++i) {
            EIP3074.authcallOrRevert(targets[i], values[i], 0, calldatas[i]);
            left -= values[i];
        }
        Address.sendValue(payable(msg.sender), left);
    }
}
