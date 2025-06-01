// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Product.sol";

contract CustomerRequestBySupplier is Product {
    struct PurchaseRequest {
        uint requestId;
        address customer;
        address supplier;
        string productName;
        uint quantity;
        uint maxPricePerUnit;
        string deliveryAddress;
        uint timestamp;
        bool quoted;
    }

    uint private nextRequestId = 0;
    mapping(uint => PurchaseRequest) public requests;
    mapping(address => uint[]) public customerRequestIds;

    event PurchaseRequested(
        uint indexed requestId,
        address indexed customer,
        address indexed supplier,
        string productName,
        uint quantity,
        uint maxPricePerUnit,
        string deliveryAddress,
        uint timestamp
    );

    /// @notice Customer yêu cầu mua sản phẩm từ supplier cụ thể theo tên sản phẩm
    function requestPurchaseFromSupplier(
        address supplier,
        string memory productName,
        uint quantity,
        uint maxPricePerUnit,
        string memory deliveryAddress
    ) public {
        require(quantity > 0, "Quantity must be greater than zero");

        // Tính tổng quantity từ supplier cụ thể với tên sản phẩm
        ProductItem[] memory all = getAllProducts();
        uint totalAvailable = 0;

        for (uint i = 0; i < all.length; i++) {
            if (
                all[i].manager == supplier &&
                keccak256(bytes(all[i].name)) == keccak256(bytes(productName))
            ) {
                totalAvailable += all[i].quantity;
            }
        }

        require(totalAvailable >= quantity, "Not enough stock from selected supplier");

        // Lưu yêu cầu mua hàng
        requests[nextRequestId] = PurchaseRequest({
            requestId: nextRequestId,
            customer: msg.sender,
            supplier: supplier,
            productName: productName,
            quantity: quantity,
            maxPricePerUnit: maxPricePerUnit,
            deliveryAddress: deliveryAddress,
            timestamp: block.timestamp,
            quoted: false
        });

        customerRequestIds[msg.sender].push(nextRequestId);

        emit PurchaseRequested(
            nextRequestId,
            msg.sender,
            supplier,
            productName,
            quantity,
            maxPricePerUnit,
            deliveryAddress,
            block.timestamp
        );

        nextRequestId++;
    }

    function getRequestsByCustomer(address customer) public view returns (PurchaseRequest[] memory) {
        uint[] storage ids = customerRequestIds[customer];
        PurchaseRequest[] memory result = new PurchaseRequest[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            result[i] = requests[ids[i]];
        }
        return result;
    }

    function getAllRequests() public view returns (PurchaseRequest[] memory) {
        PurchaseRequest[] memory result = new PurchaseRequest[](nextRequestId);
        for (uint i = 0; i < nextRequestId; i++) {
            result[i] = requests[i];
        }
        return result;
    }
}
