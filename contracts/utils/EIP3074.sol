// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library EIP3074 {
    function auth(bytes32 commit, bytes memory authsig) internal pure returns (address signer) {
        assembly {
            let v, r, s
            switch mload(authsig)
            case 65 {
                r := mload(add(authsig, 0x20))
                s := mload(add(authsig, 0x40))
                v := sub(byte(0, mload(add(authsig, 0x60))), 27)
            }
            case 64 {
                let vs := mload(add(authsig, 0x40))
                r := mload(add(authsig, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := shr(255, vs)
            }
            signer := auth(commit, v, r, s)
        }
        require(signer != address(0), "Invalid auth signature");
    }

    function authcall(address target, uint256 value, uint256 valueExt, bytes memory args) internal returns (bool result, bytes memory returndata) {
        assembly {
            //result := authcall(gas(), target, value, valueExt, add(args, 32), mload(args), 0, 0)
            result := authcall(0, target, value, valueExt, add(args, 32), mload(args), 0, 0)

            mstore8(returndata, returndatasize())
            returndatacopy(add(returndata, 32), 0, returndatasize())
        }
    }

    function authcallOrRevert(address target, uint256 value, uint256 valueExt, bytes memory args) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = authcall(target, value, valueExt, args);
        return _verifyCallResult(success, returndata, "Authcall reverted without reason");
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
