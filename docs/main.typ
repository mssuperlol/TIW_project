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
  #heading(level: 1, "Progetto di Tecnologie Informatiche per il Web", outlined: false)
  #v(1em)
  Michele Sangaletti
]

#set heading(numbering: "1.a.")

#pagebreak()

#outline(indent: 1em)

#pagebreak()

#include "Submission.typ"
#include "Html doc.typ"
#include "Javascript doc.typ"
