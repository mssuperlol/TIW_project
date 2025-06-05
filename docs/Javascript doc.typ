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

#set heading(numbering: "1.a.")


= Documentazione ver. Javascript

== Analisi requisiti dati

[...]\
- L'applicazione deve consentire all'utente di _riordinare le playlist_ con un criterio personalizzato diverso da quello di default. Dalla HOME con un link associato a ogni playlist si accede a una finestra modale RIORDINO, che mostra la lista completa dei brani della playlist ordinati secondo il criterio corrente (personalizzato o di default). L'utente può trascinare il titolo di un brano nell'elenco e di collocarlo in una _posizione_ diversa per realizzare l'ordinamento che desidera, senza invocare il server. Quando l'utente ha raggiunto l'ordinamento desiderato, usa un bottone "salva ordinamento", per memorizzare la sequenza sul server. Ai successivi accessi, l'ordinamento personalizzato è usato al posto di quello di default. Un brano aggiunto a una playlist con ordinamento personalizzato è inserito nell'ultima posizione.

Legenda:
- *Entità*;
- _Attributi_;
- #underline[Relazioni].

=== Diagramma entità-relazioni

#figure(image("ER DIagrams/ER Diagram JS.png", width: 100%));

=== Database design

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
    title           varchar(256) not null,
    image_file_name varchar(256) not null,
    album_title     varchar(256) not null,
    performer       varchar(256) not null,
    year            int          not null check ( year > 0 ),
    genre           varchar(256) not null,
    music_file_name varchar(256) not null,
    primary key (id),
    foreign key (user_id) references users (id) on update cascade on delete no action,
    foreign key (genre) references genres (name) on update cascade on delete no action,
    unique (user_id, music_file_name),
    unique (user_id, title)
);

create table playlists
(
    id               int auto_increment,
    user_id          int          not null,
    title            varchar(256) not null,
    date             date         not null default current_date,
    has_custom_order boolean      not null default false,
    primary key (id),
    unique (user_id, title)
);

