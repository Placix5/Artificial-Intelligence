extensions [ CSV ]

__includes["DF.nls" "GeneticAlgorithm.nls"]

globals [
  clases
  DataSet
  DataFrame ; Dataframe to work

  GlobalDataFrame
  CondensedDataFrame
  ReducedDataFrame

  mostrado?

  lsColors
]

;-----------------PARA LA REPRESENTACIÓN DEL PROGRAMA (PARA PODER VER EL BUEN FUNCIONAMIENTO)--------------------

;Tenemos que escoger un dataset especifico (.data) que solo tenga 3 columnas: Primera: un campo de clasificacion,
;Segunda: otro campo de clasificacion, Tercera; la clasificacion segun esos dos campos anteriores
; Propongo un dataset con 3 columnas para poder hacer una representación en un eje de coordenadas en el cual
;Primera columna sería el eje x, Segunda el eje y. El color del punto en las coordenadas (x,y) denotaría que
;clasificación tiene (Tercera columna).
;----------------------------------------------------------------------------------------------------------------

;---------------FUNCIONAMIENTO DEL LA CONDENSACIÓN---------------------------------------------------------------
;BUCLE QUE RECORRE CADA LINEA DEL DATASET
;    APLICAR K-NN A CADA LINEA PERO CON UN DATASET QUE VA DESDE LINEA_0 HASTA LINEA_i
;    SI  CLASIFICACION_ANTERIOR == CLASIFICACION_REAL(VALOR_LINEA_i_3ºColumna)
;        SE ELIMINA LINEA_i DEL DATASET
;    SINO
;        SE DEJA LINEA_i EN EL DATASET
;DEVOLVEMOS DATASET MODIFICADO
;----------------------------------------------------------------------------------------------------------------

;---------------FUCIONAMIENTO DEL K-NN---------------------------------------------------------------------------
; ENTRADA: DATASET = {(X1,Y1,C1)(X2,Y2,C2),...,(XN,YN,CN)}, (X,Y)=((X1,Y1),...,(XN,YN)) nuevo a clasificar
; PARA todo objeto ya clasificado ((Xi,Yi),Ci)
;      calcular di = d((Xi,Yi),(X,Y))
; Ordenar di(i=1,...,N) en orden ascendente
; Quedarnos con los K casos D(k,x) ya clasificados más cercanos a x
; Asignar a x la clase más frecuente en D(k,x)
; FIN
;----------------------------------------------------------------------------------------------------------------

; Load-DF carga el archivo que contiene los datos a tratar desde fichero

to load-DF
  ; Clean everything
  ca
  ask patches [set pcolor white]
  ; Read the dataset file
  set DataSet DF:load user-file
  if DataSet != false [
    ; Print the dataset
    output-print "Original Dataset:"
    output-print DF:output DataSet

    set DataSet (remove (first DataSet) DataSet)
  ]

end

; setup sirve para inicializar el mundo, colocar los puntos que representan al dataset del que partimos

to setup

  clear-patches
  clear-plot
  resize-world 0 Tamx 0 TamY

  set mostrado? false
  set DataFrame sublist DataSet 0 ((length DataSet) * PorcentajeEntrenamiento / 100)
  set GlobalDataFrame DataFrame

  ;set-patch-size 5

  ;set DataFrame map[x -> (list item (ColumnaX) x item (ColumnaY) x item (ColumnaRes) x)]GlobalDataFrame
  set CondensedDataFrame []
  set ReducedDataFrame []

  let normX 1
  let normY 1

  if(normalizeX?)[
    let normXLs map[datax -> item ColumnaX datax]DataFrame
    set normX max normXLs
    set normX (normX / TamX)
  ]
  if(normalizeY?)[
    let normYLs map[ datay -> item ColumnaY datay]DataFrame
    set normY max normYLs
    set normY (normY / TamY)
  ]

  foreach DataFrame[ r ->
    ask patches with [pxcor = round ((item ColumnaX r) / normX ) and pycor = round ((item ColumnaY r) / normY)][
      set pcolor ((last r) * 10 + 45)
    ]
  ]

  set lsColors ["Grey" "Red" "Orange" "Brown" "Yellow" "Green" "Lime" "Turquoise" "Cyan" "Sky" "Blue" "Violet" "Magenta" "Pink"]

  let colors[]
  ask patches with [pcolor != white and pcolor != black][if(not member? pcolor colors)[set colors (lput pcolor colors)]]
  foreach colors[c -> print (word (word "El color " (item (c / 10) lsColors)) (word " pertenece a los elementos con número " ((c - 45) / 10)))]

end

