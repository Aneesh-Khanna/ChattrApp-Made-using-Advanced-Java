<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to Chattrix</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Chattrix- Secure, fast, and real-time messaging">
    <meta name="keywords" content="Chattrix, Login, Secure Chat, Java Web App">
    <meta name="author" content="Aneesh Khanna">
    <link rel="stylesheet" type="text/css" href="css/index.css">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
    <link rel="icon" type="image/x-icon" href="images/chattrix.png">
</head>
<body>


    <!-- NAVBAR -->
    <header class="navbar">
        <div class="logo">💬 Chattrix</div>
        <% 
        String username = (String) session.getAttribute("username");
        if (username == null) { 
        %>
            <div class="nav-buttons">
                <a href="login.jsp" class="btn login-btn">Login</a>
                <a href="signup.jsp" class="btn signup-btn">Sign Up</a>
            </div>
        <% } else { %>
            <div class="nav-buttons">
                <a href="chat.jsp" class="btn chat-btn">Go to Chat</a>
            </div>
        <% } %>
        
        <!-- Session validation, if session is valid, user sees chat and logout button , else login and signup button --> 
       
    </header>
    
    

    <!-- HERO SECTION -->
    <section class="hero">
        <div class="hero-content">
            <h1>Connect. Chat. Collaborate.</h1>
            <p>Experience secure, fast, and real-time messaging — just like WhatsApp, now powered by Java.</p>
            <% if (username == null) { %>
                <a href="signup.jsp" class="btn hero-btn">Get Started</a>
            <% } else { %>
                <a href="chat.jsp" class="btn hero-btn">Open Chat</a>
            <% } %>
        </div>
    </section>

	<!-- Session validation, if session is valid, user chat button , else signup button --> 



    <!-- FEATURES SECTION -->
    <section class="features">
        <div class="feature">
            <h2>⚡ Fast</h2>
            <p>Instant messaging with real-time communication using sockets and multithreading.</p>
        </div>
        <div class="feature">
            <h2>🔐 Secure</h2>
            <p>Your data is protected using robust Java-based backends and session management.</p>
        </div>
        <div class="feature">
            <h2>💡 Smart</h2>
            <p>Modern UI, beautiful animations, and a simple login/signup experience.</p>
        </div>
    </section>
    
    

    <!-- FOOTER -->
    <footer class="footer">
        <p>© 2025 All rights reserved | Aneesh Khanna</p>
    </footer>
    
    

</body>
</html>
