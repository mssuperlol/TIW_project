drop table if exists playlist_contents;
drop table if exists playlists;
drop table if exists songs;
drop table if exists users;

create table users
(
    id       int auto_increment,
    username varchar(32) not null unique,
    password varchar(32) not null,
    name     varchar(32) not null,
    surname  varchar(32) not null,
    primary key (id)
);

create table songs
(
    id          int auto_increment,
    user_id     int         not null,
    title       varchar(64) not null,
    image       varchar(64) not null,
    album_title varchar(64) not null,
    performer   varchar(64) not null, #interprete
    year        int         not null,
    genre       varchar(64) not null,
    file        varchar(64) not null,
    primary key (id),
    foreign key (user_id) references users (id)
    #TODO constraint del genere
);

create table playlists
(
    id int auto_increment,
    title varchar(64) not null,
    date date not null,
    primary key (id)
);

create table playlist_contents
(
    playlist int,
    song int,
    primary key (playlist, song),
    foreign key (playlist) references playlists(id),
    foreign key (song) references  songs(id)
);