extensions [ landscapes ]

; ------------------- Include Genetic Algorithm Module --------------------

__includes ["ContinuousGeneticAlgorithm.nls"]

; --------------------------- Main procedures calling ---------------------

patches-own [
  height
]

turtles-own [
  peak? ; indicates whether a turtle has reached a "peak",
        ; that is, it can no longer go "uphill" from where it stands
]

to Setup
  ca
  landscapes:generate landscape "height"
  ask patches [ set pcolor scale-color grey height 0 1 ]
  ; put some turtles on patch centers in the landscape
  ask n-of population patches [
    sprout 1 [
      set peak? false
      set color [ 255 0 0 25 ]
      pen-down
    ]
  ]
  AI:Initial-Population population
  AI:ExternalUpdate
  plots
end

to Launch
  show AI:GeneticAlgorithm 100 Population crossover-ratio mutation-ratio
  plots
end

;------------------ Customizable Procedures ---------------------------------

; Create Initial Population
; It depends on the problem to be solved as it uses a concrete representation
to AI:Initial-Population [#population]

  create-AI:individuals #population [
    set content (list random-xcor random-ycor)
    AI:Compute-fitness
    ;hide-turtle
  ]
end

; Individual report to compute its fitness
to AI:Compute-fitness

  let x (first content)
  let y (last content)

  set xcor x
  set ycor y

  set fitness ([height] of patch-here)

end

; Crossover procedure
; It takes content from two parents and returns a list with two contents.
; When content is a list (as in DNA case) it uses a random cut-point to
; cut both contents and mix them:
; a1|a2, b1|b2, where long(ai)=long(bi)
; and report: a1|b2, b1|a2

to-report AI:CustomCrossover [c1 c2]
  let cut-point 1 + random (length c1 - 1)
  report list (sentence (sublist c1 0 cut-point)
                        (sublist c2 cut-point length c2))
              (sentence (sublist c2 0 cut-point)
                        (sublist c1 cut-point length c1))
end

to-report AI:CustomSelection [old-generation]

    let father1 one-of (old-generation)
    let father2 one-of (old-generation)

  report (list father1 father2)

end

