#import "@preview/chronos:0.2.1": *

#set text(lang: "it")

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
)
#set page(numbering: "1", number-align: center)

#let set_colour(colour, name) = {
  text(colour)[#name]
}

#align(horizon + center)[
  = Progetto di Tecnologie Informatiche per il Web
  \
  Michele Sangaletti
]

#pagebreak()

#outline(indent: 1em)

#pagebreak()

= Traccia 2: playlist musicale

== Versione HTML pura

Un'applicazione web consente la gestione di una playlist di brani musicali.

Playlist e brani sono personali di ogni utente e non condivisi. Ogni utente ha username, password, nome e cognome. Ogni brano musicale è memorizzato nella base di dati mediante un titolo, l'immagine e il titolo dell'album da cui il brano è tratto, il nome dell'interprete (singolo o gruppo) dell'album, l'anno di pubblicazione dell'album, il genere musicale (si supponga che i generi siano prefissati) e il file musicale. Non è richiesto di memorizzare l'ordine con cui i brani compaiono nell'album a cui appartengono. Si ipotizzi che un brano possa appartenere a un solo album (no compilation). L'utente, previo login, può creare brani mediante il caricamento dei dati relativi e raggrupparli in playlist. Una playlist è un insieme di brani scelti tra quelli caricati dallo stesso utente. Lo stesso brano può essere inserito in più playlist. Una playlist ha un titolo e una data di creazione ed è associata al suo creatore.

A seguito del LOGIN, l'utente accede all'HOME PAGE che presenta l'elenco delle proprie playlist, ordinate per data di creazione decrescente, un FORM per caricare un BRANO con tutti i dati relativi e un form per creare una nuova playlist. \
Il FORM per la creazione di una nuova PLAYLIST mostra l'elenco dei brani dell'utente ordinati per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene. Tramite il form è possibile selezionare uno o più brani da includere. \
Quando l'utente clicca su una playlist nell'HOME PAGE, appare la pagina PLAYLIST PAGE che contiene inizialmente una tabella di una riga e cinque colonne. Ogni cella contiene il titolo di un brano e l'immagine dell'album da cui proviene. I brani sono ordinati da sinistra a destra per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene. Se la playlist contiene più di cinque brani, sono disponibili comandi per vedere il precedente e successivo gruppo di brani. Se la pagina PLAYLIST mostra il primo gruppo e ne esistono altri successivi nell'ordinamento, compare a destra della riga il bottone SUCCESSIVI, che permette di vedere il gruppo successivo. Se la pagina PLAYLIST mostra l'ultimo gruppo e ne esistono altri precedenti nell'ordinamento, compare a sinistra della riga il bottone PRECEDENTI, che permette di vedere i cinque brani precedenti. Se la pagina PLAYLIST mostra un blocco ed esistono sia precedenti sia successivi, compare a destra della riga il bottone SUCCESSIVI e a sinistra il bottone PRECEDENTI. \
La pagina PLAYLIST contiene anche un FORM che consente di selezionare e AGGIUNGERE uno o più BRANI alla playlist corrente, se non già presente nella playlist. Tale form presenta i brani da scegliere nello stesso modo del form usato per creare una playlist. A seguito dell'aggiunta di un brano alla playlist corrente, l'applicazione visualizza nuovamente la pagina a partire dal primo blocco della playlist. \
Quando l'utente seleziona il titolo di un brano, la pagina PLAYER mostra tutti i dati del brano scelto e il player audio per la riproduzione del brano.

== Versione con JavaScript

