include .env

build :; forge build 

deploy :; forge script script/Deploy.s.sol --broadcast --rpc-url $(SEPOLIA_RPC_URL) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) --account myaccount -vvvv
interactions :; forge script script/Interactions.s.sol --broadcast --rpc-url $(SEPOLIA_RPC_URL) --account myaccount -vvvvv
