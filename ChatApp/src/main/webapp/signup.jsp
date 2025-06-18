<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Sign Up - Chattrix</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Register to ChatApp - your private chat zone.">
    <meta name="keywords" content="Chattrix, Login, Secure Chat, Java Web App">
    <meta name="author" content="Aneesh Khanna">
    <link rel="stylesheet" type="text/css" href="css/signup.css">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
     <link rel="icon" type="image/x-icon" href="images/chattrix.png">
</head>
<body>

    <div class="signup-container">
        <h1>Create an Account</h1>
        
        <!--  ERROR MESSAGE DISPLAY -->
        
        <% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        <% if (errorMessage != null) { %>
            <p class="error-message"><%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(errorMessage)  %></p>
        <% } %>     
        
        
        <!--  generating csrf token only for first time users, this can also be done in servlet 
        but it would bypass our logic of checking if we dont have token then reject the request -->
        <%
    if (session.getAttribute("csrfToken") == null) 
    	{
        String csrfToken = new java.math.BigInteger(130, new java.security.SecureRandom()).toString(32);
        session.setAttribute("csrfToken", csrfToken);
    	}
		%>
        
        
             
        <!--  FORM -->
        <form action="signup" method="post">
        	<input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
            <input type="text" name="fullname" placeholder="Full Name" required />
            <input type="number" name="age" placeholder="Age" min="1" max="150" required />
            <input type="text" name="username" placeholder="Username" required />
            <input type="password" name="password" placeholder="Password" required />
            <input type="password" name="confirmPassword" placeholder="Confirm Password" required />
            <label for="dob" class="dob-label">Enter Date of Birth:</label>
            <input type="date" name="dob" placeholder="Date of Birth" required />
            <input type="email" name="email" placeholder="Email" required />
            <input type="tel" name="phone" placeholder="Phone Number  :" required />
            
            <button type="submit">Sign Up</button>
        </form>
        <p class="login-link">Already have an account? <a href="login.jsp">Login here</a></p>
    </div>

</body>
</html>