Si realizzi un'applicazione client server web che modifica le specifiche precedenti come segue:
- Dopo il login dell'utente, l'intera applicazione è realizzata con un'unica pagina;
- Ogni interazione dell'utente è gestita senza ricaricare completamente la pagina, ma produce l'invocazione asincrona del server e l'eventuale modifica del contenuto da aggiornare a seguito dell'evento;
- L'evento di visualizzazione del blocco precedente/successivo è gestito a lato client senza generare una richiesta al server;
- L'applicazione deve consentire all'utente di riordinare le playlist con un criterio personalizzato diverso da quello di default. Dalla HOME con un link associato a ogni playlist si accede a una finestra modale #set_colour(red, [RIORDINO]), che mostra #set_colour(olive, [la lista completa dei brani della playlist ordinati secondo il criterio corrente]) (personalizzato o di default). L'utente può #set_colour(blue, [trascinare il titolo di un brano nell'elenco e di collocarlo in una posizione diversa]) per realizzare l'ordinamento che desidera, senza invocare il server. Quando l'utente ha raggiunto l'ordinamento desiderato, usa un bottone "salva ordinamento", per memorizzare la sequenza sul server. Ai successivi accessi, l'ordinamento personalizzato è usato al posto di quello di default. Un brano aggiunto a una playlist con ordinamento personalizzato è inserito nell'ultima posizione.

#pagebreak()

= Documentazione ver. html pura

== Analisi requisiti dati

#underline[Playlist e brani sono personali] di ogni utente e non condivisi. Ogni *utente* ha _username_, _password_, _nome_ e _cognome_. Ogni *brano musicale* è memorizzato nella base di dati mediante un _titolo_, l'_immagine_ e il _titolo dell'album_ da cui il brano è tratto, il _nome dell'interprete_ (singolo o gruppo) dell'album, l'_anno di pubblicazione dell'album_, il _genere musicale_ (#underline[si supponga che i *generi* siano prefissati]) e il _file musicale_. Non è richiesto di memorizzare l'ordine con cui i brani compaiono nell'album a cui appartengono. Si ipotizzi che #underline[un brano possa appartenere a un solo album] (no compilation). L'utente, previo login, può creare brani mediante il caricamento dei dati relativi e raggrupparli in playlist. #underline[Una playlist è un insieme di brani scelti tra quelli caricati dallo stesso utente]. #underline[Lo stesso brano può essere inserito in più playlist]. Una *playlist* ha un _titolo_ e una _data di creazione_ ed #underline[è associata al suo creatore].

Legenda:
- *Entità*;
- _Attributi_;
- #underline[Relazioni].

=== Design database

#figure(image("ER Diagram.png", width: 100%))

```sql
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

create table songs
(
    id              int auto_increment,
    user_id         int          not null,
    title           varchar(64)  not null,
    image_file_name varchar(64)  not null,
    album_title     varchar(64)  not null,
    performer       varchar(64)  not null,
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
```

#pagebreak()

== Analisi requisiti d'applicazione

A seguito del #set_colour(red, [LOGIN]), l'utente accede all'#set_colour(red, [HOME PAGE]) che presenta l'#set_colour(olive, [elenco delle proprie playlist]), ordinate per data di creazione decrescente, un #set_colour(olive, [#set_colour(olive, [FORM per #set_colour(blue, [caricare un BRANO])]) con tutti i dati relativi]) e #set_colour(olive, [un FORM per #set_colour(blue, [creare una nuova playlist])]). \
Il FORM per la creazione di una nuova PLAYLIST mostra l'#set_colour(olive, [elenco dei brani dell'utente ordinati per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene]). Tramite il form è possibile #set_colour(blue, [selezionare uno o più brani da includere]). \
Quando l'utente #set_colour(blue, [clicca su una playlist nell'HOME PAGE]), #set_colour(maroon, [appare la pagina]) #set_colour(red, [PLAYLIST PAGE]) che contiene inizialmente una #set_colour(olive, [tabella di una riga e cinque colonne. Ogni cella contiene il titolo di un brano e l'immagine dell'album]) da cui proviene. #set_colour(olive, [I brani sono ordinati da sinistra a destra per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene]). #set_colour(olive, [Se la playlist contiene più di cinque brani, sono disponibili comandi per #set_colour(maroon, [vedere il precedente e successivo gruppo di brani])]). Se la pagina PLAYLIST mostra il primo gruppo e ne esistono altri successivi nell'ordinamento, #set_colour(maroon, [compare a destra della riga]) #set_colour(olive, [il bottone SUCCESSIVI]), #set_colour(maroon, [che permette di vedere il gruppo successivo]). Se la pagina PLAYLIST mostra l'ultimo gruppo e ne esistono altri precedenti nell'ordinamento, #set_colour(maroon, [compare a sinistra della riga]) #set_colour(olive, [il bottone PRECEDENTI]), #set_colour(maroon, [che permette di vedere i cinque brani precedenti]). Se la pagina PLAYLIST mostra un blocco ed esistono sia precedenti sia successivi, compare a destra della riga il bottone SUCCESSIVI e a sinistra il bottone PRECEDENTI. \
La pagina PLAYLIST contiene anche un #set_colour(olive, [FORM che consente di selezionare e AGGIUNGERE uno o più BRANI alla playlist corrente]), se non già presente nella playlist. Tale form #set_colour(olive, [presenta i brani da scegliere nello stesso modo del form usato per creare una playlist]). #set_colour(blue, [A seguito dell'aggiunta di un brano alla playlist corrente]), #set_colour(maroon, [l'applicazione visualizza nuovamente la pagina a partire dal primo blocco della playlist]). \
Quando l'utente #set_colour(blue, [seleziona il titolo di un brano]), la pagina #set_colour(red, [PLAYER]) mostra tutti #set_colour(olive, [i dati del brano scelto]) e il #set_colour(olive, [player audio]) per la riproduzione del brano.

