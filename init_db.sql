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
    user_id         int          not null,
    title           varchar(64)  not null,
    image_file_name varchar(64)  not null,
    album_title     varchar(64)  not null,
    performer       varchar(64)  not null, #interprete
    year            int          not null,
    genre           varchar(64)  not null,
    music_file_name varchar(128) not null,
    primary key (id),
    foreign key (user_id) references users (id),
    foreign key (genre) references genres (name),
    unique (user_id, music_file_name)
);

create table playlists
(
    id      int auto_increment,
    user_id int         not null,
    title   varchar(64) not null,
    date    date        not null,
    primary key (id),
    unique (user_id, title)
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
        'OMORI OST - 040 You Were Wrong. Go Back..mp3'),
       ('1', 'Locked Girl ~ The Girls Secret Room', 'Touhou.jpg', 'Touhou 6 OST', 'Zun', '2002', 'Electronic',
        'EoSD Stage 4 Boss - Patchouli Knowledges Theme - Locked Girl ~ The Girls Secret Room.mp3'),
       ('1', 'A Stroll Through Nostalgia', 'Phyrnna.jpg', 'Epic Battle Fantasy 4 OST', 'Phyrnna', '2013', 'Electronic',
        'Phyrnna - A Stroll Through Nostalgia (Ending Version).mp3'),
       ('1', 'Shizuka', 'Crosscode.jpg', 'Crosscode OST', 'Deniz Akbulut', '2018', 'Electronic',
        'Shizuka ~ CrossCode (Original Game Soundtrack).mp3'),
       ('1', 'The Leopard''s Bane', 'Phyrnna.jpg', 'Epic Battle Fantasy 5 OST', 'Phyrnna', '2018', 'Electronic',
        'The Leopard''s Bane.mp3'),
       ('1', 'BAD Apple!!', 'Th04cover.jpg', 'Touhou 4 OST', 'Zun', '1998', 'Electronic',
        'Touhou 4 - Music #07 - BAD Apple!!.mp3'),
       ('1', 'Ornstein and Smough', 'Dark Souls.jpg', 'Dark Souls OST', 'Motoi Sakuraba', '2011', 'Electronic',
        'Ornstein and Smough - Dark Souls Soundtrack 15.mp3'),
       ('1', 'Windy and Ripply', 'Sonic_Adventure.png', 'Sonic Adventure OST', 'Jun Senoue', '1998', 'Electronic',
        'Windy and Ripply (Emerald Coast) - Sonic Adventure [OST].mp3'),
       ('1', 'Command 2', 'Systemshock2box.jpg', 'System Shock 2 OST', 'Josh Randall', '1999', 'Electronic',
        'System Shock 2 OST Command 2.mp3'),
       ('1', 'Intro', 'Sysshock.jpg', 'System Shock OST', 'Greg LoPiccolo', '1994', 'Electronic',
        'System Shock Soundtrack - 00 - Intro.mp3');

insert into playlists (user_id, title, date)
values (1, 'Videogames OST', '2025/02/13'),
       (1, 'Omori OST', '2023/01/01'),
       (2, 'Empty', '2025/01/01');

insert into playlist_contents (playlist, song)
values (1, 1),
       (1, 2),
       (1, 3),
       (1, 4),
       (1, 5),
       (1, 6),
       (1, 7),
       (1, 8),
       (1, 9),
       (1, 10),
       (1, 11),
       (1, 12),
       (1, 13),
       (2, 1),
       (2, 2),
       (2, 3),
       (2, 4);