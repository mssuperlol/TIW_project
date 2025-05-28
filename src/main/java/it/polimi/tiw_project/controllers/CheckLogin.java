package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.User;
import it.polimi.tiw_project.dao.UserDAO;
import it.polimi.tiw_project.utils.DBConnectionHandler;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.Serial;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/CheckLogin")
public class CheckLogin extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    public CheckLogin() {
        super();
    }

    @Override
    public void init() throws ServletException {
        connection = DBConnectionHandler.getConnection(this.getServletContext());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.getWriter().append("Served at: ").append(request.getContextPath());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        UserDAO userDAO = new UserDAO(connection);
        User user = null;

        try {
            user = userDAO.checkLogin(username, password);
        } catch (SQLException e) {
            response.sendError(HttpServletResponse.SC_BAD_GATEWAY, "Failure in database credential checking");
        }

        String path = getServletContext().getContextPath();
        if (user != null) {
            request.getSession().setAttribute("user", user);
            path += "/Homepage";
        }

        response.sendRedirect(path);
    }

    @Override
    public void destroy() {
        try {
            if (connection != null) {
                connection.close();
            }
        } catch (SQLException ignored) {
        }
    }
}
