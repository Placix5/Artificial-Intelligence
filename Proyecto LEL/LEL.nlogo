breed [campeonesAzules campeonAzul]
breed [campeonesRojos campeonRojo]

breed [torresAzules torreAzul]
breed [torresRojas torreRoja]
breed [nexos nexo]

breed [miniomsAzules miniomAzul]
breed [miniomsRojos miniomRojo]

campeonesAzules-own [vida vidaTotal danno atacandoNexo? atacandoTorre? atacandoMiniom? atacandoCampeon? contadorMinioms contadorBajas contadorMuertes corObjX corObjY]
campeonesRojos-own [vida vidaTotal danno atacandoNexo? atacandoTorre? atacandoMiniom? atacandoCampeon? contadorMinioms contadorBajas contadorMuertes]

nexos-own [vida]
torresAzules-own [vida carril atacandoCampeon? atacandoMiniom?]
torresRojas-own [vida carril atacandoCampeon? atacandoMiniom?]

miniomsAzules-own [vida carril atacandoNexo? atacandoTorre? atacandoMiniom?]
miniomsRojos-own [vida carril atacandoNexo? atacandoTorre? atacandoMiniom?]

globals [

  coordenadasTorresAzules
  coordenadasTorresRojas

  nexoAzul?
  nexoRojo?

  tempTorres

]

to setup

  let aux []
  set nexoAzul? true
  set nexoRojo? true

  inicializaMapa
  creaTorresAzules
  creaTorresRojas
  creaNexos

  ask torresAzules [set aux lput (list xcor ycor carril) aux]
  set coordenadasTorresAzules aux
  set aux []
  ask torresRojas [set aux lput (list xcor ycor carril) aux]
  set coordenadasTorresRojas aux

  reset-ticks

end

to play

  reset-timer
  let antes 0
  let tem 0
  let despues timer
  set tempTorres 0

  creaCampeones

  while[true][

    set despues timer

    if(despues - antes >= 30)[
      repeat 1 [
        creaMiniomsRojos
        creaMiniomsAzules
      ]
      print "Se han generado subditos"
      set antes despues
    ]

    if(despues - tem >= 0.05)[
      gestionaMinioms
      gestionaCampeonAzul

      if(despues - tempTorres >= 0.5)[
        gestionaTorres
        set tempTorres despues
      ]

      tick
      set tem despues
    ]

  ]

end

; --------------------------------------------FUNCIONES PARA ADMINISTRACIÓN DEL MAPA-----------------------------------------------------

to gestionaCampeonAzul

  ask campeonesAzules [

    let rango (list (list pxcor pycor) (list (pxcor + 1) (pycor + 1)) (list pxcor (pycor + 1)) (list (pxcor + 1) pycor)
      (list (pxcor + 1) (pycor - 1)) (list pxcor (pycor - 1)) (list (pxcor - 1) (pycor - 1)) (list (pxcor - 1) pycor)
      (list (pxcor - 1) (pycor + 1))(list (pxcor + 2) (pycor + 2)) (list pxcor (pycor + 2)) (list (pxcor + 2) pycor)
      (list (pxcor + 2) (pycor - 2)) (list pxcor (pycor - 2)) (list (pxcor - 2) (pycor - 2)) (list (pxcor - 2) pycor)
      (list (pxcor - 2) (pycor + 2)))

    let corObjetivo[]
    let MC 0
    let TC 0
    let CC 0

    foreach rango [ t ->

      ;let TCaux 0

      let MCaux count miniomsRojos with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(MCaux > 0)[set MC MCaux]

      let TCaux count torresRojas with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(TCaux > 0)[set TC TCaux]

      let CCaux count campeonesRojos with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(CCaux > 0)[set CC MCaux]

      if(MCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(TCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(CCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(item 0 t = 48 and item 1 t = 48)[set corObjetivo [48 48]]

    ]

    if(not atacandoMiniom? and not atacandoTorre? and CC > 0)[set atacandoCampeon? atacaCampeon (list (item 0 corObjetivo) (item 1 corObjetivo)) 200]
    if(not atacandoMiniom? and not atacandoCampeon? and TC > 0)[set atacandoTorre? atacaTorre corObjetivo danno]
    if(not atacandoCampeon? and MC > 0)[

      ask miniomsRojos with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)][
        set vida (vida - 200)
        if(vida <= 0)[
          die
        ]
      ]

      let MC2 count miniomsRojos with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)]
      if(MC2 < MC)[set atacandoMiniom? false set contadorMinioms (contadorMinioms + 1)]
    ]

    set vidaTotal ((contadorMinioms / 100) * vidaTotal)
    set danno ((contadorMinioms / 100) * danno)

    if(mouse-down?)[
      set corObjX round(mouse-xcor)
      set corObjY round(mouse-ycor)
    ]

    if(corObjX != pxcor or corObjY != pycor)[mueveCampeon corObjX corObjY]

  ]

