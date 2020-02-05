# APRENDIZAJE REFORZADO

## IINTRODUCCIÓN

El aprendizaje reforzado es algo muy común en nuestras vidas, los seres humanos formamos nuestros comportamientos en base a nuestras experiencias, aprendemos en base a nuestros errores de forma que poco a poco podemos mejorar nuestro propio rendimiento con respecto a dichas experiencias. Esto mismo podemos llevarlo al mundo de la computación, buscando que un agente pueda aprender en función de unas recompensas que le suministraremos si hace bien su trabajo.

El aprendizaje reforzado es una muy buena forma de poder enseñar a una máquina, el problema es que está un poco limitado. Esto es así debido a que nuestro agente solo aprenderá aquella tarea que le hemos asignado, no será capaz de aumentar la complejidad más allá de ello, por ejemplo, si queremos enseñar a un agente a que chute y marque en una portería no aprenderá más que a chutar, no será capaz de aprender a hacer regates o a tirar de chilena. ¿Cómo podemos aumentar el grado de complejidad de nuestro agente? La respuesta es con un sistema multiagente, en el que hayan varios agentes compitiendo por el mismo objetivo, de esta manera, cada agente aprenderá y utilizará nuevas técnicas para así poder conseguir su objetivo, aumentando así el grado de complejidad y consiguiendo el objetivo que estábamos buscando.

En esto se basa este proyecto, se ha buscado entrenar un sistema multi-agente mediante aprendizaje reforzado para así poder crear posteriormente un jugador que pueda jugar contra una persona y que esté lleno de sorpresas y técnicas complejas que otros algoritmos más simples como Monte Carlo no podrían conseguir. Para ello hemos usado el algoritmo Q-learning, del cual hablaremos más adelante. 

El jugador que hemos desarrollado está pensado para el juego conocido como Mancala. El juego Mancala es un juego de origen árabe, cuyo nombre significa mover. Este juego consiste en dos filas, cada una de ellas con 6 huecos y dos kalahas, situadas en los laterales del tablero. A cada jugador le corresponde una fila y la kalaha que esté a su derecha. Dentro de cada uno de los huecos de las filas encontramos de manera inicial cuatro semillas. El objetivo del juego es conseguir el mayor número de semillas en la kalaha, de forma que el único movimiento posible es repartir todas las semillas de un hueco en sentido antihorario.

Tras realizar este movimiento pueden darse tres casos posibles:

1. Si la última semilla cae en un hueco en el que ya había semillas, sea del jugador que sea, es turno del siguiente jugador

2. Si la última semilla cae en la kalaha correspondiente al jugador que ha realizado el movimiento, dicho jugador obtiene un turno extra

3. Si la última semilla cae en un hueco vacío correspondiente a la fila del jugador que ha realizado el movimiento y además, hay semillas en el hueco justo delante de este, el jugador roba todas esas semillas y las introduce en su kalaha

La partida terminará cuando una de las dos filas se encuentre totalmente vacía y ganará el jugador que posea más semillas en su kalaha

## MANCALA

En este punto vamos a ver todo lo relacionado con el juego Mancala, desde cómo se ha modelizado hasta cómo hemos hecho la parte gráfica.

### MODELIZACIÓN

Para este juego, hemos modelizado el tablero con una matriz de dos filas.
En la primera fila de la matriz se encuentra la línea superior del tablero, además, en la primera
posición se encuentra la kalaha correspondiente al jugador que juegue en la parte superior del
tablero.
En la segunda fila de la matriz se encuentra la línea inferior del tablero, además, en la última
posición se encuentra la kalaha correspondiente al jugador que juegue en la parte inferior del
tablero.
Hemos redimensionado el mundo para que los patches nos hagan de tablero, de forma que los
patches superiores, los cuales tienen pycor = 1, corresponden a la línea superior del tablero y los
patches inferiores, los cuales tienen pxcor = 0, corresponden a la línea inferior del tablero. Esto nos
servirá cuando vayamos a aplicar una jugada, ya que así sabremos que el jugador ha seleccionado
un hueco correspondiente a su fila y además nos servirá para representar ambas filas del tablero.
Además, la coordenada x de los patches nos sirve para determinar el hueco del tablero sobre el que
vamos a trabajar. En el caso de la línea superior, si el jugador selecciona el hueco x, trabajaremos
sobre la posición x en la fila superior de la matriz ya que corresponde con el índice del hueco en el
que están las semillas que se quieren repartir. Por otro lado, en la línea inferior del tablero, si el
jugador selecciona el hueco x, trabajaremos sobre la posición x-1 en la fila inferior de la matriz ya
que, en este caso, dicha fila se encuentra desplazada una posición a la derecha ya que la kalaha del
jugador superior toma dos partches:

​																	**ls1 = [0 4 4 4 4 4 4]**
​																	**pxcor = 0 1 2 3 4 5 6**
​																	**ls2 = [4 4 4 4 4 4 0]**
​																	**pxcor = 1 2 3 4 5 6 7**

Aquí podemos ver de una forma más visual la relación entre posiciones y coordenadas.
Una vez que sabemos la posición de la lista sobre la que vamos a trabajar, mediante las
coordenadas x e y seleccionadas con el ratón, cargamos el contenido del hueco en una variable y
empezamos a repartir semillas por el tablero sumando uno a cada hueco de la lista de la manera
correspondiente a cada una de las filas (en la fila superior de derecha a izquierda y en la fila inferior
de izquierda a derecha) y una vez que hemos dado una vuelta completa, las semillas que hayan
sobrado las añadimos a nuestra kalaha, si es que han sobrado algunas. Para realizar todas estas
acciones se usa la función aplicaJugada, la cual recibe como parámetros las coordenadas xr e yr y
además el jugador que realiza el movimiento.
En cada movimiento, se mira también la última semilla, para saber si se activa el doble turno o la
posibilidad de robar al otro jugador.
Todo esto se ha modelizado usando una variable llamada matriz-global.

### PARTE GRÁFICA

El tablero, como dijimos anteriormente, está formado por dos filas, cada una de ellas con seis
huecos y dos kalahas en los laterales, además, se ha añadido una columna adicional para
representar el turno de una forma más visual. Para representar este tablero se han usado los
patches del mundo, cambiándoles el color según lo necesitemos.
Para representar las semillas se han usado tortugas, cada una de ellas representa una semilla y se
encuentra en uno de los huecos correspondientes al tablero. Las tortugas del jugador que juegue en
la línea inferior del tablero son de color rojo, mientras que las del otro jugador son de color azul.
Además del valor del patch para representar de forma más precisa el número exacto de semillas, ya
que a veces no se puede distinguir a simple vista el número de semillas que hay.
Para realizar esta representación gráfica se han creado dos funciones:
- **representaTablero**: La cual representa el estado actual del tablero basándose en la variable
matriz-global. Para ellos, se crean tantas tortugas como semillas haya y se colocan por el
tablero en su correspondiente lugar.
- **representaTurno**: La cual representa el turno del jugador al que le toca jugar usando dos
patches de colores, iluminando el patch del color correspondiente al jugador que tiene el
turno.

## MONTE CARLO

Como se ha dicho en la introducción, para implementar el jugador automático se ha usado el
algoritmo de Monte Carlo.
Las funciones más relevantes que se han implementado para que el algoritmo de Monte Carlo
pueda funcionar son:

### MCTS:GET-RULES

Esta función recibe como parámetro un estad0 y devuelve como posibles jugadas una lista
con los índices de las filas de la matriz cuyo contenido en la lista no está vacío.
Dependiendo si el jugador que acaba de jugar ha sido el jugador 1 o el jugador 2, se
devuelve la lista dicha anteriormente para la parte superior o inferior del tablero
respectivamente.

### MCTS:APPLY

