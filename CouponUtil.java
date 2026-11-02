
package com.tap.util;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Locale;

public class CouponUtil {

    public static BigDecimal calculateDiscount(
            String couponCode, BigDecimal subtotal) {

        if (couponCode == null || subtotal == null
                || subtotal.compareTo(BigDecimal.ZERO) < 0) {
            return BigDecimal.ZERO;
        }

        String code = couponCode.trim().toUpperCase(Locale.ROOT);

        BigDecimal minimumOrder;
        BigDecimal discount;
        BigDecimal maximumDiscount;

        switch (code) {
            case "YUM10":
                minimumOrder = new BigDecimal("299");
                maximumDiscount = new BigDecimal("100");

                if (subtotal.compareTo(minimumOrder) < 0) {
                    return BigDecimal.ZERO;
                }

                discount = subtotal
                        .multiply(new BigDecimal("0.10"));

                break;

            case "FEAST100":
                minimumOrder = new BigDecimal("699");

                if (subtotal.compareTo(minimumOrder) < 0) {
                    return BigDecimal.ZERO;
                }

                return new BigDecimal("100.00");

            case "YUMLOVE15":
                minimumOrder = new BigDecimal("499");
                maximumDiscount = new BigDecimal("150");

                if (subtotal.compareTo(minimumOrder) < 0) {
                    return BigDecimal.ZERO;
                }

                discount = subtotal
                        .multiply(new BigDecimal("0.15"));

                break;

            default:
                return BigDecimal.ZERO;
        }

        if (discount.compareTo(maximumDiscount) > 0) {
            discount = maximumDiscount;
        }

        return discount.setScale(2, RoundingMode.HALF_UP);
    }

    public static String getCouponMessage(
            String couponCode, BigDecimal subtotal) {

        if (couponCode == null || couponCode.trim().isEmpty()) {
            return "Please enter a coupon code.";
        }

        String code = couponCode.trim().toUpperCase(Locale.ROOT);

        if (!code.equals("YUM10")
                && !code.equals("FEAST100")
                && !code.equals("YUMLOVE15")) {
            return "Invalid coupon code.";
        }

        BigDecimal minimumOrder;

        switch (code) {
            case "YUM10":
                minimumOrder = new BigDecimal("299");
                break;
            case "FEAST100":
                minimumOrder = new BigDecimal("699");
                break;
            default:
                minimumOrder = new BigDecimal("499");
                break;
        }

        if (subtotal == null
                || subtotal.compareTo(minimumOrder) < 0) {
            return "Minimum order for " + code
                    + " is ₹" + minimumOrder.toPlainString() + ".";
        }

        return "Coupon applied successfully!";
    }
}
