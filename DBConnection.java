package com.tap.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
            "jdbc:mysql://localhost:3306/eatero";

    private static final String USERNAME =
            "root";

    private static final String PASSWORD =
            "monisha@123";


    	public static Connection getConnection() {

    	    try {

    	        Class.forName("com.mysql.cj.jdbc.Driver");

    	        Connection connection = DriverManager.getConnection(
    	                URL,
    	                USERNAME,
    	                PASSWORD
    	        );

    	        System.out.println("Database connected successfully!");

    	        return connection;

    	    } catch (Exception e) {

    	        System.out.println("Database connection failed!");
    	        e.printStackTrace();

    	        throw new RuntimeException(
    	                "Unable to connect to Eatero database",
    	                e
    	        );
    	    }
    	}
    }
    
    	