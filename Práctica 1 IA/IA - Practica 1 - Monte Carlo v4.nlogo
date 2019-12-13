__includes ["MCTS.nls"]

globals [ matriz-global turno-extra turno ]

to setup

  clear-all
  ask patches [set pcolor white]

  resize-world 0 8 0 1
  set-patch-size 100

  set turno 0

  creaTablero
  representaTablero

  representaTurno

  reset-ticks

end

; Esta función crea el tablero base sobre el que vamos a trabajar
to creaTablero

  let i 1
  let ls [[0 4 4 4 4 4 4][4 4 4 4 4 4 0]]
  ;let ls [[0 1 0 2 0 0 0][0 1 0 0 0 1 0]]
  set matriz-global ls

  ask patches with [pxcor = 0 or pycor = 1][set pcolor brown]
  ask patches with [(pxcor > 0 and pycor = 0) or pxcor = 7][set pcolor rgb 120 65 55]

end

; Esta función representa el estado actual del tablero, para que así sea más visual el estado actual del mismo
to representaTablero

  let i 0
  let ls1 (item 0 matriz-global) ; Línea superior del tablero
  let ls2 (item 1 matriz-global) ; Línea inferior del tablero

  ask turtles [die]

  while [ i < 7 ]
  [
    repeat (item i ls1)[
      crt 1 [
        set xcor (i + (random-float 0.2 * random -2))
        set ycor (1 + (random-float 0.2 * random -2))
        set color blue
        set shape("circle")
        set size 0.25
      ]
    ]
    ask patches with [pxcor = i and pycor = 1][set plabel (item i ls1)]

    repeat (item i ls2)[
      crt 1 [
        set xcor (i + (random-float 0.2 * random -2) + 1)
        set ycor (0 + (random-float 0.2 * random -2))
        set color red
        set shape("circle")
        set size 0.25
      ]
    ]
    ask patches with [pxcor = (i + 1) and pycor = 0][set plabel (item i ls2)]

    set i (i + 1)
  ]

end

to representaTurno

  ifelse(turno = 0)[
    ask patches with [pxcor > 7 and pycor = 0][set pcolor red]
    ask patches with [pxcor > 7 and pycor = 1][set pcolor rgb 0 45 80]
  ]
  [
    ask patches with [pxcor > 7 and pycor = 0][set pcolor rgb 80 0 0]
    ask patches with [pxcor > 7 and pycor = 1][set pcolor blue]
  ]

end

to-report tratamientoJugador0 [i j n xr yr]

    let ls1 (item 0 matriz-global) ; Línea superior del tablero
    let ls2 (item 1 matriz-global) ; Línea inferior del tablero
    let cont 0

    ; Tratamiento para la fila inferior
    while[ i < 7 and cont < n]
    [
      ; Comportamiento normal en una partida
      set ls2 (replace-item i ls2 ((item i ls2) + 1))

      ; Cuando se pone la última semilla pueden ocurrir dos cosas distintas, que caiga dentro de la calaja, por lo que se ganaría un turno extra
      ; o que caiga en una casilla vacía, por lo que capturaría todas las semillas que hubiesen delante
      if(cont = n - 1)[
        if( i = 6 )[ set turno-extra true] ; Si la última semilla cae en la calaja, el jugador obtiene un turno extra
        if ((item i ls2) = 1 and i != 6)[ ; Si la última semilla cae en una casilla vacía, el jugador captura las semillas del jugador contrario y las añade a su calaja
          if((item (i + 1) ls1) > 0)[
            set ls2 (replace-item 6 ls2 ((last ls2) + (item (i + 1) ls1) + 1))
            set ls2 (replace-item i ls2 0)
            set ls1 (replace-item (i + 1) ls1 0)

            print "EL JUGADOR ROJO ROBA A JUGADOR AZUL"
          ]
        ]
      ]

      set i (i + 1)
      set cont (cont + 1)
    ]

    ; Tratamiento para la fila superior
    while[ j > 0 and cont < n]
    [
      set ls1 (replace-item j ls1 ((item j ls1) + 1))
      set j (j - 1)
      set cont (cont + 1)
    ]

    set ls2 (replace-item 6 ls2 (item 6 ls2 + (n - cont)))
    set ls2 (replace-item (xr - 1) ls2 0)
    set matriz-global (list ls1 ls2)

    report true

