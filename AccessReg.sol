pragma solidity >=0.7.0 <0.9.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "./Multisigwallet.sol";

contract AccessRegistry is Ownable, MultiSigWallet {

    constructor(address[] memory _signaturelist) {
        uint length = _signaturelist.length;
        require(length > 0, "There should be atleast one signature of the wallet");
        reqApprovals = length * 60 / 100;

        for(uint i = 0; i < length; i++){
            address signature = _signaturelist[i];
            require(signature != address(0), "Address of the signature can't be address(0)");
            require(isSignature[signature] == false, "The signature already exists");
            signatures.push(signature);
            isSignature[signature] = true;
        }
    }

    event SignatureAdded(address NewSignature);
    event SignatureRevoked(address OldSignature);
    event SignatureTransferred(address _From, address _To);

    function addSignature(address newSignature) external onlyOwner {
        require(newSignature != address(0),"invalid address provided");
        require(isSignature[newSignature] == false, "Signature already exists!");

        signatures.push(newSignature);
        reqApprovals = signatures.length * 60 / 100;
        isSignature[newSignature] = true;

        emit SignatureAdded(newSignature);
    }

    function findSignatureIndex(address _signature) private view returns(uint) {
        require(_signature != address(0),"invalid address provided");
        require(isSignature[_signature], "Given address is not already an Signature");
        uint index;
        for(uint i=0;i<signatures.length;i++){
            if(signatures[i] == _signature){
                index = i;
                break;
            }
        }
        return index;
    }

    function revokeSignature(address oldSignature) external onlyOwner {
        require(oldSignature != address(0),"invalid address provided");
        require(isSignature[oldSignature], "Given address is not already an signature");
        uint index = findSignatureIndex(oldSignature);
        isSignature[oldSignature] = false;
        signatures[index] = signatures[signatures.length - 1];
        signatures.pop();
        reqApprovals = signatures.length * 60 / 100;

        emit SignatureRevoked(oldSignature);
    }

    function transferSignature(address _from, address _to) external onlyOwner {
        require((_from != address(0)) || (_to != address(0)),"invalid address provided");
        require(isSignature[_from], "Signature is not already there");
        require(isSignature[_to] == false,"Signature already exists");
        isSignature[_from] = false;
        isSignature[_to] = true;
        uint index = findSignatureIndex(_from);
        signatures[index] = _to;

        emit SignatureTransferred(_from, _to);

    }
}