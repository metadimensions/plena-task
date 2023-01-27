// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;


contract USDCtoUSDT {
    address payable public compound;
    address payable public usdc;
    address payable public usdt;
    
    constructor(address _compound, address _usdc, address _usdt) public {
        compound = _compound;
        usdc = _usdc;
        usdt = _usdt;
    }
    
    function swapAndLend(uint256 amount) public {
        // Swap USDC to USDT
        usdc.transferFrom(msg.sender, usdt, amount);
        
        // Lend USDT on Compound
        compound.call(bytes4(keccak256("mint(address,uint256)")), usdt, amount);
    }
}