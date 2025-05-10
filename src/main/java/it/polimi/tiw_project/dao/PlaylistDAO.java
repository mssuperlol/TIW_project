package it.polimi.tiw_project.dao;

import it.polimi.tiw_project.beans.Playlist;

import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class PlaylistDAO {
    private final Connection connection;

    public PlaylistDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * Gets all the playlists created by the given user
     *
     * @param userId id of the user
     * @return a list of playlists, with the songs attribute as null
     * @throws SQLException
     */
    public List<Playlist> getPlaylists(int userId) throws SQLException {
        String query = "SELECT id, title, date " +
                "FROM playlists " +
                "WHERE user_id = ? " +
                "GROUP BY id, date ";

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
     *
     * @param playlistId ID of the playlist
     * @return Playlist object with all the information
     * @throws SQLException
     */
    public Playlist getFullPlaylist(int playlistId) throws SQLException {
        String query = "SELECT * " +
                "FROM playlists " +
                "WHERE id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, playlistId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.isBeforeFirst() || !resultSet.next()) {
                    return null;
                }

                Playlist playlist = new Playlist();
                playlist.setId(resultSet.getInt("id"));
                playlist.setUserId(resultSet.getInt("user_id"));
                playlist.setName(resultSet.getString("title"));
                playlist.setDate(resultSet.getDate("date"));
                playlist.setSongs(new SongDAO(connection).getAllSongsFromPlaylist(playlistId));
                return playlist;
            }
        }
    }

    public void insertPlaylist(int userId, String title, List<Integer> songsId) throws SQLException {
        String query = "INSERT INTO playlists (user_id, title, date) VALUES (?, ?, ?)";
        Calendar today = Calendar.getInstance();
//        today.set(Calendar.HOUR_OF_DAY, 0); // same for minutes and seconds

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);
            statement.setString(2, title);
            statement.setDate(3, new Date(today.getTime().getTime()));
            statement.executeUpdate();
        }
    }

    public void addSongsToPlaylist(int playlistId, List<Integer> songsId) throws SQLException {
    }
}
