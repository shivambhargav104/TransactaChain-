// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title TransactaChain
 * @notice A decentralized multi-asset transfer hub + on-chain audit registry
 * @dev Supports ETH transfers and ERC20 transfers with immutable logging
 */

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TransactaChain {
    address public owner;

    enum AssetType { ETH, ERC20 }

    struct TxRecord {
        address from;
        address to;
        AssetType assetType;
        address tokenAddress;   // 0x0 for ETH
        uint256 amount;
        uint256 timestamp;
        bytes32 txHash;
    }

    TxRecord[] public transactions;

    event TransferExecuted(
        address indexed from,
        address indexed to,
        AssetType assetType,
        address token,
        uint256 amount,
        bytes32 txHash
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // ─────────────────────────────────────────────
    // ⭐ ETH TRANSFER WITH LOGGING
    // ─────────────────────────────────────────────
    function transferETH(address payable to) external payable {
        require(msg.value > 0, "No ETH sent");
        require(to != address(0), "Invalid address");

        to.transfer(msg.value);

        bytes32 txHash = keccak256(
            abi.encodePacked(msg.sender, to, msg.value, block.timestamp, block.number)
        );

        transactions.push(
            TxRecord(msg.sender, to, AssetType.ETH, address(0), msg.value, block.timestamp, txHash)
        );

        emit TransferExecuted(msg.sender, to, AssetType.ETH, address(0), msg.value, txHash);
    }

    // ─────────────────────────────────────────────
    // ⭐ ERC20 TRANSFER WITH LOGGING
    // ─────────────────────────────────────────────
    function transferERC20(
        address token,
        address to,
        uint256 amount
    ) external {
        require(token != address(0), "Token required");
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount required");

        IERC20(token).transferFrom(msg.sender, to, amount);

        bytes32 txHash = keccak256(
            abi.encodePacked(msg.sender, to, amount, token, block.timestamp, block.number)
        );

        transactions.push(
            TxRecord(msg.sender, to, AssetType.ERC20, token, amount, block.timestamp, txHash)
        );

        emit TransferExecuted(msg.sender, to, AssetType.ERC20, token, amount, txHash);
    }

    // ─────────────────────────────────────────────
    // ⭐ VIEW FUNCTIONS
    // ─────────────────────────────────────────────
    function getTransaction(uint256 index) external view returns (TxRecord memory) {
        return transactions[index];
    }

    function getTotalTransactions() external view returns (uint256) {
        return transactions.length;
    }

    function getAllTransactions() external view returns (TxRecord[] memory) {
        return transactions;
    }
}
