package com.tap.util;

import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class DatabaseCleanupListener
        implements ServletContextListener {

    @Override
    public void contextDestroyed(ServletContextEvent event) {

        ClassLoader appClassLoader =
                getClass().getClassLoader();

        try {
            AbandonedConnectionCleanupThread
                    .checkedShutdown();
        } catch (Exception e) {
            event.getServletContext().log(
                    "MySQL cleanup thread shutdown failed.", e);
        }

        Enumeration<Driver> drivers =
                DriverManager.getDrivers();

        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();

            if (driver.getClass().getClassLoader()
                    == appClassLoader) {
                try {
                    DriverManager.deregisterDriver(driver);
                } catch (SQLException e) {
                    event.getServletContext().log(
                            "Unable to deregister MySQL driver.", e);
                }
            }
        }
    }
}