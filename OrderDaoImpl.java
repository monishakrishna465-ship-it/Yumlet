package com.tap.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.OrderDao;
import com.tap.model.Order;
import com.tap.util.DBConnection;

public class OrderDaoImpl implements OrderDao {

    private static final String INSERT_ORDER =
            "INSERT INTO orders "
          + "(userId, restaurantId, orderDate, totalAmount, status, paymentMode) "
          + "VALUES (?, ?, ?, ?, ?, ?)";

    private static final String SELECT_ORDER_BY_ID =
            "SELECT * FROM orders WHERE orderId = ?";

    private static final String SELECT_ALL_ORDERS =
            "SELECT * FROM orders";

    private static final String SELECT_ORDERS_BY_USER =
            "SELECT * FROM orders WHERE userId = ?";

    private static final String SELECT_ORDERS_BY_RESTAURANT =
            "SELECT * FROM orders WHERE restaurantId = ?";

    private static final String UPDATE_ORDER =
            "UPDATE orders SET userId = ?, restaurantId = ?, "
          + "orderDate = ?, totalAmount = ?, status = ?, paymentMode = ? "
          + "WHERE orderId = ?";

    private static final String UPDATE_ORDER_STATUS =
            "UPDATE orders SET status = ? WHERE orderId = ?";

    private static final String DELETE_ORDER =
            "DELETE FROM orders WHERE orderId = ?";


    // =====================================================
    // ADD ORDER
    // =====================================================

    @Override
    public int addOrder(Order order) {

        int generatedOrderId = 0;

        try (
            Connection connection = DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            INSERT_ORDER,
                            Statement.RETURN_GENERATED_KEYS
                    )
        ) {

            statement.setInt(1, order.getUserId());

            statement.setInt(2, order.getRestaurantId());

            if (order.getOrderDate() != null) {

                statement.setTimestamp(
                        3,
                        order.getOrderDate()
                );

            } else {

                statement.setTimestamp(
                        3,
                        new Timestamp(System.currentTimeMillis())
                );
            }

            statement.setBigDecimal(
                    4,
                    order.getTotalAmount()
            );

            statement.setString(
                    5,
                    order.getStatus()
            );

            statement.setString(
                    6,
                    order.getPaymentMode()
            );

            statement.executeUpdate();


            // Get generated orderId

            try (ResultSet resultSet =
                         statement.getGeneratedKeys()) {

                if (resultSet.next()) {

                    generatedOrderId =
                            resultSet.getInt(1);

                    order.setOrderId(
                            generatedOrderId
                    );
                }
            }

            System.out.println(
                    "Order added successfully! Order ID: "
                    + generatedOrderId
            );

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return generatedOrderId;
    }


    // =====================================================
    // GET ORDER BY ID
    // =====================================================

    @Override
    public Order getOrder(int orderId) {

        Order order = null;

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            SELECT_ORDER_BY_ID
                    )
        ) {

            statement.setInt(1, orderId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                if (resultSet.next()) {

                    order =
                            extractOrderFromResultSet(
                                    resultSet
                            );
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return order;
    }


    // =====================================================
    // GET ALL ORDERS
    // =====================================================

    @Override
    public List<Order> getAllOrders() {

        List<Order> orders =
                new ArrayList<>();

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            SELECT_ALL_ORDERS
                    );

            ResultSet resultSet =
                    statement.executeQuery()
        ) {

            while (resultSet.next()) {

                Order order =
                        extractOrderFromResultSet(
                                resultSet
                        );

                orders.add(order);
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return orders;
    }


    // =====================================================
    // GET ORDERS BY USER
    // =====================================================

    @Override
    public List<Order> getOrdersByUser(int userId) {

        List<Order> orders =
                new ArrayList<>();

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            SELECT_ORDERS_BY_USER
                    )
        ) {

            statement.setInt(1, userId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                while (resultSet.next()) {

                    Order order =
                            extractOrderFromResultSet(
                                    resultSet
                            );

                    orders.add(order);
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return orders;
    }


    // =====================================================
    // GET ORDERS BY RESTAURANT
    // =====================================================

    @Override
    public List<Order> getOrdersByRestaurant(
            int restaurantId) {

        List<Order> orders =
                new ArrayList<>();

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            SELECT_ORDERS_BY_RESTAURANT
                    )
        ) {

            statement.setInt(1, restaurantId);

            try (ResultSet resultSet =
                         statement.executeQuery()) {

                while (resultSet.next()) {

                    Order order =
                            extractOrderFromResultSet(
                                    resultSet
                            );

                    orders.add(order);
                }
            }

        } catch (SQLException e) {

            e.printStackTrace();
        }

        return orders;
    }


    // =====================================================
    // UPDATE ORDER
    // =====================================================

    @Override
    public void updateOrder(Order order) {

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            UPDATE_ORDER
                    )
        ) {

            statement.setInt(
                    1,
                    order.getUserId()
            );

            statement.setInt(
                    2,
                    order.getRestaurantId()
            );

            if (order.getOrderDate() != null) {

                statement.setTimestamp(
                        3,
                        order.getOrderDate()
                );

            } else {

                statement.setTimestamp(
                        3,
                        new Timestamp(
                                System.currentTimeMillis()
                        )
                );
            }

            statement.setBigDecimal(
                    4,
                    order.getTotalAmount()
            );

            statement.setString(
                    5,
                    order.getStatus()
            );

            statement.setString(
                    6,
                    order.getPaymentMode()
            );

            statement.setInt(
                    7,
                    order.getOrderId()
            );

            statement.executeUpdate();

            System.out.println(
                    "Order updated successfully!"
            );

        } catch (SQLException e) {

            e.printStackTrace();
        }
    }


    // =====================================================
    // UPDATE ORDER STATUS
    // =====================================================

    @Override
    public void updateOrderStatus(
            int orderId,
            String status) {

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            UPDATE_ORDER_STATUS
                    )
        ) {

            statement.setString(
                    1,
                    status
            );

            statement.setInt(
                    2,
                    orderId
            );

            statement.executeUpdate();

            System.out.println(
                    "Order status updated successfully!"
            );

        } catch (SQLException e) {

            e.printStackTrace();
        }
    }


    // =====================================================
    // DELETE ORDER
    // =====================================================

    @Override
    public void deleteOrder(int orderId) {

        try (
            Connection connection =
                    DBConnection.getConnection();

            PreparedStatement statement =
                    connection.prepareStatement(
                            DELETE_ORDER
                    )
        ) {

            statement.setInt(
                    1,
                    orderId
            );

            statement.executeUpdate();

            System.out.println(
                    "Order deleted successfully!"
            );

        } catch (SQLException e) {

            e.printStackTrace();
        }
    }


    // =====================================================
    // RESULTSET → ORDER
    // =====================================================

    private Order extractOrderFromResultSet(
            ResultSet resultSet)
            throws SQLException {

        Order order = new Order();

        order.setOrderId(
                resultSet.getInt("orderId")
        );

        order.setUserId(
                resultSet.getInt("userId")
        );

        order.setRestaurantId(
                resultSet.getInt("restaurantId")
        );

        order.setOrderDate(
                resultSet.getTimestamp("orderDate")
        );

        order.setTotalAmount(
                resultSet.getBigDecimal("totalAmount")
        );

        order.setStatus(
                resultSet.getString("status")
        );

        order.setPaymentMode(
                resultSet.getString("paymentMode")
        );

        return order;
    }
}