import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;  // javax is now jakarta
import jakarta.servlet.http.*; 
import at.favre.lib.crypto.bcrypt.BCrypt;  // Importing BCrypt for password hashing

public class LoginServlet extends HttpServlet 
{   
    private static final long serialVersionUID = 1L; 

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException 
    {
        // Retrieving username and password passed through login.jsp form field
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        /* CSRF Protection: Validate token before processing login */
        HttpSession session = request.getSession(false);
        String csrfToken = request.getParameter("csrfToken");
        if (csrfToken == null || session == null || !csrfToken.equals(session.getAttribute("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF validation failed.");
            return;
        }
 

        try 
        {
            Class.forName("com.mysql.cj.jdbc.Driver");  // Loading the driver
	        
            // Creating connection
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/chat_db", "root", "aneesh123");
            
            //Prevent SQL Injection with Prepared Statements

            // Query to get the stored hashed password for the username entered by the user
            PreparedStatement ps = con.prepareStatement(
                "SELECT password FROM users WHERE username = ?"
            );
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) // If the user exists in the database
            {   
                // Get the stored hashed password from the database
                String storedHashedPassword = rs.getString("password");
                	
                // Use BCrypt to verify the password entered with the hash password
                /*
             		password.toCharArray() converts the entered password into a character array (required by BCrypt).

					storedHashedPassword is the hashed password retrieved from the database.

				BCrypt.verifyer().verify(...) compares the entered password against the stored hash. 
				It returns a Result object 
					that contains the boolean verified field, which indicates whether the password is correct.
                 */
                if (BCrypt.verifyer().verify(password.toCharArray(), storedHashedPassword).verified) 
                {
                    // Session management: storing username in session object  
                    session.setAttribute("username", username);
                    
                    // Secure session cookie to prevent session hijacking
                    Cookie sessionCookie = new Cookie("JSESSIONID", session.getId());
                    sessionCookie.setHttpOnly(true);
                    /* Prevents JavaScript from accessing cookies., person cant directly do 
                     * document.cookie;,, prevents XSS
                     */
                    sessionCookie.setSecure(true);
                    /* Ensures the cookie is transmitted only over HTTPS. and not transmitted over http or
                     * unsecure connections, prevents unauthorised interception of data
                     */
 				
                    sessionCookie.setAttribute("SameSite", "Strict");  // Prevents CSRF attacks
                    /* Stops cross-site requests, preventing CSRF attacks. 
                     */
                    response.addCookie(sessionCookie);

                    // Set session timeout to auto-expire inactive sessions
                    session.setMaxInactiveInterval(1800);  // 30 minutes timeout

                    request.getRequestDispatcher("chat.jsp").forward(request, response); // Forward to chat.jsp
                }
                else 
                {
                    // Password doesn't match, invalid credentials
                    request.setAttribute("errorMessage", "Invalid Credentials! <br> Invalid username or password!");
                    request.getRequestDispatcher("login.jsp").forward(request, response); // Redirect to login page
                }
            } 
            else // No user found with the given username
            {
                request.setAttribute("errorMessage", "Invalid Credentials! <br> Invalid username or password!");
                request.getRequestDispatcher("login.jsp").forward(request, response); // Redirect to login page
            }
            
            rs.close();
            ps.close();
            con.close();
        } 
        catch (Exception e) 
        {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response); // Redirect to login page
        }
    }
}