Esta función recibe un estado y una regla y en función de esos dos parámetros crea estados
en los que se haya aplicado dicha regla.
Para ello se usa la función aplicaJugadaMC la cual es una adaptación de la función
aplicaJugada, ya que aplicaJugada trabaja directamente sobre la matriz-global y no nos
interesa eso, ya que nos interesa una función que devuelva el valor de la matriz-global pero
sin llegar a cambiarlo de forma real.

### MCTS:GET-RESULT

Esta función recibe un estado y un jugador y en función de esos dos parámetros se
comprueba si es un nodo final del árbol o si no lo es.
Esto es así ya que al algoritmo busca ganar, de modo que busca el camino más corto hasta
el nodo que consiga hacerle vencedor. Para ello, hemos modelizado el get-result haciendo
que devuelva el número de semillas que hay en la kalaha, de esta forma, busca siempre
maximizar ese número, lo que se traduce en que busca ganar con la mayor puntuación
posible. Además, se ha recortado el árbol debido a que se toma como nodo final, aquél en el
que la kalaha tiene 24 semillas o más, ya que una vez llegado a ese estado, haga las jugadas
que haga va a ganar puesto que hay 48 semillas en total y en ningún momento varía el
número de semillas.

## Q-LEARNING

Q-learning es una forma de aprendizaje por refuerzo en la que el agente aprende a asignar valores de bondad a los pares (estado,acción), siendo el estado óptimo aquel en el que el agente conoce a priori los valores Q de todos los posibles pares (estado,acción) ya que podría usar dicha información para seleccionar la acción adecuada para cada estado. El problema es que al principio el agente no tiene esta información, por lo que su primer objetivo es aproximar lo mejor posible esta asignación de valores Q. Como los valores de Q dependen tanto de recompensas futuras como de recompensas actuales, hemos de proporcionar un método que sea capaz de calcular el valor final a partir de los valores inmediatos y locales. Para ello hay que aprender a evitar aquellas acciones que provoquen resultados no deseados y si todas las acciones posibles de un estado dan resultados negativos debemos aprender a evitar siempre que se pueda dicho estado. Matemáticamente se ha usado la siguiente ecuación para formalizar el cálculo de los valores de Q:

![Captura ecuacion](C:\Users\Placi\Documents\GitHub\Artificial-Intelligence\Práctica 1 IA v2\Documentación\Captura ecuacion.PNG)

Un aspecto importante del aprendizaje por refuerzo es la restricción de que solo se actualizan los valores Q de acciones que se ejecutan sobre estados por los que se pasa, no se aprende nada de acciones que no se intentan.

## IMPLEMENTACIÓN

Nuestro objetivo es crear un grafo cuyos vértices representen los estados y cuyas aristas (dirigidas) representen las transiciones.

Los estado almacenarán en su interior la siguiente información:

- **Content:** Variable que almacena el estado del tablero, es decir, una matriz que contiene el número de semillas que hay en cada hueco.
- **Explored**?: Variable booleana que nos dirá si el nodo ha sido explorado o no.
- **Player**: Variable que contiene el jugador al que le toca jugar
- **Path**: Variable que contiene el path que se crea con la unión de todos los vértices

Las transiciones almacenarán en su interior la siguiente información:

- **Rule**: Variable que contiene la acción que se ha ejecutado, es decir, la casilla que se ha elegido para repartir las semillas
- **RR**: Variable que contiene el valor de recompensa que usaremos para el algoritmo
- **Q**: Variable que contiene el valor de Q
- **Variation**: Variable que contiene el valor de la variación

Una vez tenemos esto podemos empezar a crear el grafo, el problema es que el número de posibles combinaciones que puede darse es muy elevado como para crear un grafo completo, así que nuestra mejor opción es crear el grafo según se vayan jugando partidas y aquí es donde entra en juego el segundo agente. Vamos a hacer que ambos agentes se enfrenten entre ellos para poder conseguir nuestro jugador objetivo. 

Para ello se han implementado tres métodos:

### Q-LEARNING