end

to gestionaMinioms

  ask miniomsAzules [

    let rango (list (list pxcor pycor carril) (list (pxcor + 1) (pycor + 1) carril) (list pxcor (pycor + 1) carril) (list (pxcor + 1) pycor carril)
      (list (pxcor + 1) (pycor - 1) carril) (list pxcor (pycor - 1) carril) (list (pxcor - 1) (pycor - 1) carril) (list (pxcor - 1) pycor carril)
      (list (pxcor - 1) (pycor + 1) carril))

    let corObjetivo [0 0]
    let MC 0
    let TC 0

    foreach rango [ t ->

      ;let TCaux 0
      let MCaux count miniomsRojos with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(MCaux > 0)[set MC MCaux]

      let TCaux count torresRojas with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(TCaux > 0)[set TC TCaux]

      ;if(member? (list item 0 t item 1 t carril) coordenadasTorresRojas)[set TCaux 1]

      if(MCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(TCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(item 0 t = 48 and item 1 t = 48)[set corObjetivo [48 48]]

    ]

    if((item 0 corObjetivo) = 48 and (item 1 corObjetivo) = 48 and not atacandoMiniom? and not atacandoTorre?)[set atacandoNexo? atacaNexo 1 100]
    if(not atacandoMiniom? and TC > 0)[set atacandoTorre? atacaTorre corObjetivo 100]

    if(not atacandoTorre? and MC > 0)[
      set atacandoMiniom? true
      ask miniomsRojos with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)][
        set vida (vida - 10)
        if(vida <= 0)[
          die
        ]
      ]

      let MC2 count miniomsRojos with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)]
      if(MC2 < MC)[set atacandoMiniom? false]

    ]

    if(not atacandoTorre? and not atacandoMiniom? and not atacandoNexo?)[mueveAzul pcolor]

    ;wait 0.005

  ]

  ask miniomsRojos [

    let rango (list (list pxcor pycor carril) (list (pxcor + 1) (pycor + 1) carril) (list pxcor (pycor + 1) carril) (list (pxcor + 1) pycor carril)
      (list (pxcor + 1) (pycor - 1) carril) (list pxcor (pycor - 1) carril) (list (pxcor - 1) (pycor - 1) carril) (list (pxcor - 1) pycor carril)
      (list (pxcor - 1) (pycor + 1) carril))

    let corObjetivo [0 0]
    let MC 0
    let TC 0

    foreach rango [ t ->

      let TCaux 0
      let MCaux count miniomsAzules with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(MCaux > 0)[set MC MCaux]

      ;let TCaux count torresAzules with [pxcor = (item 0 t) and pycor = (item 1 t)]
      ;if(TCaux > 0)[set TC TCaux]

      if(member? (list item 0 t item 1 t carril) coordenadasTorresAzules)[set TCaux 1]

      ;set MC count miniomsAzules with [pxcor = (item 0 t) and pycor = (item 1 t)]
      ;set TC count torresAzules with [pxcor = (item 0 t) and pycor = (item 1 t)]

      if(MCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(TCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(item 0 t = 2 and item 1 t = 2)[set corObjetivo [2 2]]

    ]

    if(not atacandoTorre? and MC > 0)[
      set atacandoMiniom? true
      ask miniomsAzules with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)][
        set vida (vida - 10)
        if(vida <= 0)[
          set atacandoMiniom? false
          die
        ]
      ]

      let MC2 count miniomsAzules with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)]
      if(MC2 < MC)[set atacandoMiniom? false]

    ]
    if((item 0 corObjetivo) = 2 and (item 1 corObjetivo) = 2 and not atacandoMiniom? or atacandoNexo?)[set atacandoNexo? atacaNexo 0 100]
    if(member? (list item 0 corObjetivo item 1 corObjetivo carril) coordenadasTorresAzules or atacandoTorre?)[set atacandoTorre? atacaTorre corObjetivo 100]
    if(not atacandoTorre? and not atacandoMiniom? and not atacandoNexo?)[mueveRojo pcolor]

    ;wait 0.005

  ]