create table playlist_contents
(
    playlist  int,
    song      int,
    custom_id int default null,
    primary key (playlist, song),
    foreign key (playlist) references playlists (id) on update cascade on delete no action,
    foreign key (song) references songs (id) on update cascade on delete no action
);
```

#pagebreak()

== Analisi requisiti d'applicazione

[...]\
Si realizzi un'applicazione client server web che modifica le specifiche precedenti come segue:
- Dopo il #set_colour(blue, [login dell'utente]), l'intera applicazione è realizzata con un'#set_colour(red, [unica pagina]);
- Ogni interazione dell'utente è gestita senza ricaricare completamente la pagina, ma produce l'invocazione asincrona del server e l'eventuale modifica del contenuto da aggiornare a seguito dell'evento;
- L'evento di visualizzazione del blocco precedente/successivo è gestito a lato client senza generare una richiesta al server;
- L'applicazione deve consentire all'utente di riordinare le playlist con un criterio personalizzato diverso da quello di default. Dalla HOME con un link associato a ogni playlist si accede a una finestra modale #set_colour(olive, [RIORDINO]), che mostra #set_colour(olive, [la lista completa dei brani della playlist ordinati secondo il criterio corrente]) (personalizzato o di default). L'utente può #set_colour(blue, [trascinare il titolo di un brano nell'elenco e di collocarlo in una posizione diversa]) per realizzare l'ordinamento che desidera, senza invocare il server. Quando l'utente ha raggiunto l'ordinamento desiderato, usa un #set_colour(olive, [bottone "salva ordinamento"]), per #set_colour(maroon, [memorizzare la sequenza sul server]). Ai successivi accessi, #set_colour(olive, [l'ordinamento personalizzato è usato al posto di quello di default]). #set_colour(blue, [Un brano aggiunto a una playlist con ordinamento personalizzato]) è #set_colour(maroon, [inserito nell'ultima posizione]).

Legenda:
- #set_colour(red, [Pagine])\;
- #set_colour(olive, [Componenti])\;
- #set_colour(blue, [Eventi])\;
- #set_colour(maroon, [Azioni]).

=== Aggiunta alle specifiche

- Funzione di logout, accessibile tramite un pulsante dalle pagine di home, playlist e canzone;
- Funzione per tornare alla homepage, accessibile tramite un pulsante dalle pagine di playlist e canzone;
- Funzione per tornare alla pagina della playlist originale, accessibile tramite un pulsante dalla pagina della canzone;
- Messaggio di "benvenuto" quando l'utente è nella home page;
- Nella pagina della playlist viene mostrata la data in cui è stata creata;
- Possibilità di creare una playlist senza brani;
- Istruzioni sul creare una playlist nella homepage se l'utente non ha playlist associate;
- Istruzioni sull'aggiungere brani alla playlist se vuota nella pagina della playlist;
- Istruzioni sul caricare canzoni nella pagina della playlist se l'utente o ha aggiunto tutti i suoi brani alla playlist o non ha brani associati;
- Possibilità di annullare il riordino di una playlist cliccando l'apposito pulsante o al di fuori del modal.

=== Diagramma IFML

#figure(image("IFML Diagrams/IFML Diagram JS.png", width: 100%))

=== Eventi e azioni

#figure(
  table(
    align: left,
    columns: 4,
    table.header(
      table.cell(colspan: 2, align(center, strong("Client side"))),
      table.cell(colspan: 2, align(center, strong("Server side"))),
      align(center)[*Evento*],
      align(center)[*Azione*],
      align(center)[*Evento*],
      align(center)[*Azione*],
    ),

    [Index $=>$ login form $=>$ submit], [Controllo dati], [POST: username, password], [Controllo credenziali],
    [Homepage $=>$ primo caricamento], [Aggiorna view], [GET], [Recupera informazioni utente e generi],
    [Homepage $=>$ primo caricamento o creazione playlist],
    [Aggiorna elenco playlist],
    [GET],
    [Recupera playlist dell'utente],

    [Homepage $=>$ primo caricamento o aggiunta brano],
    [Aggiorna create playlist form],
    [GET],
    [Recupera canzoni dell'utente],

    [Homepage $=>$ upload song form $=>$ submit],
    [Controllo dati],
    [POST: titolo, album, interprete, anno, genere, file musicale, immagine],
    [Aggiunta brano],

    [Homepage $=>$ create playlist form $=>$ submit],
    [Controllo dati],
    [POST: titolo, elenco brani da aggiungere],
    [Creazione playlist],

    [Homepage $=>$ elenco playlist $=>$ seleziona playlist],
    [Aggiorna view e visualizza playlist page],
    [GET: playlistId],
    [Recupero canzoni presenti nella playlist e non],

    [Playlist page $=>$ add songs form $=>$ submit],
    [Controllo dati],
    [POST: elenco brani da aggiungere],
    [Aggiunta brani alla playlist],

    [Playlist page $=>$ riordino],
    [Aggiorna view e mostra modal di riordino],
    [GET: playlistId],
    [Recupero brani presenti nella playlist],

    [Modal riordino $=>$ riordino $=>$ submit],
    [Controllo dati],
    [POST: brani ordinati],
    [Salva l'ordine personalizzato],

    [Modal riordino $=>$ annulla riordino/click fuori dal modal], [Nascondi modal di riordino], [-], [-],
    [Playlist page $=>$ successive/precedenti canzoni $=>$ submit], [Aggiorna view], [-], [-],
    [Playlist page $=>$ elenco brani $=>$ seleziona brano],
    [Aggiorna view e visualizza song page],
    [GET: songId],
    [Recupero informazioni brano],

    [Playlist/song page $=>$ homepage $=>$ submit], [Aggiorna view e visualizza homepage], [-], [-],
    [Song page $=>$ torna alla playlist $=>$ submit], [Aggiorna view e visualizza playlist page], [-], [-],
    [Logout], [-], [GET], [Terminazione sessione],
  ),
)

=== Controller ed Event handler

#figure(
  table(
    align: left,
    columns: 4,
    table.header(
      table.cell(colspan: 2, align(center, strong("Client side"))),
      table.cell(colspan: 2, align(center, strong("Server side"))),
      align(center)[*Evento*],
      align(center)[*Controller*],
      align(center)[*Evento*],
      align(center)[*Controller*],
    ),

    [Index $=>$ login form $=>$ submit], [Funzione `makeCall`], [POST: username, password], [Servlet `CheckLogin`],
    [Homepage $=>$ primo caricamento], [Funzione `homepageInit`], [GET], [Servlet `GetUser` e `GetGenres`],
    [Homepage $=>$ primo caricamento o creazione playlist],
    [Funzione `updatePlaylists`],
    [GET],
    [Servlet `GetPlaylists`],

    [Homepage $=>$ primo caricamento o aggiunta brano],
    [Funzione `updCreatePlaylistForm`],
    [GET],
    [Servlet `GetSongsByUserID`],

    [Homepage $=>$ upload song form $=>$ submit],
    [Funzione `makeCall`],
    [POST: titolo, album, interprete, anno, genere, file musicale, immagine],
    [Servlet `UploadSong`],

    [Homepage $=>$ create playlist form $=>$ submit],
    [Funzione `makeCall`],
    [POST: titolo, elenco brani da aggiungere],
    [Servlet `CreatePlaylist`],

    [Homepage $=>$ elenco playlist $=>$ seleziona playlist],
    [Funzione `playlistPageInit`],
    [GET: playlistId],
    [Servlet `GetPlaylist`, `GetSongsFromPlaylist` e `GetSongsNotInPlaylist`],

    [Playlist page $=>$ add songs form $=>$ submit],
    [Funzione `makeCall`],
    [POST: elenco brani da aggiungere],
    [Servlet `AddSongsToPlaylist`],

    [Playlist page $=>$ riordino], [Funzione `showReorderPage`], [GET: playlistId], [Servlet `GetSongsFromPlaylist`],
    [Modal riordino $=>$ riordino $=>$ submit],
    [Funzione `makeCall`],
    [POST: brani ordinati],
    [Servlet `UpdateCustomOrder`],

    [Modal riordino $=>$ annulla riordino/click fuori dal modal], [Funzione `closeModal`], [-], [-],
    [Playlist page $=>$ successive/precedenti canzoni $=>$ submit], [Funzione `showVisibleSongs`], [-], [-],
    [Playlist page $=>$ elenco brani $=>$ seleziona brano],
    [Funzione `showSongPage`],
    [GET: songId],
    [Servlet `GetSong`],

    [Playlist/song page $=>$ homepage $=>$ submit], [Funzione `showHomepage`], [-], [-],
    [Song page $=>$ torna alla playlist $=>$ submit], [Funzione `showPlaylistPage`], [-], [-],
    [Logout], [-], [GET], [Servlet `Logout`],
  ),
)

#pagebreak()

=== Sequence diagrams

- *Login*

#figure(
  scale(
    90%,
    diagram({
      _par("a", display-name: "login.html + loginManagement.js")
      _par("b", display-name: "CheckLogin", color: color.aqua)
      _par("c", display-name: "UserDAO", color: color.aqua)
      _par("d", display-name: "Session")
      _par("e", display-name: "Session storage")
      _par("f", display-name: "homepage.html")

      _seq("[", "a", enable-dst: true)
      _seq(
        "a",
        "b",
        comment: [doPost \
          username, password],
        enable-dst: true,
      )
      _seq("b", "c", comment: [new UserDAO()], enable-dst: true)
      _seq("c", "b", comment: [checkLogin], disable-src: true)
      _alt(
        "User not found",
        {
          _seq("b", "a", comment: [[`user == null`]\ display error])
        },
        "User found",
        {
          _seq("b", "d", comment: [[`user != null`]\ `setAttribute("user", user)`])
          _seq(
            "b",
            "a",
            comment: [[`user != null`] `SC_OK` \
              user.getId()],
            disable-src: true,
          )
          _seq("a", "e", comment: [`setItem("user_id", message)`])
          _seq("a", "f", comment: [redirect], disable-src: true)
        },
      )
    }),
  ),
)

- *Filtro utente*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "homepage.html")
      _par("b", display-name: "LoginChecker", color: color.aqua)
      _par("c", display-name: "Session")
      _par("d", display-name: "login.html")

      _seq("[", "a", enable-dst: true)
      _seq("a", "b", enable-dst: true)
      _seq("b", "c", comment: [[`!session.isNew()`] `getAttribute("user")`], enable-dst: true)
      _seq("c", "b", comment: [`user`], disable-src: true)
      _seq("b", "d", comment: [[`session.isNew() || user == null`] redirect])
      _seq("b", "a", disable-src: true, disable-dst: true)
    }),
  ),
)

#pagebreak()

- *Caricare la homepage*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "homepage.html + filter.js")
      _par("c", display-name: "Session storage")
      _par("d", display-name: "login.html")

      _seq("[", "a", comment: [load], enable-dst: true)
      _seq("a", "c", comment: [`getItem("user_id")`], enable-dst: true)
      _seq("c", "a", comment: [`user_id`], disable-src: true)
      _seq("a", "d", comment: [[`user_id === null`] `redirect`])
      _seq("a", "a", comment: [[`user_id !== null`] `homepageInit()`], disable-dst: true)
    }),
  ),
)

#pagebreak()

- *Inizializzare la homepage*

#figure(
  scale(
    95%,
    diagram({
      _par("a", display-name: "homepage.thml + homepageManager.js")
      _par("b", display-name: "GetUser", color: color.aqua)
      _par("c", display-name: "GetGenres", color: color.aqua)
      _par("d", display-name: "GenreDAO", color: color.aqua)

      _seq("[", "a", comment: [`homepageInit()`], enable-dst: true)
      _seq("a", "b", comment: [doGet], enable-dst: true)
      _seq("b", "b", comment: [`session.`\ `getAttribute("user")`])
      _seq("b", "a", comment: [`gson.toJson(user)`], disable-src: true)
      _seq("a", "a", comment: [[`req.status !== 200`]\ `sessionStorage.`\ `removeItem("user")`])
      _seq("a", "a", comment: [set welcome message])
      _seq("a", "c", comment: [doGet], enable-dst: true)
      _seq("c", "d", comment: [`new GenreDAO()`], enable-dst: true)
      _seq("d", "c", comment: [`getGenres()`], disable-src: true)
      _seq("c", "a", comment: [`gson.toJson(genres)`], disable-src: true)
      _seq("a", "a", comment: [[`req.status !== 200`]\ `sessionStorage.`\ `removeItem("user")`])
      _seq("a", "a", comment: [set genreChoiceMenu])
      _seq("a", "a", comment: [`updatePlaylists()`])
      _seq("a", "a", comment: [`updateCreatePlaylistForm()`])
      _seq("a", "a", comment: [`showHomepage()`], disable-dst: true)
    }),
  ),
)

#pagebreak()

- *Aggiornare la lista di playlist*

#figure(
  scale(
    95%,
    diagram({
      _par("a", display-name: "homepage.thml + homepageManager.js")
      _par("b", display-name: "GetPlaylists", color: color.aqua)
      _par("c", display-name: "PlaylistDAO", color: color.aqua)
      _par("d", display-name: "playlists_list")

      _seq("[", "a", comment: [`updatePlaylists()`], enable-dst: true)
      _seq("a", "b", comment: [doGet], enable-dst: true)
      _seq("b", "c", comment: [`new PlaylistDAO()`], enable-dst: true)
      _seq("c", "b", comment: [`getPlaylists(user.getId())`], disable-src: true)
      _seq("b", "a", comment: [`gson.toJson(playlists)`], disable-src: true)
      _alt(
        "Error",
        {
          _seq("a", "a", comment: [[`req.status !== 200`]\ handle error])
        },
        "Playlists recovered",
        {
          _seq("a", "d", comment: [update], disable-src: true)
        },
      )
    }),
  ),
)

- *Aggiornare il form per creare una playlist*

#figure(
  scale(
    90%,
    diagram({
      _par("a", display-name: "homepage.thml + homepageManager.js")
      _par("b", display-name: "GetSongsByUserID", color: color.aqua)
      _par("c", display-name: "SongDAO", color: color.aqua)
      _par("d", display-name: "create_playlist_table")

      _seq("[", "a", comment: [`updateCreate`\ `PlaylistForm()`], enable-dst: true)
      _seq("a", "b", comment: [doGet], enable-dst: true)
      _seq("b", "c", comment: [`new SongDAO()`], enable-dst: true)
      _seq("c", "b", comment: [`getAllSongsFromUserId`\ `(user.getId())`], disable-src: true)
      _seq("b", "a", comment: [`gson.toJson(songs)`], disable-src: true)
      _alt(
        "Error",
        {
          _seq("a", "a", comment: [[`req.status !== 200`]\ handle error])
        },
        "Playlists recovered",
        {
          _seq("a", "d", comment: [update], disable-src: true)
        },
      )
    }),
  ),
)

#pagebreak()

- *Andare alla homepage*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "homepage.thml + homepageManager.js")
      _par("b", display-name: "main_page")
      _par("c", display-name: "homepage_button")
      _par("d", display-name: "playlist_page + song_page")

      _seq("[", "a", comment: [`showHomepage()`], enable-dst: true)
      _seq("a", "b", comment: [display])
      _seq("a", "c", comment: [mask])
      _seq("a", "d", comment: [mask], disable-src: true)
    }),
  ),
)

- *Caricare una canzone*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "upload_song_form + homepageManager.js")
      _par("b", display-name: "UploadSong", color: color.aqua)
      _par("c", display-name: "SongDAO", color: color.aqua)

      _seq("a", "a", comment: [check form], enable-dst: true)
      _alt(
        "Wrong input",
        {
          _seq("a", "a", comment: [handle error])
        },
        "Valid input",
        {
          _seq("a", "b", comment: [doPost\ form], enable-dst: true)
          _seq("b", "b", comment: [check data])
          _alt(
            "Wrong input",
            {
              _seq("b", "a", comment: [error])
              _seq("a", "a", comment: [handle error])
            },
            "Valid input",
            {
              _seq("b", "c", comment: [`new SongDAO()`], enable-dst: true)
              _seq("b", "c", comment: [`insertSong(...)`], disable-dst: true)
              _seq("b", "a", comment: [`SC_OK`], disable-src: true)
              _seq("a", "a", comment: [reset form\ notify user])
              _seq("a", "]", comment: [`updateCreatePlaylistForm()`], disable-src: true)
            },
          )
        },
      )
    }),
  ),
)

#pagebreak()

- *Creare una playlist*

#figure(
  scale(
    90%,
    diagram({
      _par("a", display-name: "create_playlist_form + homepageManager.js")
      _par("b", display-name: "CreatePlaylist", color: color.aqua)
      _par("c", display-name: "PlaylistDAO", color: color.aqua)
      _par("d", display-name: "SongDAO", color: color.aqua)

      _seq("a", "a", comment: [check form], enable-dst: true)
      _alt(
        "Wrong input",
        {
          _seq("a", "a", comment: [handle error])
        },
        "Valid input",
        {
          _seq("a", "b", comment: [doPost\ form], enable-dst: true)
          _seq("b", "c", comment: [`new PlaylistDAO()`], enable-dst: true)
          _seq("b", "d", comment: [`new SongDAO()`], enable-dst: true)
          _seq("b", "b", comment: [check data])
          _alt(
            "Wrong input",
            {
              _seq("b", "a", comment: [error])
              _seq("a", "a", comment: [handle error])
            },
            "Valid input",
            {
              _seq("d", "b", comment: [`getSongsIdFromUserId(user.getId())`], disable-src: true)
              _seq("b", "c", comment: [`insertPlaylist(...)`], disable-dst: true)
              _seq("b", "a", comment: [`SC_OK`], disable-src: true)
              _seq("a", "a", comment: [reset form\ notify user])
              _seq("a", "]", comment: [`updatePlaylists()`], disable-src: true)
            },
          )
        },
      )
    }),
  ),
)

#pagebreak()

- *Inizializzare la pagina della playlist*

Parte 1

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "homepage.html + playlistPageManager.js")
      _par("b", display-name: "GetPlaylist", color: color.aqua)
      _par("c", display-name: "PlaylistDAO", color: color.aqua)

      _seq("[", "a", comment: [`playlistPageInit`\ `(playlist.id)`], enable-dst: true)
      _seq("a", "a", comment: [`sessionStorage.setItem`\ `("playlistId", playlistId)`])
      _seq("a", "b", comment: [doGet\ playlistId], enable-dst: true)
      _alt(
        "Invalid playlit id",
        {
          _seq("b", "a", comment: [[`playlistId nan`] error])
        },
        "Valid playlist id",
        {
          _seq("b", "c", comment: `new PlaylistDAO()`, enable-dst: true)
          _seq("c", "b", comment: `getPlaylist(playlistId)`, disable-src: true)
          _alt(
            "Wrong user",
            {
              _seq("b", "a", comment: [[`user.getId() !=`\ `playlist.getUserId()`]\ `SC_UNAUTHORIZED`])
            },
            "Correct user",
            {
              _seq("b", "a", comment: [`gson.toJson(playlist)`\ `SC_OK`], disable-src: true)
              _seq("a", "a", comment: [set playlist heading])
              _seq("a", "]", comment: [doGet GetSongsFromPlaylist\ playlistId], disable-src: true)
            },
          )
        },
      )
    }),
  ),
)

#pagebreak()

Parte 2

#figure(
  scale(
    85%,
    diagram({
      _par("a", display-name: "homepage.html + playlistPageManager.js")
      _par("b", display-name: "GetSongsFromPlaylist", color: color.aqua)
      _par("c", display-name: "PlaylistDAO", color: color.aqua)
      _par("d", display-name: "SongDAO", color: color.aqua)

      _alt(
        "Correct user",
        {
          _seq("[", "a", enable-dst: true)
          _seq("a", "b", comment: [doGet\ playlistId], enable-dst: true)
          _alt(
            "Invalid playlist id",
            {
              _seq("b", "a", comment: [[`playlistId nan`] error])
            },
            "Valid playlist id",
            {
              _seq("b", "c", comment: `new PlaylistDAO()`, enable-dst: true)
              _seq("b", "d", comment: [`new SongDAO()`], enable-dst: true)
              _seq("c", "b", comment: `getUserId(playlistId)`, disable-src: true)
              _alt(
                "Wrong user",
                {
                  _seq("b", "a", comment: [[`user.getId() != userId`]\ `SC_UNAUTHORIZED`])
                },
                "Correct user",
                {
                  _seq("d", "b", comment: [`getAllSongsFromPlaylist(playlistId)`], disable-src: true)
                  _seq("b", "a", comment: [`gson.toJson(songs)`\ `SC_OK`], disable-src: true)
                  _seq("a", "a", comment: [set playlist song table])
                  _seq("a", "a", comment: [set modal song table])
                  _seq("a", "]", comment: [`showVisibleSongs(0)`])
                },
              )
            },
          )
        },
      )
      _seq("a", "]", comment: [doGet GetSongsNotInPlaylist\ playlistId], disable-src: true)
    }),
  ),
)

#pagebreak()

Parte 3

#figure(
  scale(
    90%,
    diagram({
      _par("a", display-name: "homepage.html + playlistPageManager.js")
      _par("b", display-name: "GetSongsNotInPlaylist", color: color.aqua)
      _par("c", display-name: "PlaylistDAO", color: color.aqua)
      _par("d", display-name: "SongDAO", color: color.aqua)

      _seq("[", "a", enable-dst: true)
      _seq("a", "b", comment: [doGet\ playlistId], enable-dst: true)
      _seq("b", "c", comment: [`new PlaylistDAO()`], enable-dst: true)
      _alt(
        "Invalid playlist id",
        {
          _seq("b", "a", comment: [[`playlistId nan`] error])
        },
        "Valid playlist id",
        {
          _seq("b", "d", comment: [`new SongDAO()`], enable-dst: true)
          _seq("c", "b", comment: [`getUserId(playlistId)`], disable-src: true)
          _alt(
            "Wrong user",
            {
              _seq("b", "a", comment: [[`user.getId() != userId`]\ `SC_UNAUTHORIZED`])
            },
            "Correct user",
            {
              _seq("d", "b", comment: [`getSongsNotInPlaylist(`\ `user.getId(), playlistId)`], disable-src: true)
              _seq("b", "a", comment: [`gson.toJson(songs)`\ `SC_OK`], disable-src: true)
              _seq("a", "a", comment: [set add songs to playlist form])
            },
          )
        },
      )
      _seq("a", "]", comment: [`showPlaylistPage()`], disable-src: true)
    }),
  ),
)

- *Andare alla pagina della playlist*

#figure(
  scale(
    95%,
    diagram({
      _par("a", display-name: "homepage.thml + playlistPageManager.js")
      _par("b", display-name: "playlist_page")
      _par("c", display-name: "homepage_button")
      _par("d", display-name: "main_page + song_page")

      _seq("[", "a", comment: [`showPlaylistPage()`], enable-dst: true)
      _seq("a", "b", comment: [display])
      _seq("a", "c", comment: [display])
      _seq("a", "d", comment: [mask], disable-src: true)
    }),
  ),
)

#pagebreak()

- *Visualizzare brani precedenti/successivi*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "homepage.thml + playlistPageManager.js")
      _par("b", display-name: "displayed_songs")
      _par("c", display-name: "prev_songs")
      _par("d", display-name: "next_songs")

      _seq("[", "a", comment: [`showVisibleSongs`\ `(songsIndex)`], enable-dst: true)
      _seq("a", "a", comment: [get max row index])
      _seq("a", "a", comment: [[songsIndex invalid] `songsIndex = 0`])
      _seq("a", "a", comment: [`sessionStorage.setItem`\ `("songsIndex", songsIndex)`])
      _loop(
        "maxRow times",
        {
          _seq("a", "b", comment: [[`rowIndex !== songsIndex`] mask row], enable-dst: true)
          _seq("a", "b", comment: [[`rowIndex === songsIndex`] display row], disable-dst: true)
        },
      )
      _seq("a", "c", comment: [[`songsIndex !== 0`] mask], enable-dst: true)
      _seq("a", "c", comment: [[`songsIndex === 0`] display], disable-dst: true)
      _seq("a", "d", comment: [[`songsIndex < maxRow`] display], enable-dst: true)
      _seq("a", "d", comment: [[`songsIndex >= maxRow`] mask], disable-dst: true, disable-src: true)
    }),
  ),
)

#pagebreak()

- *Aggiungere brani alla playlist*

#figure(
  scale(
    90%,
    diagram({
      _par("a", display-name: "add_songs_to_playlist + playlistPageManager.js")
      _par("b", display-name: "AddSongsToPlaylist", color: color.aqua)
      _par("c", display-name: "PlaylistDAO", color: color.aqua)
      _par("d", display-name: "SongDAO", color: color.aqua)

      _seq("a", "a", comment: [`sessionStorage.getItem`\ `("playlistId")`], enable-dst: true)
      _seq("a", "b", comment: [doPost\ playlistId, form], enable-dst: true)
      _seq("b", "c", comment: [`new PlaylistDAO()`], enable-dst: true)
      _seq("b", "d", comment: [`new SongDAO()`], enable-dst: true)
      _alt(
        "Invalid playlist id",
        {
          _seq("b", "a", comment: [[`playlistId nan`] error])
        },
        "Valid playlist id",
        {
          _seq("c", "b", comment: [`getUserId(playlistId)`])
          _alt(
            "Wrong user",
            {
              _seq("b", "a", comment: [[`user.getId() != userId`]\ `SC_UNAUTHORIZED`])
            },
            "Correct user",
            {
              _seq("d", "b", comment: [`getSongsIdFromUserId`\ `(user.getId())`], disable-src: true)
              _loop(
                "for songId : userSongsId",
                {
                  _seq("b", "b", comment: [[`request.songId != null`]\ `songs.add(songId)`])
                },
              )
              _seq("c", "b", comment: [`addSongsToPlaylist`\ `(playlistId, songs)`], disable-src: true)
              _seq("b", "a", comment: [`SC_OK`], disable-src: true)
              _seq("a", "a", comment: [notify user])
              _seq("a", "]", comment: [`playlistPageInit(playlistId)`], disable-src: true)
            },
          )
        },
      )
    }),
  ),
)

#pagebreak()

- *Aprire il modal*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "reorder_button + modalManager.js")
      _par("b", display-name: "modal-overlay")

      _seq("[", "a", comment: [click], enable-dst: true)
      _seq("a", "b", comment: [`classList.remove("masked")`], enable-dst: true)
      _seq("a", "b", comment: [`classList.add("displayed")`], disable-dst: true, disable-src: true)
    }),
  ),
)

- *Chiudere il modal*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "reorder_submit/abort_reorder + modalManager.js")
      _par("b", display-name: "modal-overlay")
      _seq("[", "a", comment: [click], enable-dst: true)
      _seq("a", "b", comment: [`classList.remove("displayed")`], enable-dst: true)
      _seq("a", "b", comment: [`classList.add("masked")`], disable-dst: true, disable-src: true)
    }),
  ),
)

- *Chiudere il modal cliccando fuori dal form*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "modal-overlay + modalManager.js")
      _par("b", display-name: "modal-overlay")
      _seq("[", "a", comment: [click], enable-dst: true)
      _seq(
        "a",
        "b",
        comment: [[`e.target.classList.contains("modal-overlay")`]\ `classList.remove("displayed")`],
        enable-dst: true,
      )
      _seq(
        "a",
        "b",
        comment: [[`e.target.classList.contains("modal-overlay")`]\ `classList.add("masked")`],
        disable-dst: true,
        disable-src: true,
      )
    }),
  ),
)

#pagebreak()

- *Cambiare ordinamento della playlist*

#figure(
  scale(
    90%,
    diagram({
      _par("a", display-name: "reorder_form + modalManager.js")
      _par("b", display-name: "UpdateCustomOrder", color: color.aqua)
      _par("c", display-name: "PlaylistDAO", color: color.aqua)
      _par("d", display-name: "SongDAO", color: color.aqua)

      _seq("a", "a", comment: [`sessionStorage.getItem`\ `("playlistId")`], enable-dst: true)
      _seq("a", "b", comment: [doPost\ playlistId, form], enable-dst: true)
      _seq("b", "c", comment: [`new PlaylistDAO()`], enable-dst: true)
      _seq("b", "d", comment: [`new SongDAO()`], enable-dst: true)
      _alt(
        "Invalid playlist id",
        {
          _seq("b", "a", comment: [[`playlistId nan`] error])
        },
        "Valid playlist id",
        {
          _seq("d", "b", comment: [`getSongsIdFromUserId`\ `(user.getId())`], disable-src: true)
          _loop(
            "for songId : request",
            {
              _seq("b", "a", comment: [[`!userSongsId.contains(songId)`]\ `SC_BAD_REQUEST`])
              _seq("b", "b", comment: [[`userSongsId.contains(songId)`]\ `songOrder.add(songId)`])
            },
          )
          _seq("b", "a", comment: [[`userSongsId.size() !=`\ `songOrder.size()`]\ `SC_BAD_REQUEST`])
          _seq("c", "b", comment: [`getUserId(playlistId)`])
          _alt(
            "Wrong user",
            {
              _seq("b", "a", comment: [[`user.getId() != userId`]\ `SC_UNAUTHORIZED`])
            },
            "Correct user",
            {
              _seq("c", "b", comment: [`updateCustomOrder`\ `(playlistId, songOrder)`], disable-src: true)
              _seq("b", "a", comment: [`SC_OK`], disable-src: true)
              _seq("a", "]", comment: [`playlistPageInit(playlistId)`], disable-src: true)
            },
          )
        },
      )
    }),
  ),
)

#pagebreak()

- *Andare alla pagina della canzone*

Parte 1

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "homepage.thml + songPageManager.js")
      _par("b", display-name: "song_page")
      _par("c", display-name: "homepage_button")
      _par("d", display-name: "main_page + playlist_page")

      _seq("[", "a", comment: [`showSongPage(songId)`], enable-dst: true)
      _seq("a", "b", comment: [display])
      _seq("a", "c", comment: [display])
      _seq("a", "d", comment: [mask])
      _seq("a", "]", comment: [doGet GetSong\ songId], disable-src: true)
    }),
  ),
)

Parte 2
#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "song_page + songPageManager.js")
      _par("b", display-name: "GetSong", color: color.aqua)
      _par("c", display-name: "SongDAO", color: color.aqua)

      _seq("[", "a", enable-dst: true)
      _seq("a", "b", comment: [doGet\ songId], enable-dst: true)
      _alt(
        "Invalid songId",
        {
          _seq("b", "a", comment: [[`songId nan`] error])
        },
        "Valid songId",
        {
          _seq("b", "c", comment: [`new SongDAO()`], enable-dst: true)
          _seq("c", "b", comment: [`getSong(songId)`], disable-src: true)
          _alt(
            "Wrong user",
            {
              _seq("b", "a", comment: [[`user.getId() !=`\ `song.getUser_id()`] error])
            },
            "Correct user",
            {
              _seq("b", "a", comment: [`gson.toJson(song)`\ `SC_OK`], disable-src: true)
              _seq("a", "a", comment: [set song info and player], disable-dst: true)
            },
          )
        },
      )
    }),
  ),
)
