
package com.tap.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordMigration {

    public static void main(String[] args) {

        String selectSQL =
                "SELECT userId, password FROM user";

        String updateSQL =
                "UPDATE user SET password = ? WHERE userId = ?";

        try (Connection con = DBConnection.getConnection()) {

            con.setAutoCommit(false);

            try (PreparedStatement selectStmt =
                         con.prepareStatement(selectSQL);
                 ResultSet rs = selectStmt.executeQuery();
                 PreparedStatement updateStmt =
                         con.prepareStatement(updateSQL)) {

                int updated = 0;
                int skipped = 0;

                while (rs.next()) {

                    int userId = rs.getInt("userId");
                    String password = rs.getString("password");

                    if (password == null || password.isEmpty()) {
                        skipped++;
                        continue;
                    }

                    // Do not hash an existing BCrypt hash again.
                    if (password.startsWith("$2a$")
                            || password.startsWith("$2b$")
                            || password.startsWith("$2y$")) {
                        skipped++;
                        continue;
                    }

                    String hashedPassword =
                            BCrypt.hashpw(password, BCrypt.gensalt(12));

                    updateStmt.setString(1, hashedPassword);
                    updateStmt.setInt(2, userId);
                    updateStmt.addBatch();

                    updated++;
                }

                updateStmt.executeBatch();
                con.commit();

                System.out.println("Password migration completed!");
                System.out.println("Passwords converted: " + updated);
                System.out.println("Passwords skipped: " + skipped);

            } catch (Exception e) {
                con.rollback();
                throw e;
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