end

to gestionaTorres

  ask torresAzules [

    let rango (list (list pxcor pycor carril) (list (pxcor + 1) (pycor + 1) carril) (list pxcor (pycor + 1) carril) (list (pxcor + 1) pycor carril)
      (list (pxcor + 1) (pycor - 1) carril) (list pxcor (pycor - 1) carril) (list (pxcor - 1) (pycor - 1) carril) (list (pxcor - 1) pycor carril)
      (list (pxcor - 1) (pycor + 1) carril)(list (pxcor + 2) (pycor + 2) carril) (list pxcor (pycor + 2) carril) (list (pxcor + 2) pycor carril)
      (list (pxcor + 2) (pycor - 2) carril) (list pxcor (pycor - 2) carril) (list (pxcor - 2) (pycor - 2) carril) (list (pxcor - 2) pycor carril)
      (list (pxcor - 2) (pycor + 2) carril)(list (pxcor + 3) (pycor + 3) carril) (list pxcor (pycor + 3) carril) (list (pxcor + 3) pycor carril)
      (list (pxcor + 3) (pycor - 3) carril) (list pxcor (pycor - 3) carril) (list (pxcor - 3) (pycor - 3) carril) (list (pxcor - 3) pycor carril)
      (list (pxcor - 3) (pycor + 3) carril))

    let corObjetivo [0 0]
    let MC 0
    let CC 0

    foreach rango [ t ->

      let MCaux count miniomsRojos with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(MCaux > 0)[set MC MCaux]

      let CCaux count campeonesRojos with [pxcor = (item 0 t) and pycor = (item 1 corObjetivo)]
      if(CCaux > 0)[set CC CCaux]

      if(CCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(MCaux > 0)[set corObjetivo (list item 0 t item 1 t)]

    ]

    if(not atacandoCampeon? and MC > 0)[

      set atacandoMiniom? true

      ask miniomsRojos with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)][
        set vida (vida - 25)
        if(vida <= 0)[
          die
        ]
      ]

      let MC2 count miniomsRojos with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)]
      if(MC2 < MC)[set atacandoMiniom? false]
    ]

    if(not atacandoMiniom? and CC > 0)[set atacandoCampeon? atacaCampeon (list (item 0 corObjetivo) (item 1 corObjetivo)) 200]

  ]

  ask torresRojas [

    let rango (list (list pxcor pycor carril) (list (pxcor + 1) (pycor + 1) carril) (list pxcor (pycor + 1) carril) (list (pxcor + 1) pycor carril)
      (list (pxcor + 1) (pycor - 1) carril) (list pxcor (pycor - 1) carril) (list (pxcor - 1) (pycor - 1) carril) (list (pxcor - 1) pycor carril)
      (list (pxcor - 1) (pycor + 1) carril)(list (pxcor + 2) (pycor + 2) carril) (list pxcor (pycor + 2) carril) (list (pxcor + 2) pycor carril)
      (list (pxcor + 2) (pycor - 2) carril) (list pxcor (pycor - 2) carril) (list (pxcor - 2) (pycor - 2) carril) (list (pxcor - 2) pycor carril)
      (list (pxcor - 2) (pycor + 2) carril)(list (pxcor + 3) (pycor + 3) carril) (list pxcor (pycor + 3) carril) (list (pxcor + 3) pycor carril)
      (list (pxcor + 3) (pycor - 3) carril) (list pxcor (pycor - 3) carril) (list (pxcor - 3) (pycor - 3) carril) (list (pxcor - 3) pycor carril)
      (list (pxcor - 3) (pycor + 3) carril))

    let corObjetivo [0 0]
    let MC 0
    let CC 0

    foreach rango [ t ->

      let MCaux count miniomsAzules with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(MCaux > 0)[set MC MCaux]

      let CCaux count campeonesAzules with [pxcor = (item 0 t) and pycor = (item 1 t)]
      if(CCaux > 0)[set CC CCaux]

      if(CCaux > 0)[set corObjetivo (list item 0 t item 1 t)]
      if(MCaux > 0)[set corObjetivo (list item 0 t item 1 t)]

    ]

    if(not atacandoCampeon? and MC > 0)[

      set atacandoMiniom? true

      ask miniomsAzules with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)][
        set vida (vida - 25)
        if(vida <= 0)[
          die
        ]
      ]

      let MC2 count miniomsAzules with [pxcor = (item 0 corObjetivo) and pycor = (item 1 corObjetivo)]
      if(MC2 < MC)[set atacandoMiniom? false]
    ]

    if(not atacandoMiniom? and CC > 0)[set atacandoCampeon? atacaCampeon (list (item 0 corObjetivo) (item 1 corObjetivo)) 200]

  ]

