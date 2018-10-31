---------------------------------------------------------

### Agregar Parámetros

---------------------------------------------------------

Aunque existe la posibilidad de incluir variables dentro del shell, **jenkins** permite incluir parámetros para su ejecución.

Para ello dentro de la configuración del Job marcaremos la opción de **Esta ejecución debe parametrizarse**.

![./img/00023.png](./img/0023.png)

Existen varias opciones entre las que usaremos primeramente **parámetro de cadena**.

![./img/00024.png](./img/0024.png)

Con el nombre de variable **NAME** y el valor definido **ricardo**.

Accedemos en nuestra **shell de jenkins** e incluimos el siguiente código `echo "Hola $NAME"`.

![./img/00025.png](./img/0025.png)

Guardamos la configuración, y construimos nuevamente el **Job** (**NOTA**: aparecerá **construir con parámetros**). Una vez pulsemos en **Construir con parámetros** nos pedirá que confirmemos el valor de las variables.

![./img/00026.png](./img/0026.png)

Si volvemos a acceder a la salida de la terminal veremos el resultado obtenido.

![./img/00027.png](./img/0027.png)

> **NOTA IMPORTANTE:** Esta opción nos permite cambiar el valor de las variables.

Ahora podemos repetir la construcción del jobs cambiando los valores de los parámetros incluidos.


---------------------------------------------------------

### Tipos de Parámetros

---------------------------------------------------------

#### Elección

![./img/00028.png](./img/0028.png)

Y añadimos en nuestro shell el siguiente código `echo "hola, $NAME $APELLIDO"`.

![./img/00029.png](./img/0029.png)

Guardamos el job, para seguidamente regenerar el job, elegir los valores de los parámetros y ver la salida en terminal.

![./img/00030.png](./img/0030.png)

![./img/00031.png](./img/0031.png)

#### Booleano

En este ejemplo incluiremos el valor de un **booleano** y realizaremos otra prueba.