package wasdev.sample.servlet;

import java.io.IOException;

import javax.naming.InitialContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class SimpleServlet
 */
@WebServlet("/SimpleServlet")
public class SimpleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse
     *      response)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String name = "TO Garage";
        response.setContentType("text/html");
        try {
            Object jndiConstant = new InitialContext().lookup("key1");
            name = (String) jndiConstant;
            jndiConstant = new InitialContext().lookup("key2");
            name += (String) jndiConstant;
        } catch (Exception e) {
            e.printStackTrace();
        }
        response.getWriter().print("Hello " + name + " !");
    }

}
