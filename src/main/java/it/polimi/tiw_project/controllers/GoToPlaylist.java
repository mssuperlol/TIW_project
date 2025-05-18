package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.Playlist;
import it.polimi.tiw_project.beans.Song;
import it.polimi.tiw_project.beans.User;
import it.polimi.tiw_project.dao.PlaylistDAO;
import it.polimi.tiw_project.dao.SongDAO;
import it.polimi.tiw_project.utils.DBConnectionHandler;
import jakarta.servlet.ServletContext;
import jakarta.servlet.UnavailableException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.templatemode.TemplateMode;
import org.thymeleaf.templateresolver.WebApplicationTemplateResolver;
import org.thymeleaf.web.servlet.JakartaServletWebApplication;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/Playlist")
public class GoToPlaylist extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TemplateEngine templateEngine;
    private Connection connection = null;
    private static int VISIBLE_SONGS = 5;

    public GoToPlaylist() {
        super();
    }

    @Override
    public void init() throws UnavailableException {
        ServletContext servletContext = getServletContext();
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(servletContext);
        WebApplicationTemplateResolver templateResolver = new WebApplicationTemplateResolver(webApplication);
        templateResolver.setTemplateMode(TemplateMode.HTML);
        this.templateEngine = new TemplateEngine();
        this.templateEngine.setTemplateResolver(templateResolver);
        templateResolver.setSuffix(".html");

        connection = DBConnectionHandler.getConnection(this.getServletContext());
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String loginPath = getServletContext().getContextPath() + "/login.html";
        String homePath = getServletContext().getContextPath() + "/Homepage";
        HttpSession session = request.getSession();

        if (session.isNew() || session.getAttribute("user") == null) {
            response.sendRedirect(loginPath);
            return;
        }

        User user = (User) session.getAttribute("user");
        int playlistId, songsIndex;

        try {
            playlistId = Integer.parseInt(request.getParameter("playlistId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(homePath);
            return;
        }
        try {
            songsIndex = Integer.parseInt(request.getParameter("songsIndex"));
        } catch (NumberFormatException e) {
            songsIndex = 0;
        }


        if (playlistId <= 0 || songsIndex < 0) {
            response.sendRedirect(homePath);
            return;
        }

        PlaylistDAO playlistDAO = new PlaylistDAO(connection);
        Playlist currPlaylist;

        try {
            currPlaylist = playlistDAO.getFullPlaylist(playlistId);
            if (currPlaylist.getUserId() != user.getId()) {
                response.sendRedirect(homePath);
                return;
            }
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        if (songsIndex * VISIBLE_SONGS > currPlaylist.getSongs().size()) {
            response.sendRedirect(homePath);
            return;
        }

        boolean songsBefore, songsAfter;

        if (songsIndex != 0) {
            songsBefore = true;
        } else {
            songsBefore = false;
        }
        if ((songsIndex + 1) * VISIBLE_SONGS < currPlaylist.getSongs().size()) {
            songsAfter = true;
        } else {
            songsAfter = false;
        }

        List<Song> currSongs = new ArrayList<>();

        for (int i = 0; i + songsIndex * VISIBLE_SONGS < currPlaylist.getSongs().size() && i < VISIBLE_SONGS; i++) {
            currSongs.add(currPlaylist.getSongs().get(i + songsIndex * VISIBLE_SONGS));
        }

        SongDAO songDAO = new SongDAO(connection);
        List<Song> otherSongs;

        try {
            otherSongs = songDAO.getSongsNotInPlaylist(user.getId(), playlistId);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        String path = "/WEB-INF/playlist.html";
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(getServletContext());
        WebContext webC = new WebContext(webApplication.buildExchange(request, response), request.getLocale());
        webC.setVariable("playlist", currPlaylist);
        webC.setVariable("songs", currSongs);
        webC.setVariable("songsBefore", songsBefore);
        webC.setVariable("songsAfter", songsAfter);
        webC.setVariable("playlistId", playlistId);
        webC.setVariable("songsIndex", songsIndex);
        webC.setVariable("otherSongs", otherSongs);
        templateEngine.process(path, webC, response.getWriter());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        doGet(request, response);
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