Este método es al que debemos llamar para entrenar a nuestro jugador, para ello debemos seleccionar el número de partidas que queremos que juegue (ajustando el deslizador llamado **numEntrenamiento**)  y ejecutarlo. El método se encarga de crear el tablero y reiniciarlo cada vez que comienza una nueva partida. Además, al final de cada partida ajusta los valores de Q para las transiciones que se han creado.

### Q-ADDNODE

Este método nos ayuda a añadir un vértice al grafo en el caso en que no exista dicho vértice, en el caso en el que exista simplemente no hace nada. Para ello debemos pasarle como parámetros de entrada los siguientes atributos:

- **P**: Jugador al que le toca jugar esta turno(coincide con el número de turno)
- **XR**: Posición X del ratón, la cual usamos para poder realizar la jugada
- **MATRIZ**: Matriz que representa el estado del tablero desde el que queremos añadir el nodo
- **IA?**: Si la ponemos a **true**, es la IA la que llama a la función, por lo que se pasará a evaluar si se va a usar el algoritmo de Monte Carlo o no. En el caso en que no se use el algoritmo de Monte Carlo, escogemos la jugada en base a una probabilidad que asignamos a las distintas reglas. Si la ponemos a **false**, evaluamos la posible adición de un nuevo estado en función de si ya existe uno o no, si no existe se crea usando la variable **XR** 
- **MCTS?**: Si la ponemos a **true** usará el algoritmo de Monte Carlo para determinar la jugada. Si la ponemos a **false** el algoritmo escogerá la próxima jugada en función de una probabilidad calculada a partir de la bondad de la selección 

### Q-TRAINING

Este es el método al que se llama cuando queremos que la máquina se entrene jugando. Podemos escoger dos modos de entrenamiento, uno en el que la máquina contra la que se va a enfrentar nuestro jugador usa Monte Carlo y otro en el que la máquina escoja la jugada por probabilidad, para ello se ha añadido un botón en la interfaz principal con el nombre **MCTS-Training?** donde podemos escoger si queremos usar Monte Carlo o no.

En cada turno se llama a la función **Q-addNode** para que evalúe si existe un estado con la jugada que acabamos de hacer y en caso de que no exista se añade al mundo, de esta manera tenemos siempre la **exploración** del mundo activa. Si el número de partidas jugadas es mayor que la mitad de partidas que hemos seleccionado para entrenar, nuestro jugador busca por los nodos que ha creado en el mundo, si encuentra uno con el que pueda determinar la jugada, usará ese nodo, en caso de que el estado no exista, se limitará a escoger la jugada en base a la probabilidad como anteriormente.

### JUGAR 4

Este es el método que nos permite jugar contra nuestro jugador. Cada vez que jugamos, nuestro jugador continúa con la **exploración**, es decir, sigue añadiendo estados al grafo si no existen para así poder aprender las jugadas. 

Podemos encontrarnos con dos casos a la hora de jugar, el caso en el que existe el estado con la distribución actual del tablero, en el cual se buscará realizar la jugada cuya Q sea la mayor y el caso en  el que el estado aún no existe. En el caso de que no exista el estado que estamos buscando, se usa el algoritmo de Monte Carlo para determinar la jugada ya que aunque podríamos usar las probabilidades como anteriormente, lo interesante es que nuestro jugador pueda aprender también jugadas medianamente buenas y la persona contra la que juega no se aburra.

## PRUEBAS

Las pruebas se han realizado con los dos tipos de entrenamiento, uno en el que nuestro jugador se enfrenta a la máquina que usa Monte Carlo y otro en el que no se usa Monte Carlo en el rival. Para realizar las pruebas, en ambos casos se ha entrenado a nuestro jugador con 1000 partidas, ya que no disponía de medios ni tiempos para hacer un entrenamiento más complejo, pero nos dará una idea aproximada de qué entrenamiento es mejor. Una vez entrenadas se ha escogido a un jugador medio de Mancala para medirlos en varias partidas y ver si había alguna evolución, ya que nuestro jugador siempre se encuentra con la exploración activa.

### ENTRENAMIENTO CON MONTE CARLO

