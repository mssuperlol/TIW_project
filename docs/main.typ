#set text(
  lang: "it",
  hyphenate: true,
  font: "New Computer Modern",
)

#set page(
  paper: "a4",
  margin: (x: 2cm, y: 2cm),
  numbering: "1",
  number-align: center,
)

#set list(indent: 0.5cm)

#set figure(numbering: none)

#text(
  size: 16pt,
  [#align(horizon + center)[
      #heading(level: 1, "Progetto di Tecnologie Informatiche per il Web", outlined: false)
      #v(1em)
      Michele Sangaletti
    ]
  ],
)

#set heading(numbering: "1.a.")

#pagebreak()

#outline(indent: 1em)

#pagebreak()

#include "Submission.typ"
#include "Html doc.typ"
#include "Javascript doc.typ"