; Mutation procedure
; Random mutation of units of the content.
; Individual procedure
to AI:CustomMutate [#mutation-ratio]
  set content map [x -> ifelse-value (random-float 100.0 < #mutation-ratio) [x] [x]] content
end

; Auxiliary procedure to be executed in every iteration of the main loop.
; Usually to show or update some information.

to AI:ExternalUpdate

  ask AI:individuals [
    let x (first content)
    let y (last content)

    ;set xcor x
    ;set ycor y

    ; remember where we started
    let old-patch patch-here
    if old-patch = patch-here [
      set shape "target"
      set color ifelse-value (height = 1) [ lime ] [ cyan ]
      set size height * 5
    ]
  ]
  plots
  wait 0.25
  display
end

;; ====== Plotting

to plots
  let lista-fitness [fitness] of AI:individuals
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
  if plot-diversity?
  [
    set-current-plot "Diversity"
    set-current-plot-pen "diversity"
    plot AI:diversity
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
145
10
756
622
-1
-1
3.0
1
10
1
1
1
0
1
1
1
-100
100
-100
100
0
0
1
ticks
30.0

BUTTON
75
10
140
43
NIL
Launch
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
10
10
70
43
NIL
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

SLIDER
10
45
140
78
Population
Population
5
200
200.0
5
1
NIL
HORIZONTAL

PLOT
770
10
1050
130
Fitness
gen #
fitness
0.0
20.0
0.0
10.0
true
false
"" ""
PENS
"best" 1.0 0 -2674135 true "" ""
"mean" 1.0 0 -10899396 true "" ""
"worst" 1.0 0 -13345367 true "" ""

SLIDER
10
115
140
148
mutation-ratio
mutation-ratio
0
50
14.8
0.1
1
NIL
HORIZONTAL

PLOT
770
130
1050
250
Diversity
gen #
diversidad
0.0
20.0
0.0
1.0
true
false
"" ""
PENS
"diversity" 1.0 0 -8630108 true "" ""

SWITCH
10
150
140
183
plot-diversity?
plot-diversity?
0
1
-1000

SLIDER
10
80
140
113
crossover-ratio
crossover-ratio
0
100
67.0
1
1
NIL
HORIZONTAL

CHOOSER
930
305
1075
350
Crossover
Crossover
"UniformCrossover" "PointCrossover" "2PointCrossover" "CustomCrossover"
1

CHOOSER
770
305
932
350
Selection
Selection
"Tekken" "Elitist" "ProportionalAptitude" "RandomSelection" "CustomSelection"
0

CHOOSER
770
350
930
395
Mutate
Mutate
"BasicMutate" "RandomMutate" "SMMutate" "ModesMutate" "ReverseMutate" "CustomMutate"
2

CHOOSER
770
260
1075
305
landscape
landscape
"3 POT HOLES" "ACKLEY'S FUNCTION" "ACKLEY'S PATH FUNCTION 10" "AXIS PARALLEL HYPER-ELLIPSOID FUNCTION" "BOHACHEVSKY'S FUNCTION" "BRANINS'S RCOS FUNCTION" "CPF1" "CPF2" "DE JONG F1" "EASOM'S FUNCTION" "EUCLIDEAN" "EXP" "F1" "F2" "F3" "F4 (PSHUBERT1)" "F5 (PSHUBERT2)" "F6 (QUARTIC)" "F7 (SHUBERT FUNCTION)" "FLAT" "G1" "G2" "G3" "GENERALIZED GRIEWANK FUNCTION" "GENERALIZED HIMMELBLAU'S FUNCTION" "GENERALIZED PENALIZED FUNCTION 1" "GENERALIZED PENALIZED FUNCTION 2" "GENERALIZED RASTRIGIN'S FUNCTION" "GENERALIZED ROSENBROCK'S FUNCTION" "GENERALIZED SCHWEFELS PROBLEM 2.26" "GOLDSTEIN-PRICE'S FUNCTION" "GRIEWANGK'S FUNCTION 8" "HANSENS FUNCTION" "HORN'S FMMEASY" "HORNS 5 PEAKS (MODIFIED)" "LANGERMANN'S FUNCTION 11 (M=4)" "LANGERMANN'S FUNCTION 11 (M=7)" "M1" "M2" "M3" "M4" "M5 (HIMMELBLAU'S FUNCTION)" "M6 (SHEKEL'S FOXHOLES)" "MICHALEWICZ'S FUNCTION 12" "MOVED AXIS PARALLEL HYPER-ELLIPSOID FUNCTION" "MULTI FUNCTION" "PEAKS" "QUARTIC FUNCTION (NOISE)" "RASTRIGIN'S FUNCTION 6" "RIPPLES" "ROOTS" "ROSENBROCK'S VALLEY (DE JONG F2)" "ROTATED HYPER-ELLIPSOID FUNCTION" "SCHAFFER'S FUNCTION" "SCHWEFEL'S FUNCTION 7" "SCHWEFEL'S PROBLEM 1.2" "SCHWEFEL'S PROBLEM 2.21" "SCHWEFEL'S PROBLEM 2.22" "SHUBERT FUNCTION" "SIX-HUMP CAMEL BACK FUNCTION" "SPHERE" "SQUASHED FROG FUNCTION (TIMBO)" "STEP FUNCTION" "SUM OF DIFFERENT POWER FUNCTION" "TEST FUNCTION F1" "TEST FUNCTION F2 (ROSENBROCK'S FUNCTION)" "TEST FUNCTION F3" "TEST FUNCTION F4 (QUARTIC FUNCTION)" "TEST FUNCTION F5 (SHEKEL'S FUNCTION)"
0

@#$#@#$#@
# Algoritmos Genéticos Continuos

En esta librería se ha implementado una serie de métodos para poder usar un algoritmo genético cuyos cromosomas estén formados por números continuos. Además, se ha implementado de una forma totalmente modular, esto es así ya que se puede seleccionar el método de cruzamiento, el método de selección y el método de mutación, además de poder customizar cada uno de dichos métodos para que se adapte totalmente a problema del usuario.

Para trabajar con esta librería se ha definido un tipo de agentes llamado ***AI:individuals***, los cuales tienen las variables ***content*** y ***fitness***, donde ***content*** es el cromosoma y ***fitness*** es el valor de la función de fitness para ese cromosoma. Además hay que especificar cuántos individuos va a haber en la población mediante la variable ***Population*** y también definir la probabilidad de mutación mediante la variable global ***mutation-ratio*** y la probabilidad de cruzamiento mediante la variable global ***crossover-ratio***.

Al igual que en la gran mayoría de librerías de algoritmos genéticos, es imprescindible que se implementen las funciones de fitness y población inicial ya que son específicas de cada problema. Para implementar la función de fitness hay que crear una función llamada ***AI:Compute-fitness*** la cual trabaja directamente sobre un agente. Para implementar la función de población inicial hay que crear una función con el nombre ***AI:Initial-Population*** en la cual es obligatorio crear los individuos llamados ***AI:individuals*** 

Destacar que los cromosomas en la población inicial deben darse normalizados entre 0 y 1 ya que la librería está pensada para trabajar con ese rango de valores, la forma de normalizarlo dependerá del usuario.

Vamos a ver que funciones se han añadido para los métodos de cruzamiento, selección y mutación y vamos a hablar sobre qué hace cada una de ellas.

## Cruzamiento

El cruzamiento consiste en dado dos cromosomas a los que consideramos padres, obtener dos cromosomas que serán hijos mediante algún método que combine los genes, los cuales se encuentran en la variable ***content*** de nuestros agentes.

En esta librería se han implementado tres funciones de cruzamiento:

### AI:PointCrossover

PointCrossover recibe dos cromosomas padres y devuelve otros dos cromosomas hijos. Para poder crear los hijos, se un punto aleatorio de la lista contenido donde se encuentran los genes, llamemos a esta posición ***alpha***. Una vez que tenemos la posición ***alpha*** se calcula un nuevo valor para dicha posición que es una combinación de los genes que se encuentran en la posición ***alpha*** de ambos padres, a este valor le vamos a llamar ***valorAlpha*** 

Una vez que hemos calculado el punto y el valor, procedemos a crear los hijos, para ello copiamos las listas de genes de los padres para cada hijo hasta el punto ***alpha*** sin incluir este, sustituimos el gen del punto ***alpha*** por ***valorAlpha*** y por último se intercambian genes restantes de forma que la primera parte del hijo1 corresponde a padre1 y la segunda parte corresponde a padre2. Lo mismo ocurre para hijo2

Es importante aclarar que por el funcionamiento de este método, solo puede usarse con cromosomas continuos.

### AI:2PointCrossover

PointCrossover recibe dos cromosomas padres y devuelve otros dos cromosomas hijos. Para poder crear los hijos, se escogen dos puntos de la lista de genes y se intercambian de manera totalmente aleatoria los genes que hay entre esos puntos, dejando el resto de las listas intactas, de forma que hijo1 tiene los genes de padre1 hasta el primer punto y desde el segundo hasta el final y viceversa

Este método puede usarse con cualquier tipo de cromosomas.

### AI:UniformCrossover

UniformCrossover recibe dos cromosomas padres y devuelve otros dos cromosomas hijos. Los hijos se crean de la siguiente forma, hijo1 hereda los genes de padre1 e hijo 2 hereda los genes de padre2, si los genes de padre1 y padre2 son iguales, permanecen igual, pero si son diferentes se le asignan aleatoriamente a cada uno de los hijos, de manera que hijo1 tiene los genes de padre1 y algunos de padre2 y viceversa

Este método puede usarse con cualquier tipo de cromosomas.

## Selección

La principal idea de la selección es escoger a los cromosomas de la población actual a partir de los cuales vamos a generar la nueva población. Para ello se han definido varios métodos predefinidos, que el usuario podrá usar según su conveniencia para un problema determinado, además, la librería proporciona la posibilidad de que sea el propio usuario el que diseñe su propio método de selección.

En todos los métodos de selección que incorpora esta librería, necesitamos saber la generación actual o “old-generation” como se denomina en esta, la cual se debe enviar a dicho método como parámetro de entrada. Cada método de selección aplica un criterio, que se explicará a continuación, y devolverá una lista con los dos padres mejor considerados según dicho criterio.

Nuestra librería incorpora cuatro métodos definidos para la selección

### AI:Tekken

Este método recibe la generación actual y devuelve dos cromosomas. Selecciona tres cromosomas aleatorios y elige el mejor de ellos, basándose en el valor de su función fitness,para que se convierta en padre. Este proceso se realiza dos veces para generar los dos padres que debe devolver.

Este método puede usarse con cualquier tipo de cromosomas.

### AI:Elitist

Este método recibe la generación actual y devuelve dos cromosomas. Selecciona los dos cromosomas con el mejor valor de función de fitness para que sean los padres de la siguiente generación, Es decir de todos escoge los dos mejores.

Este método puede usarse con cualquier tipo de cromosomas.

### AI:ProportionalAptitude

Este método recibe la generación actual y devuelve dos cromosomas. Cada individuo recibe una probabilidad de ser seleccionado, esta probabilidad se asigna acorde con el valor de su función fitness. De esta forma los mejores individuos tienen mayor probabilidad de ser elegidos, al contrario que los métodos anteriores no tienen la certeza de que por ser mejores sean seleccionados.

Este método puede usarse con cualquier tipo de cromosomas.

### AI:RandomSelection

Este método recibe la generación actual y devuelve dos cromosomas. Se escogen dos individuos al azar y estos pasan a ser los padres de la siguiente generación.

Este método puede usarse con cualquier tipo de cromosomas.

## Mutación

Se ve como un método de cambio, una manera sencilla de mejorar a los genes para la generación posterior, consiste en un algoritmo que cambia los genes de algunas partes aleatoriamente y realizando algunos cambios en la propia codificación.

Podemos considerar hasta cinco tipos de mutaciones, todas ellas reciben un gen y realizan una mutación o no dependiendo de si se cumple una serie de condiciones:

### AI:BasicMutate

Con un número generado aleatoriamente, se hace una comparación con mutation-ratio, si ese número es menor se cambia el gen, sino se queda sin ninguna alteración.

Es importante aclarar que por el funcionamiento de este método, solo puede usarse con cromosomas continuos.

### AI:RandomMutate

Con un número generado aleatoriamente, se hace una comparación con mutation-ratio, si ese número es menor se cambia el gen por un número aleatorio, sino se queda sin ninguna alteración.

Es importante aclarar que por el funcionamiento de este método, solo puede usarse con cromosomas continuos.

### AI:SMMutate

Con un número generado aleatoriamente, se hace una comparación con mutation-ratio, si ese número es menor se sustituye el gen por otro gen elegido alazar, sino se queda sin ninguna alteración.

Este método puede usarse con cualquier tipo de cromosomas.

### AI:ModesMutate

Con un número generado aleatoriamente, se hace una comparación con mutation-ratio, si ese número es menor sustituye el gen por el gen que más se repite(la moda)

Este método puede usarse con cualquier tipo de cromosomas.

### AI:ReverseMutate

Mutación muy simple, en la cual se realiza una mutación de los genes invirtiendo el orden de los genes.

Este método puede usarse con cualquier tipo de cromosomas.

## Bonus Track

Junto con esta librería se han incluido tres programas simples de ejemplo, los cuales nos servirán para poder comprobar cómo funciona la librería. Tenemos un programa que trabaja con una función de fitness que representa una función matemática que viene dada por senos, otro programa que busca crear una función que se aproxime a una función dada y por último un programa con la batería de problemas de ***LandScape*** para que podamos ver cómo son capaces nuestros agentes de resolver los problemas propuestos en ellos.

En cada uno de estos programas adjuntos podemos seleccionar el algoritmo de cruzamiento, de selección y de mutación que queremos usar, de esta forma podemos ver cómo se comporta el programa para los diferentes casos, siempre y cuando los algoritmos escogidos puedan usarse ya que hay algunos que solo sirven para cromosomas continuos, para saber más sobre cuales pueden usarse y cuales no, por favor lea la descripción de cada método ya que se especifica en ellas.

Esperamos que disfrute usando nuestra librería.
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

chess queen
false
0
Circle -7500403 true true 140 11 20
Circle -16777216 false false 139 11 20
Circle -7500403 true true 120 22 60
Circle -16777216 false false 119 20 60
Rectangle -7500403 true true 90 255 210 300
Line -16777216 false 75 255 225 255
Rectangle -16777216 false false 90 255 210 300
Polygon -7500403 true true 105 255 120 90 180 90 195 255
Polygon -16777216 false false 105 255 120 90 180 90 195 255
Rectangle -7500403 true true 105 105 195 75
Rectangle -16777216 false false 105 75 195 105
Polygon -7500403 true true 120 75 105 45 195 45 180 75
Polygon -16777216 false false 120 75 105 45 195 45 180 75
Circle -7500403 true true 180 35 20
Circle -16777216 false false 180 35 20
Circle -7500403 true true 140 35 20
Circle -16777216 false false 140 35 20
Circle -7500403 true true 100 35 20
Circle -16777216 false false 99 35 20
Line -16777216 false 105 90 195 90

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
need-to-manually-make-preview-for-this-model
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
1
@#$#@#$#@
