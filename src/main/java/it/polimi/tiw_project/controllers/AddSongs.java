package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.Song;
import it.polimi.tiw_project.beans.User;
import it.polimi.tiw_project.dao.PlaylistDAO;
import it.polimi.tiw_project.dao.SongDAO;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.UnavailableException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/AddSongs")
public class AddSongs extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private Connection connection = null;

    public AddSongs() {
        super();
    }

    @Override
    public void init() throws ServletException {
        try {
            ServletContext context = getServletContext();
            String driver = context.getInitParameter("dbDriver");
            String url = context.getInitParameter("dbUrl");
            String user = context.getInitParameter("dbUser");
            String password = context.getInitParameter("dbPassword");
            Class.forName(driver);

            connection = DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException e) {
            throw new UnavailableException("Can't load database driver");
        } catch (SQLException e) {
            throw new UnavailableException("Couldn't get db connection");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(getServletContext().getContextPath() + "/login.html");
            return;
        }

        PlaylistDAO playlistDAO = new PlaylistDAO(connection);
        SongDAO songDAO = new SongDAO(connection);
        int userId = user.getId(), playlistId;
        List<Integer> songs = new ArrayList<>(), userSongsId;

        try {
            playlistId = Integer.parseInt(request.getParameter("playlistId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(getServletContext().getContextPath() + "/Homepage");
            return;
        }

        try {
            if (userId != playlistDAO.getFullPlaylist(playlistId).getUserId()) {
                response.sendRedirect(getServletContext().getContextPath() + "/Homepage");
                return;
            }

            userSongsId = songDAO.getAllSongsFromUserId(userId).stream()
                    .map(Song::getId)
                    .collect(Collectors.toList());
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        for (Integer songId : userSongsId) {
            String currSongId = request.getParameter("songId" + songId.toString());
            if (currSongId != null) {
                songs.add(songId);
            }
        }

        try {
            playlistDAO.addSongsToPlaylist(playlistId, songs);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        response.sendRedirect(getServletContext().getContextPath() + "/Playlist?playlistId=" + playlistId);
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
