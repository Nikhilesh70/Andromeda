package org.navigator;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.json.JSONObject;

import java.security.SecureRandom;
import java.sql.*;

@Path("/myresource")
public class MyResource {

    // DB connection 
    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";
    
    static {
        try {
            Class.forName("org.postgresql.Driver");
            //System.out.println("PostgreSQL JDBC Driver Registered!");
        } catch (ClassNotFoundException e) {
            //System.err.println("PostgreSQL JDBC Driver not found. Include it in your library path!");
            e.printStackTrace();
        }
    }
    
    //post
    
    @POST
    @Path("/register")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response registerUser(@FormParam("Email") String email,@FormParam("Username") String username,
            @FormParam("Firstname") String firstname,@FormParam("Lastname") String lastname,@FormParam("Password") String password,
            @FormParam("ConfirmPassword") String confirmPassword,@FormParam("Country") String country,@FormParam("Access") String access) {
        JSONObject response = new JSONObject();
        SecureRandom secureRandom = new SecureRandom();
        try {
            if (!password.equals(confirmPassword)) {
                response.put("Status", "Failed");
                response.put("Message", "Password and Confirm Password do not match");
                return Response.status(Response.Status.BAD_REQUEST).entity(response.toString()).build();
            }
            String checkQuery = "SELECT COUNT(*) FROM amxcorepersondata WHERE username = ? OR email = ?";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement checkStmt = conn.prepareStatement(checkQuery)) {
                checkStmt.setString(1, username);
                checkStmt.setString(2, email);
                ResultSet rs = checkStmt.executeQuery();
                if (rs.next() && rs.getInt(1) > 0) {
                    response.put("Status", "Failed");
                    response.put("Message", "Email or Username already exists");
                    return Response.status(Response.Status.CONFLICT).entity(response.toString()).build();
                }
                rs.close();
            }
            String objectId = "";
            boolean isUnique = false;

            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
                while (!isUnique) {
                    int part1 = 100 + secureRandom.nextInt(900);
                    int part2 = 100 + secureRandom.nextInt(900);
                    objectId = part1 + "." + part2 + "." +username+ "."+"PERS";

                    String checkObjectIdQuery = "SELECT COUNT(*) FROM amxcorepersondata WHERE objectid = ?";
                    try (PreparedStatement checkStmt = conn.prepareStatement(checkObjectIdQuery)) {
                        checkStmt.setString(1, objectId);
                        ResultSet rs = checkStmt.executeQuery();
                        if (rs.next() && rs.getInt(1) == 0) {
                            isUnique = true; 
                        }
                        rs.close();
                    }
                }

                String insertQuery = """
                    INSERT INTO amxcorepersondata (email, username, firstname, lastname, password, confirmpassword, country, objectid, access)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;
                try (PreparedStatement stmt = conn.prepareStatement(insertQuery, Statement.RETURN_GENERATED_KEYS)) {
                    stmt.setString(1, email);
                    stmt.setString(2, username);
                    stmt.setString(3, firstname);
                    stmt.setString(4, lastname);
                    stmt.setString(5, password);
                    stmt.setString(6, confirmPassword);
                    stmt.setString(7, country);
                    stmt.setString(8, objectId);
                    stmt.setString(9, access);

                    int rows = stmt.executeUpdate();

                    if (rows > 0) {
                        ResultSet keys = stmt.getGeneratedKeys();
                        if (keys.next()) {
                            int userId = keys.getInt(1);
                            response.put("Status", "Success");
                            response.put("Message", "User registered successfully");
                            response.put("UserId", userId);
                            response.put("ObjectId", objectId);
                        } else {
                            response.put("Status", "Failed");
                            response.put("Message", "Failed to retrieve user ID");
                        }
                        keys.close();
                        return Response.ok(response.toString(), MediaType.APPLICATION_JSON).build();
                    } else {
                        response.put("Status", "Failed");
                        response.put("Message", "User not inserted");
                        return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(response.toString()).build();
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.put("Status", "Failed");
            response.put("Message", "SQL Error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(response.toString()).build();
        }
    }


    //login
    
    @POST
    @Path("/login")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response loginUser(@FormParam("Username") String username, 
                              @FormParam("Password") String password, 
                              @Context HttpServletRequest request) {

        JSONObject response = new JSONObject();
        String query = "SELECT * FROM amxcorepersondata WHERE username = ? AND password = ?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement stmt = conn.prepareStatement(query)) {

            stmt.setString(1, username);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession(true);  
                session.setAttribute("username", rs.getString("username"));
                session.setAttribute("emailId", rs.getString("email"));
                session.setAttribute("userAccess", rs.getString("access"));
//
//                System.out.println("Session created for user: " + rs.getString("username"));
//                System.out.println("Session ID: " + session.getId());
//                System.out.println("Email set in session: " + rs.getString("email"));
                response.put("Status", "Success");
                response.put("Access", rs.getString("access"));
                response.put("Message", "Login successful");
                response.put("UserId", rs.getInt("id"));
                response.put("Email", rs.getString("email"));
                response.put("Username", rs.getString("username"));
                response.put("Firstname", rs.getString("firstname"));
                response.put("Lastname", rs.getString("lastname"));
                response.put("Country", rs.getString("country"));
                response.put("Access", rs.getString("access"));
                response.put("ObjectId", rs.getString("objectid"));
                return Response.ok(response.toString(), MediaType.APPLICATION_JSON).build();

            } else {
                response.put("Status", "Failed");
                response.put("Message", "Invalid username or password");
                return Response.status(Response.Status.UNAUTHORIZED).entity(response.toString()).build();
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.put("Status", "Failed");
            response.put("Message", "Login failed: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(response.toString()).build();
        }
    }

}
