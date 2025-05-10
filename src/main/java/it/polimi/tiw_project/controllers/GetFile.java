package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;

@WebServlet("/GetFile/*")
public class GetFile extends HttpServlet {
    private static final long serialVersionUID = 1L;
    String folderPath = "";

    @Override
    public void init() throws ServletException {
        folderPath = getServletContext().getInitParameter("musicPath");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String loginPath = getServletContext().getContextPath() + "/login.html";
        HttpSession session = request.getSession();

        if (session.isNew() || session.getAttribute("user") == null) {
            response.sendRedirect(loginPath);
            return;
        }

        User user = (User) session.getAttribute("user");
        String filename = request.getParameter("filename");

        File file = new File(folderPath + user.getId() + File.separator, filename);

        if (!file.exists() || file.isDirectory()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not present");
            return;
        }

        response.setHeader("Content-Type", getServletContext().getMimeType(filename));
        response.setHeader("Content-Length", String.valueOf(file.length()));
        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");

        Files.copy(file.toPath(), response.getOutputStream());
    }
}
