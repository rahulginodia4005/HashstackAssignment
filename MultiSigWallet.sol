pragma solidity >=0.7.0 <0.9.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract MultiSigWallet is Ownable{
    uint public reqApprovals;

    struct Txn {
        address to;
        uint value;
        bool executed;
    }

    Txn[] public txns;

    address[] public signatures;

    mapping(address => bool) public isSignature;

    mapping(uint => mapping(address => bool)) public approved;

    event TxnSent(uint txnID);
    event Approved(address signature, uint txnID);
    event Executed(uint _txnId, address to, uint value);

    function SendTxn(address _to, uint _value) external payable onlyOwner {

        txns.push(Txn({
            to: _to,
            value: _value,
            executed: false
        }));

        uint txnId = txns.length - 1;
        emit TxnSent(txnId);
    }

    function approve(uint _txnId) external onlyOwner {
        require(_txnId < txns.length, "transaction is out of the limit");
        require(txns[_txnId].executed == false, "transaction has already been executed");
        require(approved[_txnId][msg.sender] == false, "You have already apporved the transaction");

        approved[_txnId][msg.sender] = true;

        emit Approved(msg.sender, _txnId);

    }

    function execute(uint _txnId) external {
        require(_txnId < txns.length, "transaction is out of the limit");
        require(txns[_txnId].executed == false, "transaction has already been executed");
        uint countApproved = 0;
        for(uint i =0; i < signatures.length; i++){
            if(approved[_txnId][signatures[i]]){
                countApproved++;
            }
        }
        require(countApproved >= reqApprovals, "Number of approvals are less than the required approvals");
        txns[_txnId].executed = true;

        (bool sucess, ) = (txns[_txnId].to).call{value: txns[_txnId].value}("");
        require(sucess, "Transaction couldn't complete");
        emit Executed(_txnId, txns[_txnId].to, txns[_txnId].value);
    }


}