package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.User;
import it.polimi.tiw_project.dao.SongDAO;
import it.polimi.tiw_project.utils.DBConnectionHandler;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.UnavailableException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

@MultipartConfig
@WebServlet("/UploadSong")
public class UploadSong extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private Connection connection = null;
    String folderPath;

    @Override
    public void init() throws ServletException {
        connection = DBConnectionHandler.getConnection(this.getServletContext());
        folderPath = getServletContext().getInitParameter("musicPath");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(getServletContext().getContextPath() + "/login.html");
            return;
        }

        Part imageFilePart = request.getPart("image_file");
        if (imageFilePart == null || imageFilePart.getSize() == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing image file");
            return;
        }

        if (!imageFilePart.getContentType().startsWith("image")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Image: file format not permitted");
            return;
        }

        Part musicFilePart = request.getPart("music_file");
        if (musicFilePart == null || musicFilePart.getSize() == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing music file");
            return;
        }

        if (!musicFilePart.getContentType().startsWith("audio")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Music: file format not permitted");
            return;
        }

        SongDAO songDAO = new SongDAO(connection);
        int userID = user.getId();
        String title = request.getParameter("title");
        String imageFileName = Paths.get(imageFilePart.getSubmittedFileName()).getFileName().toString();
        String albumTitle = request.getParameter("album_title");
        String performer = request.getParameter("performer");
        int year;
        String genre = request.getParameter("genre");
        String musicFileName = Paths.get(musicFilePart.getSubmittedFileName()).getFileName().toString();

        try {
            year = Integer.parseInt(request.getParameter("year"));
        } catch (NumberFormatException e) {
            response.sendRedirect(getServletContext().getContextPath() + "/Homepage");
            return;
        }

        if (title != null && albumTitle != null && performer != null && genre != null) {
            //saves the files to /home/mssuperlol/Documents/TIW_project_resources/ID/
            String outputPath = folderPath + user.getId() + File.separator + imageFileName;
            File outputFile = new File(outputPath);
            try (InputStream fileContent = imageFilePart.getInputStream()) {
                Files.copy(fileContent, outputFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            outputPath = folderPath + user.getId() + File.separator + musicFileName;
            outputFile = new File(outputPath);
            try (InputStream fileContent = musicFilePart.getInputStream()) {
                Files.copy(fileContent, outputFile.toPath());
            }

            //update the db
            try {
                songDAO.insertSong(userID, title, imageFileName, albumTitle, performer, year, genre, musicFileName);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        }

        response.sendRedirect(getServletContext().getContextPath() + "/Homepage");
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
