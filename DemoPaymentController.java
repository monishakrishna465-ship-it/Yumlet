
package com.tap.controllers;

import java.io.IOException;
import java.security.SecureRandom;
import java.util.List;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/demo-payment")
public class DemoPaymentController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Please log in again.\"}"
            );
            return;
        }

        Object cartObject = session.getAttribute("cart");

        if (!(cartObject instanceof List<?>)
                || ((List<?>) cartObject).isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write(
                "{\"success\":false,\"message\":\"Your cart is empty.\"}"
            );
            return;
        }

        String action = request.getParameter("action");

        if ("start".equals(action)) {
            String reference = "YUMDEMO"
                    + Long.toHexString(System.currentTimeMillis()).toUpperCase()
                    + Integer.toHexString(RANDOM.nextInt()).toUpperCase();

            session.setAttribute("demoPaymentReference", reference);
            session.setAttribute("demoPaymentConfirmed", Boolean.FALSE);
            session.removeAttribute("demoPaymentMethod");

            response.getWriter().write(
                "{\"success\":true,\"reference\":\"" + reference + "\"}"
            );
            return;
        }

        if ("confirm".equals(action)) {
            String reference = request.getParameter("reference");
            String method = request.getParameter("method");
            String result = request.getParameter("result");

            Object savedReference =
                    session.getAttribute("demoPaymentReference");

            boolean validReference = savedReference instanceof String
                    && savedReference.equals(reference);

            boolean validMethod = "UPI".equals(method)
                    || "CARD".equals(method)
                    || "NETBANKING".equals(method);

            boolean validResult = "SUCCESS".equals(result)
                    || "FAILURE".equals(result);

            if (!validReference || !validMethod || !validResult) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write(
                    "{\"success\":false,\"message\":\"Invalid or expired demo payment. Please retry.\"}"
                );
                return;
            }

            if ("FAILURE".equals(result)) {
                session.setAttribute("demoPaymentConfirmed", Boolean.FALSE);
                session.removeAttribute("demoPaymentMethod");

                response.getWriter().write(
                    "{\"success\":true,\"status\":\"FAILED\",\"demo\":true}"
                );
                return;
            }

            session.setAttribute("demoPaymentConfirmed", Boolean.TRUE);
            session.setAttribute("demoPaymentMethod", method);

            response.getWriter().write(
                "{\"success\":true,\"status\":\"SUCCESS\",\"demo\":true}"
            );
            return;
        }

        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.getWriter().write(
            "{\"success\":false,\"message\":\"Invalid action.\"}"
        );
    }
}
