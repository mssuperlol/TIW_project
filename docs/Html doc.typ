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

= Documentazione ver. html pura

== Analisi requisiti dati

#underline[Playlist e brani sono personali] di ogni utente e non condivisi. Ogni *utente* ha _username_, _password_, _nome_ e _cognome_. Ogni *brano musicale* è memorizzato nella base di dati mediante un _titolo_, l'_immagine_ e il _titolo dell'album_ da cui il brano è tratto, il _nome dell'interprete_ (singolo o gruppo) dell'album, l'_anno di pubblicazione dell'album_, il _genere musicale_ (#underline[si supponga che i *generi* siano prefissati]) e il _file musicale_. Non è richiesto di memorizzare l'ordine con cui i brani compaiono nell'album a cui appartengono. Si ipotizzi che #underline[un brano possa appartenere a un solo album] (no compilation). L'utente, previo login, può creare brani mediante il caricamento dei dati relativi e raggrupparli in playlist. #underline[Una playlist è un insieme di brani scelti tra quelli caricati dallo stesso utente]. #underline[Lo stesso brano può essere inserito in più playlist]. Una *playlist* ha un _titolo_ e una _data di creazione_ ed #underline[è associata al suo creatore].

Legenda:
- *Entità*;
- _Attributi_;
- #underline[Relazioni].

=== Diagramma entità-relazioni

#figure(image("ER DIagrams/ER Diagram HTML.png", width: 100%))

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
    id      int auto_increment,
    user_id int          not null,
    title   varchar(256) not null,
    date    date         not null default current_date,
    primary key (id),
    unique (user_id, title)
);

