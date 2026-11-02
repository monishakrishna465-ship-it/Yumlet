
package com.tap.dao;

import java.util.List;
import com.tap.model.DeliveryAddress;

public interface DeliveryAddressDao {

    boolean addAddress(DeliveryAddress address);

    List<DeliveryAddress> getAddressesByUserId(int userId);

    DeliveryAddress getAddressById(int addressId, int userId);

    boolean updateAddress(DeliveryAddress address);

    boolean deleteAddress(int addressId, int userId);

    boolean setDefaultAddress(int addressId, int userId);
}
