
package com.tap.daoImpl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.tap.dao.DeliveryAddressDao;
import com.tap.model.DeliveryAddress;
import com.tap.util.DBConnection;

public class DeliveryAddressDaoImpl implements DeliveryAddressDao {

    @Override
    public boolean addAddress(DeliveryAddress address) {
        String sql = "INSERT INTO saved_addresses "
                + "(userId, fullName, phone, address, landmark, city, "
                + "pincode, addressType, isDefault) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, address.getUserId());
            ps.setString(2, address.getFullName());
            ps.setString(3, address.getPhone());
            ps.setString(4, address.getAddress());
            ps.setString(5, address.getLandmark());
            ps.setString(6, address.getCity());
            ps.setString(7, address.getPincode());
            ps.setString(8, address.getAddressType());
            ps.setBoolean(9, address.isDefault());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public List<DeliveryAddress> getAddressesByUserId(int userId) {
        List<DeliveryAddress> addresses = new ArrayList<>();

        String sql = "SELECT * FROM saved_addresses "
                + "WHERE userId = ? ORDER BY isDefault DESC, addressId DESC";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DeliveryAddress address = new DeliveryAddress();

                    address.setAddressId(rs.getInt("addressId"));
                    address.setUserId(rs.getInt("userId"));
                    address.setFullName(rs.getString("fullName"));
                    address.setPhone(rs.getString("phone"));
                    address.setAddress(rs.getString("address"));
                    address.setLandmark(rs.getString("landmark"));
                    address.setCity(rs.getString("city"));
                    address.setPincode(rs.getString("pincode"));
                    address.setAddressType(rs.getString("addressType"));
                    address.setDefault(rs.getBoolean("isDefault"));

                    addresses.add(address);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return addresses;
    }

    @Override
    public DeliveryAddress getAddressById(int addressId, int userId) {
        String sql = "SELECT * FROM saved_addresses "
                + "WHERE addressId = ? AND userId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, addressId);
            ps.setInt(2, userId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    DeliveryAddress address = new DeliveryAddress();

                    address.setAddressId(rs.getInt("addressId"));
                    address.setUserId(rs.getInt("userId"));
                    address.setFullName(rs.getString("fullName"));
                    address.setPhone(rs.getString("phone"));
                    address.setAddress(rs.getString("address"));
                    address.setLandmark(rs.getString("landmark"));
                    address.setCity(rs.getString("city"));
                    address.setPincode(rs.getString("pincode"));
                    address.setAddressType(rs.getString("addressType"));
                    address.setDefault(rs.getBoolean("isDefault"));

                    return address;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    @Override
    public boolean updateAddress(DeliveryAddress address) {
        String sql = "UPDATE saved_addresses SET fullName = ?, phone = ?, "
                + "address = ?, landmark = ?, city = ?, pincode = ?, "
                + "addressType = ? WHERE addressId = ? AND userId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, address.getFullName());
            ps.setString(2, address.getPhone());
            ps.setString(3, address.getAddress());
            ps.setString(4, address.getLandmark());
            ps.setString(5, address.getCity());
            ps.setString(6, address.getPincode());
            ps.setString(7, address.getAddressType());
            ps.setInt(8, address.getAddressId());
            ps.setInt(9, address.getUserId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean deleteAddress(int addressId, int userId) {
        String sql = "DELETE FROM saved_addresses "
                + "WHERE addressId = ? AND userId = ?";

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, addressId);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    @Override
    public boolean setDefaultAddress(int addressId, int userId) {
        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String resetSql = "UPDATE saved_addresses "
                    + "SET isDefault = 0 WHERE userId = ?";

            try (PreparedStatement ps = con.prepareStatement(resetSql)) {
                ps.setInt(1, userId);
                ps.executeUpdate();
            }

            String setSql = "UPDATE saved_addresses "
                    + "SET isDefault = 1 WHERE addressId = ? AND userId = ?";

            int updated;

            try (PreparedStatement ps = con.prepareStatement(setSql)) {
                ps.setInt(1, addressId);
                ps.setInt(2, userId);
                updated = ps.executeUpdate();
            }

            if (updated == 0) {
                con.rollback();
                return false;
            }

            con.commit();
            return true;

        } catch (SQLException e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (SQLException rollbackError) {
                    rollbackError.printStackTrace();
                }
            }

            e.printStackTrace();
            return false;

        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