end

to-report atacaCampeon [coord damage]

  let res true

  ask campeonesAzules with [pxcor = (item 0 coord) and pycor = (item 1 coord)][
    set vida (vida - damage)
    if(vida <= 0)[
      set xcor 0
      set ycor 0
      set vida vidaTotal
      set danno (danno - 10)
      set res false
    ]
  ]

  ask campeonesRojos with [pxcor = (item 0 coord) and pycor = (item 1 coord)][
    set vida (vida - damage)
    if(vida <= 0)[
      set xcor 0
      set ycor 0
      set vida vidaTotal
      set danno (danno - 10)
      set res false
    ]
  ]

  report res

end

to-report atacaTorre [coord damage]

  let res true

  ;set coord (list first coord last coord carril )

  ask torresAzules with[xcor = (item 0 coord) and ycor = (item 1 coord)][
    set vida (vida - damage)
    if(vida <= 0)[
      ;set coordenadasTorresAzules remove coord coordenadasTorresAzules
      set res false
      die
    ]
  ]
  ask torresRojas with[xcor = (item 0 coord) and ycor = (item 1 coord)][
    set vida (vida - damage)
    if(vida <= 0)[
      ;set coordenadasTorresRojas remove coord coordenadasTorresRojas
      set res false
      die
    ]
  ]

  report res

end

to-report atacaNexo[n damage]

  let res true

  ifelse(n = 1)[ask nexos with[pxcor = 46 and pycor = 46][
    set vida (vida - damage)
    if(vida <= 0)[
      set nexoRojo? false
      die
    ]
   ]
  ][
  ask nexos with[pxcor = 4 and pycor = 4][
    set vida (vida - damage)
    if(vida <= 0)[
      set nexoRojo? false
      die
    ]
   ]
  ]

  report res

end

to mueveCampeon [x y]

  if(xcor < x)[set xcor (xcor + 0.15)]
  if(xcor > x)[set xcor (xcor - 0.15)]
  if(ycor < y)[set ycor (ycor + 0.15)]
  if(ycor > y)[set ycor (ycor - 0.15)]

end

to mueveAzul [zona]

  (ifelse
    carril = 2 [ifelse(zona = blue or ycor < 49)[set ycor (ycor + 0.015)][set xcor (xcor + 0.015)]]
    carril = 1 [set xcor (xcor + 0.015)set ycor (ycor + 0.015)]
    carril = 0 [ifelse(zona = blue or xcor < 49)[set xcor (xcor + 0.015)][set ycor (ycor + 0.015)]]
  )

end

to mueveRojo [zona]

  (ifelse
    carril = 2 [ifelse(zona = red or xcor > 1)[set xcor (xcor - 0.015)][set ycor (ycor - 0.015)]]
    carril = 1 [set xcor (xcor - 0.015)set ycor (ycor - 0.015)]
    carril = 0 [ifelse(zona = red or ycor > 1)[set ycor (ycor - 0.015)][set xcor (xcor - 0.015)]]
  )

end

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

; --------------------------------------------FUNCIONES PARA CREACIÓN DEL MAPA-----------------------------------------------------

to creaCampeones

  create-campeonesAzules 1 [
    set xcor 5
    set ycor 5
    set size 2
    set vida 1000
    set vidaTotal 1000
    set danno 80
    set atacandoCampeon? false
    set atacandoTorre? false
    set atacandoMiniom? false
    set atacandoNexo? false
    set contadorMinioms 0
    set contadorBajas 0
    set contadorMuertes 0
  ]

  create-campeonesRojos 1 [
    set xcor 45
    set ycor 45
    set size 2
    set vida 1000
    set vidaTotal 1000
    set danno 80
    set atacandoCampeon? false
    set atacandoTorre? false
    set atacandoMiniom? false
    set atacandoNexo? false
    set contadorMinioms 0
    set contadorBajas 0
    set contadorMuertes 0
  ]

end

