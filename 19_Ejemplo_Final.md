# Jenkins | Ejercicio Final

---------------------------------------------------------

En este ejercicio llevaremos a cabo un ejemplo real de **pipelines**.

Crearemos un **pipeline** que usará **jenkins**, **docker** y **maven**.

Dispondremos de un **Jenkins server** que mediante **docker** ejecutará las distintas fases del desarrollo.

* En el **Build** generaremos el **.jar** de nuestra aplicación y una imagen **docker** que contendrá esa aplicación **.jar**.
* En el **Test** ejecutaremos **UnitTest** usando **docker** en **jenkins**.
* En el **Push** crearemos un **Registry** con autenticación y sin autenticación para subir la imagen ya testeada.
* Finalmente desplegaremos el **.jar** la imagen de **producción**.

[Volver al Inicio](#jenkins--ejercicio-final)



## INSTALACIÓN BÁSICA INICIAL

---------------------------------------------------------

Para ello crearemos nuestra carpeta **jenkins_home** dónde se alojara jenkins usando `mkdir jenkins_home` y `mkdir db_data` para posteriormente asignarle permisos mediante `chown 1000 -R jenkins_home` y `chown 1000 -R db_data` como usuario root (`sudo su`).

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

[Volver al Inicio](#jenkins-pipeline)



## PIPELINE

---------------------------------------------------------