package com.tap.dao;

import java.util.List;

import com.tap.model.OrderItem;

public interface OrderItemDao {

    // Create
    void addOrderItem(OrderItem orderItem);

    // Read
    OrderItem getOrderItem(int orderItemId);

    List<OrderItem> getAllOrderItems();

    List<OrderItem> getOrderItemsByOrder(int orderId);

    // Update
    void updateOrderItem(OrderItem orderItem);

    // Delete
    void deleteOrderItem(int orderItemId);
}