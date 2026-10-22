package com.tap.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.OrderItemDao;
import com.tap.model.OrderItem;
import com.tap.util.DBConnection;

public class OrderItemDaoImpl implements OrderItemDao {

    private static final String INSERT_ORDER_ITEM =
            "INSERT INTO orderItem "
          + "(orderId, menuId, totalAmount) "
          + "VALUES (?, ?, ?)";

    private static final String SELECT_ORDER_ITEM_BY_ID =
            "SELECT * FROM orderItem WHERE orderItemId = ?";

    private static final String SELECT_ALL_ORDER_ITEMS =
            "SELECT * FROM orderItem";

    private static final String SELECT_ORDER_ITEMS_BY_ORDER =
            "SELECT * FROM orderItem WHERE orderId = ?";

    private static final String UPDATE_ORDER_ITEM =
            "UPDATE orderItem SET orderId = ?, menuId = ?, "
          + "totalAmount = ? WHERE orderItemId = ?";

    private static final String DELETE_ORDER_ITEM =
            "DELETE FROM orderItem WHERE orderItemId = ?";


    // =========================
    // ADD ORDER ITEM
    // =========================

    @Override
    public void addOrderItem(OrderItem orderItem) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(INSERT_ORDER_ITEM)) {

            statement.setInt(1, orderItem.getOrderId());
            statement.setInt(2, orderItem.getMenuId());
            statement.setBigDecimal(3, orderItem.getTotalAmount());

            statement.executeUpdate();

            System.out.println("Order item added successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // GET ORDER ITEM BY ID
    // =========================

    @Override
    public OrderItem getOrderItem(int orderItemId) {

        OrderItem orderItem = null;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ORDER_ITEM_BY_ID)) {

            statement.setInt(1, orderItemId);

            ResultSet resultSet = statement.executeQuery();

            if (resultSet.next()) {

                orderItem = extractOrderItemFromResultSet(resultSet);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItem;
    }


    // =========================
    // GET ALL ORDER ITEMS
    // =========================

    @Override
    public List<OrderItem> getAllOrderItems() {

        List<OrderItem> orderItems = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ALL_ORDER_ITEMS)) {

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                OrderItem orderItem =
                        extractOrderItemFromResultSet(resultSet);

                orderItems.add(orderItem);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItems;
    }


    // =========================
    // GET ITEMS BY ORDER
    // =========================

    @Override
    public List<OrderItem> getOrderItemsByOrder(int orderId) {

        List<OrderItem> orderItems = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(SELECT_ORDER_ITEMS_BY_ORDER)) {

            statement.setInt(1, orderId);

            ResultSet resultSet = statement.executeQuery();

            while (resultSet.next()) {

                OrderItem orderItem =
                        extractOrderItemFromResultSet(resultSet);

                orderItems.add(orderItem);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return orderItems;
    }


    // =========================
    // UPDATE ORDER ITEM
    // =========================

    @Override
    public void updateOrderItem(OrderItem orderItem) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(UPDATE_ORDER_ITEM)) {

            statement.setInt(1, orderItem.getOrderId());
            statement.setInt(2, orderItem.getMenuId());
            statement.setBigDecimal(3, orderItem.getTotalAmount());
            statement.setInt(4, orderItem.getOrderItemId());

            statement.executeUpdate();

            System.out.println("Order item updated successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // DELETE ORDER ITEM
    // =========================

    @Override
    public void deleteOrderItem(int orderItemId) {

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement =
                     connection.prepareStatement(DELETE_ORDER_ITEM)) {

            statement.setInt(1, orderItemId);

            statement.executeUpdate();

            System.out.println("Order item deleted successfully!");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    // =========================
    // RESULTSET → ORDER ITEM
    // =========================

    private OrderItem extractOrderItemFromResultSet(ResultSet resultSet)
            throws SQLException {

        OrderItem orderItem = new OrderItem();

        orderItem.setOrderItemId(
                resultSet.getInt("orderItemId"));

        orderItem.setOrderId(
                resultSet.getInt("orderId"));

        orderItem.setMenuId(
                resultSet.getInt("menuId"));

        orderItem.setTotalAmount(
                resultSet.getBigDecimal("totalAmount"));

        return orderItem;
    }
}