<!-- JSP directive that gives the JSP engine info about how to compile the page.
     language="java" — Tells the engine we are using Java code inside the JSP. 
     and tells the engine that the jsp pages has UTF encoding  -->
     
     
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>

<!--  This enables the HttpSession object.

session="true" — tells the JSP container to create or use an existing session 
so we can use session.getAttribute() to access login data. -->
<%@ page session="true" %>



<%  // Ensuring chat.jsp is only accessible when client is logged in
	// ensuring he/she is not  bypassing or directly opening the link
    String username = (String) session.getAttribute("username");
    if (username == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    /*  Storing DB record in a array of a string */
    // all messages are stored in a list having array at each index.

    List<String[]> messages = new ArrayList<>();
    
    /* Extracting messages from database */
    try 
    {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/chat_db", "root", "aneesh123");
        Statement stmt = con.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT sender, message, timestamp FROM messages ORDER BY timestamp ASC");
        while (rs.next()) 
        {	// for each row in DB, put them in a list. 
            messages.add(new String[]
            	{
            		org.apache.commons.text.StringEscapeUtils.escapeHtml4(rs.getString("sender")),
                	org.apache.commons.text.StringEscapeUtils.escapeHtml4(rs.getString("message")),
                	rs.getString("timestamp")
            	}
            );
        }
        con.close();
    } 
    catch (Exception e) 
    {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Chat - Chattrix</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="css/chat.css">
     <link rel="icon" type="image/x-icon" href="images/chattrix.png">
</head>
<body>
    <div class="chat-container">
        
        <!-- DISPLAY USERNAME BASED ON SESSION DATA -->
        <header class="chat-header">
            <h2>Welcome, <%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(username)  %></h2>   
            <%
    			String csrfToken = (String) session.getAttribute("csrfToken");
			%>
			<!-- if request is through form, csrf token is passed as hidden field, if through anchor tag
			     we have to send using query parameter  -->
			<a href="logout?csrfToken=<%= csrfToken %>" class="logout-btn">Logout</a>
        </header>
        
        <!-- Online users display -->
		<div id="online-users" class="online-users"></div>
		
		<!-- Search bar for messages -->
		<div class="search-bar">
    		<input type="text" id="search-input" placeholder="Search for messages...">
    		<span id="clear-search" title="Clear search">✖</span>
		</div>


		<!--  MAIN CHAT AREA  -->
        <div class="chat-box" id="chat-box">
            <% 
            	for (String[] msg : messages) 
            {
                String sender = msg[0];
                String message = msg[1];
                String time = msg[2];
                boolean sent = username != null && username.equals(sender);
                
                /* sent is a boolean flag which checks if the message is sent by sender or
                receiver, based on this class is assigned which display on the right side or left
                side */
             

            %>
                <div class="chat-message <%= sent ? "sent" : "received" %>">
    				<div class="chat-username"><%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(sender) %></div>
    				<div class="chat-text"><%= org.apache.commons.text.StringEscapeUtils.escapeHtml4(message) %></div>
    				<span class="timestamp"><%= time %></span>
				</div>
				
            <% } %>
        </div>
        
        <!--  TYPING INDICATOR -->
        <div id="typing-indicator" class="typing-indicator"></div>
        
		<!-- MESSAGE BOX -->	
        <form class="chat-form">
        	<input type="hidden" name="csrfToken" value="<%= session.getAttribute("csrfToken") %>" />
            <input type="text" name="message" placeholder="Type a message..." required autocomplete="off" />
            <button type="submit">Send</button>
        </form>
        <!-- autocomplete="off" — disables saved suggestions. -->
        
    </div>

    <script>
	const chatBox = document.getElementById("chat-box");
	const messageInput = document.querySelector("input[name='message']");
	/* Selects an <input> element with the attribute name="message". */
	const form = document.querySelector(".chat-form");
	const typingIndicator = document.getElementById("typing-indicator");

	const socket = new WebSocket("ws://localhost:8080/ChatApp/chatserver"); //Opening a web socket connection
	const username = "<%= username %>";

	let typingUsers = new Set(); // To keep track of users typing
	let typingTimeouts = {};     // For clearing typing timeouts
	/*Object used to track timeouts per user so their typing indicator can expire after a delay. */
	
	/* object is a key-value pair where key is typingUser and value is timeout ID */
	

	socket.onmessage = function(event) 
	{
    	const message = event.data;

    	// Typing notification handling
    	if (message.startsWith("typing:")) 
    	{
        	const typingUser = message.split(":")[1];
			/* Gets the username of the user who is typing. */ 
        	if (typingUser !== username)
        	{
            	typingUsers.add(typingUser);

            	// Clear any previous timeout for this user to reset the timer.
            	clearTimeout(typingTimeouts[typingUser]);
            	
            	typingTimeouts[typingUser] = setTimeout(() => {
                typingUsers.delete(typingUser);
                updateTypingIndicator();
            }, 3000);
				/* setTimeout() sets a delay to execute the code inside after 3 seconds. */
            	updateTypingIndicator();
        	}
        	return; //	Avoid further processing of typing message, don't want it to be stored in database.
    	}	
	
    	// Online users update
    	if (message.startsWith("users:")) 
    	{
        	const onlineUsers = message.substring(6).split(",");
       		/* Removing users: and splits usernames by comma. */
        	document.getElementById("online-users").innerText = "Online Users: " + onlineUsers.join(", ");
        	return;
    	}
    	
    	function escapeHtml(text) {
            const div = document.createElement("div");
            div.appendChild(document.createTextNode(text));
            return div.innerHTML;
        }
    	
    	/* Creating a temp div to store the message, message is not stored as text but it is stored as
    	plain text , any html tags or js scripts are not parsed. it automatically escapes unsafe characters
    	using document.createTextNode function (XSS protection ) */
    	
    	// Clears all typing indicators when a real message is received.
    	typingUsers.clear();
    	updateTypingIndicator();

    	const div = document.createElement("div"); // create new div for new message 
    	const isMine = message.startsWith(username + ":"); // Check if this message is sent by the current user.
    	const sender = message.split(":")[0]; // extract sender username
    	const text = escapeHtml(message.split(":").slice(1).join(":")); // Sanitize incoming messages
	
    	/* We are first splitting the string username:message based on colons, if the message contains colons, we need 
    	everything to be part of message, then slice(1) removes the first part from the array i.e username, then we
    	concatenate them  together again */
    
    	div.className = "chat-message " + (isMine ? "sent" : "received");

    	const usernameDiv = document.createElement("div");
    	usernameDiv.className = "chat-username";
    	usernameDiv.textContent = sender; // assign username of sender to new msg

    	const messageDiv = document.createElement("div");
    	messageDiv.className = "chat-text";
    	messageDiv.textContent = text;  // assign new message in the message div created

    	const timestampSpan = document.createElement("span");
    	timestampSpan.className = "timestamp";
    	timestampSpan.textContent = new Date().toLocaleTimeString();  // add current time to new msg

    	div.appendChild(usernameDiv);
    	div.appendChild(messageDiv);
    	div.appendChild(timestampSpan);

    	chatBox.appendChild(div);
    	chatBox.scrollTop = chatBox.scrollHeight;  
    
    	/* automatically scroll the chat area to the bottom, 
    	so the latest message is always visible when a new one is added.  */
	};

	function updateTypingIndicator() 
	{
    	if (typingUsers.size > 0)   // if 1 user or more
    	{
        	typingIndicator.innerText = [...typingUsers].join(", ") + " is typing...";
        	/* spread operator converts typingUsers set into a array */ 
        	typingIndicator.style.display = "block"; // show the indicator when any user is typing.
   		} 
   		else 
    	{
        	typingIndicator.style.display = "none"; // keep indicator hidden
   		}
	}

	form.onsubmit = function(e) 
	{
    	e.preventDefault();
    	/* Prevents form from refreshing the page. */ 
    	const msg = messageInput.value;
    	if (msg.trim() !== "")
    	{
        	socket.send(msg);
        	messageInput.value = "";
        	/* If message is not empty, send it over WebSocket and clear the input box */
    	}
	};

	// Send typing notification
	messageInput.addEventListener("input", () => {
    	socket.send("typing:" + username);
	});

	// Message search functionality
	const searchInput = document.getElementById("search-input");
	const clearBtn = document.getElementById("clear-search");

	searchInput.addEventListener("input", function () {
    	const query = this.value.toLowerCase();
    	/* Runs whenever the user types in the search box. */
    	const messages = document.querySelectorAll(".chat-message");
    	/* Selects all chat message divs */

    	// Show or hide clear button only whenever there is something written in search box
    	clearBtn.style.display = query ? "inline" : "none";

    	messages.forEach(msg => {
        	const username = msg.querySelector(".chat-username").textContent.toLowerCase();
        	const text = msg.querySelector(".chat-text").textContent.toLowerCase();
        	const timestamp = msg.querySelector(".timestamp").textContent.toLowerCase();

        	const match = username.includes(query) || text.includes(query) || timestamp.includes(query);
        	msg.style.display = match ? "block" : "none";
        	
        	/* Looping over each message and checking if the search query matches any part of:

        	Sender username

        	Message content

        	Timestamps

        	and showing only matching messages.
        	
        	*/ 
    	});
	});

	// Clear button functionality
	clearBtn.addEventListener("click", function () {
		/* when clear button is clicked */ 
		/* Clear the input box */
    	searchInput.value = "";
		/* Hide the button */ 
    	clearBtn.style.display = "none";

    // Show all messages back again
    const messages = document.querySelectorAll(".chat-message");
    messages.forEach(msg => msg.style.display = "block");
	});


	</script>
    
</body>
</html>

