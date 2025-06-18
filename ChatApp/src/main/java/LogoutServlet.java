import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;
import jakarta.servlet.annotation.WebServlet;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet 
{
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException 
	{
        HttpSession session = request.getSession(false);
        /* request.getSession(false) → means:

		If a session already exists, return it.

		If no session exists, return null.
		
		not getSession(true) or just getSession() as
         we only want to invalidate an existing session — we don't want 
         to create a new one just to destroy it.
		*/
        
        /* CSRF PROTECTION, logout only if we have csrf token */
        String csrfToken = request.getParameter("csrfToken");
        if (csrfToken == null || session == null || !csrfToken.equals(session.getAttribute("csrfToken"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "CSRF validation failed.");
            return;
        }

        if (session != null) 
        {
            session.invalidate();
            //It invalidates the session, removing all session data (like username, email, etc.).
        }
        
        /* Remove Session Cookie as  Even after invalidating the session, cookies might persist in the browser.*/
        Cookie sessionCookie = new Cookie("JSESSIONID", "");
        sessionCookie.setMaxAge(0); // Expire immediately
        sessionCookie.setHttpOnly(true);
        sessionCookie.setSecure(true);
        sessionCookie.setAttribute("SameSite", "Strict"); // Prevent CSRF attacks
        response.addCookie(sessionCookie);

        response.sendRedirect("login.jsp?logout=success");
    }
}
