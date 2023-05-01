// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface UniswapV2Factory {
    function getPair(address token0, address token1) external returns (address);
}