end

to-report tratamientoJugador1 [i j n xr yr]

    let ls1 (item 0 matriz-global) ; Línea superior del tablero
    let ls2 (item 1 matriz-global) ; Línea inferior del tablero
    let cont 0

  ; Tratamiento para la línea superior
    while[ j >= 0 and cont < n]
    [
      ; Comportamiento normal en una partida
      set ls1 (replace-item j ls1 ((item j ls1) + 1))

      ; Cuando se pone la última semilla pueden ocurrir dos cosas distintas, que caiga dentro de la calaja, por lo que se ganaría un turno extra
      ; o que caiga en una casilla vacía, por lo que capturaría todas las semillas que hubiesen delante
      if(cont = n - 1)[
        if( j = 0 )[ set turno-extra true]
        if((item j ls1) = 1 and j != 0)[
          if((item (j - 1) ls2) > 0)[
            set ls1 (replace-item 0 ls1 ((first ls1) + (item (j - 1) ls2) + 1))
            set ls1 (replace-item j ls1 0)
            set ls2 (replace-item (j - 1) ls2 0)

            print "EL JUGADOR AZUL ROBA A JUGADOR ROJO"
          ]
        ]
      ]

      set j (j - 1)
      set cont (cont + 1)
    ]

    ; Tratamiento para la línea inferior
    while [ i < 6 and cont < n]
    [
      set ls2 (replace-item i ls2 ((item i ls2) + 1))
      set i (i + 1)
      set cont (cont + 1)
    ]

    set ls1 (replace-item 0 ls1 (item 0 ls1 + (n - cont)))
    set ls1 (replace-item xr ls1 0)
    set matriz-global (list ls1 ls2)

    report true

end

to-report aplicaJugada [xr yr jugador]

  let res false
  let ls1 (item 0 matriz-global) ; Línea superior del tablero
  let ls2 (item 1 matriz-global) ; Línea inferior del tablero

  if(jugador = 0 and xr > 0 and xr < 7 and yr = 0)[ ; Jugador1

    ; ls1 = [0 4 4 4 4 4 4]
    ; cor =  0 1 2 3 4 5 6
    ; ls2 = [4 4 4 4 4 4 0]
    ; cor =  1 2 3 4 5 6 7

    let cont 0 ; Un contador
    let n (item (xr - 1) ls2) ; Límite del contador

    let i xr
    let j 6

    set res (tratamientoJugador0 i j n xr yr)

  ]

  if(jugador = 1 and xr > 0 and xr < 7 and yr = 1)[ ; Jugador2

    ; ls1 = [0 4 4 4 4 4 4]
    ; cor =  0 1 2 3 4 5 6
    ; ls2 = [4 4 4 4 4 4 0]
    ; cor =  1 2 3 4 5 6 7

    let cont 0 ; Un contador
    let n (item xr ls1) ; Límite del contador

    let i 0
    let j (xr - 1)

    set res (tratamientoJugador1 i j n xr yr)
  ]

  report res

end

to-report finPartida?

  let res false

  let ls1 (item 0 matriz-global)
  let ls2 (item 1 matriz-global)

  let pj1 sum(ls1)
  let pj2 sum(ls2)

  if( sum(but-first ls1) = 0 or sum(but-last ls2) = 0)[
    print "SE ACABÓ LA PARTIDA"
    ifelse(pj1 > pj2)[ print "EL GANADOR ES EL JUGADOR AZUL" ][ print "EL GANADOR ES EL JUGADOR ROJO" ]
    set res true
  ]

  report res

end


; Con esta función podemos jugar 2 jugadores, 1vs1
to jugar

  set turno-extra false

  let jugado? false

  while[not jugado?]
  [
    if(mouse-down?)[
      set jugado? (aplicaJugada round(mouse-xcor) round(mouse-ycor) turno) ; Jugador2, juega la parte superior
      if(jugado?)[
        set turno ((turno + 1) mod 2)
      ]

    ]
    if(turno-extra)[
      set turno-extra false
      set turno ((turno + 1) mod 2)
      ifelse(turno = 0)[print "TURNO EXTRA PARA EL JUGADOR ROJO"][print "TURNO EXTRA PARA EL JUGADOR AZUL"]
    ]
  ]

  representaTablero
  representaTurno
  if(finPartida?)[stop]
  wait 1.0

