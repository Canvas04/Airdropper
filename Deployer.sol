//SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC1155Airdropper.sol";

contract ERC1155Deployer is Ownable {
    uint256 public deployFee;

    mapping(address => address[]) public deployedContracts;

    error InsufficientFunds();
    error AddressCantBeZero();
    error TransferError();

    event Deployed(
        address deployer,
        address ERC1155Airdropper,
        uint256 fees,
        address _tokenAddress,
        uint256 timestamp
    );
    event FeeUpdated(uint256 newFee);

    constructor(uint256 _deployFee) Ownable(msg.sender) {
        deployFee = _deployFee;
    }

    function setDeployFee(uint256 _fee) external {
        deployFee = _fee;

        emit FeeUpdated(_fee);
    }

    function deployERC1155Airdropper(address _tokenAddress)
        external
        payable
        returns (address)
    {
        require(msg.value >= deployFee, InsufficientFunds());
        require(_tokenAddress != address(0), AddressCantBeZero());

        ERC1155Airdropper airdropper = new ERC1155Airdropper(_tokenAddress);

        _safeTransfer(owner(), msg.value);
        emit Deployed(
            msg.sender,
            address(airdropper),
            msg.value,
            _tokenAddress,
            block.timestamp
        );

        return address(airdropper);
    }

    function _safeTransfer(address _to, uint256 _amount) internal {
        (bool success, ) = payable(_to).call{value: _amount}("");
        require(success, TransferError());
    }
}
