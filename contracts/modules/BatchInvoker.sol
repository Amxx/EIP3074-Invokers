// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "../utils/EIP3074.sol";

contract BatchInvoker {
    function batch(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[]   calldata calldatas,
        bytes     calldata authsig)
    public payable
    {
        address signer = EIP3074.auth(bytes32(0), authsig);

        require(msg.sender == signer, "Restricted to self-auth");

        uint256 left = msg.value;
        for (uint256 i = 0; i < targets.length; ++i) {
            EIP3074.authcallOrRevert(targets[i], values[i], 0, calldatas[i]);
            left -= values[i];
        }
        Address.sendValue(payable(msg.sender), left);
    }
}