end


; Con esta función se puede jugar contra la IA, de forma que la IA es el jugador azul y la persona el rojo
to jugar2

  set turno-extra false
  let jugado? false

  if(turno = 0)[
    if(mouse-down?)[
      set jugado? (aplicaJugada round(mouse-xcor) round(mouse-ycor) turno) ; Jugador2, juega la parte superior
      if(jugado?)[
        set turno ((turno + 1) mod 2)
        representaTablero
        ;representaTurno
        if(finPartida?)[stop]
        wait 0.25
      ]
    ]
    if(turno-extra)[
      set jugado? false
      set turno-extra false
      set turno ((turno + 1) mod 2)
      ifelse(turno = 0)[print "TURNO EXTRA PARA EL JUGADOR ROJO"][print "TURNO EXTRA PARA EL JUGADOR AZUL"]
    ]
  ]

  representaTurno

  if(turno = 1)[
    print "--------------------------------------------IA----------------------------------------------------"
    print "Que calaja tan bonitaa :D\n"
    let m MCTS:UCT (list matriz-global 0) 1000
    print(word "Al final, he decidido repartir las semillas del hueco " m)
    print "--------------------------------------------------------------------------------------------------\n"
    set turno-extra false

    set jugado? (aplicaJugada m 1 turno) ; Jugador2, juega la parte superior
    if(jugado?)[
      set turno ((turno + 1) mod 2)
      representaTablero
      ;representaTurno
      if(finPartida?)[stop]
      wait 1
    ]
    if(turno-extra)[
      representaTurno
      set jugado? false
      set turno-extra false
      set turno ((turno + 1) mod 2)
      ifelse(turno = 0)[print "TURNO EXTRA PARA EL JUGADOR ROJO"][print "TURNO EXTRA PARA EL JUGADOR AZUL"]
    ]
  ]

end

to jugar3

  set turno-extra false
  let jugado? false

  if(turno = 0)[
    print "--------------------------------------------IA ROJA----------------------------------------------------"
    print "Que calaja tan bonitaa :D\n"
    let m MCTS:UCT (list matriz-global 1) 1000
    print(word "Al final, he decidido repartir las semillas del hueco " m)
    print "--------------------------------------------------------------------------------------------------\n"
    set turno-extra false

    set jugado? (aplicaJugada m 0 turno) ; Jugador1, juega la parte inferior
    if(jugado?)[
      set turno ((turno + 1) mod 2)
      representaTablero
      ;representaTurno
      if(finPartida?)[stop]
      wait 1
    ]
    if(turno-extra)[
      representaTurno
      set jugado? false
      set turno-extra false
      set turno ((turno + 1) mod 2)
      ifelse(turno = 0)[print "TURNO EXTRA PARA EL JUGADOR ROJO"][print "TURNO EXTRA PARA EL JUGADOR AZUL"]
    ]
  ]

  representaTurno

  if(turno = 1)[
    print "--------------------------------------------IA AZUL----------------------------------------------------"
    print "Que calaja tan bonitaa :D\n"
    let m MCTS:UCT (list matriz-global 0) 1000
    print(word "Al final, he decidido repartir las semillas del hueco " m)
    print "--------------------------------------------------------------------------------------------------\n"
    set turno-extra false

    set jugado? (aplicaJugada m 1 turno) ; Jugador2, juega la parte superior
    if(jugado?)[
      set turno ((turno + 1) mod 2)
      representaTablero
      ;representaTurno
      if(finPartida?)[stop]
      wait 1
    ]
    if(turno-extra)[
      representaTurno
      set jugado? false
      set turno-extra false
      set turno ((turno + 1) mod 2)
      ifelse(turno = 0)[print "TURNO EXTRA PARA EL JUGADOR ROJO"][print "TURNO EXTRA PARA EL JUGADOR AZUL"]
    ]
  ]

end

;--------------------------------------------MONTE CARLO----------------------------------------------

to-report MCTS:get-content [s]

  report first s

end

