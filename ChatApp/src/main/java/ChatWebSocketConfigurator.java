import jakarta.websocket.server.ServerEndpointConfig;
import jakarta.servlet.http.HttpSession;
import jakarta.websocket.*;
import jakarta.websocket.server.*;

public class ChatWebSocketConfigurator extends ServerEndpointConfig.Configurator 
{
    
    @Override
    public void modifyHandshake(ServerEndpointConfig config, HandshakeRequest request, HandshakeResponse response) 
    {
        // Retrieve HttpSession from request attributes
        HttpSession httpSession = (HttpSession) request.getHttpSession();
        if (httpSession != null) 
        {
            String username = (String) httpSession.getAttribute("username");
            if (username != null) 
            {
                // Add username to WebSocket session properties
                config.getUserProperties().put("username", username);
            }
        }
    }
}


/* transfers data from httpsession object to web socket session object */