to test

  let DataTrain filter[x -> not member? x DataFrame]DataSet
  let ClasifiedData []

  (ifelse
    DataSelect = "DataFrame" [set ClasifiedData map[x -> (list x ((K-NNGen DataFrame but-last x TRUE k)))]DataTrain]
    DataSelect = "CondensedDataFrame" [set ClasifiedData map[x -> (list x ((K-NNGen CondensedDataFrame but-last x TRUE k)))]DataTrain]
    DataSelect = "ReducedDataFrame" [set ClasifiedData map[x -> (list x ((K-NNGen ReducedDataFrame but-last x TRUE k)))]DataTrain]
  )

  let correct 0
  let wrong 0

  foreach ClasifiedData[ d -> ifelse(last d = last(first d))[set correct (correct + 1)][set wrong (wrong + 1)]]
  print (word "El porcentaje de acierto es de: " (correct / (length DataTrain) * 100))
  print (word "El porcentaje de fallo es de: " (wrong / (length DataTrain) * 100))

end

to searchBestK

  let bestKls []

  repeat 3 [
  AI:Initial-Population population
  let bestk AI:GeneticAlgorithm 100 Population crossover-ratio mutation-ratio
  set bestKls (lput first ([content] of bestk) bestKls)
  ]
  print (word "La mejor K para el DataSet especificado es: " first (modes bestKls))

end

; muestraKNN se encarga de aplicar el algoritmo KNN a los datos que se le pasa como parámetro
; y los representa en el mundo usando los patches

to muestraKNN [Data]

  let coordenadas map[d -> (list item ColumnaX d item ColumnaY d)] Data
  ask patches with [not member? (list pxcor pycor) coordenadas][set pcolor (K-NN Data pxcor pycor TRUE k) * 10 + 45]

end

; K-NN utiliza el algoritmo KNN para calcular cual sería la clasificación de un punto en el espacio (que representa a un elemento del dataset no
; contemplado en la base de datos) con respecto a los k vecinos más cercanos que se encuentren en el dataset que se pasa como parámetro
; Además, la variable k? la usamos para definir si queremos usar los k vecinos más cercanos o todos los puntos que hay en el dataset,
; esto es así ya que en la técnica de la condensación debemos usar todos los vecinos y puede entrar en conflicto con la k que haya establecido el usuario

to-report K-NN [df x y k? K-User]

  let c 0
  let vecinos []
  let coloresVecinos []

  let normX 1
  let normY 1
  if(normalizeX?)[
    let normXLs map[datax -> first datax]df
    set normX max normXLs
    set normX (normX / TamX)
  ]
  if(normalizeY?)[
    let normYLs map[ datay -> last datay]df
    set normY max normYLs
    set normY (normY / TamY )
  ]

  let distancias sort-by [[p1 p2] -> sqrt((((item 0 p1) / normX) - x) ^ 2 + (((item 1 p1) / normY ) - y) ^ 2) < sqrt((((item 0 p2) / normX ) - x) ^ 2 + (((item 1 p2) / normY ) - y) ^ 2) ] df
  ;print distancias

  ifelse(k? and length(distancias) > K-User)[set vecinos (sublist distancias 0 k)][set vecinos (sublist distancias 0 (length(df)))]
  foreach vecinos[ v -> set coloresVecinos (lput (item 2 v) coloresVecinos)]

  report first (modes coloresVecinos)

end

; K-NNGen es el KNN pero generalizado

to-report K-NNGen [df coord k? K-User]

  let c 0
  let vecinos []
  let coloresVecinos []

  let distancias sort-by [[p1 p2] -> sqrt(sum(map[[d1 dc] -> (d1 - dc) ^ 2](but-last p1) coord)) < sqrt(sum (map[[d2 dc] -> (d2 - dc) ^ 2](but-last p2) coord))] df
  ;let distancias sort-by [[p1 p2] -> sqrt(((item 0 p1) - x) ^ 2 + ((item 1 p1) - y) ^ 2) < sqrt(((item 0 p2) - x) ^ 2 + ((item 1 p2) - y) ^ 2) ] df

  ;ifelse(k?)[ifelse(k-Genetic = 0)[set vecinos (sublist distancias 0 K-User)][set vecinos (sublist distancias 0 K-Genetic)]][set vecinos (sublist distancias 0 (length(df)))]
  ifelse(k?)[set vecinos (sublist distancias 0 K-User)][set vecinos (sublist distancias 0 (length(df)))]
  foreach vecinos[ v -> set coloresVecinos (lput (item 2 v) coloresVecinos)]

  report first (modes coloresVecinos)

end


; aplicaKNN se encarga de aplicar el algoritmo KNN a todo el mapa de puntos

to aplicaKNN

  muestraKNN DataFrame

end

