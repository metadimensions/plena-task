// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/aave/aave-protocol/blob/master/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "https://github.com/aave/aave-protocol/blob/master/contracts/interfaces/ILendingPoolAddressesProvider.sol";
import "https://github.com/aave/aave-protocol/blob/master/contracts/lendingpool/LendingPool.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


contract Lending is FlashLoanReceiverBase {

    address public owner;

    address public usdtAddress;
    address public usdcAddress;
    address public uniswapRouterAddress;

    enum Exchange {
        UNI
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can call this");
        _;
    }

        constructor(
        address _addressProvider,
        address _uniswapRouterAddress,
        address _usdc,
        address _usdt
    )
        public
        FlashLoanReceiverBase(ILendingPoolAddressesProvider(_addressProvider))
    {
        uniswapRouterAddress = _uniswapRouterAddress;
        owner = msg.sender;
        usdcAddress = _usdc;
        usdtAddress = _usdt;
    }

    function deposit(uint256 amount) public onlyOwner {
        require(amount > 0, "Deposit amount must be greater than 0");
        IERC20(usdcAddress).transferFrom(msg.sender, address(this), amount);
    }

   function withdraw(uint256 amount) public onlyOwner {
        uint256 usdtBalance = getERC20Balance(usdtAddress);
        require(amount <= usdtBalance, "Not enough amount deposited");
        IERC20(usdtAddress).transferFrom(address(this), msg.sender, amount);
    }

    function _swap(
        uint256 amountIn,
        address routerAddress,
        address sell_token,
        address buy_token
    ) internal returns (uint256) {
        IERC20(sell_token).approve(routerAddress, amountIn);

        uint256 amountOutMin = (_getPrice(
            routerAddress,
            sell_token,
            buy_token,
            amountIn
        ) * 95) / 100;

        address[] memory path = new address[](2);
        path[0] = sell_token;
        path[1] = buy_token;

        uint256 amountOut = IUniswapV2Router02(routerAddress)
            .swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                block.timestamp
            )[1];
        return amountOut;
    }

    function _flashloan(address[] memory assets, uint256[] memory amounts)
        internal
    {
        address receiverAddress = address(this);

        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;

        uint256[] memory modes = new uint256[](assets.length);

        for (uint256 i = 0; i < assets.length; i++) {
            modes[i] = 0;
        }

        LENDING_POOL.flashLoan(
            receiverAddress,
            assets,
            amounts,
            modes,
            onBehalfOf,
            params,
            referralCode
        );
    }


    function flashloan(address[] memory assets, uint256[] memory amounts)
        public
        onlyOwner
    {
        _flashloan(assets, amounts);
    }

    function flashloan(address _asset, uint256 _amount) public onlyOwner {
        bytes memory data = "";

        address[] memory assets = new address[](1);
        assets[0] = _asset;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;

        _flashloan(assets, amounts);
    }  
}
