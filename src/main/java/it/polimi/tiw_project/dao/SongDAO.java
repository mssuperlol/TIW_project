package it.polimi.tiw_project.dao;

import it.polimi.tiw_project.beans.Song;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SongDAO {
    private final Connection connection;

    public SongDAO(Connection connection) {
        this.connection = connection;
    }

    /**
     * Gets all the songs associated with the given user id
     * @param userId user id
     * @return a list containing all the songs associated with id, or null if no songs were found
     * @throws SQLException
     */
    public List<Song> getAllSongs(int userId) throws SQLException {
        String query = "SELECT id, title, image_file_name, album_title, performer, year, genre, music_file_name " +
                "FROM songs " +
                "WHERE user_id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return getSongsFromResultSet(resultSet);
            }
        }
    }

    /**
     * Gets all the songs associated with the given playlist id
     * @param playlistId playlist id
     * @return a list containing all the songs associated with id, or null if no songs were found
     * @throws SQLException
     */
    public List<Song> getAllSongsFromPlaylist(int playlistId) throws SQLException {
        String query = "SELECT id, title, image_file_name, album_title, performer, year, genre, music_file_name " +
                "FROM songs JOIN playlist_contents ON songs.id = playlist_contents.song " +
                "WHERE playlist_contents.playlist = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, playlistId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return getSongsFromResultSet(resultSet);
            }
        }
    }

    /**
     * Extracts songs from a given resultSet
     * @param resultSet
     * @return list of all songs from resultSet, or null if no songs were found
     * @throws SQLException
     */
    private List<Song> getSongsFromResultSet(ResultSet resultSet) throws SQLException {
        if (!resultSet.isBeforeFirst()) {
            return null;
        }

        List<Song> songs = new ArrayList<>();
        while (resultSet.next()) {
            Song song = new Song();

            song.setId(resultSet.getInt("id"));
            song.setTitle(resultSet.getString("title"));
            song.setImage_file_name(resultSet.getString("image_file_name"));
            song.setAlbum_title(resultSet.getString("album_title"));
            song.setPerformer(resultSet.getString("performer"));
            song.setYear(resultSet.getInt("year"));
            song.setGenre(resultSet.getString("genre"));
            song.setMusic_file_name(resultSet.getString("music_file_name"));

            songs.add(song);
        }
        return songs;
    }
}
