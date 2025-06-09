package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.IOException;
import java.io.Serial;
import java.nio.file.Files;

@WebServlet("/GetFile/*")
public class GetFile extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    String folderPath = "";

    @Override
    public void init() {
        folderPath = getServletContext().getInitParameter("musicPath");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String loginPath = getServletContext().getContextPath() + "/login.html";
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (session.isNew() || user == null) {
            response.sendRedirect(loginPath);
            return;
        }

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
