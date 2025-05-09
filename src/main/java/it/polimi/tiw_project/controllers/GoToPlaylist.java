package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.Playlist;
import it.polimi.tiw_project.beans.Song;
import it.polimi.tiw_project.beans.User;
import it.polimi.tiw_project.dao.PlaylistDAO;
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

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String loginPath = getServletContext().getContextPath() + "/login.html";
        String homePath = getServletContext().getContextPath() + "/Homepage";
        HttpSession session = request.getSession();

        if (session.isNew() || session.getAttribute("user") == null) {
            response.sendRedirect(loginPath);
            return;
        }

        User user = (User) session.getAttribute("user");
        int playlistId, songId;

        try {
            playlistId = Integer.parseInt(request.getParameter("playlistId"));
        } catch (NumberFormatException e) {
            response.sendRedirect(homePath);
            return;
        }
        try {
            songId = Integer.parseInt(request.getParameter("songId"));
        } catch (NumberFormatException e) {
            songId = 0;
        }


        if (playlistId <= 0 || songId < 0) {
            response.sendRedirect(homePath);
            return;
        }

        PlaylistDAO playlistDAO = new PlaylistDAO(connection);
        Playlist currPlaylist;

        try {
            if (playlistDAO.getUserId(playlistId) != user.getId()) {
                response.sendRedirect(homePath);
                return;
            }

            currPlaylist = playlistDAO.getFullPlaylist(playlistId);
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        if (songId * 5 > currPlaylist.getSongs().size()) {
            response.sendRedirect(homePath);
            return;
        }

        boolean songsBefore, songsAfter;

        if (songId != 0) {
            songsBefore = true;
        } else {
            songsBefore = false;
        }
        if ((songId + 1) * 5 < currPlaylist.getSongs().size()) {
            songsAfter = true;
        } else {
            songsAfter = false;
        }

        List<Song> currSongs = new ArrayList<>();

        for (int i = 0; i + songId * 5 < currPlaylist.getSongs().size() && i < 5; i++) {
            currSongs.add(currPlaylist.getSongs().get(i + songId * 5));
        }

        String path = "/WEB-INF/playlist.html";
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(getServletContext());
        WebContext webC = new WebContext(webApplication.buildExchange(request, response), request.getLocale());
        webC.setVariable("playlist", currPlaylist);
        webC.setVariable("songs", currSongs);
        webC.setVariable("songsBefore", songsBefore);
        webC.setVariable("songsAfter", songsAfter);
        webC.setVariable("playlistId", playlistId);
        webC.setVariable("songId", songId);
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
