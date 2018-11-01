---------------------------------------------------------

### Job With Ansible

---------------------------------------------------------

#### Instalación básica inicial

Para ello crearemos nuestra carpeta **jenkins_home** dónde se alojara jenkins usando `mkdir jenkins_home` para posteriormente asignarle permisos mediante `chown 1000 -R jenkins_home` como usuario root (`sudo su`).

```bash
demo@VirtualBox:~/Demo_Docker$ mkdir jenkins_home

demo@VirtualBox:~/Demo_Docker$ sudo su
[sudo] password for demo:
root@hector-VirtualBox:/home/demo/jenkins-by-sample# chown 1000 -R jenkins_home
```

Una vez creada la carpeta, lanzaremos el servicio de jenkins con la configuración de [docker-compose.yml](./docker-compose.yml).

```bash
demo@VirtualBox:~/Demo_Docker$ docker-compose up -d
Starting jenkins ... done

demo@VirtualBox:~/Demo_Docker$ docker ps
CONTAINER ID IMAGE    COMMAND      CREATED   STATUS  PORTS     NAMES
7f41ec7f07ac jenkin.. "/sbin/t..." 55 se...  Up 3..  0.0....   jenkins
```

#### Seguridad Básica | acceso libre

Aunque no es para nada recomendable, podemos permitir el acceso a cualquier usuario sin una autentificación previa. Para elo accederemos a **Administrar Jenkins** >> **Configuración global de la seguridad**

![00045.png](./img/0045.png)

Y desactivar la opción de **Activar seguiridad**.

![00046.png](./img/0046.png)

Una vez hecho podríamos intentar acceder desde una nueva venta de incógnito para ver que:

* No es necesario loguearse.
* No aparece usuario autentificado.
* Aparece un mensaje de advertencia al estar el estado de la aplicación sin seguridad.

![00047.png](./img/0047.png)

#### Permitir Registro de Usuarios

Para ello, accederemos a **Administrar Jenkins** >> **Configuración global de la seguridad**, dónde marcaremos la opción de **Activar seguiridad**, e indicaremos que queremos que la seguridad **Usará bae de datos de Jenkins**, más la opciónd de **registrarse a los usuarios**.

![00048.png](./img/0048.png)

Además desmarcaremos la opción de que los **usuarios anónimos tengan acceso de lectura**

![00049.png](./img/0049.png)

Ahora si volvemos acceder a jenkins en una nueva ventana de incógnito veremos que es necesario loguearse,y además aparece la opción de registro.

![00050.png](./img/0050.png)

![00051.png](./img/0051.png)

Si creamos el nuevo usuario y accedemos al **Dashboard** de **jenkins** veremos que este nuevo usuario tiene acceso a todo el contenido.

![00052.png](./img/0052.png)

#### Permitir registro de usuarios

Para gestionar el acceso al distinto contenido de **Jenkins** usaremos un **plugin** llamado **Role-based Authorization Strategy**.

Para acceder a descargarlo entraremos en **Administrar Jenkins** >> **Administrar Plugins**, y seleccionaremos la pestaña de **Todos los plugins** para filtrar por el nombre del **plugin a instalar**.

![00053.png](./img/0053.png)

Una vez se inicie la instalación, esperaremos a que acabe para marcar la opción de **Reiniciar Jenkins cuando termine la instalación**.

![00054.png](./img/0054.png)

Ahora si accedemos nuevamente a **Administrar Jenkins** >> **Configuración global de la seguridad**, veremos que apareció una nueva sección (**Autorización**), en la cual marcaremos **Role-Based Strategy**

![00055.png](./img/0055.png)

El siguiente paso consistirá en acceder a **Administrar Jenkins** >> **Manage and Assign Role** para gestionar los permisos de acceso.

![00056.png](./img/0056.png)