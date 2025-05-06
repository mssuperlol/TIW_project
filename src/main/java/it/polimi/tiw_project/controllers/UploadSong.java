package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;

@WebServlet("/UploadSong")
public class UploadSong extends HttpServlet {
    private static final long serialVersionUID = 1L;
    String folderPath;

    @Override
    public void init() throws ServletException {
        folderPath = getServletContext().getInitParameter("folderPath");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getAttribute("user");
        if (user == null) {
            response.sendRedirect(getServletContext().getContextPath() + "/login.html");
            return;
        }

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing file");
            return;
        }

        //TODO fix the control to allow more file types
        if (!filePart.getContentType().equals(".mp3")) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File format not permitted");
            return;
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        //saves the file to /home/mssuperlol/Documents/TIW_project_resources/ID/
        String outputPath = folderPath + user.getId() + File.separator + fileName;
        File outputFile = new File(outputPath);

        try (InputStream fileContent = filePart.getInputStream()) {
            Files.copy(fileContent, outputFile.toPath());
        }
    }
}
