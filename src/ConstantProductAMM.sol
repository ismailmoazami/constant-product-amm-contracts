// SPDX-License-Identifier: MIT 
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConstantProductAMM {

    event Swap(address indexed user, uint256 amountIn, uint256 amountOut);

    IERC20 public immutable token0; 
    IERC20 public immutable token1;
    
    uint256 public reserve0;
    uint256 public reserve1; 

    mapping(address => uint256) public balances; 

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0); 
        token1 = IERC20(_token1);
    } 

    function swap(address _tokenIn, uint256 _amountIn) external returns(uint256 amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "Invalid token!");
        require(_amountIn > 0, "Zero amount!");

        bool isToken0 = _tokenIn == address(token0); 
        (IERC20 tokenIn, IERC20 tokenOut, uint256 reserveIn, uint256 reserveOut) = 
        isToken0 ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        IERC20(tokenIn).transferFrom(msg.sender, address(this), _amountIn); 

        // 0.5% fee
        uint256 amountInWithFee = (_amountIn* 995) / 1000; 
        amountOut = (reserveOut*amountInWithFee) / (reserveIn + amountInWithFee); 
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        reserveOut = reserveOut - amountOut; 
        reserveIn = reserveIn + amountInWithFee; 
        _updateReserves(reserveIn, reserveOut);

        emit Swap(msg.sender, _amountIn, amountOut);
    }

    function _updateReserves(uint256 _reserve0, uint256 _reserve1) internal {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

}