; aplicaCondensación se encarga de crear un dataset con los datos condensados, es decir, siguiendo la técnica de condensación
; y una vez calculados, representa el mundo

to aplicaCondensacion

 if(mostrado?)[setup]

 let DatosCondensados []

 foreach DataFrame [ d ->
    ifelse(length(DatosCondensados) = 0)[set DatosCondensados (lput d DatosCondensados)]
    [if(not ((K-NNGen DatosCondensados (but-last d) FALSE k) = last d))[set DatosCondensados (lput d DatosCondensados)]]

    let coordenadas map[c -> (list item 0 c item 1 c)] DatosCondensados
    ask patches with [not member? (list pxcor pycor) coordenadas][set pcolor (K-NN DatosCondensados pxcor pycor FALSE k) * 10 + 45]
  ]

  muestraKNN DatosCondensados
  set CondensedDataFrame DatosCondensados

  print "Los datos usados inicialmente son: "
  print DataFrame
  print "Los datos usados finalmente son: "
  print CondensedDataFrame

end

to muestraCondensacion

  set mostrado? true
  let DatosExcluidos filter [x -> not member? x CondensedDataFrame]DataFrame
  ask patches [set pcolor black]

  foreach DatosExcluidos [d ->
    ask patches with [pxcor = item 0 d and pycor = item 1 d][set pcolor red]
  ]

end

; aplicaReducción se encarga de crear un dataset con los datos reducidos, es decir, siguiendo la técnica de reducción
; y una vez calculados, representa el mundo

to aplicaReduccion

  if(mostrado?)[setup]

  let DatosReducidos DataFrame

  foreach DataFrame [ d ->
    if ((K-NNGen DatosReducidos (but-last d) FALSE k) = last d)[if(length(DatosReducidos) > k)[set DatosReducidos (remove d DatosReducidos)]]
  ]

  muestraKNN DatosReducidos
  set ReducedDataFrame DatosReducidos

  print "Los datos usados inicialmente son: "
  print DataFrame
  print "Los datos usados finalmente son: "
  print DatosReducidos

end

to muestraReduccion

  set mostrado? true
  let DatosExcluidos filter [x -> not member? x ReducedDataFrame]DataFrame
  ask patches [set pcolor black]

  foreach DatosExcluidos [d ->
    ask patches with [pxcor = item 0 d and pycor = item 1 d][set pcolor red]
  ]

end

; ----------------------------------------------------------------------------SEARCHING BEST PARAMETERS-------------------------------------------------------------------------------

to AI:Initial-Population [#population]

  create-AI:individuals #population [

  set content (list 0)

  (ifelse
    DataSelect = "DataFrame" [while[first content = 0][ifelse(length(DataFrame) < 10)[set content (list random(length(DataFrame)))][set content (list random(10))]]]
    DataSelect = "CondensedDataFrame" [while[first content = 0][ifelse(length(CondensedDataFrame) < 10)[set content (list random(length(CondensedDataFrame)))][set content (list random(10))]]]
    DataSelect = "ReducedDataFrame" [while[first content = 0][ifelse(length(ReducedDataFrame) < 10)[set content (list random(length(ReducedDataFrame)))][set content (list random(10))]]]
  )
    AI:Compute-fitness
    hide-turtle
  ]

end

to AI:Compute-fitness

  let DataTrain filter[x -> not member? x DataFrame]DataSet
  let ClasifiedData []

  (ifelse
    DataSelect = "DataFrame" [set ClasifiedData map[x -> (list x ((K-NNGen DataFrame but-last x TRUE (first content))))]DataTrain]
    DataSelect = "CondensedDataFrame" [set ClasifiedData map[x -> (list x ((K-NNGen CondensedDataFrame but-last x TRUE (first content))))]DataTrain]
    DataSelect = "ReducedDataFrame" [set ClasifiedData map[x -> (list x ((K-NNGen ReducedDataFrame but-last x TRUE (first content))))]DataTrain]
  )

  let correct 0
  let wrong 0

  foreach ClasifiedData[ d -> ifelse(last d = last(first d))[set correct (correct + 1)][set wrong (wrong + 1)]]
  ;print (word "El porcentaje de acierto es de: " (correct / (length DataTrain) * 100))
  ;print (word "El porcentaje de fallo es de: " (wrong / (length DataTrain) * 100))

  set fitness (correct / (length DataTrain) * 100)

end

to-report AI:Crossover [c1 c2]

  let h1 [] ; Cromosoma hijo1
  let h2 [] ; Cromosoma hijo2

  ; Intercambio aleatorio de los genes que no son iguales para los dos padres
  (foreach c1 c2
  [[p1 p2] -> ifelse(p1 != p2 and (random 1) = 1)[set h1 (lput p2 h1) set h2 (lput p1 h2)]
    [set h1 (lput p1 h1) set h2 (lput p2 h2)]])

  report (list h1 h2)