to-report MCTS:get-playerJustMoved[s]

  report last s

end

to-report MCTS:create-state[c s]

  report (list c s)

end

; Las reglas que puede aplicar la IA seran aquellas casillas que no estén vacías, ya que no tiene sentido que pueda
; jugar semillas que no existen
to-report MCTS:get-rules[s]

  let c MCTS:get-content s
  let p MCTS:get-playerJustMoved s

  let ls1 (item 0 c) ; Parte superior
  let ls2 (item 1 c) ; Parte inferior

  ifelse p = 0 [
    report filter [x -> item x ls1 != 0](range 1 7)
  ][
    report filter [x -> item (x - 1) ls2 != 0](range 1 7)
  ]

end

to-report MCTS:get-result [s p]

  let c MCTS:get-content s
  let pl MCTS:get-playerJustMoved s

  let ls1 (item 0 c) ; Parte superior
  let ls2 (item 1 c) ; Parte inferior

  if (pl = p and p = 0 and (last ls2) >= 24)[report last ls2]
  if (pl = p and p = 1 and (first ls1) >= 24)[report first ls1]
  report 0

end

; Aplicar una regla no es más que calcular como variaría el tablero después de seleccionar una casilla
to-report MCTS:apply [r s]

  let c MCTS:get-content s
  let p MCTS:get-playerJustMoved s

  let ls1 (item 0 c) ; Parte superior
  let ls2 (item 1 c) ; Parte inferior

  ifelse p = 0 [
    report MCTS:create-state (aplicaJugadaMC r 1 1 c) 1
  ][
    report MCTS:create-state (aplicaJugadaMC r 0 0 c) 0
  ]

end

to-report tratamientoJugador0MC [i j n xr yr tablero]

   let ls1 (item 0 tablero) ; Línea superior del tablero
   let ls2 (item 1 tablero) ; Línea inferior del tablero

   let res []
   let cont 0

  ; Tratamiento para la fila inferior
    while[ i < 7 and cont < n]
    [
      ; Comportamiento normal en una partida
      set ls2 (replace-item i ls2 ((item i ls2) + 1))

      ; Cuando se pone la última semilla pueden ocurrir dos cosas distintas, que caiga dentro de la calaja, por lo que se ganaría un turno extra
      ; o que caiga en una casilla vacía, por lo que capturaría todas las semillas que hubiesen delante
      if(cont = n - 1)[
        if( i = 6 )[ set turno-extra true] ; Si la última semilla cae en la calaja, el jugador obtiene un turno extra
        if ((item i ls2) = 1 and i != 6)[ ; Si la última semilla cae en una casilla vacía, el jugador captura las semillas del jugador contrario y las añade a su calaja
          if((item (i + 1) ls1) > 0)[
            set ls2 (replace-item 6 ls2 ((last ls2) + (item (i + 1) ls1) + 1))
            set ls2 (replace-item i ls2 0)
            set ls1 (replace-item (i + 1) ls1 0)

            ;print "EL JUGADOR ROJO ROBA A JUGADOR AZUL"
          ]
        ]
      ]

      set i (i + 1)
      set cont (cont + 1)
    ]

    ; Tratamiento para la fila superior
    while[ j > 0 and cont < n]
    [
      set ls1 (replace-item j ls1 ((item j ls1) + 1))
      set j (j - 1)
      set cont (cont + 1)
    ]

    set ls2 (replace-item 6 ls2 (item 6 ls2 + (n - cont)))
    set ls2 (replace-item (xr - 1) ls2 0)
    report(list ls1 ls2)

end

