package it.polimi.tiw_project.controllers;

import it.polimi.tiw_project.beans.Playlist;
import it.polimi.tiw_project.beans.Song;
import it.polimi.tiw_project.beans.User;
import it.polimi.tiw_project.dao.GenreDAO;
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
import java.io.Serial;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/Homepage")
public class GoToHomepage extends HttpServlet {
    @Serial
    private static final long serialVersionUID = 1L;
    private TemplateEngine templateEngine;
    private Connection connection = null;

    public GoToHomepage() {
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

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String loginPath = getServletContext().getContextPath() + "/login.html";
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (session.isNew() || user == null) {
            response.sendRedirect(loginPath);
            return;
        }

        PlaylistDAO playlistDAO = new PlaylistDAO(connection);
        GenreDAO genreDAO = new GenreDAO(connection);
        SongDAO songDAO = new SongDAO(connection);
        List<Playlist> playlists;
        List<String> genres;
        List<Song> songs;

        try {
            playlists = playlistDAO.getPlaylists(user.getId());
            genres = genreDAO.getGenres();
            songs = songDAO.getAllSongsFromUserId(user.getId());
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

        String path = "/homepage.html";
        JakartaServletWebApplication webApplication = JakartaServletWebApplication.buildApplication(getServletContext());
        WebContext webC = new WebContext(webApplication.buildExchange(request, response), request.getLocale());
        webC.setVariable("playlists", playlists);
        webC.setVariable("genres", genres);
        webC.setVariable("songs", songs);
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
