// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Interface/IUSDC.sol";
import "./Interface/IUSDT.sol";
import "./Interface/IDAI.sol";
import "./Interface/IUniswapV2Factory.sol";
import "./Interface/IUniswapV2Pair.sol";
import "./Interface/IUniswapV2Router.sol";

contract SwapToken is ReentrancyGuard {
    USDC public usdc;
    USDT public usdt;
    DAI public dai;
    UniswapV2Router public uniswapV2Router;
    UniswapV2Pair public uniswapV2Pair;
    UniswapV2Factory public uniswapV2Factory;

    mapping(address => uint256[3]) userBalance;

    //address of the uniswap v2 router
    address private constant UNISWAP_V2_ROUTER =
        0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    //address of WMATIC token
    address private constant WMATIC =
        0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    constructor(
        address usdcContractAddress,
        address usdtContractAddress,
        address daiContractAddress
    ) {
        usdc = USDC(usdcContractAddress);
        usdt = USDT(usdtContractAddress);
        dai = DAI(daiContractAddress);
        uniswapV2Router = UniswapV2Router(UNISWAP_V2_ROUTER);
    }

    function depositFund(uint256 _amount, uint8 _coinIdx) external {
        if (_coinIdx == 0) {
            require(
                usdc.balanceOf(msg.sender) >= _amount,
                "Not enough balance in user wallet"
            );

            usdc.transferFrom(msg.sender, address(this), _amount);
        } else if (_coinIdx == 1) {
            require(
                usdt.balanceOf(msg.sender) >= _amount,
                "Not enough balance in user wallet"
            );

            usdt.transferFrom(msg.sender, address(this), _amount);
        } else {
            require(
                dai.balanceOf(msg.sender) >= _amount,
                "Not enough balance in user wallet"
            );

            dai.transferFrom(msg.sender, address(this), _amount);
        }

        userBalance[msg.sender][_coinIdx] += _amount;
    }

    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to,
        uint8 _coinIdx
    ) external {
        if (_coinIdx == 0) {
            require(
                usdc.balanceOf(msg.sender) >= _amountIn,
                "Not enough balance in user wallet"
            );
            usdc.transferFrom(msg.sender, address(this), _amountIn);
            usdc.approve(UNISWAP_V2_ROUTER, _amountIn);
        } else if (_coinIdx == 1) {
            require(
                usdt.balanceOf(msg.sender) >= _amountIn,
                "Not enough balance in user wallet"
            );
            usdt.transferFrom(msg.sender, address(this), _amountIn);
            usdt.approve(UNISWAP_V2_ROUTER, _amountIn);
        } else {
            require(
                dai.balanceOf(msg.sender) >= _amountIn,
                "Not enough balance in user wallet"
            );
            dai.transferFrom(msg.sender, address(this), _amountIn);
            dai.approve(UNISWAP_V2_ROUTER, _amountIn);
        }

        address[] memory path;
        if (_tokenIn == WMATIC || _tokenOut == WMATIC) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WMATIC;
            path[2] = _tokenOut;
        }

        uniswapV2Router.swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }

    function getAmountOutMin(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn
    ) external view returns (uint256) {
        address[] memory path;
        if (_tokenIn == WMATIC || _tokenOut == WMATIC) {
            path = new address[](2);
            path[0] = _tokenIn;
            path[1] = _tokenOut;
        } else {
            path = new address[](3);
            path[0] = _tokenIn;
            path[1] = WMATIC;
            path[2] = _tokenOut;
        }

        uint256[] memory amountOutMins = uniswapV2Router.getAmountsOut(
            _amountIn,
            path
        );
        return amountOutMins[path.length - 1];
    }

    function withdrawFund(
        uint256 _amount,
        uint8 _coinIdx
    ) external nonReentrant {
        require(
            userBalance[msg.sender][_coinIdx] >= _amount,
            "You have not enough balance to withdraw"
        );

        if (_coinIdx == 0) {
            require(
                usdc.balanceOf(address(this)) >= _amount,
                "Not enough balance in the pool"
            );

            usdc.approve(msg.sender, _amount);
            usdc.transfer(msg.sender, _amount);
        } else if (_coinIdx == 1) {
            require(
                usdt.balanceOf(address(this)) >= _amount,
                "Not enough balance in the pool"
            );

            usdt.approve(msg.sender, _amount);
            usdt.transfer(msg.sender, _amount);
        } else {
            require(
                dai.balanceOf(address(this)) >= _amount,
                "Not enough balance in the pool"
            );

            dai.approve(msg.sender, _amount);
            dai.transfer(msg.sender, _amount);
        }

        userBalance[msg.sender][_coinIdx] -= _amount;
    }
}
