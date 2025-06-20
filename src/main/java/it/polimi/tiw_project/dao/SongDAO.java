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
     * Gets all the songs associated with the given user id, ordered by performer and year
     *
     * @param userId user id
     * @return a list containing all the songs associated with id, or null if no songs were found
     * @throws SQLException
     */
    public List<Song> getAllSongsFromUserId(int userId) throws SQLException {
        String query = """
                SELECT *
                FROM songs
                WHERE user_id = ?
                ORDER BY performer, year, id
                """;

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return getSongListFromResultSet(resultSet);
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
        String query = """
                SELECT *
                FROM songs AS s JOIN playlist_contents AS c ON s.id = c.song
                WHERE c.playlist = ?
                ORDER BY performer, year, s.id
                """;

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, playlistId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return getSongListFromResultSet(resultSet);
            }
        }
    }

    /**
     * Extracts songs from a given resultSet
     *
     * @param resultSet
     * @return list of all songs from resultSet, or null if no songs were found
     * @throws SQLException
     * @see SongDAO#getSongFromResultSet
     */
    private List<Song> getSongListFromResultSet(ResultSet resultSet) throws SQLException {
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
     * @param userId        id of the user
     * @param title         title of the song
     * @param imageFileName file name of the album image
     * @param albumTitle    title of the album
     * @param performer     artist of the song
     * @param year          year of the performance
     * @param genre         genre of the song
     * @param musicFileName file name of the music file
     * @throws SQLException
     */
    public void insertSong(int userId, String title, String imageFileName, String albumTitle, String performer, int year, String genre, String musicFileName) throws SQLException {
        String query = """
                INSERT INTO songs(user_id, title, image_file_name, album_title, performer, year, genre, music_file_name)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                """;
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
     *
     * @param songId id of the song
     * @return Song object with all data; null if not found
     * @throws SQLException
     * @see SongDAO#getSongFromResultSet
     */
    public Song getSong(int songId) throws SQLException {
        String query = """
                SELECT *
                FROM songs
                WHERE id = ?
                """;

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
     * @param userId     id of the user
     * @param playlistId id of the playlist to exclude
     * @return a list of Song that were uploaded by the given user that are not already part of the given playlist
     * @throws SQLException
     * @see SongDAO#getSongListFromResultSet
     */
    public List<Song> getSongsNotInPlaylist(int userId, int playlistId) throws SQLException {
        String query = """
                SELECT *
                FROM songs
                WHERE user_id = ? AND id NOT IN(
                   SELECT song
                   FROM playlist_contents
                   WHERE playlist = ?
                )
                ORDER BY performer, year, id
                """;

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);
            statement.setInt(2, playlistId);

            try (ResultSet resultSet = statement.executeQuery()) {
                return getSongListFromResultSet(resultSet);
            }
        }
    }

    /**
     * @param userId id of the user
     * @return a list of the user's songs ids
     * @throws SQLException
     */
    public List<Integer> getSongsIdFromUserId(int userId) throws SQLException {
        String query = """
                SELECT id
                FROM songs
                WHERE user_id = ?
                """;

        try (PreparedStatement statement = connection.prepareStatement(query)) {
            statement.setInt(1, userId);

            try (ResultSet resultSet = statement.executeQuery()) {
                List<Integer> songIds = new ArrayList<>();

                while (resultSet.next()) {
                    songIds.add(resultSet.getInt("id"));
                }

                return songIds;
            }
        }
    }

    /**
     * @param resultSet result set containing the song data
     * @return song object with the result set data
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
