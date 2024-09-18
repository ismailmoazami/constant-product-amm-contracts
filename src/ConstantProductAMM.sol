// SPDX-License-Identifier: MIT 
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ConstantProductAMM {

    event Swap(address indexed user, uint256 amountIn, uint256 amountOut);
    event AddLiquidity(address indexed user, uint256 amount0, uint256 amount1, uint256 shares);
    event RemoveLiquidity(address indexed user, uint256 amount0, uint256 amount1, uint256 shares); 

    IERC20 public immutable token0; 
    IERC20 public immutable token1;
    
    uint256 public reserve0;
    uint256 public reserve1; 
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf; 

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0); 
        token1 = IERC20(_token1);
    } 

    /* 
    * @notice Swap function to swap between two tokens
    * @param _tokenIn The address of the token to swap from
    * @param _amountIn The amount of the token to swap
    * @return amountOut The amount of the token received
    */
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

    function addLiquidity(uint256 _amount0, uint256 _amount1) external returns(uint256 shares) {
        require(_amount0 > 0 && _amount1 > 0, "Zero amount!"); 
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        if(reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1 == reserve1 * _amount0, "Mismatch!"); 
        }

        if(totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min((_amount0 * totalSupply) / reserve0, (_amount1 * totalSupply) / reserve1);
        }
        require(shares > 0, "Zero shares!");
        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        _updateReserves(reserve0 + _amount0, reserve1 + _amount1);
        emit AddLiquidity(msg.sender, _amount0, _amount1, shares);
        
    }

    function removeLiquidity(uint256 _shares) external returns(uint256 amount0, uint256 amount1) {
        require(_shares > 0, "Zero shares!"); 

        uint256 balance0 = token0.balanceOf(address(this)); 
        uint256 balance1 = token1.balanceOf(address(this));  

        amount0 = (_shares * balance0) / totalSupply;
        amount1 = (_shares * balance1) / totalSupply;

        require(amount0 > 0 && amount1 > 0, "Zero amount!"); 

        balanceOf[msg.sender] -= _shares; 
        totalSupply -= _shares; 
        
        _updateReserves(balance0 - amount0, balance1 - amount1); 

        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1); 

        emit RemoveLiquidity(msg.sender, amount0, amount1, _shares);

    }

    function _updateReserves(uint256 _reserve0, uint256 _reserve1) internal {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}

