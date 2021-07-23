// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./modules/BatchInvoker.sol";
import "./modules/RelayInvoker.sol";

contract Invoker is BatchInvoker, RelayInvoker {}
