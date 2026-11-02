
package com.tap.controllers;

import java.io.IOException;
import java.util.List;

import com.tap.dao.DeliveryAddressDao;
import com.tap.daoImpl.DeliveryAddressDaoImpl;
import com.tap.model.DeliveryAddress;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/delivery-address")
public class DeliveryAddressController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final DeliveryAddressDao addressDao =
            new DeliveryAddressDaoImpl();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = Integer.parseInt(
                session.getAttribute("userId").toString());

        String action = request.getParameter("action");

        if ("edit".equals(action)) {
            int addressId = Integer.parseInt(
                    request.getParameter("addressId"));

            DeliveryAddress address =
                    addressDao.getAddressById(addressId, userId);

            if (address == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Address not found.");
                return;
            }

            request.setAttribute("editAddress", address);
        }

        List<DeliveryAddress> addresses =
                addressDao.getAddressesByUserId(userId);

        request.setAttribute("addresses", addresses);

        request.getRequestDispatcher("/delivery-addresses.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        int userId = Integer.parseInt(
                session.getAttribute("userId").toString());

        String action = request.getParameter("action");

        try {
            boolean success = false;

            if ("save".equals(action)) {
                DeliveryAddress address = new DeliveryAddress();

                address.setUserId(userId);
                address.setFullName(request.getParameter("fullName"));
                address.setPhone(request.getParameter("phone"));
                address.setAddress(request.getParameter("address"));
                address.setLandmark(request.getParameter("landmark"));
                address.setCity(request.getParameter("city"));
                address.setPincode(request.getParameter("pincode"));
                address.setAddressType(request.getParameter("addressType"));

                String addressIdText = request.getParameter("addressId");

                if (addressIdText != null && !addressIdText.isBlank()) {
                    int addressId = Integer.parseInt(addressIdText);

                    DeliveryAddress existing =
                            addressDao.getAddressById(addressId, userId);

                    if (existing == null) {
                        response.sendError(
                                HttpServletResponse.SC_NOT_FOUND,
                                "Address not found.");
                        return;
                    }

                    address.setAddressId(addressId);
                    success = addressDao.updateAddress(address);

                } else {
                    success = addressDao.addAddress(address);
                }

            } else if ("delete".equals(action)) {
                int addressId = Integer.parseInt(
                        request.getParameter("addressId"));

                success = addressDao.deleteAddress(addressId, userId);

            } else if ("default".equals(action)) {
                int addressId = Integer.parseInt(
                        request.getParameter("addressId"));

                success = addressDao.setDefaultAddress(addressId, userId);

            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid action.");
                return;
            }

            if (success) {
                response.sendRedirect(request.getContextPath()
                        + "/delivery-address?message=success");
            } else {
                response.sendRedirect(request.getContextPath()
                        + "/delivery-address?message=failed");
            }

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid address ID.");
        }
    }
}
