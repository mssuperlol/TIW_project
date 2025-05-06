package it.polimi.tiw_project.dao;

import it.polimi.tiw_project.beans.Playlist;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PlaylistDAO {
    private final Connection connection;

    public PlaylistDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * Gets all the playlists created by the given user
     * @param userId id of the user
     * @return a list of playlists, with the songs attribute as null
     * @throws SQLException
     */
    public List<Playlist> getPlaylists(int userId) throws SQLException {
        String query = "SELECT p.id, p.title, p.date " +
                "FROM playlists as p join playlist_contents as c on p.id = c.playlist join songs as s on c.song = s.id " +
                "WHERE s.user_id = ? " +
                "ORDER BY p.date DESC";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.isBeforeFirst()) {
                    return null;
                }

                List<Playlist> playlists = new ArrayList<>();
                while (resultSet.next()) {
                    Playlist playlist = new Playlist();
                    playlist.setId(resultSet.getInt("id"));
                    playlist.setName(resultSet.getString("title"));
                    playlist.setDate(resultSet.getDate("date"));
                    playlists.add(playlist);
                }

                return playlists;
            }
        }
    }

    /**
     * Given a playlist ID, returns all the information of that playlist and a list its songs
     * @param playlistId ID of the playlist
     * @return Playlist object with all the information
     * @throws SQLException
     */
    public Playlist getFullPlaylist(int playlistId) throws SQLException {
        String query = "SELECT id, title, date " +
                "FROM playlists " +
                "WHERE id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, playlistId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.isBeforeFirst()) {
                    return null;
                }

                Playlist playlist = new Playlist();
                playlist.setId(resultSet.getInt("id"));
                playlist.setName(resultSet.getString("title"));
                playlist.setDate(resultSet.getDate("date"));
                playlist.setSongs(new SongDAO(connection).getAllSongsFromPlaylist(playlistId));
                return playlist;
            }
        }
    }
}
