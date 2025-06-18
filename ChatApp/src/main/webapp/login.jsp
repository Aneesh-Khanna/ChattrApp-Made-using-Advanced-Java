<%
    // Generate CSRF token if it doesn't exist in session
    if (session.getAttribute("csrfToken") == null) {
        String csrfToken = new java.math.BigInteger(130, new java.security.SecureRandom()).toString(32);
        session.setAttribute("csrfToken", csrfToken);
    }
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Login to Chattrix- Secure Real-Time Messaging">
    <meta name="keywords" content="Chattrix, Login, Secure Chat, Java Web App">
    <meta name="author" content="Aneesh Khanna">
    <link rel="icon" type="image/x-icon" href="images/chattrix.png">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Login - Chattrix</title>
    <link rel="stylesheet" type="text/css" href="css/login.css">
</head>
<body>
    <div class="login-wrapper">
    
    	<!--  Account created message, only shown when account created not on normal opening -->
        <% String signupSuccess = request.getParameter("signup");
           if ("success".equals(signupSuccess)) 
           { 
        %>
            <div class="alert-success">
                ✅ Account created successfully! Please log in to continue.
            </div>
        <% } 
        %>
        
        <!--  Logout message only shown when users logs out not on normal opening-->
        <% if ("success".equals(request.getParameter("logout"))) { %>
    	<p class="alert-success">✅ You have logged out successfully!</p>
		<% } %>
        
        
       
        <div class="login-card">
        
        	<!--  FORM  -->
            <h1>Login to Chattrix</h1>
            <form action="login" method="post" class="login-form">
            	<input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
            	<!-- CSRF TOKEN -->
                <input type="text" name="username" placeholder="Username" required  />
                <input type="password" name="password" placeholder="Password" required  />
                <input type="submit" value="Login" />
            </form>
            
            
            
            
            <!--  ERROR MESSAGE DISPLAY -->
        
        	<% String errorMessage = (String) request.getAttribute("errorMessage"); %>
        	<% if (errorMessage != null) { %>
            	<p class="error-message"><%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(errorMessage) %></p>
        	<% } %>
        	
        	<!--  StringEscapeUtils.escapeHtml4(errorMessage) 
        	       escapes special HTML characters, preventing XSS attacks.
        	       converts < > to lt gt, if an attacker provides that in input
        	        -->
        	
        </div>
    </div>
</body>
</html>

