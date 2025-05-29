// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ManagerRole.sol"; // ManagerRole kế thừa từ Owner và định nghĩa onlyManager

contract Product is ManagerRole {
    struct ProductItem {
        uint id;
        string name;
        uint quantity;
        address manager;
        uint timestamp;
    }

    ProductItem[] private products;

    // Mapping để truy vết sản phẩm theo manager
    mapping(address => uint[]) private managerProductIds;

    event ProductAdded(
        uint indexed id,
        string name,
        uint quantity,
        address indexed manager,
        uint timestamp
    );

    /// @notice Chỉ manager được phép thêm sản phẩm
    function addProduct(string memory name, uint quantity) public onlyManager {
        uint id = products.length;
        products.push(ProductItem({
            id: id,
            name: name,
            quantity: quantity,
            manager: msg.sender,
            timestamp: block.timestamp
        }));

        managerProductIds[msg.sender].push(id);

        emit ProductAdded(id, name, quantity, msg.sender, block.timestamp);
    }

    /// @notice Trả về tổng số sản phẩm đã thêm
    function getProductCount() public view returns (uint) {
        return products.length;
    }

    /// @notice Lấy thông tin chi tiết của một sản phẩm theo index
    function getProduct(uint index) public view returns (
        uint id,
        string memory name,
        uint quantity,
        address manager,
        uint timestamp
    ) {
        require(index < products.length, "Invalid product index");
        ProductItem storage item = products[index];
        return (item.id, item.name, item.quantity, item.manager, item.timestamp);
    }

    /// @notice Lấy danh sách ID sản phẩm do một manager cụ thể đã thêm
    function getProductIdsByManager(address manager) public view returns (uint[] memory) {
        return managerProductIds[manager];
    }

    /// @notice Lấy toàn bộ thông tin sản phẩm của một manager cụ thể
    function getProductsByManager(address manager) public view returns (ProductItem[] memory) {
        uint[] storage ids = managerProductIds[manager];
        ProductItem[] memory result = new ProductItem[](ids.length);

        for (uint i = 0; i < ids.length; i++) {
            result[i] = products[ids[i]];
        }

        return result;
    }

    /// @notice Lấy tất cả sản phẩm (dành cho customer xem trong tương lai)
    function getAllProducts() public view returns (ProductItem[] memory) {
        return products;
    }
}
