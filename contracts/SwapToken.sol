// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Interface/IUSDC.sol";
import "./Interface/IUSDT.sol";
import "./Interface/IDAI.sol";

contract SwapToken is ReentrancyGuard {
    USDC public usdc;
    USDT public usdt;
    DAI public dai;

    mapping(address => uint256[3]) userBalance;

    constructor(
        address usdcContractAddress,
        address usdtContractAddress,
        address daiContractAddress
    ) {
        usdc = USDC(usdcContractAddress);
        usdt = USDT(usdtContractAddress);
        dai = DAI(daiContractAddress);
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