to creaMiniomsAzules

  create-miniomsAzules 1 [
    set xcor 5
    set ycor 1
    set shape "miniom azul"
    set size 3
    set heading 0
    set color grey
    set vida 1200
    set atacandoTorre? false
    set atacandoMiniom? false
    set atacandoNexo? false
  ]

  create-miniomsAzules 1 [
    set xcor 7
    set ycor 7
    set shape "miniom azul"
    set size 3
    set heading 0
    set color grey
    set vida 1200
    set atacandoTorre? false
    set atacandoMiniom? false
    set atacandoNexo? false
  ]

  create-miniomsAzules 1 [
    set xcor 1
    set ycor 5
    set shape "miniom azul"
    set size 3
    set heading 0
    set color grey
    set vida 1200
    set atacandoTorre? false
    set atacandoMiniom? false
    set atacandoNexo? false
  ]

  ask miniomsAzules [set carril K-NNGen coordenadasTorresAzules (list xcor ycor) TRUE 3]

end

to creaMiniomsRojos

  create-miniomsRojos 1 [
    set xcor 45
    set ycor 49
    set shape "miniom rojo"
    set size 3
    set heading 0
    set color grey
    set vida 1200
    set atacandoTorre? false
    set atacandoMiniom? false
    set atacandoNexo? false
  ]

  create-miniomsRojos 1 [
    set xcor 42
    set ycor 42
    set shape "miniom rojo"
    set size 3
    set heading 0
    set color grey
    set vida 1200
    set atacandoTorre? false
    set atacandoMiniom? false
    set atacandoNexo? false
  ]

  create-miniomsRojos 1 [
    set xcor 49
    set ycor 45
    set shape "miniom rojo"
    set size 3
    set heading 0
    set color grey
    set vida 1200
    set atacandoTorre? false
    set atacandoMiniom? false
    set atacandoNexo? false
  ]

  ask miniomsRojos [set carril K-NNGen coordenadasTorresRojas (list xcor ycor) TRUE 3]

end

to inicializaMapa

  ca
  resize-world 0 50 0 50

  ; Creación de la jungla
  ask patches [set pcolor green]

  ; Creación del lado rojo
  ask patches with[pxcor >= 40 and pycor >= 40][set pcolor red]
  ask patches with[pxcor >= 2 and pycor >= 48][set pcolor red]
  ask patches with[pxcor >= 48 and pycor <= 50][set pcolor red]
  ask patches with[(pxcor = pycor or
    pxcor - 1 = pycor or
    pxcor - 2 = pycor or
    pxcor + 1 = pycor or
    pxcor + 2 = pycor) and
    pxcor >= 25 and pycor >= 25
  ][set pcolor red]

  ; Creación del lado azul
  ask patches with[pxcor <= 10 and pycor <= 10][set pcolor blue]
  ask patches with[pxcor <= 49 and pycor <= 2][set pcolor blue]
  ask patches with[pxcor <= 2 and pycor <= 49][set pcolor blue]
  ask patches with[(pxcor = pycor or
    pxcor - 1 = pycor or
    pxcor - 2 = pycor or
    pxcor + 1 = pycor or
    pxcor + 2 = pycor) and
    pxcor <= 25 and pycor <= 25
  ][set pcolor blue]

  ; Creación del río
  ask patches with[pxcor = (50 - pycor) or
    pxcor - 1 = (50 - pycor) or
    pxcor - 2 = (50 - pycor) or
    pxcor + 1 = (50 - pycor) or
    pxcor + 2 = (50 - pycor)
  ][set pcolor cyan]

end

to creaNexos

  create-nexos 1 [
    set xcor 4
    set ycor 4
    set shape "nexo azul"
    set size 4
    set heading 0
    set color grey
    set vida 50000
  ]

  create-nexos 1 [
    set xcor 46
    set ycor 46
    set shape "nexo rojo"
    set size 4
    set heading 0
    set color grey
    set vida 50000
  ]

end

