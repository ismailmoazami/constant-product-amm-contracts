# Constant Product Automated Market Maker (CPAMM)

This project implements a Constant Product Automated Market Maker (CPAMM) using Solidity. It's designed to facilitate token swaps and liquidity provision in a decentralized manner.

## Overview

The CPAMM is a smart contract that allows users to:
- Swap between two ERC20 tokens
- Add liquidity to the pool
- Remove liquidity from the pool

The contract maintains a constant product of reserves (x * y = k) to determine exchange rates and manage liquidity.

## Key Features

- Swap tokens with a 0.5% fee
- Add and remove liquidity
- Automatic price adjustment based on supply and demand
- Compatible with any ERC20 token pair

## Smart Contracts

- `ConstantProductAMM.sol`: The main CPAMM contract
- `Deploy.s.sol`: Script for deploying the CPAMM

## Setup and Deployment

1. Install dependencies:
   ```
   forge install
   ```

2. Set up your `.env` file with the following variables:
   - `SEPOLIA_RPC_URL`: RPC URL for the Sepolia testnet
   - `ETHERSCAN_API_KEY`: Your Etherscan API key
   - `PRIVATE_KEY`: Your wallet's private key

3. Deploy the contract:
   ```
   make deploy
   ```

4. Interact with the contract:
   ```
   make interactions
   ```

## Testing

Run the test suite using Forge:
