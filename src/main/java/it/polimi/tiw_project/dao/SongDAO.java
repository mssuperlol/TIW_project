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
     *
     * @param userId user id
     * @return a list containing all the songs associated with id, or null if no songs were found
     * @throws SQLException
     */
    public List<Song> getAllSongsFromUserId(int userId) throws SQLException {
        String query = "SELECT * " +
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
     *
     * @param playlistId playlist id
     * @return a list containing all the songs associated with id, or null if no songs were found
     * @throws SQLException
     */
    public List<Song> getAllSongsFromPlaylist(int playlistId) throws SQLException {
        String query = "SELECT * " +
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
     *
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
            songs.add(getSongFromResultSet(resultSet));
        }

        return songs;
    }

    /**
     * Adds a song to the songs database
     *
     * @param userId
     * @param title
     * @param imageFileName
     * @param albumTitle
     * @param performer
     * @param year
     * @param genre
     * @param musicFileName
     * @throws SQLException
     */
    public void insertSong(int userId, String title, String imageFileName, String albumTitle, String performer, int year, String genre, String musicFileName) throws SQLException {
        String query = "INSERT into songs(user_id, title, image_file_name, album_title, performer, year, genre, music_file_name) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);
            statement.setString(2, title);
            statement.setString(3, imageFileName);
            statement.setString(4, albumTitle);
            statement.setString(5, performer);
            statement.setInt(6, year);
            statement.setString(7, genre);
            statement.setString(8, musicFileName);
            statement.executeUpdate();
        }
    }

    /**
     * Gets Song object from given songId
     * @param songId id of the song
     * @return Song object with all data; null if not found
     * @throws SQLException
     */
    public Song getSong(int songId) throws SQLException {
        String query = "SELECT * FROM songs WHERE id = ?";

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, songId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return getSongFromResultSet(resultSet);
                } else {
                    return null;
                }
            }
        }
    }

    /**
     * @param resultSet
     * @return
     * @throws SQLException
     */
    private Song getSongFromResultSet(ResultSet resultSet) throws SQLException {
        Song song = new Song();
        song.setId(resultSet.getInt("id"));
        song.setUser_id(resultSet.getInt("user_id"));
        song.setTitle(resultSet.getString("title"));
        song.setImage_file_name(resultSet.getString("image_file_name"));
        song.setAlbum_title(resultSet.getString("album_title"));
        song.setPerformer(resultSet.getString("performer"));
        song.setYear(resultSet.getInt("year"));
        song.setGenre(resultSet.getString("genre"));
        song.setMusic_file_name(resultSet.getString("music_file_name"));
        return song;
    }
}
