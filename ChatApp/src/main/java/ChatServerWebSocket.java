import jakarta.websocket.*;
import jakarta.websocket.server.ServerEndpoint;
import java.util.*;
import java.sql.*;

@ServerEndpoint(value = "/chatserver", configurator = ChatWebSocketConfigurator.class)
public class ChatServerWebSocket 
{
	//creating a set of websocket session objects which stores current session objects of users connected.
	// Collections is a utility class and synchronizedSet is a method which makes our set : thread safe
	// Multiple threads can access it without corrupting data
	// prevents ConcurrentModificationException
    private static Set<Session> clients = Collections.synchronizedSet(new HashSet<>());
    

    @OnOpen  // OnOpen annotation
    /* function that is executed when new session is opened from user*/
    public void handleOpen(Session userSession)
    {
        clients.add(userSession);     // add new client to set of current users
        System.out.println("New session opened: " + userSession.getId());
        broadcastUserList(); // send updated user list to all
    }

    @OnMessage
    public void handleMessage(String message, Session userSession)
    {
        try 
        {	String username =  (String) userSession.getUserProperties().get("username");
        
        	// Check for typing message
        	if (message.startsWith("typing:")) 
        	{
            // Broadcast typing message to others
        		synchronized (clients) 
        		{
        			for (Session client : clients) 
        			{
        				if (client.isOpen() && client != userSession) 
                    	/* checking if websocket connection is still open and the 
                    	 * the current client is not the sender of the message 
                    	 * 
                    	 * user session is the person who send the message and client is remaining users
                    	 * from client array
                    	 */
        				{
        					client.getAsyncRemote().sendText("typing:" + username);
        				}
        			}
        		}
        		return; // Don't continue to process it as a normal message
        	}
            // Save to DB
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/chat_db", "root", "aneesh123");
            PreparedStatement ps = con.prepareStatement("INSERT INTO messages (sender, message) VALUES (?, ?)");
            ps.setString(1, username);
            ps.setString(2, message);
            ps.executeUpdate();
            con.close();
            
        } 
        catch (Exception e) 
        {
            e.printStackTrace();
        }

        // Broadcast to all clients
        synchronized (clients) 
        {
            for (Session client : clients) 
            {   // client is aynschronous remote endpoint of client session object
                client.getAsyncRemote().sendText(
                		(String) userSession.getUserProperties().get("username") + ": " + message
                		); // broadcasts username : message to each client
            }
        }
    }

    @OnClose
    public void handleClose(Session userSession) 
    {	// remove the current client from the list of active clients.
        clients.remove(userSession);
        System.out.println("Session closed: " + userSession.getId());
        broadcastUserList(); // send updated user list to all
    }
    
    
    private void broadcastUserList() 
    {
        String userListMessage = "users:";
        	
        /* iterating in current users set and adding them to a string */ 
        synchronized(clients)
        {
            int count = 0;
            for (Session client : clients) 
            {
                String name = (String) client.getUserProperties().get("username");
                if (name != null) 
                {	
                    if (count > 0) userListMessage += ",";
                    userListMessage += name;
                    count++;
                }
            }
            
            /* Broadcast active users to every user */ 
            for (Session client : clients)
            {
                if (client.isOpen()) 
                {
                    client.getAsyncRemote().sendText(userListMessage);
                }
            }
        }
    }


}
