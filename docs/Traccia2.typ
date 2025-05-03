#set text(lang: "it")

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
)
#set page(numbering: "1", number-align: center)

#let set_colour(colour, name) = {
  text(colour)[#name]
}

Progetto di Tecnologie Informatiche per il Web

Michele Sangaletti

//TODO formattazione e info tipo codice persona, ...

#pagebreak()

#outline(indent: 1em)

#pagebreak()

= Esercizio 2: playlist musicale

== Versione HTML pura

Un'applicazione web consente la gestione di una playlist di brani musicali.

#underline[Playlist e brani sono personali] di ogni utente e non condivisi. Ogni *utente* ha _username_, _password_, _nome_ e _cognome_. Ogni *brano musicale* è memorizzato nella base di dati mediante un _titolo_, l'_immagine_ e il _titolo dell'album_ da cui il brano è tratto, il _nome dell'interprete_ (singolo o gruppo) dell'album, l'_anno di pubblicazione dell'album_, il _genere musicale_ (#underline[si supponga che i generi siano prefissati]) e il _file musicale_. Non è richiesto di memorizzare l'ordine con cui i brani compaiono nell'album a cui appartengono. Si ipotizzi che #underline[un brano possa appartenere a un solo album] (no compilation). L'utente, previo login, può creare brani mediante il caricamento dei dati relativi e raggrupparli in playlist. #underline[Una playlist è un insieme di brani scelti tra quelli caricati dallo stesso utente]. #underline[Lo stesso brano può essere inserito in più playlist]. Una *playlist* ha un _titolo_ e una _data di creazione_ ed #underline[è associata al suo creatore].

A seguito del #set_colour(red, [LOGIN]), l'utente accede all'#set_colour(red, [HOME PAGE]) che presenta l'#set_colour(olive, [elenco delle proprie playlist]), ordinate per data di creazione decrescente, un #set_colour(olive, [#set_colour(red, [FORM per caricare un BRANO]) con tutti i dati relativi]) e #set_colour(olive, [un form per creare una nuova playlist]). \
Il #set_colour(red, [FORM per la creazione di una nuova PLAYLIST]) mostra l'#set_colour(olive, [elenco dei brani dell'utente]) #set_colour(maroon, [ordinati per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene]). Tramite il form è possibile #set_colour(blue, [selezionare uno o più brani da includere]). \
Quando l'utente #set_colour(blue, [clicca su una playlist nell'HOME PAGE]), appare la pagina #set_colour(red, [PLAYLIST PAGE]) che contiene inizialmente una #set_colour(olive, [tabella di una riga e cinque colonne. Ogni cella contiene il titolo di un brano e l'immagine dell'album]) da cui proviene. #set_colour(maroon, [I brani sono ordinati da sinistra a destra per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene]). #set_colour(olive, [Se la playlist contiene più di cinque brani, sono disponibili comandi per vedere il precedente e successivo gruppo di brani]). Se la pagina PLAYLIST mostra il primo gruppo e ne esistono altri successivi nell'ordinamento, compare a destra della riga #set_colour(green, [il bottone SUCCESSIVI]), #set_colour(maroon, [che permette di vedere il gruppo successivo]). Se la pagina PLAYLIST mostra l'ultimo gruppo e ne esistono altri precedenti nell'ordinamento, compare a sinistra della riga #set_colour(green, [il bottone PRECEDENTI]), #set_colour(maroon, [che permette di vedere i cinque brani precedenti]). Se la pagina PLAYLIST mostra un blocco ed esistono sia precedenti sia successivi, compare a destra della riga il bottone SUCCESSIVI e a sinistra il bottone PRECEDENTI. \
La pagina PLAYLIST contiene anche un #set_colour(red, [FORM che consente di selezionare e AGGIUNGERE uno o più BRANI alla playlist corrente]), se non già presente nella playlist. Tale form #set_colour(olive, [presenta i brani da scegliere nello stesso modo del form usato per creare una playlist]). #set_colour(blue, [A seguito dell'aggiunta di un brano alla playlist corrente]), #set_colour(maroon, [l'applicazione visualizza nuovamente la pagina a partire dal primo blocco della playlist]). \
Quando l'utente #set_colour(blue, [seleziona il titolo di un brano]), la pagina #set_colour(red, [PLAYER]) mostra tutti #set_colour(olive, [i dati del brano scelto]) e il #set_colour(olive, [player audio]) per la riproduzione del brano.

#pagebreak()

== Versione con JavaScript

Si realizzi un'applicazione client server web che modifica le specifiche precedenti come segue:
- Dopo il login dell'utente, l'intera applicazione è realizzata con un'unica pagina;
- Ogni interazione dell'utente è gestita senza ricaricare completamente la pagina, ma produce l'invocazione asincrona del server e l'eventuale modifica del contenuto da aggiornare a seguito dell'evento;
- L'evento di visualizzazione del blocco precedente/successivo è gestito a lato client senza generare una richiesta al server;
- L'applicazione deve consentire all'utente di riordinare le playlist con un criterio personalizzato diverso da quello di default. Dalla HOME con un link associato a ogni playlist si accede a una finestra modale #set_colour(red, [RIORDINO]), che mostra #set_colour(olive, [la lista completa dei brani della playlist ordinati secondo il criterio corrente]) (personalizzato o di default). L'utente può #set_colour(blue, [trascinare il titolo di un brano nell'elenco e di collocarlo in una posizione diversa]) per realizzare l'ordinamento che desidera, senza invocare il server. Quando l'utente ha raggiunto l'ordinamento desiderato, usa un bottone "salva ordinamento", per memorizzare la sequenza sul server. Ai successivi accessi, l'ordinamento personalizzato è usato al posto di quello di default. Un brano aggiunto a una playlist con ordinamento personalizzato è inserito nell'ultima posizione.

#pagebreak()

= Analisi requisiti dati

Legenda:
- *Entità*;
- _Attributi_;
- #underline[Relazioni].

== Design database

//TODO fixa l'immagine
#figure(image("ER Diagram.png", width: 200%))

```sql
CREATE TABLE prova
```

#pagebreak()

= Analisi requisiti d'applicazione

Legenda:
- #set_colour(red, [Pagine])
- #set_colour(color.olive, [Componenti])
- #set_colour(blue, [Eventi])
- #set_colour(color.maroon, [Azioni])
