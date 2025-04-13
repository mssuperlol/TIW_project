#set text(lang: "it")

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
)
#set page(numbering: "1", number-align: center)

#let set_colour(colour, name) = {
  text(colour)[#name]
}

= Esercizio 2: playlist musicale

== Versione HTML pura

Un'applicazione web consente la gestione di una playlist di brani musicali.

#underline[Playlist e brani sono personali] di ogni utente e non condivisi. Ogni *utente* ha *username*, *password*, *nome* e *cognome*. Ogni *brano musicale* è memorizzato nella base di dati mediante un *titolo*, l‘*immagine* e il *titolo dell'album* da cui il brano è tratto, il *nome dell'interprete* (singolo o gruppo) dell'album, l'*anno di pubblicazione* dell'album, il *genere musicale* (#underline[si supponga che i generi siano prefissati]) e il *file musicale*. Non è richiesto di memorizzare l'ordine con cui i brani compaiono nell'album a cui appartengono. Si ipotizzi che #underline[un brano possa appartenere a un solo album] (no compilation). L'utente, previo login, può creare brani mediante il caricamento dei dati relativi e raggrupparli in playlist. Una playlist è un insieme di brani scelti tra quelli caricati dallo stesso utente. #underline[Lo stesso brano può essere inserito in più playlist]. Una *playlist* ha un *titolo* e una *data di creazione* ed *è associata al suo creatore*.

A seguito del #set_colour(red, [LOGIN]), l'utente accede all'#set_colour(red, [HOME PAGE]) che presenta l'#set_colour(green, [elenco delle proprie playlist]), ordinate per data di creazione decrescente, un #set_colour(green, [#set_colour(red, [FORM per caricare un BRANO]) con tutti i dati relativi]) e #set_colour(green, [un form per creare una nuova playlist]). \
Il #set_colour(red, [FORM per la creazione di una nuova PLAYLIST]) mostra l'#set_colour(green, [elenco dei brani dell'utente]) ordinati per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene. Tramite il form è possibile selezionare #underline[uno o più brani] da includere. \
Quando l'utente #set_colour(blue, [clicca su una playlist nell'HOME PAGE]), appare la pagina #set_colour(red, [PLAYLIST PAGE]) che contiene inizialmente una #set_colour(green, [tabella di una riga e cinque colonne. Ogni cella contiene il titolo di un brano e l'immagine dell'album]) da cui proviene. I brani sono ordinati da sinistra a destra per ordine alfabetico crescente dell'autore o gruppo e per data crescente di pubblicazione dell'album a cui il brano appartiene. #set_colour(green, [Se la playlist contiene più di cinque brani, sono disponibili comandi per vedere il precedente e successivo gruppo di brani]). Se la pagina PLAYLIST mostra il primo gruppo e ne esistono altri successivi nell'ordinamento, compare a destra della riga il bottone SUCCESSIVI, che permette di vedere il gruppo successivo. Se la pagina PLAYLIST mostra l'ultimo gruppo e ne esistono altri precedenti nell'ordinamento, compare a sinistra della riga il bottone PRECEDENTI, che permette di vedere i cinque brani precedenti. Se la pagina PLAYLIST mostra un blocco ed esistono sia precedenti sia successivi, compare a destra della riga il bottone SUCCESSIVI e a sinistra il bottone PRECEDENTI. \
La pagina PLAYLIST contiene anche un #set_colour(red, [FORM che consente di selezionare e AGGIUNGERE uno o più BRANI alla playlist corrente]), se non già presente nella playlist. Tale form #set_colour(green, [presenta i brani da scegliere nello stesso modo del form usato per creare una playlist]). #set_colour(blue, [A seguito dell'aggiunta di un brano alla playlist corrente]), l'applicazione visualizza nuovamente la pagina a partire dal primo blocco della playlist. \
Quando l'utente #set_colour(blue, [seleziona il titolo di un brano]), la pagina #set_colour(red, [PLAYER]) mostra tutti #set_colour(green, [i dati del brano scelto]) e il #set_colour(green, [player audio]) per la riproduzione del brano.

#pagebreak()

== Versione con JavaScript

Si realizzi un'applicazione client server web che modifica le specifiche precedenti come segue:
- Dopo il login dell'utente, l'intera applicazione è realizzata con un'unica pagina;
- Ogni interazione dell'utente è gestita senza ricaricare completamente la pagina, ma produce l'invocazione asincrona del server e l'eventuale modifica del contenuto da aggiornare a seguito dell'evento;
- L'evento di visualizzazione del blocco precedente/successivo è gestito a lato client senza generare una richiesta al server;
- L'applicazione deve consentire all'utente di riordinare le playlist con un criterio personalizzato diverso da quello di default. Dalla HOME con un link associato a ogni playlist si accede a una finestra modale #set_colour(red, [RIORDINO]), che mostra #set_colour(green, [la lista completa dei brani della playlist ordinati secondo il criterio corrente]) (personalizzato o di default). L'utente può #set_colour(blue, [trascinare il titolo di un brano nell'elenco e di collocarlo in una posizione diversa]) per realizzare l'ordinamento che desidera, senza invocare il server. Quando l'utente ha raggiunto l'ordinamento desiderato, usa un bottone "salva ordinamento", per memorizzare la sequenza sul server. Ai successivi accessi, l'ordinamento personalizzato è usato al posto di quello di default. Un brano aggiunto a una playlist con ordinamento personalizzato è inserito nell'ultima posizione.