Legenda:
- #set_colour(red, [Pagine])
- #set_colour(color.olive, [Componenti])
- #set_colour(blue, [Eventi])
- #set_colour(color.maroon, [Azioni])

=== Diagramma IFL

#figure(image("IFML Diagram HTML.png", width: 100%))

=== Sequence diagram

*Login*

#figure(
  diagram({
    _par("a", display-name: "login.html")
    _par("b", display-name: "CheckLogin")
    _par("c", display-name: "UserDao")
    _par("d", display-name: "Session")
    _par("e", display-name: "GotToHomepage")

    _seq(
      "a",
      "b",
      comment: [doPost\
        username, password],
      enable-dst: true,
    )
    _seq("b", "c", comment: "new UserDao()", enable-dst: true)
    _seq("c", "b", comment: "checkLogin", disable-src: true)
    _seq("b", "a", comment: [[`user == null`] redirect])
    _seq("b", "d", comment: [[`user != null`] `setAttribute("user", user)`])
    _seq("b", "e", comment: [[`user != null`] redirect], disable-src: true)
  }),
)

*Controllare l'user*

#figure(
  diagram({
    _par("a", display-name: "GoToHomepage")
    _par("b", display-name: "Request")
    _par("c", display-name: "Session")
    _par("d", display-name: "login.html")

    _seq("[", "a", comment: "doGet/doPost", enable-dst: true)
    _seq("a", "b", comment: [`getSession()`], enable-dst: true)
    _seq("b", "a", comment: "Session", disable-src: true)
    _seq("a", "c", comment: [[`!session.isNew()`] `getAttribute(user)`], enable-dst: true)
    _seq("c", "a", comment: "user", disable-src: true)
    _seq("a", "d", comment: [`[session.isNew() || user == null]` redirect])
    _seq("a", "]", comment: [[`user != null`] `methodY()`/forward/redirect], disable-src: true)
  }),
)

*Tornare/andare alla homepage*

