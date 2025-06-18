import java.io.IOException;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import at.favre.lib.crypto.bcrypt.BCrypt;

public class SignupServlet extends HttpServlet 
{	private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException 
    {	// csrf token validation
    	HttpSession session = request.getSession(false);
    	String csrfToken = request.getParameter("csrfToken");
    	if (csrfToken == null || session == null || !csrfToken.equals(session.getAttribute("csrfToken"))) 
    	{
    		response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF validation failed.");
    		return;
    	}

        // get details from signup page form
        String fullname = request.getParameter("fullname");
        int age = Integer.parseInt(request.getParameter("age"));
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String dob = request.getParameter("dob");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        
      //Password validation if password entered != confirmed password
        
        if (!password.equals(confirmPassword))     
        {
            request.setAttribute("errorMessage", "Passwords do not match!");  // send error
            request.getRequestDispatcher("signup.jsp").forward(request, response);  // re direct to signup.jsp
            return;
        }
        
        String hashedPassword = BCrypt.withDefaults().hashToString(12, password.toCharArray());
        // hashing the password
        // takes the user’s password, hashes it using BCrypt with a cost factor of 12, 
        // and returns a securely hashed password string that you can store in the database.
        
      //Full name validation
        boolean isValidFullName = true;   
                                          //checks if it only contains letter and spaces and no digits,symbols\
                                          // and minimum length = 2

        for (int i = 0; i < fullname.length(); i++) {
            char c = fullname.charAt(i);
            if (!Character.isLetter(c) && c != ' ') {
                isValidFullName = false;
                break;
            }
        }

        if (!isValidFullName || fullname.trim().length() < 2) {
            request.setAttribute("errorMessage", "Full name must be at least 2 letters and contain only letters and spaces.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }
        
        // Email format validation using regex
        String emailRegex = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$";
        if (!email.matches(emailRegex)) {
        	request.setAttribute("errorMessage", "Please enter a valid email address.<br>Format: example@gmail.com");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

     // Phone number validation - should be exactly 10 digits and all digits
        if (phone.length() != 10) {
            request.setAttribute("errorMessage", "Phone number must be exactly 10 digits.");
            request.getRequestDispatcher("signup.jsp").forward(request, response);
            return;
        }

        for (int i = 0; i < phone.length(); i++) {
            if (!Character.isDigit(phone.charAt(i))) {
                request.setAttribute("errorMessage", "Phone number must contain only digits (0-9).");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }
        }

        try 	
        {
        	Class.forName("com.mysql.cj.jdbc.Driver"); //Loading the driver
	        
	        //Creating connection
	        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/chat_db", "root", "aneesh123");
	        
            
            // Check if username already exists
            PreparedStatement checkUser = con.prepareStatement("SELECT * FROM users WHERE username = ?");
            checkUser.setString(1, username);
            ResultSet rs = checkUser.executeQuery();

            if (rs.next())   // traverse result set row by row.
            {
                // Username already exists
                request.setAttribute("errorMessage", "Username already taken. Please choose another.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }
            
         // Check if phone number already exists
            PreparedStatement checkPhone = con.prepareStatement("SELECT * FROM users WHERE phone = ?");
            checkPhone.setString(1, phone);
            ResultSet phoneRs = checkPhone.executeQuery();
            if (phoneRs.next()) {
                request.setAttribute("errorMessage", "Phone number already taken. Please use another.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }

            // Check if email already exists
            PreparedStatement checkEmail = con.prepareStatement("SELECT * FROM users WHERE email = ?");
            checkEmail.setString(1, email);
            ResultSet emailRs = checkEmail.executeQuery();
            if (emailRs.next()) {
                request.setAttribute("errorMessage", "Email already registered. Please use another.");
                request.getRequestDispatcher("signup.jsp").forward(request, response);
                return;
            }
  
            
            // insert details of new user 
            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO users (fullname, age, username, password, dob, email, phone) VALUES (?, ?, ?, ?, ?, ?, ?)"
            );
            // positional parameter being entered
            
            ps.setString(1, fullname);
            ps.setInt(2, age);
            ps.setString(3, username);
            ps.setString(4, hashedPassword); //  storing hashed password.
            ps.setString(5, dob);
            ps.setString(6, email);
            ps.setString(7, phone);
            
            // execute query
            int result = ps.executeUpdate();
            
            // if query is successfully executed, number > 0 is returned else 0 is returned
            if (result > 0)   
            {
            	response.sendRedirect("login.jsp?signup=success");    // if signup successful, redirect to login page
            } else 
            {
                request.setAttribute("errorMessage", "Registration failed.");  
                request.getRequestDispatcher("signup.jsp").forward(request, response);
            }
            
            rs.close();
            checkUser.close();
            ps.close();
            con.close();
        } 
        catch (Exception e) 
        {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            request.getRequestDispatcher("signup.jsp").forward(request, response);
        }
    }
}
