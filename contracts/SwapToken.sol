// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Interface/IUSDC.sol";

contract SwapToken is ReentrancyGuard {
    USDC public usdc;

    mapping(address => uint256[3]) userBalance;

    constructor(address usdcContractAddress) {
        usdc = USDC(usdcContractAddress);
    }

    function depositFund(uint256 _amount) external {
        require(
            usdc.balanceOf(msg.sender) >= _amount,
            "Not enough balance in user wallet"
        );

        usdc.transferFrom(msg.sender, address(this), _amount);

        userBalance[msg.sender][0] += _amount;
    }

    function withdrawFundSet(uint256 _amount) external nonReentrant {
        require(
            usdc.balanceOf(address(this)) >= _amount,
            "Not enough balance in the pool"
        );
        require(
            userBalance[msg.sender][0] > _amount,
            "You have not enough balance to withdraw"
        );

        usdc.approve(msg.sender, _amount);

        usdc.transfer(msg.sender, _amount);

        userBalance[msg.sender][0] -= _amount;
    }
}
