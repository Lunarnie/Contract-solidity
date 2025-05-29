// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Owner.sol";
import "./Roles.sol";

contract ManagerRole is Owner {
    using Roles for Roles.Role;

    event ManagerAdded(address indexed account);
    event ManagerRemoved(address indexed account);

    Roles.Role private managers;
    address[] private managerList; // Danh sách các địa chỉ đã được thêm làm manager

    constructor() {
        // Không tự động thêm owner vào managers
    }

    modifier onlyManager() {
        require(isManager(_msgSender()), "ManagerRole: caller is not a manager");
        _;
    }

    function isManager(address account) public view returns (bool) {
        return managers.has(account);
    }

    function addManager(address account) public onlyOwner {
        _addManager(account);
    }

    function addManagers(address[] memory accounts) public onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            _addManager(accounts[i]);
        }
    }

    function removeManager(address account) public onlyOwner {
        _removeManager(account);
    }

    function renounceManager() public onlyManager {
        _removeManager(_msgSender());
    }

    function _addManager(address account) internal {
        if (!managers.has(account)) {
            managers.add(account);
            managerList.push(account);
            emit ManagerAdded(account);
        }
    }

    function _removeManager(address account) internal {
        if (managers.has(account)) {
            managers.remove(account);
            emit ManagerRemoved(account);
            // Không xóa khỏi mảng để tránh tốn gas, chỉ kiểm tra bằng `has()`
        }
    }

    /// ✅ Public: Lấy danh sách tất cả địa chỉ đã từng được thêm làm manager
    function getAllManagers() public view returns (address[] memory activeManagers) {
        uint count = 0;
        for (uint i = 0; i < managerList.length; i++) {
            if (managers.has(managerList[i])) {
                count++;
            }
        }

        activeManagers = new address[](count);
        uint index = 0;
        for (uint i = 0; i < managerList.length; i++) {
            if (managers.has(managerList[i])) {
                activeManagers[index] = managerList[i];
                index++;
            }
        }
    }
}