to-report tratamientoJugador1MC [i j n xr yr tablero]

   let ls1 (item 0 tablero) ; Línea superior del tablero
   let ls2 (item 1 tablero) ; Línea inferior del tablero

   let res []
   let cont 0

   ; Tratamiento para la línea superior
   while[ j >= 0 and cont < n]
   [
      ; Comportamiento normal en una partida
      set ls1 (replace-item j ls1 ((item j ls1) + 1))

      ; Cuando se pone la última semilla pueden ocurrir dos cosas distintas, que caiga dentro de la calaja, por lo que se ganaría un turno extra
      ; o que caiga en una casilla vacía, por lo que capturaría todas las semillas que hubiesen delante
      if(cont = n - 1)[
        if( j = 0 )[ set turno-extra true]
        if((item j ls1) = 1 and j != 0)[
          if((item (j - 1) ls2) > 0)[
            set ls1 (replace-item 0 ls1 ((first ls1) + (item (j - 1) ls2) + 1))
            set ls1 (replace-item j ls1 0)
            set ls2 (replace-item (j - 1) ls2 0)

            ;print "EL JUGADOR AZUL ROBA A JUGADOR ROJO"
          ]
        ]
      ]

      set j (j - 1)
      set cont (cont + 1)
    ]

    ; Tratamiento para la línea inferior
    while [ i < 6 and cont < n]
    [
      set ls2 (replace-item i ls2 ((item i ls2) + 1))
      set i (i + 1)
      set cont (cont + 1)
    ]

    set ls1 (replace-item 0 ls1 (item 0 ls1 + (n - cont)))
    set ls1 (replace-item xr ls1 0)
    report (list ls1 ls2)


end

; Esta función es una adaptación de la función aplicaJugada, pero esta no trabaja sobre la matriz global,
; sino que trabaja sobre una matriz local de forma que devuelve el resultado de aplicar una determinada regla
; a un tablero determiando que se pasan por parámetros

to-report aplicaJugadaMC [xr yr jugador tablero]

  let ls1 (item 0 tablero) ; Línea superior del tablero
  let ls2 (item 1 tablero) ; Línea inferior del tablero

  let res []

  if(jugador = 0 and xr > 0 and xr < 7 and yr = 0)[ ; Jugador1

    ; ls1 = [0 4 4 4 4 4 4]
    ; cor =  0 1 2 3 4 5 6
    ; ls2 = [4 4 4 4 4 4 0]
    ; cor =  1 2 3 4 5 6 7

    let cont 0 ; Un contador
    let n (item (xr - 1) ls2) ; Límite del contador

    let i xr
    let j 6

    set res (tratamientoJugador0MC i j n xr yr tablero)

  ]

  if(jugador = 1 and xr > 0 and xr < 7 and yr = 1)[ ; Jugador2

    ; ls1 = [0 4 4 4 4 4 4]
    ; cor =  0 1 2 3 4 5 6
    ; ls2 = [4 4 4 4 4 4 0]
    ; cor =  1 2 3 4 5 6 7

    let cont 0 ; Un contador
    let n (item xr ls1) ; Límite del contador

    let i 0
    let j (xr - 1)

    set res (tratamientoJugador1MC i j n xr yr tablero)
  ]

  report res

end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
1118
219
-1
-1
100.0
1
10
1
1
1
0
1
1
1
0
8
0
1
0
0
1
ticks
30.0

BUTTON
211
223
278
256
SETUP
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
282
223
420
256
PLAYER VS PLAYER
jugar
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
1138
14
1492
359
REGLAS DEL MANCALA:\n\n1- SELECCIONA UNA CASILLA CON UN NÚMERO DE SEMILLAS, ESTAS SEMILLAS SE REPARTIRÁN A PARTIR DE ESA CASILLA EN ADELANTE, EN SENTIDO ANTIHORARIO\n\n2- SI LA ÚLTIMA SEMILLA CAE EN TU MANCALA, TIENES UN TURNO EXTRA\n\n3- SI LA ÚLTIMA SELMILLA CAE EN UN HUECO VACÍO DE TU LÍNEA, ROBAS AL JUGADOR CONTRARIO TODAS LAS SEMILLAS QUE HAYA JUSTO DELANTE DE TU HUECO, SIEMPRE QUE HAYA AL MENOS UNA
12
0.0
1

BUTTON
424
223
532
256
PLAYER VS IA
jugar2
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
213
279
703
414
SI QUIERES JUGAR CONTRA OTRO JUGADOR, PULSA EL BOTÓN PLAYER VS PLAYER\n\nSI QUIERES JUGAR CONTRA LA IA, PULSA EL BOTÓN PLAYER VS IA\n\n
12
0.0
1

MONITOR
212
339
324
384
NIL
count MCTSnodes
17
1
11

BUTTON
537
223
615
256
IA VS IA
jugar3
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
