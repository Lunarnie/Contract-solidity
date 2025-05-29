// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Context.sol";

contract Owner is Context {
    address private _owner;

    // Địa chỉ deployer được phép (bạn có thể sửa lại cho phù hợp)
    address private constant _allowedDeployer = 0xe7c23E48FcE2a43FAf525e2A0B32f55f934B3232;

    // Sự kiện khi thay đổi owner
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // Gán owner ban đầu (nếu được phép)
    constructor() {
        require(_msgSender() == _allowedDeployer, "Owner: deployer not authorized");
        _owner = _msgSender();
        emit OwnerSet(address(0), _owner);
    }

    // Modifier kiểm tra quyền owner
    modifier onlyOwner() {
        require(_msgSender() == _owner, "Owner: caller is not the owner");
        _;
    }

    // Trả về owner hiện tại
    function getOwner() external view returns (address) {
        return _owner;
    }

    // Cho phép chuyển quyền sở hữu
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Owner: new owner is the zero address");
        emit OwnerSet(_owner, newOwner);
        _owner = newOwner;
    }

    // Cho phép từ bỏ quyền sở hữu (optional)
    function renounceOwnership() external onlyOwner {
        emit OwnerSet(_owner, address(0));
        _owner = address(0);
    }
}