end

; Mutation procedure
; Random mutation of units of the content.
; Individual procedure
to AI:mutate [#mutation-ratio]

  let moda modes content
  set content map [p -> ifelse-value(random-float 100.0 < #mutation-ratio)[item 0 moda][p]] content

end

to AI:ExternalUpdate

  let best max-one-of AI:individuals [fitness]
  plots
  display

end

to plots
  let lista-fitness [fitness] of turtles
  let mejor-fitness max lista-fitness
  let media-fitness mean lista-fitness
  let peor-fitness min lista-fitness
  set-current-plot "Fitness"
  set-current-plot-pen "mean"
  plot media-fitness
  set-current-plot-pen "best"
  plot mejor-fitness
  set-current-plot-pen "worst"
  plot peor-fitness
end



;----------------------------------------------------------------------------CREATOR OF .CSV-------------------------------------------------------------------------------

to creaCSV

  let lineas []
  ask turtles [die]

  coloreaMundo

  ;repeat Entradas[
  ;  ask patches with [pxcor = random-pxcor and pycor = random-pycor][set lineas (lput (list pxcor pycor pcolor) lineas)]
  ;]

  crt Entradas[
    set xcor random-pxcor
    set ycor random-pycor
    set shape "circle"
    set color black
  ]

  ask turtles [set lineas (lput (list pxcor pycor pcolor) lineas)]

  ;set lineas (fput cabecera lineas)
  csv:to-file "autoCSV-netlogo.csv" lineas

end

to coloreaMundo

  clear-patches
  resize-world 0 Tamx 0 TamY

  let mundoColoreado? false
  let aunPulsado? false
  let c 15

  while[not mundoColoreado?][
    set mundoColoreado? true
    set aunPulsado? false

    if(mouse-down?)[
      let corx round(mouse-xcor)
      let cory round(mouse-ycor)
      ask patches with [
        (pxcor = corx and pycor = cory) or
        (pxcor = corx + 1 and pycor = cory) or
        (pxcor = corx - 1 and pycor = cory) or
        (pxcor = corx and pycor = cory + 1) or
        (pxcor = corx and pycor = cory - 1)
      ][set pcolor c]
      set aunPulsado? true
    ]

    if(not aunPulsado?)[set c (c + 10)]

    ask patches [if(pcolor = 0)[set mundoColoreado? false]]

  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
538
10
1256
729
-1
-1
10.0
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
70
0
70
0
0
1
ticks
30.0

OUTPUT
180
10
534
446
11

BUTTON
436
19
510
52
NIL
load-DF
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
10
170
43
k
k
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
0
43
170
76
TamX
TamX
0
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
0
75
170
108
TamY
TamY
0
100
70.0
1
1
NIL
HORIZONTAL

BUTTON
1
229
65
262
Setup
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
67
229
170
262
NIL
aplicaKNN
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
0
263
170
296
NIL
aplicaCondensacion
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
0
295
170
328
NIL
aplicaReduccion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
0
108
63
168
ColumnaX
0.0
1
0
Number

INPUTBOX
0
168
63
228
ColumnaY
1.0
1
0
Number

BUTTON
0
327
170
360
NIL
muestraCondensacion
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
0
360
170
393
NIL
muestraReduccion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
180
447
534
480
PorcentajeEntrenamiento
PorcentajeEntrenamiento
0
100
75.0
1
1
NIL
HORIZONTAL

BUTTON
180
479
363
524
NIL
test
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
362
480
534
525
DataSelect
DataSelect
"DataFrame" "CondensedDataFrame" "ReducedDataFrame"
0

SWITCH
63
108
170
141
normalizeX?
normalizeX?
1
1
-1000

SWITCH
62
168
170
201
normalizeY?
normalizeY?
1
1
-1000

PLOT
0
446
180
589
Fitness
gen n
fitness
0.0
20.0
0.0
100.0
true
false
"" ""
PENS
"best" 1.0 0 -13791810 true "" ""
"mean" 1.0 0 -13840069 true "" ""
"worst" 1.0 0 -2674135 true "" ""

SLIDER
361
523
534
556
crossover-ratio
crossover-ratio
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
361
556
534
589
mutation-ratio
mutation-ratio
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
180
523
362
556
Population
Population
0
10
5.0
1
1
NIL
HORIZONTAL

BUTTON
180
556
362
589
NIL
searchBestK
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
648
172
681
Entradas
Entradas
0
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
173
648
282
681
NIL
creaCSV
NIL
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
