# 💬 ChattrApp – Real-Time Chat Application (Advanced Java)

### 🔗 GitHub Repository
[https://github.com/Aneesh-Khanna/ChattrApp-Made-using-Advanced-Java](https://github.com/Aneesh-Khanna/ChattrApp-Made-using-Advanced-Java)

---

## 📖 About

**ChattrApp** is a **browser-based real-time public chatroom** built using **Advanced Java technologies** such as JSP, Servlets, and WebSockets.  
It enables multiple users to chat simultaneously with **real-time message broadcasting**, **secure authentication**, and **persistent chat history** using **MySQL**.  
The project is structured using the **MVC (Model–View–Controller)** architecture and deployed on **Apache Tomcat**.

---

## ✨ Features

- 🔐 **User Authentication**
  - Session-based login and logout using JSP and Servlets  
  - Passwords encrypted with **BCrypt** for enhanced security  

- 💬 **Real-Time Chat System**
  - Implemented using **Java WebSockets**  
  - Broadcasts messages instantly to all connected users  

- 🗃️ **Persistent Storage**
  - Stores all messages, usernames, and timestamps in **MySQL**  
  - Loads previous chat history when the user logs in  

- 🌐 **Browser-Based Interface**
  - Responsive **JSP** frontend styled with CSS  
  - Displays messages with sender info and timestamps  
  - Logout button and username display  

- ⚙️ **Backend Architecture**
  - Built using **Servlets**, **WebSockets**, **JDBC**, and **Hibernate**  
  - Clean **MVC architecture** (Model, View, Controller)  
  - Error handling and database connection pooling  

---

## 🧠 Tech Stack

| Category | Technologies Used |
|-----------|------------------|
| **Language** | Java (JDK 21) |
| **Frontend** | JSP, HTML, CSS |
| **Backend** | Servlets, WebSockets, JDBC, Hibernate |
| **Database** | MySQL |
| **Server** | Apache Tomcat |
| **Architecture** | MVC (Model–View–Controller) |

---

## ⚙️ Setup Instructions

### 1️⃣ Prerequisites
- JDK 21 or higher  
- Apache Tomcat 10 or higher  
- MySQL Server (XAMPP or standalone)  
- Eclipse IDE (Enterprise Edition recommended)

### 2️⃣ Database Setup
```sql
CREATE DATABASE chat_db;
USE chat_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL
);

CREATE TABLE messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sender VARCHAR(100),
    message TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
3️⃣ Configure Database Connection
Open DBUtil.java or DBConnection.java

Update your database credentials:
private static final String URL = "jdbc:mysql://localhost:3306/chat_db";
private static final String USER = "root";
private static final String PASSWORD = "your_password";
4️⃣ Deploy on Tomcat
Export project as a .war file or run directly from Eclipse

Start Tomcat server and navigate to:
http://localhost:8080/ChattrApp/login.jsp
5️⃣ Login & Chat
Sign up or log in with your credentials

Start chatting in the public chatroom — messages update in real-time 🎯

🧩 Project Structure
ChattrApp/
│
├── src/main/java/
│   ├── com.chatapp.beans/           # User beans
│   ├── com.chatapp.dao/             # Database access objects
│   ├── com.chatapp.servlets/        # Servlets for login, signup, logout
│   ├── com.chatapp.websocket/       # WebSocket server endpoint
│   └── com.chatapp.util/            # Utility classes (DBUtil, Encryption)
│
├── src/main/webapp/
│   ├── login.jsp
│   ├── signup.jsp
│   ├── chat.jsp
│   ├── css/
│   │   └── style.css
│   └── WEB-INF/
│       └── web.xml
│
└── pom.xml / build.xml (if Maven/Ant)
🔒 Security Highlights
Password hashing using BCrypt

Session validation to prevent unauthorized access

Clean logout invalidating active sessions

Input sanitization to prevent SQL injection

🚀 Future Enhancements
Private 1:1 chats using unique chat rooms

User typing indicators

Online/offline status updates

File and image sharing support

Notification system for new messages
