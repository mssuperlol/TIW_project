drop table if exists playlist_contents;
drop table if exists playlists;
drop table if exists songs;
drop table if exists genres;
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

create table genres
(
    name varchar(32),
    primary key (name)
);

#source: https://en.wikipedia.org/wiki/List_of_music_genres_and_styles
load data local infile 'docs/genres.csv'
    into table genres
    fields terminated by ','
    enclosed by ','
    lines terminated by '\n'
    (name);

create table songs
(
    id              int auto_increment,
    user_id         int         not null,
    title           varchar(64) not null,
    image_file_name varchar(64) not null,
    album_title     varchar(64) not null,
    performer       varchar(64) not null, #interprete
    year            int         not null,
    genre           varchar(64) not null,
    music_file_name varchar(64) not null,
    primary key (id),
    foreign key (user_id) references users (id),
    foreign key (genre) references genres (name),
    unique (user_id, music_file_name)
);

create table playlists
(
    id    int auto_increment,
    title varchar(64) not null,
    date  date        not null,
    primary key (id)
);

create table playlist_contents
(
    playlist int,
    song     int,
    primary key (playlist, song),
    foreign key (playlist) references playlists (id),
    foreign key (song) references songs (id)
);

insert into users (username, password, name, surname)
values ('mssuperlol', 'pass', 'Michele', 'Sangaletti'),
       ('john', 'word', 'John', 'DarkSouls');

insert into songs (user_id, title, image_file_name, album_title, performer, year, genre, music_file_name)
values ('1', 'Lovesick - 80,000 Lightyears', 'Omori_Portrait.png', 'OMORI OST', 'Omocat', '2020', 'Electronic',
        'OMORI OST - 025 Lovesick - 80,000 Lightyears.mp3'),
       ('1', 'Three Bar Logos', 'Omori_Portrait.png', 'OMORI OST', 'Omocat', '2020', 'Electronic',
        'OMORI OST - 027 Three Bar Logos.mp3'),
       ('1', 'Stardust Diving', 'Omori_Portrait.png', 'OMORI OST', 'Omocat', '2020', 'Electronic',
        'OMORI OST - 032 Stardust Diving.mp3'),
       ('1', 'You Were Wrong. Go Back', 'Omori_Portrait.png', 'OMORI OST', 'Omocat', '2020', 'Electronic',
        'OMORI OST - 040 You Were Wrong. Go Back..mp3');

insert into playlists (title, date)
values ('Videogames OST', '2023/01/01');

insert into playlist_contents (playlist, song)
values (1, 1),
       (1, 2),
       (1, 3),
       (1, 4);