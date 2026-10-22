package com.tap.dao;

import java.util.List;

import com.tap.model.Order;

public interface OrderDao {

    // Create
    int addOrder(Order order);

    // Read
    Order getOrder(int orderId);

    List<Order> getAllOrders();

    List<Order> getOrdersByUser(int userId);

    List<Order> getOrdersByRestaurant(int restaurantId);

    // Update
    void updateOrder(Order order);

    void updateOrderStatus(int orderId, String status);

    // Delete
    void deleteOrder(int orderId);
}