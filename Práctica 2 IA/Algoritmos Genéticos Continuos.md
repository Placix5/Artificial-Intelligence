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

