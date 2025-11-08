// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title TransactaChain
 * @notice A decentralized transaction ledger enabling users to record, verify,
 *         and audit peer-to-peer transactions transparently on the blockchain.
 */
contract Project {
    address public admin;
    uint256 public txnCount;

    struct Transaction {
        uint256 id;
        address sender;
        address receiver;
        uint256 amount;
        string purpose;
        uint256 timestamp;
        bool verified;
    }

    mapping(uint256 => Transaction) public transactions;

    event TransactionRecorded(uint256 indexed id, address indexed sender, address indexed receiver, uint256 amount, string purpose);
    event TransactionVerified(uint256 indexed id);
    event AdminChanged(address indexed oldAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Record a new transaction on the blockchain
     * @param _receiver Address of the transaction receiver
     * @param _amount Amount transferred
     * @param _purpose Short description or note about the transaction
     */
    function recordTransaction(address _receiver, uint256 _amount, string memory _purpose) external {
        require(_receiver != address(0), "Invalid receiver address");
        require(_amount > 0, "Amount must be greater than 0");
        require(bytes(_purpose).length > 0, "Purpose cannot be empty");

        txnCount++;
        transactions[txnCount] = Transaction(
            txnCount,
            msg.sender,
            _receiver,
            _amount,
            _purpose,
            block.timestamp,
            false
        );

        emit TransactionRecorded(txnCount, msg.sender, _receiver, _amount, _purpose);
    }

    /**
     * @notice Verify a recorded transaction (admin only)
     * @param _id Transaction ID
     */
    function verifyTransaction(uint256 _id) external onlyAdmin {
        require(_id > 0 && _id <= txnCount, "Invalid transaction ID");
        require(!transactions[_id].verified, "Transaction already verified");

        transactions[_id].verified = true;

        emit TransactionVerified(_id);
    }

    /**
     * @notice Change the contract administrator
     * @param _newAdmin Address of the new admin
     */
    function changeAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0), "Invalid admin address");

        address oldAdmin = admin;
        admin = _newAdmin;

        emit AdminChanged(oldAdmin, _newAdmin);
    }

    /**
     * @notice Fetch transaction details by ID
     * @param _id Transaction ID
     * @return Transaction struct
     */
    function getTransaction(uint256 _id) external view returns (Transaction memory) {
        require(_id > 0 && _id <= txnCount, "Invalid transaction ID");
        return transactions[_id];
    }
}
// 
End
// 