El entrenamiento usando el algoritmo de Monte Carlo es muy lento en comparación del entrenamiento en el que no se usa Monte Carlo, ya que para cada jugada en cada partida crea un árbol con 1000 vértices de profundidad, por lo que aumenta mucho el coste en tiempo, sin embargo, tras realizar las partidas contra el sujeto, al principio mostró que podía ganar, aunque posteriormente el sujeto aprendió a ganarle ya que como seres humanos que somos, el aprendizaje por refuerzo es una parte de nosotros.

Con las 1000 partidas que entrenó, conseguimos un total de 20.000 estados aproximadamente.

![Entrenamiento con Monte Carlo.png](C:\Users\Placi\Documents\GitHub\Artificial-Intelligence\Práctica 1 IA v2\Documentación\Entrenamiento con Monte Carlo.png)

Como se puede ver en el grafo, la IA empezó a perder partidas y a empeorar, esto es debido a que nuestro sujeto aprendió las técnicas que usaba la IA y a usarlas en su contra. Si le hubiésemos dado más partidas para que entrenase, quizás habría desarrollado técnicas diferentes y nuestro sujeto no podría haber ganado en ningún caso.

### ENTRENAMIENTO SIN MONTE CARLO

El entrenamiento sin usar Monte Carlo es computacionalmente más rápido ya que no requiere de crear un árbol muy grande, puesto que ambas máquinas escogen la próxima jugada en base a una probabilidad. 

Con las 1000 partidas que entrenó, conseguimos un total de 27.000 estados aproximadamente. Bastantes más estados que con el entrenamiento con Monte Carlo, aunque que haya más estado no significa que el entrenamiento sea mejor, ya que puede que de esos 27.000 estados, 15.000 sean estados inútiles que nunca se van a dar en una partida normal.

![Entrenamiento sin Monte Carlo.png](C:\Users\Placi\Documents\GitHub\Artificial-Intelligence\Práctica 1 IA v2\Documentación\Entrenamiento sin Monte Carlo.png)

En este caso, nuestro sujeto ya se había enfrentado anteriormente a la IA, por lo que le resultó más fácil conseguir la victoria desde el principio, aún así, la IA supo defenderse más que con el entrenamiento con Monte Carlo. Al igual que en el caso anterior, si hubiese entrenado con más partidas, quizás habría desarrollado técnicas diferentes y podría haberse hecho con la victoria.

## CONCLUSIONES

Q-learning es un algoritmo de aprendizaje por refuerzo muy fácil de implementar y muy interesante para aprender cómo funciona dicho tipo de aprendizaje. El problema del aprendizaje por refuerzo es que en juegos grandes requiere de mucho entrenamiento y para ello es necesario una infraestructura que pueda proporcionar dicho entrenamiento.

En base al entrenamiento que yo he podido proporcionar a esta IA, me ha sorprendido gratamente ya que en muy pocas partidas, prácticamente aprendió a que no le pudiesen robar. Quizás con un entrenamiento más extenso pueda aprender técnicas que nos sorprendan y llegar a convertirse así en un gran rival que seguirá aprendiendo sobre cómo jugamos y a ganarnos.

## REFERENCIAS

**Fernando Sancho Caparrini**, Introducción al Aprendizaje Automático, http://www.cs.us.es/~fsancho/?e=75

**Fernando Sancho Caparrini**, Aprendizaje por refuerzo: algoritmo Q Learning, http://www.cs.us.es/~fsancho/?e=109

**Rubén López**, Q-learning: Aprendizaje automático por refuerzo, https://rubenlopezg.wordpress.com/2015/05/12/q-learning-aprendizaje-automatico-por-refuerzo/

**Dot CSV**, ¡Esta IA juega al ESCONDITE demasiado bien! https://www.youtube.com/watch?v=5SkQuT3kZOc&t=214s

**Dot CSV**, Montezuma's Revenge - ¿Hito del Aprendizaje Reforzado? | Data Coffee #8, https://www.youtube.com/watch?v=DBJh4cfq0ro

**Francisco Javier Ceballos López**, El sujeto