create table playlist_contents
(
    playlist int,
    song     int,
    primary key (playlist, song),
    foreign key (playlist) references playlists (id) on update cascade on delete no action,
    foreign key (song) references songs (id) on update cascade on delete no action
);
```

#pagebreak()

== Analisi requisiti d'applicazione

A seguito del #set_colour(red, [LOGIN]), l'utente accede all'#set_colour(red, [HOME PAGE]) che presenta l'#set_colour(olive, [elenco delle proprie playlist]), ordinate per data di creazione decrescente, un #set_colour(olive, [#set_colour(olive, [FORM per #set_colour(blue, [caricare un BRANO])]) con tutti i dati relativi]) e #set_colour(olive, [un FORM per #set_colour(blue, [creare una nuova playlist])]). \
Il FORM per la creazione di una nuova PLAYLIST mostra l'#set_colour(olive, [elenco dei brani dell'utente ordinati per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene]). Tramite il form è possibile #set_colour(blue, [selezionare uno o più brani da includere]). \
Quando l'utente #set_colour(blue, [clicca su una playlist nell'HOME PAGE]), #set_colour(maroon, [appare la pagina]) #set_colour(red, [PLAYLIST PAGE]) che contiene inizialmente una #set_colour(olive, [tabella di una riga e cinque colonne. Ogni cella contiene il titolo di un brano e l'immagine dell'album]) da cui proviene. #set_colour(olive, [I brani sono ordinati da sinistra a destra per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene]). #set_colour(olive, [Se la playlist contiene più di cinque brani, sono disponibili comandi per #set_colour(maroon, [vedere il precedente e successivo gruppo di brani])]). Se la pagina PLAYLIST mostra il primo gruppo e ne esistono altri successivi nell'ordinamento, #set_colour(maroon, [compare a destra della riga]) #set_colour(olive, [il bottone SUCCESSIVI]), #set_colour(maroon, [che permette di vedere il gruppo successivo]). Se la pagina PLAYLIST mostra l'ultimo gruppo e ne esistono altri precedenti nell'ordinamento, #set_colour(maroon, [compare a sinistra della riga]) #set_colour(olive, [il bottone PRECEDENTI]), #set_colour(maroon, [che permette di vedere i cinque brani precedenti]). Se la pagina PLAYLIST mostra un blocco ed esistono sia precedenti sia successivi, compare a destra della riga il bottone SUCCESSIVI e a sinistra il bottone PRECEDENTI. \
La pagina PLAYLIST contiene anche un #set_colour(olive, [FORM che consente di]) #set_colour(blue, [selezionare e AGGIUNGERE uno o più BRANI alla playlist corrente]), se non già presente nella playlist. Tale form #set_colour(olive, [presenta i brani da scegliere nello stesso modo del form usato per creare una playlist]). #set_colour(blue, [A seguito dell'aggiunta di un brano alla playlist corrente]), #set_colour(maroon, [l'applicazione visualizza nuovamente la pagina a partire dal primo blocco della playlist]). \
Quando l'utente #set_colour(blue, [seleziona il titolo di un brano]), la pagina #set_colour(red, [PLAYER]) mostra tutti #set_colour(olive, [i dati del brano scelto]) e il #set_colour(olive, [player audio]) per la riproduzione del brano.

Legenda:
- #set_colour(red, [Pagine])\;
- #set_colour(olive, [Componenti])\;
- #set_colour(blue, [Eventi])\;
- #set_colour(maroon, [Azioni]).

=== Aggiunta alle specifiche

- Funzione di logout, accessibile tramite un pulsante dalle pagine di home, playlist e canzone;
- Funzione per tornare alla homepage, accessibile tramite un pulsante dalle pagine di playlist e canzone;
- Funzione per tornare alla pagina della playlist originale, accessibile tramite un link dalla pagina della canzone;
- Messaggio di "benvenuto" quando l'utente è nella home page;
- Nella pagina della playlist viene mostrata la data in cui è stata creata;
- Possibilità di creare una playlist senza brani;
- Istruzioni sul creare una playlist nella homepage se l'utente non ha playlist associate;
- Istruzioni sull'aggiungere brani alla playlist se vuota nella pagina della playlist;
- Istruzioni sul caricare canzoni nella pagina della playlist se l'utente o ha aggiunto tutti i suoi brani alla playlist o non ha brani associati.

=== Diagramma IFML

#figure(image("IFML Diagrams/IFML Diagram HTML.png", width: 100%))

#pagebreak()

=== Componenti e viste

1. *Beans*

#figure(image("UML Diagrams/beans.svg"))

Tutti gli attributi sono riconducibili al diagramma ER del database (tranne per la tabella `playlist_contents`, che è stata incorporata dentro l'oggetto `Playlist` per convenienza), mentre i metodi sono i soliti getter e setter di Java.

2. *DAO*

#figure(image("UML Diagrams/daos/GenreDAO.svg"))

- `getGenres()`: ritorna una lista dei generi come stringhe.

#figure(image("UML Diagrams/daos/PlaylistDAO.svg"))

- `getPlaylists(int userId)`: ritorna una lista di `Playlist` create dallo user associato all'assegnato `userId`. Gli oggetti `Playlist` hanno l'attributo `songs = null`, dato che questa funzione viene chiamata solo per riempire la lista di playlist nella homepage;
- `getFullPlaylist(int playlistId)`: ritorna la `Playlist` con l'id dato con tutte le informazioni associate (compreso l'elenco di canzoni associate);
- `insertPlaylist(int userId, String title, List<Integer> songsId)`: crea una nuova playlist con le informazioni date e "oggi" comme data di creazione;
- `addSongsToPlaylist(int playlistId, List<Integer> songsId)`: aggiunge la coppia (playlistId, songId) alla tabella `playlist_contents` per ogni id nella lista `songsId`;
- `getPlaylistId(int userId, String title)`: ritorna l'id della playlist che ha associati lo user id e il titolo passati;
- `getUserId(int playlistId)`: ritorna l'id dello user che ha creato la playlist, o $-1$ altrimenti.

#figure(image("UML Diagrams/daos/SongDAO.svg"))

- `getAllSongsFromUserId(int userId)`: ritorna una lista di tutte le canzoni associate allo user dato, ordinate per interprete e anno, o `null` se non ne sono state trovate;
- `getAllSongsFromPlaylist(int playlistId)`: ritorna una lista di tutte le canzoni associate all'id della playlist dato, ordinate per interprete e anno, o `null` se non ne sono state trovate;
- `getSongListFromResultSet(ResultSet resultSet)`: metodo che estrare le canzoni dal set dato (se vuoto, ritorna `null`);
- `insertSong(int userId, String title, String imageFileName, String albumTitle, String performer, int year, String genre, String musicFileName)`: aggiunge la canzone alla tabella `songs`;
- `getSong(int songId)`: ritorna un oggetto `Song` dato l'id della canzone;
- `getSongsNotInPlaylist(int userId, int playlistId)`: ritorna una lista di tutte le canzoni associate al dato user che non appartengono alla data playlist;
- `getSongsIdFromUserId(int userId)`: ritorna una lista di tutti gli id delle canzoni associate al dato user;
- `getSongFromResultSet(ResultSet resultSet)`: estrae un'oggetto `Song` dal dato result set.

#figure(image("UML Diagrams/daos/UserDAO.svg"))

- `checkLogin(String username, String password)`: controlla nel database se un utente con i dati username e password esiste: in caso affermativo, ritorna un oggetto `User` con le informazioni dell'utente, `null` altrimenti.

3. *Controllers*

- `AddSongs`;
- `CheckLogin`;
- `CreatePlaylist`;
- `GetFile`;
- `GoToHomepage`;
- `GoToPlaylist`;
- `GoToSong`;
- `Logout`;
- `UploadSong`.

4. *Utils*

- `getConnection(ServletContext context)`: dato il contesto della servlet, inizializza e restituisce la connessione al database.

5. *Templates*

- `login.html` (welcome-file);
- `homepage.html`;
- `playlist.html`;
- `song.html`;

#pagebreak()

=== Sequence diagrams

*Login*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "login.html")
      _par("b", display-name: "CheckLogin")
      _par("c", display-name: "UserDAO")
      _par("d", display-name: "Session")
      _par("e", display-name: "GoToHomepage")

      _seq(
        "a",
        "b",
        comment: [doPost\
          username, password],
        enable-dst: true,
      )
      _seq("b", "c", comment: `new UserDAO()`, enable-dst: true)
      _seq("c", "b", comment: `checkLogin(username, password)`, disable-src: true)
      _alt(
        "User not found in db",
        {
          _seq("b", "a", comment: [[`user == null`] redirect])
        },
        "User found in db",
        {
          _seq("b", "d", comment: [[`user != null`] `setAttribute("user", user)`])
          _seq("b", "e", comment: [[`user != null`] redirect], disable-src: true)
        },
      )
    }),
  ),
)

Dopo che l'utente ha inserito le credenziali nel form e l'ha inviato, la servlet `CheckLogin` controlla, tramite `UserDAO`, se un utente con quel username e password esiste nel database: in caso affermativo, salva l'oggetto `user` nella sessione e reindirizza l'utente verso `GoToHomepage`; se l'utente non viene trovato, il DAO ritorna `null` e viene ricaricato `login.html`.

*Controllare l'user*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "/...")
      _par("b", display-name: "Request")
      _par("c", display-name: "Session")
      _par("d", display-name: "login.html")

      _seq("[", "a", comment: "doGet/doPost", enable-dst: true)
      _seq("a", "b", comment: [`getSession()`], enable-dst: true)
      _seq("b", "a", comment: `session`, disable-src: true)
      _seq("a", "c", comment: [[`!session.isNew()`] `getAttribute(user)`], enable-dst: true)
      _seq("c", "a", comment: "user", disable-src: true)
      _seq("a", "d", comment: [`[session.isNew() || user == null]` redirect])
      _seq("a", "]", comment: [[`user != null`] `methodY()`/forward/redirect], disable-src: true)
    }),
  ),
)

Questo controllo viene fatto all'inizio di ogni servlet da qui in poi, ed è stato riportato separatamente per sintesi. Quando l'utente tenta di accedere a una servlet, questa controlla che la sessione non sia "nuova", e richiede l'attributo `user`. Se la sessione è nuova o l'`user` è `null`, l'utente viene indirizzato alla pagina di login, altrimenti la servlet procede nel suo compito.

#pagebreak()

*Tornare/andare alla homepage*

#figure(
  scale(
    90%,
    diagram({
      _par("a", display-name: "GoToHomepage")
      _par("b", display-name: "PlaylistDAO")
      _par("c", display-name: "GenreDAO")
      _par("d", display-name: "SongDAO")
      _par("e", display-name: "Context")
      _par("f", display-name: "TemplateEngine")

      _seq("[", "a", comment: "Redirect", enable-dst: true)
      _seq("a", "b", comment: [`new PlaylistDAO()`], enable-dst: true)
      _seq("b", "a", comment: [`getPlaylists(session.user.getId())`], disable-src: true)
      // _seq("b", "a", comment: "playlists", disable-src: true)
      _seq("a", "c", comment: [`new GenreDAO()`], enable-dst: true)
      _seq("c", "a", comment: [`getGenres()`], disable-src: true)
      // _seq("c", "a", comment: "genres", disable-src: true)
      _seq("a", "d", comment: [`new SongDAO()`], enable-dst: true)
      _seq("d", "a", comment: [`getAllSongsFromUserID(session.user.getId())`], disable-src: true)
      // _seq("d", "a", comment: "songs", disable-src: true)
      _seq("a", "e", comment: [`setVariable(playlists)`], enable-dst: true)
      _seq("a", "e", comment: [`setVariable(genres)`])
      _seq("a", "e", comment: [`setVariable(songs)`], disable-dst: true)
      _seq("a", "f", comment: [`process("homepage.html", Context, ...)`], disable-src: true)
    }),
  ),
)

Quando l'utente fa il log-in o ritorna alla homepage tramite l'apposito pulsante, viene chiamata la servlet `GoToHomepage`, che richiede la lista di playlist dell'utente dalla `PlaylistDAO`, i generi da `GenreDAO` e l'elenco delle canzoni dell'utente dal `SongDAO`. Questi vengono poi inseriti nel contesto e il template engine carica la pagina con le informazioni necessarie:

- Dalla sessione recupera lo user e mette il suo nome e cognome nel messaggio di benvenuto;
- Se la lista di playlist è vuota, viene renderizzato un messaggio che consiglia all'utente di usare il form apposito per creare una playlist. Se invece l'utente ha già creato delle playlist, viene renderizzata una tabella con il nome delle playlist (che serve da link per chiamare la servlet `GoToPlaylist`) e la sua data di creazione;
- I generi vengono caricati in un menu a tendina nel form per caricare una nuova canzone;
- Se la lista di canzoni è vuota, viene renderizzato un messaggio che consiglia all'utente di usare il form apposito per caricare un brano; altrimenti tutte le canzoni vengono renderizzati come opzioni per creare una nuova playlist. In entrambi i casi, viene renderizzato la casella di testo per inserire il nome della nuova playlist.

*Logout*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "Logout")
      _par("b", display-name: "Session")
      _par("c", display-name: "login.html")

      _seq("[", "a", comment: "doGet/doPost", enable-dst: true)
      _seq("a", "b", comment: [[`session != null`] `invalidate`])
      _seq("a", "c", comment: "redirect", disable-src: true)
    }),
  ),
)

Quando l'utente clicca l'apposito pulsante di logout, viene chiamata la servlet `Logout`, che invalida la sessione (se non è già nulla) e reindirizza l'utente alla pagina di login.

- *Caricare una canzone*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "UploadSong")
      _par("b", display-name: "SongDAO")
      _par("c", display-name: "homepage.html")
      _par("d", display-name: "localStorage")

      _seq("[", "a", comment: "doPost", enable-dst: true)
      _note(
        "left",
        [\ /UploadSong
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
      _seq("a", "b", comment: [`new SongDAO()`], enable-dst: true)
      _alt(
        "Invalid form",
        {
          _seq(
            "a",
            "c",
            comment: [[at least one field is invalid]\ `redirect`],
          )
        },
        "Valid form",
        {
          _seq(
            "a",
            "b",
            comment: [`insertSong(...)`],
            disable-dst: true,
          )
          _seq(
            "a",
            "d",
            comment: [`Files.copy(image_file,`\ `ServletContext.musicPath + user.getId() + image_file_name)`],
            enable-dst: true,
          )
          _seq(
            "a",
            "d",
            comment: [`Files.copy(music_file,`\ `ServletContext.musicPath + user.getId() + music_file_name)`],
            disable-dst: true,
          )
          _seq("a", "c", comment: [`redirect`], disable-src: true)
        },
      )
    }),
  ),
)

Quando l'utente invia il form per creare una canzone (tutti i campi sono `required`) viene controllato che i file d'immagine dell'album e musicale non sia nulli o vuoti e che siano del tipo giusto. Successivamente, se tutto il resto degli attributi è valido (non sono nulli e l'anno è positivo e non nel futuro) viene aggiornato il database e vengono copiati i file nell'apposita cartella dell'utente. Infine, l'utente viene reindirizzato alla homepage.

#pagebreak()

- *Creare una playlist*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "CreatePlaylist")
      _par("b", display-name: "PlaylistDAO")
      _par("c", display-name: "SongDAO")
      _par("d", display-name: "homepage.html")

      _seq("[", "a", comment: "doPost", enable-dst: true)
      _note(
        "left",
        pos: "a",
        [\ /CreatePlaylist
          - title;
          - songs id.
          From: homepage.html],
      )
      _seq("a", "b", comment: [`new PlaylistDAO()`], enable-dst: true)
      _seq("a", "c", comment: [`new songDAO()`], enable-dst: true)
      _alt(
        "Invalid title",
        {
          _seq("a", "d", comment: [[`title == null`] `redirect`])
        },
        "Valid title",
        {
          _seq("c", "a", comment: [`getSongsIdFromUserId(session.user.getId())`], disable-src: true)
          // _seq("c", "a", comment: [`userSongsId`], disable-src: true)
          _loop(
            "songId : userSongsId",
            {
              _seq("a", "a", comment: [[`request.songId != null`]\ `songs.add(songId)`])
            },
          )
          _seq("a", "b", comment: [`insertPlaylist(`\ `session.user.getId(), title, songs)`], disable-dst: true)
          _seq("a", "d", comment: [`redirect`], disable-src: true)
        },
      )
    }),
  ),
)

Quando l'utente invia il form per creare una nuova playlist (il campo del titolo è `required`) viene controllato che il titolo non sia nullo. Viene poi chiamato il `SongDAO` che restituisce una lista degli id delle canzoni dell'utente, e controlla quali tra questi si trova nella richiesta: se viene trovato, viene aggiunto alla lista di canzoni da aggiungere alla playlist. Una volta terminato questo controllo, il `PlaylistDAO` crea la nuova playlist e l'utente è reindirizzato alla homepage.

#pagebreak()

*Recuperare un file*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "GetFile")
      _par("b", display-name: "Response")

      _seq("[", "a", comment: "doGet", enable-dst: true)
      _note("left", pos: "a", [From: playlist.html,\ song.html])
      _seq("a", "b", comment: [`getParameter("filename")`], enable-dst: true)
      _seq("b", "a", comment: "filename")
      _seq("a", "a", comment: [`new File(folderPath + user.getId(), filename)`])
      _alt(
        "File not found",
        {
          _seq(
            "a",
            "b",
            comment: [[`!file.exists() || file.isDirectory()`]\ `sendError(SC_NOT_FOUND)`],
          )
        },
        "File found",
        {
          _seq("a", "b", comment: [`setHeader(...)`])
          _seq(
            "a",
            "b",
            comment: [`Files.copy(file.toPath(), response.getOutputStream())`],
            disable-dst: true,
            disable-src: true,
          )
        },
      )
    }),
  ),
)

Quando la pagina web deve renderizzare un contenuto multimediale, chiama questa servlet, che cerca il file richiesto nella cartella dell'utente. Se non viene trovato, manda un errore, altrimenti renderizza il file tramite l'output stream.

#pagebreak()

*Andare alla pagina della playlist*

#figure(
  scale(
    95%,
    diagram({
      _par("a", display-name: "GoToPlaylist")
      _par("b", display-name: "PlaylistDAO")
      _par("c", display-name: "SongDAO")
      _par("d", display-name: "WebContext")
      _par("e", display-name: "TemplateEngine")
      _par("f", display-name: "homepage.html")

      _seq("[", "a", comment: [`/Playlist(`\ `playlistId,`\ `songsIndex)`], enable-dst: true)
      _alt(
        "Invalid playlistId",
        {
          _seq(
            "a",
            "f",
            comment: [[`playlistId nan || playlistId <= 0 || songsIndex < 0`] `redirect`],
            enable-dst: true,
          )
        },
        "Valid playlistId",
        {
          _seq("a", "a", comment: [[`songsIndex nan`]\ `songsIndex = 0`])
          _seq("a", "b", comment: [`new PlaylistDAO()`], enable-dst: true)
          _seq("b", "a", comment: [`getFullPlaylist(`\ `playlistid)`], disable-src: true)
          _alt(
            "Wrong user",
            {
              _seq("a", "f", comment: [[`currPlaylist.getUserId() != session.user.getId()`] `redirect`])
            },
            "songsIndex overflows the playlist",
            {
              _seq("a", "f", comment: [[`songsIndex oob`] `redirect`], disable-dst: true)
            },
            "Ok",
            {
              _seq("a", "a", comment: [`currSongs =`\ `visible songs`])
              _seq("a", "c", comment: [`new SongDAO()`], enable-dst: true)
              _seq(
                "c",
                "a",
                comment: [`getSongsNotInPlaylist(`\ `session.user.getId(),`\ `playlistId)`],
                disable-src: true,
              )
              _seq("a", "d", comment: [`setVariable(currPlaylist)`], enable-dst: true)
              _seq("a", "d", comment: [`setVariable(currSongs)`])
              _seq("a", "d", comment: [`setVariable(songsBefore)`])
              _seq("a", "d", comment: [`setVariable(songsAfter)`])
              _seq("a", "d", comment: [`setVariable(playlistId)`])
              _seq("a", "d", comment: [`setVariable(songsIndex)`])
              _seq("a", "d", comment: [`setVariable(otherSongs)`], disable-dst: true)
              _seq("a", "e", comment: [`process("playlist.html", WebContext, ...)`], disable-src: true)
            },
          )
        },
      )
    }),
  ),
)

Quando l'utente clicca sul nome di una playlist o clicca l'apposito pulsante nella pagina di una canzone, viene reindirizzato a questa pagina. Se l'id della playlist non è valido o è associato a una playlist non dell'utente corrente, viene reindirizzato alla homepage. Se l'indice non è un numero, gli viene dato il valore di default `0`, altrimenti se è "out of bounds" o negativo l'utente viene reindirizzato alla homepage. Se tutti i controlli hanno esito positivo, viene recuperata la playlist dalla `PlaylistDAO` e i brani dell'utente che non appartengono a quella playlist dal `SongDAO`. Dai brani della playlist vengono selezionati quelli "puntati" dall'indice (es. `songsIndex = 0` $=>$ `currSongs = [song0, song1, song2, song3, song4]`) e vengono assegnati ai valori booleani `songsBefore` e `songsAfter` valori appropriati in base all'indice. Tutte le variabili vengono poi caricate nel contesto e il template engine carica la pagina `playlist.html` con le informazioni necessarie:

- Dalla playlist recupera il titolo e la data di creazione, che vengono mostrate a inizio pagina;
- Se la playlist è vuota, viene renderizzato un messaggio che consiglia di usare il form apposito per caricare brani alla playlist; altrimenti, vengono renderizzati i brani in base all'indice, disposti in una tabella di una riga e 5 colonne. Ogni cella ha il titolo del brano (che funge da link per la relativa pagina) e l'immagine dell'album (caricata tramite una chiamata alla `GetFile` servlet);
- I pulsanti per vedere i brani precedenti/successivi vengono renderizzati in base alle variabili:
  - Se l'indice è 0, allora `songsBefore` è falso, e il pulsante non viene renderizzato; viceversa se l'indice è 0;
  - Se l'indice punta all'ultimo "gruppo di 5", allora `songsAfter` è falso, e il pulsante non viene renderizzato; viceversa se l'indice punta a un altro gruppo;
- Se la playlist contiene già tutte le canzoni dell'utente, viene renderizzato un messaggio che consiglia di caricare nuovi brani dalla homepage. Altrimenti, è presente un form da cui è possibile selezionare tutte le canzoni non già presenti nella playlist per aggiungerle.

#pagebreak()

*Aggiungere canzoni alla playlist*

#figure(
  scale(
    95%,
    diagram({
      _par("a", display-name: "AddSongs")
      _par("b", display-name: "PlaylistDAO")
      _par("c", display-name: "SongDAO")
      _par("d", display-name: "GoToPlaylist")
      _par("e", display-name: "homepage.html")

      _seq("[", "a", comment: "doPost", enable-dst: true)
      _note(
        "left",
        pos: "a",
        [\ /AddSongs
          - playlistId
          - songs id
          From: playlist.html],
      )
      _seq("a", "b", comment: [`new PlaylistDAO`], enable-dst: true)
      _seq("a", "c", comment: [`new SongDAO`], enable-dst: true)
      _alt(
        "Invalid playlistId",
        {
          _seq("a", "e", comment: [[`playlistId nan`] `redirect`], enable-dst: true)
        },
        "Valid playlistId",
        {
          _seq("b", "a", comment: [`getUserId(playlistId)`])
          _alt(
            "Wrong user",
            {
              _seq("a", "e", comment: [[`session.user.getId() != userId`] `redirect`], disable-dst: true)
            },
            "Correct user",
            {
              _seq("a", "c", comment: [`getSongsIdFromUserId(session.user.getId())`])
              _seq("c", "a", comment: [`userSongsId`], disable-src: true)
              _seq("a", "a", comment: [[`request.songId != null`]\ `songs.add(songId)`])
              _seq("a", "b", comment: [`addSongsToPlaylist(`\ `playlistId, songs)`], disable-dst: true)
              _seq("a", "d", comment: [`redirect /Playlist?playlistId`], disable-src: true)
            },
          )
        },
      )
    }),
  ),
)

Quando l'utente invia il form per aggiungere brani alla playlist, viene controllato che il playlist id della request sia valido: in caso negativo, l'utente viene reindirizzato alla homepage (idem se l'id è di una playlist non dell'attuale utente). Se l'id è valido si recupera la lista degli id dei brani dell'utente e viene controllata la request come descritto nel sequence diagram "Creare una playlist": poi la playlist viene aggiornata tramite il `PlaylistDAO` e l'utente viene reindirizzato alla pagina della playlist.

#pagebreak()

*Andare alla pagina della canzone*

#figure(
  scale(
    100%,
    diagram({
      _par("a", display-name: "GoToSong")
      _par("b", display-name: "SongDAO")
      _par("c", display-name: "WebContext")
      _par("d", display-name: "TemplateEngine")
      _par("e", display-name: "homepage.html")

      _seq("[", "a", comment: [`/Song(`\ `playlistId,`\ `songsIndex,`\ `songId)`], enable-dst: true)
      _alt(
        "Invalid playlistId",
        {
          _seq("a", "e", comment: [[`playlistId nan || songsIndex nan || songId nan`] `redirect`], enable-dst: true)
        },
        "Valid playlistId",
        {
          _seq("a", "b", comment: [`new SongDAO()`], enable-dst: true)
          _seq("b", "a", comment: [`getSong(songId)`], disable-src: true)
          // _seq("b", "a", comment: "currSong", disable-src: true)
          _alt(
            "Song not found or wrong user",
            {
              _seq(
                "a",
                "e",
                comment: [[`currSong == null || currSong.getId() != session.user.getId()`] `redirect`],
                disable-dst: true,
              )
            },
            "Ok",
            {
              _seq("a", "c", comment: [`setVariable(playlistId)`], enable-dst: true)
              _seq("a", "c", comment: [`setVariable(songsIndex)`])
              _seq("a", "c", comment: [`setVariable(currSong)`], disable-dst: true)
              _seq("a", "d", comment: [`process("song.html", WebContext, ...)`], disable-src: true)
            },
          )
        },
      )
    }),
  ),
)

Quando l'utente clicca sul titolo di una canzone, viene reindirizzato a questa servlet. Se l'id della plalist, l'indice o l'id del brano non sono numeri, l'utente viene reindirizzato alla homepage. `SongDAO` viene chiamato per controllare che una canzone con quell'id esista e che appartenga allo user corrente: in caso negativo, viene reindirizzato alla homepage. Se tutti i controlli vanno bene, vengono salvati i dati nel contesto e caricata `song.html`:
- Tutte le informazioni della canzone vengono renderizzate, insieme alla foto associata e al suo lettore musicale;
- L'id della playlist e l'indice servono quando l'utente usa il pulsante per tornare alla playlist: così facendo, ritorna alla pagina dalla quale ha cliccato la canzone.

#pagebreak()