#figure(
  diagram({
    _par("a", display-name: "GoToHomepage")
    _par("b", display-name: "PlaylistDao")
    _par("c", display-name: "GenreDao")
    _par("d", display-name: "SongDao")
    _par("e", display-name: "Context")
    _par("f", display-name: "TemplateEngine")

    _seq("[", "a", comment: "Redirect", enable-dst: true)
    _seq("a", "b", comment: [`new PlaylistDao()`], enable-dst: true)
    _seq("a", "b", comment: [`getPlaylists(session.user.getId())`])
    _seq("b", "a", comment: "playlists", disable-src: true)
    _seq("a", "c", comment: [`new GenreDao()`], enable-dst: true)
    _seq("a", "c", comment: [`getGenres()`])
    _seq("c", "a", comment: "genres", disable-src: true)
    _seq("a", "d", comment: [`new SongDao()`], enable-dst: true)
    _seq("a", "d", comment: [`getAllSongsFromUserID(session.user.getId())`])
    _seq("d", "a", comment: "songs", disable-src: true)
    _seq("a", "e", comment: [`setVariable(playlists)`], enable-dst: true)
    _seq("a", "e", comment: [`setVariable(genres)`])
    _seq("a", "e", comment: [`setVariable(songs)`], disable-dst: true)
    _seq("a", "f", comment: [`process("/WEB-INF/homepage.html", Context, ...)`], disable-src: true)
  }),
)

*Logout*

#figure(
  diagram({
    _par("a", display-name: "Logout")
    _par("b", display-name: "Session")
    _par("c", display-name: "login.html")

    _seq("[", "a", comment: "doGet/doPost", enable-dst: true)
    _seq("a", "b", comment: [[`session != null`] `invalidate`])
    _seq("a", "c", comment: "redirect", disable-src: true)
  }),
)

*Caricare una canzone*

#figure(
  diagram({
    _par("a", display-name: "UploadSong")
    _par("b", display-name: "SongDao")
    _par("c", display-name: "homepage.html")
    _par("d", display-name: "localStorage")

    _seq("[", "a", comment: "doPost", enable-dst: true)
    _note(
      "left",
      [/UploadSong
        - title;
        - album;
        - performer;
        - year;
        - genre;
        - music_file;
        - image_file.
        From: homepage.html],
      pos: "a",
    )
    _seq("a", "a", comment: [check file\ format])
    _seq("a", "b", comment: [`new SongDao()`], enable-dst: true)
    _seq(
      "a",
      "c",
      comment: [[`title == null || albumTitle == null ||`\ `performer == null || genre == null`]\ `redirect`],
    )
    _seq("a", "d", comment: [`Files.copy(image_file,`\ `ServletContext.musicPath + image_file_name)`], enable-dst: true)
    _seq(
      "a",
      "d",
      comment: [`Files.copy(music_file,`\ `ServletContext.musicPath + music_file_name)`],
      disable-dst: true,
    )
    _seq(
      "a",
      "b",
      comment: [`insertSong(session.user.getId(),`\ `title, imageFileName, albumTitle,`\ `performer, year, genre,`\ `musicFileName)`],
      disable-dst: true,
    )
    _seq("a", "c", comment: [`redirect`], disable-src: true)
  }),
)

*Creare una playlist*

#figure(
  diagram({
    _par("a", display-name: "CreatePlaylist")
    _par("b", display-name: "PlaylistDao")
    _par("c", display-name: "SongDao")
    _par("d", display-name: "homepage.html")

    _seq("[", "a", comment: "doPost", enable-dst: true)
    _note(
      "left",
      pos: "a",
      [/CreatePlaylist
        - title;
        - songs id.
        From: homepage.html],
    )
    _seq("a", "b", comment: [`new PlaylistDao()`], enable-dst: true)
    _seq("a", "c", comment: [`new songDao()`], enable-dst: true)
    _seq("a", "d", comment: [[`title == null`] `redirect`])
    _seq("a", "c", comment: [`getSongsIdFromUserId(session.user.getId())`])
    _seq("c", "a", comment: [`userSongsId`], disable-src: true)
    _seq("a", "a", comment: [[`request.songId != null`]\ `songs.add(songId)`])
    _seq("a", "b", comment: [`insertPlaylist(`\ `session.user.getId(), title, songs)`], disable-dst: true)
    _seq("a", "d", comment: [`redirect`], disable-src: true)
  }),
)

*Recuperare un file*

#figure(diagram({ }))

*Andare alla pagina della playlist*

#figure(diagram({ }))

*Aggiungere canzoni alla playlist*

#figure(diagram({ }))

*Andare alla pagina della canzone*

#figure(diagram({ }))
