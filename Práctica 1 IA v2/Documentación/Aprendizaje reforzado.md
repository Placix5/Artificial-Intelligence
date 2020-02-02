# APRENDIZAJE REFORZADO

## IINTRODUCCIÓN

El aprendizaje reforzado es algo muy común en nuestras vidas, los seres humanos formamos nuestros comportamientos en base a nuestras experiencias, aprendemos en base a nuestros errores de forma que poco a poco podemos mejorar nuestro propio rendimiento con respecto a dichas experiencias. Esto mismo podemos llevarlo al mundo de la computación, buscando que un agente pueda aprender en función de unas recompensas que le suministraremos si hace bien su trabajo.

El aprendizaje reforzado es una muy buena forma de poder enseñar a una máquina, el problema es que está un poco limitado. Esto es así debido a que nuestro agente solo aprenderá aquella tarea que le hemos asignado, no será capaz de aumentar la complejidad más allá de ello, por ejemplo, si queremos enseñar a un agente a que chute y marque en una portería no aprenderá más que a chutar, no será capaz de aprender a hacer regates o a tirar de chilena. ¿Cómo podemos aumentar el grado de complejidad de nuestro agente? La respuesta es con un sistema multiagente, en el que hayan varios agentes compitiendo por el mismo objetivo, de esta manera, cada agente aprenderá y utilizará nuevas técnicas para así poder conseguir su objetivo, aumentando así el grado de complejidad y consiguiendo el objetivo que estábamos buscando.

En esto se basa este proyecto, se ha buscado entrenar un sistema multiagente mediante aprendizaje reforzado para así poder crear posteriormente un jugador que pueda jugar contra una persona y que esté lleno de sorpresas y técnicas complejas que otros algoritmos más simples como Monte Carlo no podrían conseguir. Para ello hemos usado el algoritmo Q-learning, del cual hablaremos más adelante. 

El jugador que hemos desarrollado está pensado para el juego conocido como Mancala. El juego Mancala es un juego de origen árabe, cuyo nombre significa mover. Este juego consiste en dos filas, cada una de ellas con 6 huecos y dos kalahas, situadas en los laterales del tablero. A cada jugador le corresponde una fila y la kalaha que esté a su derecha. Dentro de cada uno de los huecos de las filas encontramos de manera inicial cuatro semillas. El objetivo del juego es conseguir el mayor número de semillas en la kalaha, de forma que el único movimiento posible es repartir todas las semillas de un hueco en sentido antihorario.

Tras realizar este movimiento pueden darse tres casos posibles:

1. Si la última semilla cae en un hueco en el que ya había semillas, sea del jugador que sea, es turno del siguiente jugador

2. Si la última semilla cae en la kalaha correspondiente al jugador que ha realizado el movimiento, dicho jugador obtiene un turno extra

3. Si la última semilla cae en un hueco vacío correspondiente a la fila del jugador que ha realizado el movimiento y además, hay semillas en el hueco justo delante de este, el jugador roba todas esas semillas y las introduce en su kalaha

La partida terminará cuando una de las dos filas se encuentre totalmente vacía y ganará el jugador que posea más semillas en su kalaha

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
- **IA?**: Si la ponemos a **true**, es la IA la que llama a la función, por lo que se pasará a evaluar si se va a usar el algoritmo de Monte Carlo o no. Si la ponemos a **false**, evaluamos la posible adición de un nuevo estado en función de si ya existe uno o no, si no existe se crea usando la variable **XR** 
- **MCTS?**: Si la ponemos a **true** usará el algoritmo de Monte Carlo para determinar la jugada. Si la ponemos a **false** el algoritmo escogerá la próxima jugada en función de una probabilidad calculada a partir de la bondad de la selección 

### Q-TRAINING



### 



Para mejorar el aprendizaje y que nuestro jugador no se enfrente a una máquina que escoge 