to creaTorresAzules

  ; TORRES DEL CARRIL INFERIOR
  create-torresAzules 1 [
    set xcor 44
    set ycor 1
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 0
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresAzules 1 [
    set xcor 25
    set ycor 1
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 0
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresAzules 1 [
    set xcor 10
    set ycor 1
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 0
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  ;TORRES DEL CARRIL SUPERIOR
  create-torresAzules 1 [
    set xcor 1
    set ycor 10
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 2
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresAzules 1 [
    set xcor 1
    set ycor 25
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 2
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresAzules 1 [
    set xcor 1
    set ycor 44
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 2
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  ;TORRES DEL CARRIL CENTRAL
  create-torresAzules 1 [
    set xcor 10
    set ycor 10
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 1
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresAzules 1 [
    set xcor 16
    set ycor 16
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 1
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresAzules 1 [
    set xcor 22
    set ycor 22
    set shape "torreta azul"
    set size 3
    set heading 0
    set color grey
    set carril 1
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

end

to creaTorresRojas

  ; TORRES DEL CARRIL INFERIOR
  create-torresRojas 1 [
    set xcor 49
    set ycor 6
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 0
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresRojas 1 [
    set xcor 49
    set ycor 25
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 0
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

    create-torresRojas 1 [
    set xcor 49
    set ycor 41
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 0
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  ;TORRES DEL CARRIL SUPERIOR
  create-torresRojas 1 [
    set xcor 6
    set ycor 49
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 2
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresRojas 1 [
    set xcor 25
    set ycor 49
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 2
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresRojas 1 [
    set xcor 40
    set ycor 49
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 2
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  ;TORRES DEL CARRIL CENTRAL
  create-torresRojas 1 [
    set xcor 40
    set ycor 40
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 1
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresRojas 1 [
    set xcor 34
    set ycor 34
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 1
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

  create-torresRojas 1 [
    set xcor 28
    set ycor 28
    set shape "torreta roja"
    set size 3
    set heading 0
    set color grey
    set carril 1
    set vida 50000
    set atacandoCampeon? false
    set atacandoMiniom? false
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
881
682
-1
-1
13.0
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
50
0
50
0
0
1
ticks
30.0

BUTTON
0
10
63
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

BUTTON
63
10
126
43
NIL
play
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

miniom azul
true
0
Rectangle -13791810 true false 120 150 180 225
Circle -13791810 true false 120 90 60
Polygon -13791810 true false 135 90 165 90 150 60 135 90
Rectangle -7500403 true true 90 120 105 165
Polygon -13791810 true false 90 165 75 165 90 180 90 195 105 195 105 180 120 165 105 165
Polygon -7500403 true true 90 120 105 105 105 120
Circle -7500403 true true 129 99 42
Rectangle -955883 true false 150 150 150 225
Rectangle -7500403 true true 135 150 165 225

miniom rojo
true
0
Rectangle -955883 true false 120 150 180 225
Circle -955883 true false 120 90 60
Polygon -955883 true false 135 90 165 90 150 60 135 90
Rectangle -7500403 true true 90 120 105 165
Polygon -955883 true false 90 165 75 165 90 180 90 195 105 195 105 180 120 165 105 165
Polygon -7500403 true true 90 120 105 105 105 120
Circle -7500403 true true 129 99 42
Rectangle -955883 true false 150 150 150 225
Rectangle -7500403 true true 135 150 165 225

nexo azul
true
0
Circle -7500403 true true 15 15 270
Circle -13791810 true false 44 44 210
Rectangle -1184463 true false 15 135 45 165
Rectangle -1184463 true false 135 15 165 45
Rectangle -1184463 true false 255 135 285 165
Rectangle -1184463 true false 135 255 165 285

nexo rojo
true
0
Circle -7500403 true true 15 15 270
Circle -955883 true false 43 43 212
Rectangle -1184463 true false 135 15 165 45
Rectangle -1184463 true false 15 135 45 165
Rectangle -1184463 true false 135 255 165 285
Rectangle -1184463 true false 255 135 285 165

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

torreta
true
0
Rectangle -7500403 true true 120 105 180 300
Circle -7500403 true true 116 26 67
Rectangle -7500403 true true 90 30 105 300

torreta azul
true
0
Rectangle -13791810 true false 120 105 180 300
Circle -13791810 true false 116 26 67
Rectangle -7500403 true true 90 30 105 300
Rectangle -7500403 true true 135 105 165 300
Circle -7500403 true true 120 30 58
Rectangle -13791810 true false 90 30 105 60

torreta roja
true
0
Rectangle -955883 true false 120 105 180 300
Circle -955883 true false 116 26 67
Rectangle -7500403 true true 90 30 105 300
Rectangle -7500403 true true 135 105 165 300
Circle -7500403 true true 120 30 58
Rectangle -955883 true false 90 30 105 60

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
